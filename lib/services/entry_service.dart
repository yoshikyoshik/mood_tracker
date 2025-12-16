import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/mood_entry.dart';

class EntryService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _queueKey = 'offline_queue';

  // 1. LADEN: DB + Offline Queue (Creates, Updates UND Deletes beachten)
  Future<List<MoodEntry>> getEntries({int limit = 100, int offset = 0}) async {
    List<MoodEntry> dbEntries = [];
    
    // A) Versuch, Daten zu laden (Cache oder Netz)
    try {
      final response = await _client
          .from('mood_entries')
          .select()
          .order('created_at', ascending: false) 
          .range(offset, offset + limit - 1);
      dbEntries = (response as List).map((json) => MoodEntry.fromMap(json)).toList();
    } catch (e) {
      debugPrint("Offline Mode oder Ladefehler: $e");
    }

    // B) Lokale Queue verarbeiten
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    
    // Wir sammeln IDs, die lokal gelöscht wurden
    final Set<String> localDeletedIds = {};

    for (String jsonStr in offlineQueue) {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      
      // Prüfen auf Lösch-Befehl
      if (data['_action'] == 'delete') {
        if (data['id'] != null) {
          localDeletedIds.add(data['id']);
        }
        continue; // Nächster Eintrag, da dies kein anzuzeigender Eintrag ist
      }

      // Wenn kein Delete, ist es ein Save/Update
      // 'is_locally_modified' ist ggf. true
      final localEntry = MoodEntry.fromMap(data);
      
      // Prüfen, ob dieser Eintrag schon in der DB-Liste ist
      final index = dbEntries.indexWhere((e) => e.id == localEntry.id);
      
      if (index != -1) {
        // Eintrag existiert schon -> mit lokaler Version überschreiben
        dbEntries[index] = localEntry; 
      } else {
        // Eintrag ist neu (z.B. offline_...) -> Vorne anfügen
        dbEntries.insert(0, localEntry);
      }
    }
    
    // C) WICHTIG: Alle Einträge rauswerfen, die offline gelöscht wurden
    dbEntries.removeWhere((e) => e.id != null && localDeletedIds.contains(e.id));
    
    // Zur Sicherheit nochmal sortieren
    dbEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return dbEntries;
  }

  // 2. SPEICHERN (Create & Update)
  Future<MoodEntry> saveEntry(MoodEntry entry, String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // OFFLINE
      await _addToQueue(entry.toMap(), userId, action: 'upsert');
      
      return entry.copyWith(
        id: entry.id ?? 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        isLocallyModified: true, 
      );
    } else {
      // ONLINE
      final entryData = entry.toMap();
      entryData['user_id'] = userId;

      final res = await _client
          .from('mood_entries')
          .upsert(entryData)
          .select()
          .single();
      
      return MoodEntry.fromMap(res);
    }
  }
  
  // Wrapper
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? entry.userId ?? '';
      return await saveEntry(entry, userId);
  }

  // 3. DELETE (Jetzt robust und offline-fähig)
  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    
    // SCHRITT A: Zuerst bereinigen wir die Queue.
    // Wenn wir einen Eintrag löschen, brauchen wir keine ausstehenden Updates mehr dafür.
    offlineQueue.removeWhere((str) {
      final map = jsonDecode(str);
      return map['id'] == id && map['_action'] != 'delete';
    });
    
    // Speichern der bereinigten Queue
    await prefs.setStringList(_queueKey, offlineQueue);

    // SCHRITT B: Wenn es ein temporärer Offline-Eintrag war, sind wir fertig.
    // (Er wurde oben aus der Queue entfernt und existiert am Server nicht).
    if (id.startsWith('offline_')) {
      return;
    }

    // SCHRITT C: Online oder Offline löschen
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // OFFLINE: Wir fügen einen "Lösch-Befehl" zur Queue hinzu
      final deleteCommand = {
        'id': id,
        '_action': 'delete', // <--- Magic Flag
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'timestamp': DateTime.now().toIso8601String(), // Optional, fürs Debugging
      };
      
      offlineQueue.add(jsonEncode(deleteCommand));
      await prefs.setStringList(_queueKey, offlineQueue);
      debugPrint("EntryService: Löschen offline vorgemerkt für ID $id");

    } else {
      // ONLINE: Direkt löschen
      try {
         await _client.from('mood_entries').delete().eq('id', id);
      } catch(e) {
         // Falls wir hier crashen (doch kein Netz?), Fallback zur Queue
         debugPrint("Fehler beim Online-Löschen: $e. Füge zur Queue hinzu.");
         final deleteCommand = {
            'id': id,
            '_action': 'delete',
            'user_id': Supabase.instance.client.auth.currentUser?.id,
         };
         // Neu laden, da wir oben schon geschrieben haben könnten
         List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];
         currentQueue.add(jsonEncode(deleteCommand));
         await prefs.setStringList(_queueKey, currentQueue);
      }
    }
  }

  // 4. SYNC (Verarbeitet Upserts UND Deletes)
  Future<int> syncOfflineEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    
    if (offlineQueue.isEmpty) return 0;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return 0;

    debugPrint("EntryService: 🔄 Starte Sync von ${offlineQueue.length} Operationen...");
    
    final List<String> remainingQueue = [];
    int syncedCount = 0;

    for (String jsonStr in offlineQueue) {
      try {
        var data = jsonDecode(jsonStr);
        final action = data['_action'] ?? 'upsert'; // Default auf upsert für alte Daten

        // Metadaten entfernen, die Supabase nicht kennt
        data.remove('_action');
        data.remove('is_locally_modified');

        if (action == 'delete') {
          // --- FALL: LÖSCHEN ---
          final idToDelete = data['id'];
          if (idToDelete != null) {
            await _client.from('mood_entries').delete().eq('id', idToDelete);
          }
        } else {
          // --- FALL: SPEICHERN / UPDATE ---
          // Bei neuen Offline-IDs diese entfernen, damit Postgres eine generiert
          if (data['id'] != null && data['id'].toString().startsWith('offline_')) {
             data.remove('id');
          }
          await _client.from('mood_entries').upsert(data);
        }
        
        syncedCount++;
      } catch (e) {
        debugPrint("EntryService: ❌ Fehler beim Sync ($jsonStr): $e");
        remainingQueue.add(jsonStr); // Bei Fehler drin behalten
      }
    }

    await prefs.setStringList(_queueKey, remainingQueue);
    return syncedCount;
  }

  // Interner Helper
  Future<void> _addToQueue(Map<String, dynamic> map, String userId, {String action = 'upsert'}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    
    // Für Queue vorbereiten
    map['user_id'] = userId;
    map['is_locally_modified'] = true;
    map['_action'] = action; 
    
    // Falls Eintrag (anhand ID) schon in Queue ist, erst entfernen (Update im Queue)
    if (map['id'] != null) {
      offlineQueue.removeWhere((str) {
        final existing = jsonDecode(str);
        return existing['id'] == map['id'];
      });
    }
    
    offlineQueue.add(jsonEncode(map));
    await prefs.setStringList(_queueKey, offlineQueue);
  }
}
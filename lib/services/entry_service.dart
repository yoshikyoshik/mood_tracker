import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/mood_entry.dart';

class EntryService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _queueKey = 'offline_queue';

  // 1. LADEN: DB + Offline Queue
  // FIX: Limit auf 2000 erhöht, damit alte Einträge nicht verschwinden
  Future<List<MoodEntry>> getEntries({int limit = 2000, int offset = 0}) async {
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
    final Set<String> localDeletedIds = {};

    for (String jsonStr in offlineQueue) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        
        if (data['_action'] == 'delete') {
          if (data['id'] != null) localDeletedIds.add(data['id']);
          continue;
        }

        final localEntry = MoodEntry.fromMap(data);
        
        // Prüfen, ob Eintrag schon in DB-Liste -> Überschreiben
        final index = dbEntries.indexWhere((e) => e.id == localEntry.id);
        if (index != -1) {
          dbEntries[index] = localEntry; 
        } else {
          dbEntries.add(localEntry);
        }
      } catch (e) {
        debugPrint("Fehler beim Parsen der Queue: $e");
      }
    }
    
    // C) Gelöschte entfernen
    dbEntries.removeWhere((e) => e.id != null && localDeletedIds.contains(e.id));
    
    // D) Finale Sortierung nach Datum (Wichtig!)
    dbEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return dbEntries;
  }

  // 2. SPEICHERN (Create)
  Future<MoodEntry> saveEntry(MoodEntry entry, String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // OFFLINE: In Queue speichern
      final offlineId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offlineEntry = entry.copyWith(id: offlineId, isLocallyModified: true);
      await _addToQueue(offlineEntry.toLocalJson(), userId, action: 'upsert');
      return offlineEntry;
    } else {
      // ONLINE: Direkt an DB
      try {
        final entryMap = entry.toMap();
        entryMap.remove('id'); // ID von DB generieren lassen
        entryMap['user_id'] = userId;
        
        final response = await _client
            .from('mood_entries')
            .insert(entryMap)
            .select()
            .single();
            
        return MoodEntry.fromMap(response);
      } catch (e) {
        debugPrint("Fehler beim Online-Speichern: $e -> Fallback auf Offline");
        // Fallback
        final offlineId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final offlineEntry = entry.copyWith(id: offlineId, isLocallyModified: true);
        await _addToQueue(offlineEntry.toLocalJson(), userId, action: 'upsert');
        return offlineEntry;
      }
    }
  }

  // 3. UPDATEN (Edit)
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // OFFLINE
      final offlineEntry = entry.copyWith(isLocallyModified: true);
      await _addToQueue(offlineEntry.toLocalJson(), entry.userId ?? '', action: 'upsert');
      return offlineEntry;
    } else {
      // ONLINE
      try {
        final updateData = entry.toMap();
        // ID nicht updaten, aber zum Finden nutzen
        updateData.remove('id'); 
        
        final response = await _client
            .from('mood_entries')
            .update(updateData)
            .eq('id', entry.id!)
            .select()
            .single();
            
        return MoodEntry.fromMap(response);
      } catch (e) {
        debugPrint("Fehler beim Update: $e -> Fallback auf Queue");
        final offlineEntry = entry.copyWith(isLocallyModified: true);
        await _addToQueue(offlineEntry.toLocalJson(), entry.userId ?? '', action: 'upsert');
        return offlineEntry;
      }
    }
  }

  // 4. LÖSCHEN
  Future<void> deleteEntry(String id) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      await _addToQueue({'id': id}, '', action: 'delete');
    } else {
      try {
        await _client.from('mood_entries').delete().eq('id', id);
      } catch (e) {
        await _addToQueue({'id': id}, '', action: 'delete');
      }
    }
  }

  // 5. SYNC (Wird beim App-Start aufgerufen)
  Future<int> syncOfflineEntries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    if (offlineQueue.isEmpty) return 0;

    int syncedCount = 0;
    List<String> remainingQueue = [];

    for (String jsonStr in offlineQueue) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final String action = data['_action'] ?? 'upsert';
        
        // Aufräumen für DB
        data.remove('_action');
        data.remove('is_locally_modified');

        if (action == 'delete') {
          final idToDelete = data['id'];
          if (idToDelete != null && !idToDelete.toString().startsWith('offline_')) {
             await _client.from('mood_entries').delete().eq('id', idToDelete);
          }
        } else {
          // UPDATE / INSERT
          if (data['id'] != null && data['id'].toString().startsWith('offline_')) {
             data.remove('id'); // Neue ID generieren lassen
          }
          await _client.from('mood_entries').upsert(data);
        }
        
        syncedCount++;
      } catch (e) {
        debugPrint("Sync Fehler: $e");
        remainingQueue.add(jsonStr); // Bei Fehler behalten
      }
    }

    await prefs.setStringList(_queueKey, remainingQueue);
    return syncedCount;
  }

  // Interner Helper für die Queue
  Future<void> _addToQueue(Map<String, dynamic> map, String userId, {String action = 'upsert'}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> offlineQueue = prefs.getStringList(_queueKey) ?? [];
    
    map['user_id'] = userId;
    map['is_locally_modified'] = true;
    map['_action'] = action; 
    
    // Falls Eintrag schon in Queue ist, erst entfernen (Update gewinnt)
    if (map['id'] != null) {
      offlineQueue.removeWhere((s) {
        try {
          final d = jsonDecode(s);
          return d['id'] == map['id'];
        } catch (_) { return false; }
      });
    }
    
    offlineQueue.add(jsonEncode(map));
    await prefs.setStringList(_queueKey, offlineQueue);
  }
}
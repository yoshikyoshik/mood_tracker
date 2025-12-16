import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/mood_entry.dart';

class EntryService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- 1. LADEN (Mit Vorbereitung für Pagination) ---
  Future<List<MoodEntry>> getEntries({int limit = 100, int offset = 0}) async {
    final response = await _client
        .from('mood_entries')
        .select()
        // HIER ÄNDERN: von 'timestamp' zu 'created_at'
        .order('created_at', ascending: false) 
        .range(offset, offset + limit - 1); 

    return (response as List).map((json) => MoodEntry.fromMap(json)).toList();
  }

  // --- 2. SPEICHERN (Smart: Online oder Offline) ---
  // Gibt den gespeicherten Eintrag zurück (entweder den echten aus der DB oder den Offline-Dummy)
  Future<MoodEntry> saveEntry(MoodEntry entry, String userId) async {
    // Netz prüfen
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // A) OFFLINE FALL
      await _saveToLocalQueue(entry, userId);
      
      // Wir geben eine Kopie zurück mit temporärer ID, damit das UI sie anzeigen kann
      return entry.copyWith(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId, // Wichtig für lokale Anzeige
      );
    } else {
      // B) ONLINE FALL
      final entryData = entry.toMap();
      entryData['user_id'] = userId;

      // Senden und den fertigen Eintrag (mit echter ID) zurückbekommen
      final res = await _client
          .from('mood_entries')
          .insert(entryData)
          .select()
          .single();
      
      return MoodEntry.fromMap(res);
    }
  }

  // --- 3. LÖSCHEN ---
  Future<void> deleteEntry(String id) async {
    if (id.startsWith('offline_')) {
       // Wenn es ein Offline-Eintrag ist, müssten wir ihn aus der Queue entfernen
       // (Das ist komplexer, für V1 löschen wir ihn einfach aus dem UI)
       return;
    }
    await _client.from('mood_entries').delete().eq('id', id);
  }

  // --- 4. UPDATE ---
  Future<void> updateEntry(MoodEntry entry) async {
    if (entry.id == null || entry.id!.startsWith('offline_')) return;
    
    await _client.from('mood_entries').update({
      'score': entry.score,
      'sleep_rating': entry.sleepRating,
      'tags': entry.tags.toList(),
      'note': entry.note,
    }).eq('id', entry.id!);
  }

  // --- 5. OFFLINE SYNC ---
  // Gibt die Anzahl der synchronisierten Einträge zurück
  Future<int> syncOfflineEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineQueue = prefs.getStringList('offline_queue') ?? [];
    
    if (offlineQueue.isEmpty) return 0;

    // Sicherheitscheck Netz
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return 0;

    debugPrint("EntryService: 🔄 Starte Sync von ${offlineQueue.length} Einträgen...");
    
    final List<String> remainingQueue = [];
    int syncedCount = 0;

    for (String jsonStr in offlineQueue) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        await _client.from('mood_entries').insert(data);
        syncedCount++;
      } catch (e) {
        debugPrint("EntryService: ❌ Fehler beim Sync: $e");
        remainingQueue.add(jsonStr);
      }
    }

    await prefs.setStringList('offline_queue', remainingQueue);
    return syncedCount;
  }

  // Interner Helper für die Queue
  Future<void> _saveToLocalQueue(MoodEntry entry, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineQueue = prefs.getStringList('offline_queue') ?? [];
    
    final entryMap = entry.toMap();
    entryMap['user_id'] = userId; 
    
    offlineQueue.add(jsonEncode(entryMap));
    await prefs.setStringList('offline_queue', offlineQueue);
  }
}
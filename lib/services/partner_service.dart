import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_entry.dart';

class PartnerService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> updatePartnerSettings(String profileId, String myEmail, String partnerEmail) async {
    // Hier ändern wir nichts, das Speichern funktioniert ja
    await _client.from('profiles').update({
      'email': myEmail,
      'partner_email': partnerEmail.trim(),
    }).eq('id', profileId);
  }

  Future<Map<String, dynamic>?> getPartnerStatus(String myEmail, String targetPartnerEmail) async {
    final searchMail = targetPartnerEmail.trim();
    final myMailClean = myEmail.trim();

    try {
      // FIX: Wir suchen jetzt PRÄZISE:
      // 1. Die E-Mail muss stimmen
      // 2. UND: In diesem Profil muss ICH als Partner stehen
      // 3. limit(1) sorgt dafür, dass wir nicht abstürzen, falls es doch mehrere gibt
      
      final response = await _client
          .from('profiles')
          .select('id, name, email, partner_email')
          .eq('email', searchMail)
          .eq('partner_email', myMailClean) // <--- DER WICHTIGE FILTER
          .limit(1) // <--- SICHERHEITSNETZ gegen "Multiple Rows" Fehler
          .maybeSingle();

      if (response == null) {
        debugPrint("PartnerService: Kein passendes Profil gefunden.");
        // Das passiert, wenn Rico dich noch nicht eingetragen hat
        // ODER wenn er dich im falschen Profil eingetragen hat
        return null;
      }

      // Wenn wir hier sind, haben wir einen Match! ❤️
      
      // Jetzt Stimmung laden (MIT TAGS & SCHLAF)
      final entryRes = await _client
          .from('mood_entries')
          .select()
          .eq('profile_id', response['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // 1. Das Grundgerüst bauen (IMMER mit ID!)
      final result = {
        'partner_profile_id': response['id'], // <--- DAS IST DER WICHTIGE FIX
        'name': response['name'],
        'score': null, // Standardwert
      };

      // 2. Wenn ein Eintrag existiert, Daten überschreiben
      if (entryRes != null) {
        // Wir nutzen dein Model, um die Daten sicher zu parsen
        final entry = MoodEntry.fromMap(entryRes);
        
        result['score'] = entry.score;
        result['timestamp'] = entry.timestamp;
        result['sleep'] = entry.sleepRating;
        result['tags'] = entry.tags.toList(); // Sicherstellen, dass es eine Liste ist
        result['note'] = entry.note;
      }
      
      return result;

    } catch (e) {
      debugPrint("PartnerService Error: $e");
      return null;
    }
  }

  // Ping senden
  Future<void> sendPing(String senderId, String receiverProfileId, String type) async {
    await Supabase.instance.client.from('partner_pings').insert({
      'sender_id': senderId,
      'receiver_profile_id': receiverProfileId,
      'ping_type': type,
    });
  }
}
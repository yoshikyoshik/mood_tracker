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
          .select() // Lädt alle Felder (inkl. tags, sleep_rating)
          .eq('profile_id', response['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (entryRes == null) {
        return {
          'name': response['name'],
          'score': null, 
        };
      }

      final entry = MoodEntry.fromMap(entryRes);
      
      return {
        'name': response['name'],
        'score': entry.score,
        'timestamp': entry.timestamp,
        'tags': entry.tags.toList(), // <--- NEU
        'sleep': entry.sleepRating,  // <--- NEU
      };

    } catch (e) {
      debugPrint("PartnerService Error: $e");
      return null;
    }
  }
}
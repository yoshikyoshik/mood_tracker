import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

class MoodUtils {
  
  // 1. Hintergrundfarbe
  static Color getBackgroundColor(double value) {
    if (value <= 5.0) {
      return Color.lerp(Colors.redAccent.withValues(alpha: 0.5), Colors.amber.withValues(alpha: 0.5), value / 5.0)!;
    } else {
      return Color.lerp(Colors.amber.withValues(alpha: 0.5), Colors.greenAccent.withValues(alpha: 0.5), (value - 5.0) / 5.0)!;
    }
  }

  // 2. Emoji & Label
  static Map<String, String> getMoodData(double value, AppLocalizations l10n) {
    if (value < 2.0) return {'emoji': '😫', 'label': l10n.inputMoodTerrible};
    if (value < 4.0) return {'emoji': '😟', 'label': l10n.inputMoodBad};
    if (value < 6.0) return {'emoji': '😐', 'label': l10n.inputMoodOkay};
    if (value < 8.0) return {'emoji': '🙂', 'label': l10n.inputMoodGood};
    return {'emoji': '🤩', 'label': l10n.inputMoodFantastic};
  }

  // 3. Tag-Übersetzung (Jetzt erweitert)
  static String getLocalizedTagLabel(String rawTag, AppLocalizations l10n) {
    switch (rawTag) {
      // Soziales
      case 'Familie': case 'Family': return l10n.tagFamily;
      case 'Beziehung': case 'Relationship': return l10n.tagRelationship;
      case 'Freunde': case 'Friends': return l10n.tagFriends;
      case 'Party': return l10n.tagParty;
      case 'Sex': case 'Intimität': case 'Intimacy': return l10n.tagSex; // NEU
      
      // Körper & Geist
      case 'Sport': case 'Workout': return l10n.tagSport;
      case 'Schlaf': case 'Sleep': return l10n.tagSleep;
      case 'Essen': case 'Food': return l10n.tagFood;
      case 'Gesundheit': case 'Health': return l10n.tagHealth;
      case 'Meditation': return l10n.tagMeditation;
      case 'Alkohol': case 'Alcohol': return l10n.tagAlcohol; // NEU
      case 'Natur': case 'Nature': return l10n.tagNature; // NEU
      case 'Sauna': case 'Wellness': return l10n.tagSauna; // NEU
      
      // Ernährung & Verhalten (NEU)
      case 'Fast Food': case 'Junk Food': return l10n.tagFastFood;
      case 'Viel Handy': case 'High Screen Time': return l10n.tagScreenTime;
      case 'Wenig Wasser': case 'Little Water': return l10n.tagWater;
      case 'Gesund gegessen': case 'Healthy Food': return l10n.tagHealthyFood;
      
      // Pflichten
      case 'Arbeit': case 'Work': return l10n.tagWork;
      case 'Schule': case 'School': return l10n.tagSchool;
      case 'Hausaufgaben': case 'Homework': return l10n.tagHomework;
      case 'Uni': case 'University': return l10n.tagUni;
      case 'Haushalt': case 'Household': return l10n.tagHousehold;
      
      // Freizeit
      case 'Hobby': return l10n.tagHobby;
      case 'Reisen': case 'Travel': return l10n.tagTravel;
      case 'Wetter': case 'Weather': return l10n.tagWeather;
      case 'Gaming': return l10n.tagGaming;
      case 'Lesen': case 'Reading': return l10n.tagReading;
      case 'Musik': case 'Music': return l10n.tagMusic;
      
      // Zyklus
      case 'Periode (Leicht)': case 'Period (Light)': return l10n.tagPeriodLight;
      case 'Periode (Mittel)': case 'Period (Medium)': return l10n.tagPeriodMedium;
      case 'Periode (Stark)': case 'Period (Heavy)': return l10n.tagPeriodHeavy;
      case 'Schmierblutung': case 'Spotting': return l10n.tagSpotting;
      case 'Regelschmerzen': case 'Cramps': return l10n.tagCramps;
      case 'PMS': return l10n.tagPMS;
      case 'Ovulation': case 'Eisprung': return l10n.tagOvulation;
      
      default: return rawTag;
    }
  }

  // 4. PREDICTION LOGIK (Sprachunabhängig)
  static double getTagImpact(String tag, AppLocalizations l10n) {
    
    // Wir normalisieren den Tag für den Vergleich (optional lowercase)
    // und prüfen, ob er in einer unserer bekannten Listen vorkommt.
    
    // --- NEGATIV ---
    if (_matches(tag, [l10n.tagAlcohol, 'Alkohol', 'Alcohol', 'Bier', 'Beer', 'Wine'])) return -0.8;
    if (_matches(tag, [l10n.tagFastFood, 'Fast Food', 'Junk Food', 'Burger'])) return -0.3;
    if (_matches(tag, [l10n.tagScreenTime, 'Viel Handy', 'High Screen Time', 'Social Media'])) return -0.4;
    
    // --- POSITIV ---
    if (_matches(tag, [l10n.tagSport, 'Sport', 'Workout', 'Gym', 'Joggen'])) return 0.6;
    if (_matches(tag, [l10n.tagNature, 'Natur', 'Nature', 'Wald', 'Hiking'])) return 0.4;
    if (_matches(tag, [l10n.tagSex, 'Sex', 'Intimität', 'Intimacy'])) return 0.5;
    if (_matches(tag, [l10n.tagFamily, 'Familie', 'Family'])) return 0.2; // Familie ist meist gut, aber neutraler Startwert

    return 0.0;
  }

  // Kleiner Helper, um Listen abzugleichen
  static bool _matches(String tag, List<String> variants) {
    return variants.contains(tag);
  }
}
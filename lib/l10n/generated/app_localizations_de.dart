// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'LuvioSphere';

  @override
  String get today => 'Heute';

  @override
  String get moodEntry => 'Eintrag';

  @override
  String get statistics => 'Statistik';

  @override
  String get profile => 'Profil';

  @override
  String get newProfile => 'Neu...';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String streakMessage(int count) {
    return '$count Tage in Folge! Weiter so! 🔥';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get becomePro => 'Pro werden';

  @override
  String get manageSub => 'Abo verwalten';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get logout => 'Abmelden';

  @override
  String get version => 'Version';

  @override
  String get proMember => 'PRO MITGLIED';

  @override
  String get freeUser => 'FREE USER';

  @override
  String get achievements => 'Deine Erfolge';

  @override
  String get badgeStart => 'Aller Anfang';

  @override
  String get badgeStartDesc => 'Der erste Eintrag.';

  @override
  String get badgeStreak => 'Dranbleiber';

  @override
  String get badgeStreakDesc => 'An 7 verschiedenen Tagen getrackt.';

  @override
  String get badgeWeekend => 'Wochenend-Held';

  @override
  String get badgeWeekendDesc => '10 Einträge am Wochenende.';

  @override
  String get badgeVeteran => 'Veteran';

  @override
  String get badgeVeteranDesc => '100 Einträge insgesamt.';

  @override
  String get badgeNightOwl => 'Nachteule';

  @override
  String get badgeNightOwlDesc => '20x spät abends getrackt.';

  @override
  String get badgeSleep => 'Schlaf-Wächter';

  @override
  String get badgeSleepDesc => '30x Schlaf protokolliert.';

  @override
  String get badgeJournal => 'Tagebuch';

  @override
  String get badgeJournalDesc => '50 ausführliche Notizen.';

  @override
  String get badgeContext => 'Kontext-Profi';

  @override
  String get badgeContextDesc => '20 Einträge mit vielen Tags.';

  @override
  String get badgeOptimist => 'Optimist';

  @override
  String get badgeOptimistDesc => '50x sehr gute Laune (8+).';

  @override
  String get inputHowAreYou => 'Wie geht es dir?';

  @override
  String get inputSleep => 'Schlaf erfassen';

  @override
  String get inputNoteHint => 'Notiz hinzufügen...';

  @override
  String get inputNoTags => 'Keine Tags gewählt';

  @override
  String get inputAddTag => 'Tag hinzufügen';

  @override
  String get inputEdit => 'Tag bearbeiten';

  @override
  String get statsAnalysis => 'Woche analysieren';

  @override
  String get statsAnalysisWait => 'Analysiere...';

  @override
  String get statsAnalysisError => 'Fehler bei Analyse';

  @override
  String get statsChartTitle => 'Stimmung & Schlaf';

  @override
  String get statsMood => 'Stimmung';

  @override
  String get statsSleep => 'Schlaf';
}

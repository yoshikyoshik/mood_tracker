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
}

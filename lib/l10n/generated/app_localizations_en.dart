// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LuvioSphere';

  @override
  String get today => 'Today';

  @override
  String get moodEntry => 'Entry';

  @override
  String get statistics => 'Statistics';

  @override
  String get profile => 'Profile';

  @override
  String get newProfile => 'New...';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String streakMessage(int count) {
    return '$count day streak! Keep it up! 🔥';
  }
}

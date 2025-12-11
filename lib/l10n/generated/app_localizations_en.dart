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

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get becomePro => 'Become Pro';

  @override
  String get manageSub => 'Manage Subscription';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get logout => 'Logout';

  @override
  String get version => 'Version';

  @override
  String get proMember => 'PRO MEMBER';

  @override
  String get freeUser => 'FREE USER';

  @override
  String get achievements => 'Your Achievements';

  @override
  String get badgeStart => 'The Beginning';

  @override
  String get badgeStartDesc => 'Your first entry.';

  @override
  String get badgeStreak => 'Consistent';

  @override
  String get badgeStreakDesc => 'Tracked on 7 different days.';

  @override
  String get badgeWeekend => 'Weekend Hero';

  @override
  String get badgeWeekendDesc => '10 entries on weekends.';

  @override
  String get badgeVeteran => 'Veteran';

  @override
  String get badgeVeteranDesc => '100 entries in total.';

  @override
  String get badgeNightOwl => 'Night Owl';

  @override
  String get badgeNightOwlDesc => '20 entries late at night.';

  @override
  String get badgeSleep => 'Sleep Guardian';

  @override
  String get badgeSleepDesc => 'Logged sleep 30 times.';

  @override
  String get badgeJournal => 'Journalist';

  @override
  String get badgeJournalDesc => '50 detailed notes written.';

  @override
  String get badgeContext => 'Context Pro';

  @override
  String get badgeContextDesc => '20 entries with many tags.';

  @override
  String get badgeOptimist => 'Optimist';

  @override
  String get badgeOptimistDesc => '50x very good mood (8+).';

  @override
  String get inputHowAreYou => 'How are you?';

  @override
  String get inputSleep => 'Track Sleep';

  @override
  String get inputNoteHint => 'Add a note...';

  @override
  String get inputNoTags => 'No tags selected';

  @override
  String get inputAddTag => 'Add Tag';

  @override
  String get inputEdit => 'Edit Tag';

  @override
  String get statsAnalysis => 'Analyze Week';

  @override
  String get statsAnalysisWait => 'Analyzing...';

  @override
  String get statsAnalysisError => 'Analysis Error';

  @override
  String get statsChartTitle => 'Mood & Sleep';

  @override
  String get statsMood => 'Mood';

  @override
  String get statsSleep => 'Sleep';
}

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

  @override
  String get inputMoodTerrible => 'Terrible';

  @override
  String get inputMoodBad => 'Bad';

  @override
  String get inputMoodOkay => 'Okay';

  @override
  String get inputMoodGood => 'Good';

  @override
  String get inputMoodFantastic => 'Fantastic';

  @override
  String get dialogNewProfileTitle => 'Create New Profile';

  @override
  String get dialogEditProfileTitle => 'Edit Profile';

  @override
  String get dialogNameLabel => 'Name';

  @override
  String get dialogCycleTracking => 'Track Cycle';

  @override
  String get dialogCycleDesc => 'Calculates cycle days';

  @override
  String get dialogPeriodStart => 'Start of last period';

  @override
  String get dialogSelectDate => 'Select Date';

  @override
  String get dialogAdd => 'Add';

  @override
  String get dialogMoveCategory => 'Move Category';

  @override
  String get dialogRenameTag => 'Rename tag';

  @override
  String dialogDeleteTagTitle(String tag) {
    return 'Delete tag \'$tag\'?';
  }

  @override
  String get dialogDeleteTagContent =>
      'This tag will be removed from selection.';

  @override
  String dialogEditTagTitle(String tag) {
    return 'Options for \'$tag\'';
  }

  @override
  String get statsYearly => 'Yearly Overview';

  @override
  String get statsNoData => 'No data yet.';

  @override
  String get statsPatternDay => 'Patterns by Weekday';

  @override
  String get statsInsights => 'Influencing Factors';

  @override
  String get statsAiIntro => 'Let AI analyze your week.';

  @override
  String get statsAiButton => 'Analyze Week';

  @override
  String get statsAiButtonUpdate => 'Update Analysis';

  @override
  String get statsTrendTitle => 'Forecast for tomorrow';

  @override
  String get statsTrendGood => 'Good Outlook! ☀️';

  @override
  String get statsTrendNormal => 'Solid Day Ahead 🌱';

  @override
  String get statsTrendBad => 'Stay Mindful 💜';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryBodyMind => 'Body & Mind';

  @override
  String get categoryObligations => 'Obligations';

  @override
  String get categoryLeisure => 'Leisure & Environment';

  @override
  String get categoryCycle => 'Cycle & Body';

  @override
  String get categoryOther => 'Other';

  @override
  String get tagFamily => 'Family';

  @override
  String get tagRelationship => 'Relationship';

  @override
  String get tagFriends => 'Friends';

  @override
  String get tagParty => 'Party';

  @override
  String get tagSport => 'Sports';

  @override
  String get tagSleep => 'Sleep';

  @override
  String get tagFood => 'Food';

  @override
  String get tagHealth => 'Health';

  @override
  String get tagMeditation => 'Meditation';

  @override
  String get tagWork => 'Work';

  @override
  String get tagSchool => 'School';

  @override
  String get tagHomework => 'Homework';

  @override
  String get tagUni => 'University';

  @override
  String get tagHousehold => 'Household';

  @override
  String get tagHobby => 'Hobby';

  @override
  String get tagTravel => 'Travel';

  @override
  String get tagWeather => 'Weather';

  @override
  String get tagGaming => 'Gaming';

  @override
  String get tagReading => 'Reading';

  @override
  String get tagMusic => 'Music';

  @override
  String get tagPeriodLight => 'Period (Light)';

  @override
  String get tagPeriodMedium => 'Period (Medium)';

  @override
  String get tagPeriodHeavy => 'Period (Heavy)';

  @override
  String get tagSpotting => 'Spotting';

  @override
  String get tagCramps => 'Cramps';

  @override
  String get tagPMS => 'PMS';

  @override
  String get tagOvulation => 'Ovulation';

  @override
  String get unknownProfile => 'Unknown';

  @override
  String get btnSelect => 'SELECT';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get premiumTeaserTitle => 'Multiple Profiles';

  @override
  String get premiumTeaserMessage =>
      'In the free version, you have one profile.\nDo you want to add profiles for partners, children, or pets?';

  @override
  String get snackSaved => 'Saved';

  @override
  String get snackDeleted => 'Deleted';

  @override
  String get snackTagDeleted => 'Tag deleted';

  @override
  String snackError(String error) {
    return 'Error: $error';
  }

  @override
  String get dialogNewTagName => 'New name';

  @override
  String get dialogNewTagPlaceholder => 'Name (e.g. Yoga)';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelDescription => 'Description';

  @override
  String predTextGood(String day, String score) {
    return 'Tomorrow is $day. Your data and environment suggest a strong day ahead (Ø $score).';
  }

  @override
  String predTextBad(String day, String score) {
    return 'For $day, data predicts slightly lower energy levels (Ø $score).';
  }

  @override
  String predTextNormal(String day, String score) {
    return 'The forecast for $day is balanced (Ø $score).';
  }

  @override
  String get tipSleep => 'Tip: Go to sleep earlier today.';

  @override
  String get tipFamilyBad => 'Household vibes were tense recently.';

  @override
  String get tipFamilyGood => 'Positive household vibes give you a boost!';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authRegisterTitle => 'Create new account';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginButton => 'Login';

  @override
  String get authRegisterButton => 'Register';

  @override
  String get authHaveAccount => 'I already have an account';

  @override
  String get authNoAccount => 'Register';

  @override
  String get authLoading => 'Loading...';

  @override
  String authError(String message) {
    return 'Error: $message';
  }

  @override
  String get authSuccessVerify => 'Please verify your email!';

  @override
  String get legal => 'Legal';

  @override
  String get imprint => 'Imprint';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get tutorialMoodTitle => 'Your Mood';

  @override
  String get tutorialMoodDesc =>
      'Move the slider to capture how you feel right now.';

  @override
  String get tutorialSaveTitle => 'Save Entry';

  @override
  String get tutorialSaveDesc => 'Tap here to write your entry to the diary.';

  @override
  String get tutorialStatsTitle => 'Your Insights';

  @override
  String get tutorialStatsDesc =>
      'Discover charts and patterns about your mood here.';

  @override
  String get tutorialProfileTitle => 'Your Profile';

  @override
  String get tutorialProfileDesc =>
      'Manage your data, settings, and exports here.';
}

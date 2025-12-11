import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'LuvioSphere'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @moodEntry.
  ///
  /// In de, this message translates to:
  /// **'Eintrag'**
  String get moodEntry;

  /// No description provided for @statistics.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// No description provided for @profile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @newProfile.
  ///
  /// In de, this message translates to:
  /// **'Neu...'**
  String get newProfile;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @streakMessage.
  ///
  /// In de, this message translates to:
  /// **'{count} Tage in Folge! Weiter so! 🔥'**
  String streakMessage(int count);

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @becomePro.
  ///
  /// In de, this message translates to:
  /// **'Pro werden'**
  String get becomePro;

  /// No description provided for @manageSub.
  ///
  /// In de, this message translates to:
  /// **'Abo verwalten'**
  String get manageSub;

  /// No description provided for @contactSupport.
  ///
  /// In de, this message translates to:
  /// **'Support kontaktieren'**
  String get contactSupport;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @proMember.
  ///
  /// In de, this message translates to:
  /// **'PRO MITGLIED'**
  String get proMember;

  /// No description provided for @freeUser.
  ///
  /// In de, this message translates to:
  /// **'FREE USER'**
  String get freeUser;

  /// No description provided for @achievements.
  ///
  /// In de, this message translates to:
  /// **'Deine Erfolge'**
  String get achievements;

  /// No description provided for @badgeStart.
  ///
  /// In de, this message translates to:
  /// **'Aller Anfang'**
  String get badgeStart;

  /// No description provided for @badgeStartDesc.
  ///
  /// In de, this message translates to:
  /// **'Der erste Eintrag.'**
  String get badgeStartDesc;

  /// No description provided for @badgeStreak.
  ///
  /// In de, this message translates to:
  /// **'Dranbleiber'**
  String get badgeStreak;

  /// No description provided for @badgeStreakDesc.
  ///
  /// In de, this message translates to:
  /// **'An 7 verschiedenen Tagen getrackt.'**
  String get badgeStreakDesc;

  /// No description provided for @badgeWeekend.
  ///
  /// In de, this message translates to:
  /// **'Wochenend-Held'**
  String get badgeWeekend;

  /// No description provided for @badgeWeekendDesc.
  ///
  /// In de, this message translates to:
  /// **'10 Einträge am Wochenende.'**
  String get badgeWeekendDesc;

  /// No description provided for @badgeVeteran.
  ///
  /// In de, this message translates to:
  /// **'Veteran'**
  String get badgeVeteran;

  /// No description provided for @badgeVeteranDesc.
  ///
  /// In de, this message translates to:
  /// **'100 Einträge insgesamt.'**
  String get badgeVeteranDesc;

  /// No description provided for @badgeNightOwl.
  ///
  /// In de, this message translates to:
  /// **'Nachteule'**
  String get badgeNightOwl;

  /// No description provided for @badgeNightOwlDesc.
  ///
  /// In de, this message translates to:
  /// **'20x spät abends getrackt.'**
  String get badgeNightOwlDesc;

  /// No description provided for @badgeSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf-Wächter'**
  String get badgeSleep;

  /// No description provided for @badgeSleepDesc.
  ///
  /// In de, this message translates to:
  /// **'30x Schlaf protokolliert.'**
  String get badgeSleepDesc;

  /// No description provided for @badgeJournal.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get badgeJournal;

  /// No description provided for @badgeJournalDesc.
  ///
  /// In de, this message translates to:
  /// **'50 ausführliche Notizen.'**
  String get badgeJournalDesc;

  /// No description provided for @badgeContext.
  ///
  /// In de, this message translates to:
  /// **'Kontext-Profi'**
  String get badgeContext;

  /// No description provided for @badgeContextDesc.
  ///
  /// In de, this message translates to:
  /// **'20 Einträge mit vielen Tags.'**
  String get badgeContextDesc;

  /// No description provided for @badgeOptimist.
  ///
  /// In de, this message translates to:
  /// **'Optimist'**
  String get badgeOptimist;

  /// No description provided for @badgeOptimistDesc.
  ///
  /// In de, this message translates to:
  /// **'50x sehr gute Laune (8+).'**
  String get badgeOptimistDesc;

  /// No description provided for @inputHowAreYou.
  ///
  /// In de, this message translates to:
  /// **'Wie geht es dir?'**
  String get inputHowAreYou;

  /// No description provided for @inputSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf erfassen'**
  String get inputSleep;

  /// No description provided for @inputNoteHint.
  ///
  /// In de, this message translates to:
  /// **'Notiz hinzufügen...'**
  String get inputNoteHint;

  /// No description provided for @inputNoTags.
  ///
  /// In de, this message translates to:
  /// **'Keine Tags gewählt'**
  String get inputNoTags;

  /// No description provided for @inputAddTag.
  ///
  /// In de, this message translates to:
  /// **'Tag hinzufügen'**
  String get inputAddTag;

  /// No description provided for @inputEdit.
  ///
  /// In de, this message translates to:
  /// **'Tag bearbeiten'**
  String get inputEdit;

  /// No description provided for @statsAnalysis.
  ///
  /// In de, this message translates to:
  /// **'Woche analysieren'**
  String get statsAnalysis;

  /// No description provided for @statsAnalysisWait.
  ///
  /// In de, this message translates to:
  /// **'Analysiere...'**
  String get statsAnalysisWait;

  /// No description provided for @statsAnalysisError.
  ///
  /// In de, this message translates to:
  /// **'Fehler bei Analyse'**
  String get statsAnalysisError;

  /// No description provided for @statsChartTitle.
  ///
  /// In de, this message translates to:
  /// **'Stimmung & Schlaf'**
  String get statsChartTitle;

  /// No description provided for @statsMood.
  ///
  /// In de, this message translates to:
  /// **'Stimmung'**
  String get statsMood;

  /// No description provided for @statsSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf'**
  String get statsSleep;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

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

  /// No description provided for @inputMoodTerrible.
  ///
  /// In de, this message translates to:
  /// **'Schrecklich'**
  String get inputMoodTerrible;

  /// No description provided for @inputMoodBad.
  ///
  /// In de, this message translates to:
  /// **'Schlecht'**
  String get inputMoodBad;

  /// No description provided for @inputMoodOkay.
  ///
  /// In de, this message translates to:
  /// **'Okay'**
  String get inputMoodOkay;

  /// No description provided for @inputMoodGood.
  ///
  /// In de, this message translates to:
  /// **'Gut'**
  String get inputMoodGood;

  /// No description provided for @inputMoodFantastic.
  ///
  /// In de, this message translates to:
  /// **'Fantastisch'**
  String get inputMoodFantastic;

  /// No description provided for @dialogNewProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Profil erstellen'**
  String get dialogNewProfileTitle;

  /// No description provided for @dialogEditProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get dialogEditProfileTitle;

  /// No description provided for @dialogNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get dialogNameLabel;

  /// No description provided for @dialogCycleTracking.
  ///
  /// In de, this message translates to:
  /// **'Zyklus tracken'**
  String get dialogCycleTracking;

  /// No description provided for @dialogCycleDesc.
  ///
  /// In de, this message translates to:
  /// **'Berechnet Zyklustage'**
  String get dialogCycleDesc;

  /// No description provided for @dialogPeriodStart.
  ///
  /// In de, this message translates to:
  /// **'Start letzte Periode'**
  String get dialogPeriodStart;

  /// No description provided for @dialogSelectDate.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get dialogSelectDate;

  /// No description provided for @dialogAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get dialogAdd;

  /// No description provided for @dialogMoveCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie verschieben'**
  String get dialogMoveCategory;

  /// No description provided for @dialogRenameTag.
  ///
  /// In de, this message translates to:
  /// **'Tag umbenennen'**
  String get dialogRenameTag;

  /// No description provided for @dialogDeleteTagTitle.
  ///
  /// In de, this message translates to:
  /// **'Tag \'{tag}\' löschen?'**
  String dialogDeleteTagTitle(String tag);

  /// No description provided for @dialogDeleteTagContent.
  ///
  /// In de, this message translates to:
  /// **'Dieser Tag wird aus der Auswahl entfernt.'**
  String get dialogDeleteTagContent;

  /// No description provided for @dialogEditTagTitle.
  ///
  /// In de, this message translates to:
  /// **'Optionen für \'{tag}\''**
  String dialogEditTagTitle(String tag);

  /// No description provided for @statsYearly.
  ///
  /// In de, this message translates to:
  /// **'Jahres-Verlauf'**
  String get statsYearly;

  /// No description provided for @statsNoData.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Daten.'**
  String get statsNoData;

  /// No description provided for @statsPatternDay.
  ///
  /// In de, this message translates to:
  /// **'Muster nach Wochentag'**
  String get statsPatternDay;

  /// No description provided for @statsInsights.
  ///
  /// In de, this message translates to:
  /// **'Einflussfaktoren'**
  String get statsInsights;

  /// No description provided for @statsAiIntro.
  ///
  /// In de, this message translates to:
  /// **'Lass deine Woche von der KI analysieren.'**
  String get statsAiIntro;

  /// No description provided for @statsAiButton.
  ///
  /// In de, this message translates to:
  /// **'Woche analysieren'**
  String get statsAiButton;

  /// No description provided for @statsAiButtonUpdate.
  ///
  /// In de, this message translates to:
  /// **'Analyse aktualisieren'**
  String get statsAiButtonUpdate;

  /// No description provided for @statsTrendTitle.
  ///
  /// In de, this message translates to:
  /// **'Trend für morgen'**
  String get statsTrendTitle;

  /// No description provided for @statsTrendGood.
  ///
  /// In de, this message translates to:
  /// **'Gute Aussichten! ☀️'**
  String get statsTrendGood;

  /// No description provided for @statsTrendNormal.
  ///
  /// In de, this message translates to:
  /// **'Solider Tag erwartet 🌱'**
  String get statsTrendNormal;

  /// No description provided for @statsTrendBad.
  ///
  /// In de, this message translates to:
  /// **'Achtsam bleiben 💜'**
  String get statsTrendBad;

  /// No description provided for @categorySocial.
  ///
  /// In de, this message translates to:
  /// **'Soziales'**
  String get categorySocial;

  /// No description provided for @categoryBodyMind.
  ///
  /// In de, this message translates to:
  /// **'Körper & Geist'**
  String get categoryBodyMind;

  /// No description provided for @categoryObligations.
  ///
  /// In de, this message translates to:
  /// **'Pflichten'**
  String get categoryObligations;

  /// No description provided for @categoryLeisure.
  ///
  /// In de, this message translates to:
  /// **'Freizeit & Umwelt'**
  String get categoryLeisure;

  /// No description provided for @categoryCycle.
  ///
  /// In de, this message translates to:
  /// **'Zyklus & Körper'**
  String get categoryCycle;

  /// No description provided for @categoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryOther;

  /// No description provided for @tagFamily.
  ///
  /// In de, this message translates to:
  /// **'Familie'**
  String get tagFamily;

  /// No description provided for @tagRelationship.
  ///
  /// In de, this message translates to:
  /// **'Beziehung'**
  String get tagRelationship;

  /// No description provided for @tagFriends.
  ///
  /// In de, this message translates to:
  /// **'Freunde'**
  String get tagFriends;

  /// No description provided for @tagParty.
  ///
  /// In de, this message translates to:
  /// **'Party'**
  String get tagParty;

  /// No description provided for @tagSport.
  ///
  /// In de, this message translates to:
  /// **'Sport'**
  String get tagSport;

  /// No description provided for @tagSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf'**
  String get tagSleep;

  /// No description provided for @tagFood.
  ///
  /// In de, this message translates to:
  /// **'Essen'**
  String get tagFood;

  /// No description provided for @tagHealth.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit'**
  String get tagHealth;

  /// No description provided for @tagMeditation.
  ///
  /// In de, this message translates to:
  /// **'Meditation'**
  String get tagMeditation;

  /// No description provided for @tagWork.
  ///
  /// In de, this message translates to:
  /// **'Arbeit'**
  String get tagWork;

  /// No description provided for @tagSchool.
  ///
  /// In de, this message translates to:
  /// **'Schule'**
  String get tagSchool;

  /// No description provided for @tagHomework.
  ///
  /// In de, this message translates to:
  /// **'Hausaufgaben'**
  String get tagHomework;

  /// No description provided for @tagUni.
  ///
  /// In de, this message translates to:
  /// **'Uni'**
  String get tagUni;

  /// No description provided for @tagHousehold.
  ///
  /// In de, this message translates to:
  /// **'Haushalt'**
  String get tagHousehold;

  /// No description provided for @tagHobby.
  ///
  /// In de, this message translates to:
  /// **'Hobby'**
  String get tagHobby;

  /// No description provided for @tagTravel.
  ///
  /// In de, this message translates to:
  /// **'Reisen'**
  String get tagTravel;

  /// No description provided for @tagWeather.
  ///
  /// In de, this message translates to:
  /// **'Wetter'**
  String get tagWeather;

  /// No description provided for @tagGaming.
  ///
  /// In de, this message translates to:
  /// **'Gaming'**
  String get tagGaming;

  /// No description provided for @tagReading.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get tagReading;

  /// No description provided for @tagMusic.
  ///
  /// In de, this message translates to:
  /// **'Musik'**
  String get tagMusic;

  /// No description provided for @tagPeriodLight.
  ///
  /// In de, this message translates to:
  /// **'Periode (Leicht)'**
  String get tagPeriodLight;

  /// No description provided for @tagPeriodMedium.
  ///
  /// In de, this message translates to:
  /// **'Periode (Mittel)'**
  String get tagPeriodMedium;

  /// No description provided for @tagPeriodHeavy.
  ///
  /// In de, this message translates to:
  /// **'Periode (Stark)'**
  String get tagPeriodHeavy;

  /// No description provided for @tagSpotting.
  ///
  /// In de, this message translates to:
  /// **'Schmierblutung'**
  String get tagSpotting;

  /// No description provided for @tagCramps.
  ///
  /// In de, this message translates to:
  /// **'Regelschmerzen'**
  String get tagCramps;

  /// No description provided for @tagPMS.
  ///
  /// In de, this message translates to:
  /// **'PMS'**
  String get tagPMS;

  /// No description provided for @tagOvulation.
  ///
  /// In de, this message translates to:
  /// **'Eisprung'**
  String get tagOvulation;

  /// No description provided for @unknownProfile.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get unknownProfile;

  /// No description provided for @btnSelect.
  ///
  /// In de, this message translates to:
  /// **'AUSWÄHLEN'**
  String get btnSelect;

  /// No description provided for @maybeLater.
  ///
  /// In de, this message translates to:
  /// **'Vielleicht später'**
  String get maybeLater;

  /// No description provided for @premiumTeaserTitle.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Profile'**
  String get premiumTeaserTitle;

  /// No description provided for @premiumTeaserMessage.
  ///
  /// In de, this message translates to:
  /// **'In der Free-Version hast du ein Profil.\nMöchtest du Profile für Partner, Kinder oder Haustiere anlegen?'**
  String get premiumTeaserMessage;

  /// No description provided for @snackSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert'**
  String get snackSaved;

  /// No description provided for @snackDeleted.
  ///
  /// In de, this message translates to:
  /// **'Gelöscht'**
  String get snackDeleted;

  /// No description provided for @snackTagDeleted.
  ///
  /// In de, this message translates to:
  /// **'Tag gelöscht'**
  String get snackTagDeleted;

  /// No description provided for @snackError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String snackError(String error);

  /// No description provided for @dialogNewTagName.
  ///
  /// In de, this message translates to:
  /// **'Neuer Name'**
  String get dialogNewTagName;

  /// No description provided for @dialogNewTagPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Name (z.B. Yoga)'**
  String get dialogNewTagPlaceholder;

  /// No description provided for @labelCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get labelCategory;

  /// No description provided for @labelDescription.
  ///
  /// In de, this message translates to:
  /// **'Bezeichnung'**
  String get labelDescription;

  /// No description provided for @predTextGood.
  ///
  /// In de, this message translates to:
  /// **'Morgen ist {day}. Deine Daten und das Umfeld deuten auf einen starken Tag hin (Ø {score}).'**
  String predTextGood(String day, String score);

  /// No description provided for @predTextBad.
  ///
  /// In de, this message translates to:
  /// **'Für {day} sagen die Daten etwas weniger Energie voraus (Ø {score}).'**
  String predTextBad(String day, String score);

  /// No description provided for @predTextNormal.
  ///
  /// In de, this message translates to:
  /// **'Die Prognose für {day} ist ausgeglichen (Ø {score}).'**
  String predTextNormal(String day, String score);

  /// No description provided for @tipSleep.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Geh heute früher schlafen.'**
  String get tipSleep;

  /// No description provided for @tipFamilyBad.
  ///
  /// In de, this message translates to:
  /// **'Die Stimmung im Haus war zuletzt angespannt.'**
  String get tipFamilyBad;

  /// No description provided for @tipFamilyGood.
  ///
  /// In de, this message translates to:
  /// **'Positive Vibes im Haushalt geben dir Rückenwind!'**
  String get tipFamilyGood;

  /// No description provided for @authLoginTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In de, this message translates to:
  /// **'Neuen Account erstellen'**
  String get authRegisterTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In de, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authRegisterButton;

  /// No description provided for @authHaveAccount.
  ///
  /// In de, this message translates to:
  /// **'Ich habe schon einen Account'**
  String get authHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authNoAccount;

  /// No description provided for @authLoading.
  ///
  /// In de, this message translates to:
  /// **'Lade...'**
  String get authLoading;

  /// No description provided for @authError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {message}'**
  String authError(String message);

  /// No description provided for @authSuccessVerify.
  ///
  /// In de, this message translates to:
  /// **'Bitte bestätige deine E-Mail!'**
  String get authSuccessVerify;
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

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

  /// No description provided for @legal.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get legal;

  /// No description provided for @imprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get imprint;

  /// No description provided for @privacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get privacy;

  /// No description provided for @tutorialMoodTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Stimmung'**
  String get tutorialMoodTitle;

  /// No description provided for @tutorialMoodDesc.
  ///
  /// In de, this message translates to:
  /// **'Bewege den Slider, um festzuhalten, wie du dich fühlst.'**
  String get tutorialMoodDesc;

  /// No description provided for @tutorialSaveTitle.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get tutorialSaveTitle;

  /// No description provided for @tutorialSaveDesc.
  ///
  /// In de, this message translates to:
  /// **'Tippe hier, um deinen Eintrag in das Tagebuch zu schreiben.'**
  String get tutorialSaveDesc;

  /// No description provided for @tutorialStatsTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Erkenntnisse'**
  String get tutorialStatsTitle;

  /// No description provided for @tutorialStatsDesc.
  ///
  /// In de, this message translates to:
  /// **'Hier siehst du Charts und Muster zu deiner Stimmung.'**
  String get tutorialStatsDesc;

  /// No description provided for @tutorialProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Profil'**
  String get tutorialProfileTitle;

  /// No description provided for @tutorialProfileDesc.
  ///
  /// In de, this message translates to:
  /// **'Verwalte hier deine Daten, Einstellungen und Export-Funktionen.'**
  String get tutorialProfileDesc;

  /// No description provided for @tutorialStart.
  ///
  /// In de, this message translates to:
  /// **'Tutorial starten'**
  String get tutorialStart;

  /// No description provided for @exportPdf.
  ///
  /// In de, this message translates to:
  /// **'Report erstellen (PDF)'**
  String get exportPdf;

  /// No description provided for @predCycleRest.
  ///
  /// In de, this message translates to:
  /// **'Dein Zyklus fordert vielleicht etwas Ruhe.'**
  String get predCycleRest;

  /// No description provided for @predCyclePower.
  ///
  /// In de, this message translates to:
  /// **'Dein Zyklus gibt dir extra Power!'**
  String get predCyclePower;

  /// No description provided for @predSentimentStress.
  ///
  /// In de, this message translates to:
  /// **'Deine Notizen wirkten zuletzt gestresst.'**
  String get predSentimentStress;

  /// No description provided for @predSleepTip.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Geh heute früher schlafen.'**
  String get predSleepTip;

  /// No description provided for @aiCalibration.
  ///
  /// In de, this message translates to:
  /// **'AI Kalibrierung...'**
  String get aiCalibration;

  /// No description provided for @aiCalibrationText.
  ///
  /// In de, this message translates to:
  /// **'Deine Smart Forecast wird eingerichtet. Wir benötigen noch {missing} Einträge.'**
  String aiCalibrationText(int missing);

  /// No description provided for @aiEntriesCount.
  ///
  /// In de, this message translates to:
  /// **'{count} / {target} Einträge'**
  String aiEntriesCount(int count, int target);

  /// No description provided for @lockedPredTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie wird dein Tag morgen?'**
  String get lockedPredTitle;

  /// No description provided for @lockedPredDesc.
  ///
  /// In de, this message translates to:
  /// **'Basierend auf deinem Schlaf, Trend und Wochentag.'**
  String get lockedPredDesc;

  /// No description provided for @lockedAiTitle.
  ///
  /// In de, this message translates to:
  /// **'Tiefenanalyse deiner Woche'**
  String get lockedAiTitle;

  /// No description provided for @errorNoEntries7Days.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge in den letzten 7 Tagen gefunden.'**
  String get errorNoEntries7Days;

  /// No description provided for @errorAnalysisFailed.
  ///
  /// In de, this message translates to:
  /// **'Fehler bei der Analyse: {code}'**
  String errorAnalysisFailed(Object code);

  /// No description provided for @sentimentNegativeWords.
  ///
  /// In de, this message translates to:
  /// **'Stress,Streit,Krank,Schmerz,Müde,Angst,Traurig,Schlecht'**
  String get sentimentNegativeWords;

  /// No description provided for @sentimentPositiveWords.
  ///
  /// In de, this message translates to:
  /// **'Urlaub,Liebe,Erfolg,Sport,Glücklich,Super,Entspannt,Party'**
  String get sentimentPositiveWords;

  /// No description provided for @statsAiCoachTitle.
  ///
  /// In de, this message translates to:
  /// **'AI Wochen-Coach'**
  String get statsAiCoachTitle;

  /// No description provided for @labelDataFor.
  ///
  /// In de, this message translates to:
  /// **'Daten für {name}:'**
  String labelDataFor(String name);

  /// No description provided for @labelNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get labelNote;

  /// No description provided for @exportPdfButton.
  ///
  /// In de, this message translates to:
  /// **'Report erstellen (PDF)'**
  String get exportPdfButton;

  /// No description provided for @pdfTitle.
  ///
  /// In de, this message translates to:
  /// **'LuvioSphere Report'**
  String get pdfTitle;

  /// No description provided for @pdfProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil: {name}'**
  String pdfProfile(String name);

  /// No description provided for @pdfPeriod.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum: Letzte 30 Tage'**
  String get pdfPeriod;

  /// No description provided for @pdfAvgMood.
  ///
  /// In de, this message translates to:
  /// **'Ø Stimmung'**
  String get pdfAvgMood;

  /// No description provided for @pdfAvgSleep.
  ///
  /// In de, this message translates to:
  /// **'Ø Schlaf'**
  String get pdfAvgSleep;

  /// No description provided for @pdfEntriesCount.
  ///
  /// In de, this message translates to:
  /// **'Einträge'**
  String get pdfEntriesCount;

  /// No description provided for @pdfHeaderDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get pdfHeaderDate;

  /// No description provided for @pdfHeaderTime.
  ///
  /// In de, this message translates to:
  /// **'Zeit'**
  String get pdfHeaderTime;

  /// No description provided for @pdfHeaderMood.
  ///
  /// In de, this message translates to:
  /// **'Mood'**
  String get pdfHeaderMood;

  /// No description provided for @pdfHeaderSleep.
  ///
  /// In de, this message translates to:
  /// **'Schlaf'**
  String get pdfHeaderSleep;

  /// No description provided for @pdfHeaderTags.
  ///
  /// In de, this message translates to:
  /// **'Tags'**
  String get pdfHeaderTags;

  /// No description provided for @pdfHeaderNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get pdfHeaderNote;

  /// No description provided for @pdfFooter.
  ///
  /// In de, this message translates to:
  /// **'Erstellt mit LuvioSphere'**
  String get pdfFooter;

  /// No description provided for @predWeatherGood.
  ///
  /// In de, this message translates to:
  /// **'Die Sonne morgen gibt dir Energie!'**
  String get predWeatherGood;

  /// No description provided for @predWeatherBad.
  ///
  /// In de, this message translates to:
  /// **'Regen angesagt – mach es dir gemütlich.'**
  String get predWeatherBad;

  /// No description provided for @partnerTitle.
  ///
  /// In de, this message translates to:
  /// **'Partner Connect ❤️'**
  String get partnerTitle;

  /// No description provided for @partnerDesc.
  ///
  /// In de, this message translates to:
  /// **'Verbinde dich mit deinem Partner, um zu sehen, wie es ihm geht.'**
  String get partnerDesc;

  /// No description provided for @partnerEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail deines Partners'**
  String get partnerEmailLabel;

  /// No description provided for @partnerConnectBtn.
  ///
  /// In de, this message translates to:
  /// **'Verbinden'**
  String get partnerConnectBtn;

  /// No description provided for @partnerConnected.
  ///
  /// In de, this message translates to:
  /// **'Verbunden mit {name}'**
  String partnerConnected(String name);

  /// No description provided for @partnerStatus.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Stimmung: {score}'**
  String partnerStatus(String score);

  /// No description provided for @partnerNeedsLove.
  ///
  /// In de, this message translates to:
  /// **'⚠️ {name} hat einen schweren Tag. Schick etwas Liebe!'**
  String partnerNeedsLove(String name);

  /// No description provided for @partnerWait.
  ///
  /// In de, this message translates to:
  /// **'Warte auf Rückbestätigung...'**
  String get partnerWait;

  /// No description provided for @partnerDisconnectTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbindung trennen?'**
  String get partnerDisconnectTitle;

  /// No description provided for @partnerDisconnectMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du die Verbindung zu {partnerEmail} wirklich aufheben?'**
  String partnerDisconnectMessage(String partnerEmail);

  /// No description provided for @partnerDisconnectConfirm.
  ///
  /// In de, this message translates to:
  /// **'Ja, trennen'**
  String get partnerDisconnectConfirm;

  /// No description provided for @partnerDisconnectCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get partnerDisconnectCancel;

  /// No description provided for @partnerDisconnectSuccess.
  ///
  /// In de, this message translates to:
  /// **'Verbindung aufgehoben.'**
  String get partnerDisconnectSuccess;

  /// No description provided for @partnerDisconnectTooltip.
  ///
  /// In de, this message translates to:
  /// **'Verbindung trennen'**
  String get partnerDisconnectTooltip;

  /// No description provided for @tagAlcohol.
  ///
  /// In de, this message translates to:
  /// **'Alkohol'**
  String get tagAlcohol;

  /// No description provided for @tagFastFood.
  ///
  /// In de, this message translates to:
  /// **'Fast Food'**
  String get tagFastFood;

  /// No description provided for @tagScreenTime.
  ///
  /// In de, this message translates to:
  /// **'Viel Handy'**
  String get tagScreenTime;

  /// No description provided for @tagWater.
  ///
  /// In de, this message translates to:
  /// **'Wenig Wasser'**
  String get tagWater;

  /// No description provided for @tagNature.
  ///
  /// In de, this message translates to:
  /// **'Natur'**
  String get tagNature;

  /// No description provided for @tagSauna.
  ///
  /// In de, this message translates to:
  /// **'Sauna/Wellness'**
  String get tagSauna;

  /// No description provided for @tagHealthyFood.
  ///
  /// In de, this message translates to:
  /// **'Gesund gegessen'**
  String get tagHealthyFood;

  /// No description provided for @tagSex.
  ///
  /// In de, this message translates to:
  /// **'Intimität'**
  String get tagSex;

  /// No description provided for @tagStress.
  ///
  /// In de, this message translates to:
  /// **'Stress'**
  String get tagStress;

  /// No description provided for @predSeasonTip.
  ///
  /// In de, this message translates to:
  /// **'Licht tanken hilft!'**
  String get predSeasonTip;

  /// No description provided for @predPersonalized.
  ///
  /// In de, this message translates to:
  /// **'Basierend auf deinen Mustern.'**
  String get predPersonalized;

  /// No description provided for @labelFactors.
  ///
  /// In de, this message translates to:
  /// **'Einflussfaktoren'**
  String get labelFactors;

  /// No description provided for @labelAiVersion.
  ///
  /// In de, this message translates to:
  /// **'AI 2.0'**
  String get labelAiVersion;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In de, this message translates to:
  /// **'Bist du sicher? Alle deine Daten (Einträge, Tags, Profil) werden unwiderruflich gelöscht.'**
  String get deleteAccountContent;

  /// No description provided for @deleteAccountBtn.
  ///
  /// In de, this message translates to:
  /// **'Konto endgültig löschen'**
  String get deleteAccountBtn;

  /// No description provided for @authForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authForgotPassword;

  /// No description provided for @authResetSuccess.
  ///
  /// In de, this message translates to:
  /// **'Link gesendet! Prüfe deine E-Mails.'**
  String get authResetSuccess;

  /// No description provided for @authEnterEmail.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deine E-Mail-Adresse ein.'**
  String get authEnterEmail;

  /// No description provided for @inputDateLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get inputDateLabel;

  /// No description provided for @inputCycleDay.
  ///
  /// In de, this message translates to:
  /// **'Tag {day}'**
  String inputCycleDay(int day);

  /// No description provided for @btnAddEntry.
  ///
  /// In de, this message translates to:
  /// **'Weiteren Eintrag (+)'**
  String get btnAddEntry;

  /// No description provided for @proDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Pro-Feature'**
  String get proDialogTitle;

  /// No description provided for @proDialogDesc.
  ///
  /// In de, this message translates to:
  /// **'Dieses Feature ist exklusiv für Pro-Nutzer. Möchtest du upgraden?'**
  String get proDialogDesc;

  /// No description provided for @btnShop.
  ///
  /// In de, this message translates to:
  /// **'ZUM SHOP'**
  String get btnShop;

  /// No description provided for @partnerLabelConnected.
  ///
  /// In de, this message translates to:
  /// **'Verbunden mit:'**
  String get partnerLabelConnected;

  /// No description provided for @partnerLabelMyEmail.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail (Automatisch)'**
  String get partnerLabelMyEmail;

  /// No description provided for @partnerHintEmail.
  ///
  /// In de, this message translates to:
  /// **'z.B. partner@example.com'**
  String get partnerHintEmail;

  /// No description provided for @partnerTitleLocked.
  ///
  /// In de, this message translates to:
  /// **'Partner Connect'**
  String get partnerTitleLocked;

  /// No description provided for @partnerDescLocked.
  ///
  /// In de, this message translates to:
  /// **'Verbinde dich für mehr Verständnis & Harmonie.'**
  String get partnerDescLocked;

  /// No description provided for @adviceSick.
  ///
  /// In de, this message translates to:
  /// **'Partner ist krank. Tee, Suppe oder Medikamente wären lieb!'**
  String get adviceSick;

  /// No description provided for @adviceCycle.
  ///
  /// In de, this message translates to:
  /// **'Vorsicht: Zyklus-Beschwerden. Wärmflasche & Schokolade bereitstellen!'**
  String get adviceCycle;

  /// No description provided for @adviceStress.
  ///
  /// In de, this message translates to:
  /// **'Hohes Stresslevel. Nimm dem Partner heute vielleicht eine Pflicht ab.'**
  String get adviceStress;

  /// No description provided for @adviceSleep.
  ///
  /// In de, this message translates to:
  /// **'Massiver Schlafmangel. Sorge für einen ruhigen Abend.'**
  String get adviceSleep;

  /// No description provided for @adviceSad.
  ///
  /// In de, this message translates to:
  /// **'Stimmung ist im Keller. Eine Umarmung oder Zuhören hilft oft mehr als Lösungen.'**
  String get adviceSad;

  /// No description provided for @adviceHappy.
  ///
  /// In de, this message translates to:
  /// **'Super Stimmung! Perfekter Zeitpunkt für gemeinsame Unternehmungen.'**
  String get adviceHappy;

  /// No description provided for @lockedInsightsTitle.
  ///
  /// In de, this message translates to:
  /// **'Schalte Premium-Insights frei'**
  String get lockedInsightsTitle;

  /// No description provided for @lockedInsightsDesc.
  ///
  /// In de, this message translates to:
  /// **'Erfahre genau, was deine Stimmung beeinflusst. Unsere KI analysiert deine Muster.'**
  String get lockedInsightsDesc;

  /// No description provided for @btnUnlock.
  ///
  /// In de, this message translates to:
  /// **'Jetzt Pro werden'**
  String get btnUnlock;

  /// No description provided for @insightTrackMore.
  ///
  /// In de, this message translates to:
  /// **'Tracke mehr Tags, um Muster zu erkennen.'**
  String get insightTrackMore;

  /// No description provided for @insightBasdOnPattern.
  ///
  /// In de, this message translates to:
  /// **'Basierend auf deinen Mustern.'**
  String get insightBasdOnPattern;

  /// No description provided for @patternTitle.
  ///
  /// In de, this message translates to:
  /// **'Muster erkannt 💡'**
  String get patternTitle;

  /// No description provided for @patternDrop.
  ///
  /// In de, this message translates to:
  /// **'Immer wenn du \'{tag}\' trackst, sinkt deine Stimmung am nächsten Tag um durchschnittlich {delta} Punkte.'**
  String patternDrop(String tag, String delta);

  /// No description provided for @patternCycle.
  ///
  /// In de, this message translates to:
  /// **'Oft folgt auf \'{tag1}\' am nächsten Tag \'{tag2}\'.'**
  String patternCycle(String tag1, String tag2);

  /// No description provided for @patternCount.
  ///
  /// In de, this message translates to:
  /// **'(Basiert auf {count} Ereignissen)'**
  String patternCount(int count);
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

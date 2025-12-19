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

  @override
  String get inputMoodTerrible => 'Schrecklich';

  @override
  String get inputMoodBad => 'Schlecht';

  @override
  String get inputMoodOkay => 'Okay';

  @override
  String get inputMoodGood => 'Gut';

  @override
  String get inputMoodFantastic => 'Fantastisch';

  @override
  String get dialogNewProfileTitle => 'Neues Profil erstellen';

  @override
  String get dialogEditProfileTitle => 'Profil bearbeiten';

  @override
  String get dialogNameLabel => 'Name';

  @override
  String get dialogCycleTracking => 'Zyklus tracken';

  @override
  String get dialogCycleDesc => 'Berechnet Zyklustage';

  @override
  String get dialogPeriodStart => 'Start letzte Periode';

  @override
  String get dialogSelectDate => 'Datum wählen';

  @override
  String get dialogAdd => 'Hinzufügen';

  @override
  String get dialogMoveCategory => 'Kategorie verschieben';

  @override
  String get dialogRenameTag => 'Tag umbenennen';

  @override
  String dialogDeleteTagTitle(String tag) {
    return 'Tag \'$tag\' löschen?';
  }

  @override
  String get dialogDeleteTagContent =>
      'Dieser Tag wird aus der Auswahl entfernt.';

  @override
  String dialogEditTagTitle(String tag) {
    return 'Optionen für \'$tag\'';
  }

  @override
  String get statsYearly => 'Jahres-Verlauf';

  @override
  String get statsNoData => 'Noch keine Daten.';

  @override
  String get statsPatternDay => 'Muster nach Wochentag';

  @override
  String get statsInsights => 'Einflussfaktoren';

  @override
  String get statsAiIntro => 'Lass deine Woche von der KI analysieren.';

  @override
  String get statsAiButton => 'Woche analysieren';

  @override
  String get statsAiButtonUpdate => 'Analyse aktualisieren';

  @override
  String get statsTrendTitle => 'Trend für morgen';

  @override
  String get statsTrendGood => 'Gute Aussichten! ☀️';

  @override
  String get statsTrendNormal => 'Solider Tag erwartet 🌱';

  @override
  String get statsTrendBad => 'Achtsam bleiben 💜';

  @override
  String get categorySocial => 'Soziales';

  @override
  String get categoryBodyMind => 'Körper & Geist';

  @override
  String get categoryObligations => 'Pflichten';

  @override
  String get categoryLeisure => 'Freizeit & Umwelt';

  @override
  String get categoryCycle => 'Zyklus & Körper';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get tagFamily => 'Familie';

  @override
  String get tagRelationship => 'Beziehung';

  @override
  String get tagFriends => 'Freunde';

  @override
  String get tagParty => 'Party';

  @override
  String get tagSport => 'Sport';

  @override
  String get tagSleep => 'Schlaf';

  @override
  String get tagFood => 'Essen';

  @override
  String get tagHealth => 'Gesundheit';

  @override
  String get tagMeditation => 'Meditation';

  @override
  String get tagWork => 'Arbeit';

  @override
  String get tagSchool => 'Schule';

  @override
  String get tagHomework => 'Hausaufgaben';

  @override
  String get tagUni => 'Uni';

  @override
  String get tagHousehold => 'Haushalt';

  @override
  String get tagHobby => 'Hobby';

  @override
  String get tagTravel => 'Reisen';

  @override
  String get tagWeather => 'Wetter';

  @override
  String get tagGaming => 'Gaming';

  @override
  String get tagReading => 'Lesen';

  @override
  String get tagMusic => 'Musik';

  @override
  String get tagPeriodLight => 'Periode (Leicht)';

  @override
  String get tagPeriodMedium => 'Periode (Mittel)';

  @override
  String get tagPeriodHeavy => 'Periode (Stark)';

  @override
  String get tagSpotting => 'Schmierblutung';

  @override
  String get tagCramps => 'Regelschmerzen';

  @override
  String get tagPMS => 'PMS';

  @override
  String get tagOvulation => 'Eisprung';

  @override
  String get unknownProfile => 'Unbekannt';

  @override
  String get btnSelect => 'AUSWÄHLEN';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get premiumTeaserTitle => 'Mehrere Profile';

  @override
  String get premiumTeaserMessage =>
      'In der Free-Version hast du ein Profil.\nMöchtest du Profile für Partner, Kinder oder Haustiere anlegen?';

  @override
  String get snackSaved => 'Gespeichert';

  @override
  String get snackDeleted => 'Gelöscht';

  @override
  String get snackTagDeleted => 'Tag gelöscht';

  @override
  String snackError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get dialogNewTagName => 'Neuer Name';

  @override
  String get dialogNewTagPlaceholder => 'Name (z.B. Yoga)';

  @override
  String get labelCategory => 'Kategorie';

  @override
  String get labelDescription => 'Bezeichnung';

  @override
  String predTextGood(String day, String score) {
    return 'Morgen ist $day. Deine Daten und das Umfeld deuten auf einen starken Tag hin (Ø $score).';
  }

  @override
  String predTextBad(String day, String score) {
    return 'Für $day sagen die Daten etwas weniger Energie voraus (Ø $score).';
  }

  @override
  String predTextNormal(String day, String score) {
    return 'Die Prognose für $day ist ausgeglichen (Ø $score).';
  }

  @override
  String get tipSleep => 'Tipp: Geh heute früher schlafen.';

  @override
  String get tipFamilyBad => 'Die Stimmung im Haus war zuletzt angespannt.';

  @override
  String get tipFamilyGood =>
      'Positive Vibes im Haushalt geben dir Rückenwind!';

  @override
  String get authLoginTitle => 'Willkommen zurück';

  @override
  String get authRegisterTitle => 'Neuen Account erstellen';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authLoginButton => 'Login';

  @override
  String get authRegisterButton => 'Registrieren';

  @override
  String get authHaveAccount => 'Ich habe schon einen Account';

  @override
  String get authNoAccount => 'Registrieren';

  @override
  String get authLoading => 'Lade...';

  @override
  String authError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get authSuccessVerify => 'Bitte bestätige deine E-Mail!';

  @override
  String get legal => 'Rechtliches';

  @override
  String get imprint => 'Impressum';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get tutorialMoodTitle => 'Deine Stimmung';

  @override
  String get tutorialMoodDesc =>
      'Bewege den Slider, um festzuhalten, wie du dich fühlst.';

  @override
  String get tutorialSaveTitle => 'Speichern';

  @override
  String get tutorialSaveDesc =>
      'Tippe hier, um deinen Eintrag in das Tagebuch zu schreiben.';

  @override
  String get tutorialStatsTitle => 'Deine Erkenntnisse';

  @override
  String get tutorialStatsDesc =>
      'Hier siehst du Charts und Muster zu deiner Stimmung.';

  @override
  String get tutorialProfileTitle => 'Dein Profil';

  @override
  String get tutorialProfileDesc =>
      'Verwalte hier deine Daten, Einstellungen und Export-Funktionen.';

  @override
  String get tutorialStart => 'Tutorial starten';

  @override
  String get exportPdf => 'Report erstellen (PDF)';

  @override
  String get predCycleRest => 'Dein Zyklus fordert vielleicht etwas Ruhe.';

  @override
  String get predCyclePower => 'Dein Zyklus gibt dir extra Power!';

  @override
  String get predSentimentStress => 'Deine Notizen wirkten zuletzt gestresst.';

  @override
  String get predSleepTip => 'Tipp: Geh heute früher schlafen.';

  @override
  String get aiCalibration => 'AI Kalibrierung...';

  @override
  String aiCalibrationText(int missing) {
    return 'Deine Smart Forecast wird eingerichtet. Wir benötigen noch $missing Einträge.';
  }

  @override
  String aiEntriesCount(int count, int target) {
    return '$count / $target Einträge';
  }

  @override
  String get lockedPredTitle => 'Wie wird dein Tag morgen?';

  @override
  String get lockedPredDesc =>
      'Basierend auf deinem Schlaf, Trend und Wochentag.';

  @override
  String get lockedAiTitle => 'Tiefenanalyse deiner Woche';

  @override
  String get errorNoEntries7Days =>
      'Keine Einträge in den letzten 7 Tagen gefunden.';

  @override
  String errorAnalysisFailed(Object code) {
    return 'Fehler bei der Analyse: $code';
  }

  @override
  String get sentimentNegativeWords =>
      'Stress,Streit,Krank,Schmerz,Müde,Angst,Traurig,Schlecht';

  @override
  String get sentimentPositiveWords =>
      'Urlaub,Liebe,Erfolg,Sport,Glücklich,Super,Entspannt,Party';

  @override
  String get statsAiCoachTitle => 'AI Wochen-Coach';

  @override
  String labelDataFor(String name) {
    return 'Daten für $name:';
  }

  @override
  String get labelNote => 'Notiz';

  @override
  String get exportPdfButton => 'Report erstellen (PDF)';

  @override
  String get pdfTitle => 'LuvioSphere Report';

  @override
  String pdfProfile(String name) {
    return 'Profil: $name';
  }

  @override
  String get pdfPeriod => 'Zeitraum: Letzte 30 Tage';

  @override
  String get pdfAvgMood => 'Ø Stimmung';

  @override
  String get pdfAvgSleep => 'Ø Schlaf';

  @override
  String get pdfEntriesCount => 'Einträge';

  @override
  String get pdfHeaderDate => 'Datum';

  @override
  String get pdfHeaderTime => 'Zeit';

  @override
  String get pdfHeaderMood => 'Mood';

  @override
  String get pdfHeaderSleep => 'Schlaf';

  @override
  String get pdfHeaderTags => 'Tags';

  @override
  String get pdfHeaderNote => 'Notiz';

  @override
  String get pdfFooter => 'Erstellt mit LuvioSphere';

  @override
  String get predWeatherGood => 'Die Sonne morgen gibt dir Energie!';

  @override
  String get predWeatherBad => 'Regen angesagt – mach es dir gemütlich.';

  @override
  String get partnerTitle => 'Partner Connect ❤️';

  @override
  String get partnerDesc =>
      'Verbinde dich mit deinem Partner, um zu sehen, wie es ihm geht.';

  @override
  String get partnerEmailLabel => 'E-Mail deines Partners';

  @override
  String get partnerConnectBtn => 'Verbinden';

  @override
  String partnerConnected(String name) {
    return 'Verbunden mit $name';
  }

  @override
  String partnerStatus(String score) {
    return 'Aktuelle Stimmung: $score';
  }

  @override
  String partnerNeedsLove(String name) {
    return '⚠️ $name hat einen schweren Tag. Schick etwas Liebe!';
  }

  @override
  String get partnerWait => 'Warte auf Rückbestätigung...';

  @override
  String get partnerDisconnectTitle => 'Verbindung trennen?';

  @override
  String partnerDisconnectMessage(String partnerEmail) {
    return 'Möchtest du die Verbindung zu $partnerEmail wirklich aufheben?';
  }

  @override
  String get partnerDisconnectConfirm => 'Ja, trennen';

  @override
  String get partnerDisconnectCancel => 'Abbrechen';

  @override
  String get partnerDisconnectSuccess => 'Verbindung aufgehoben.';

  @override
  String get partnerDisconnectTooltip => 'Verbindung trennen';

  @override
  String get tagAlcohol => 'Alkohol';

  @override
  String get tagFastFood => 'Fast Food';

  @override
  String get tagScreenTime => 'Viel Handy';

  @override
  String get tagWater => 'Wenig Wasser';

  @override
  String get tagNature => 'Natur';

  @override
  String get tagSauna => 'Sauna/Wellness';

  @override
  String get tagHealthyFood => 'Gesund gegessen';

  @override
  String get tagSex => 'Intimität';

  @override
  String get tagStress => 'Stress';

  @override
  String get predSeasonTip => 'Licht tanken hilft!';

  @override
  String get predPersonalized => 'Basierend auf deinen Mustern.';

  @override
  String get labelFactors => 'Einflussfaktoren';

  @override
  String get labelAiVersion => 'AI 2.0';

  @override
  String get deleteAccountTitle => 'Konto löschen?';

  @override
  String get deleteAccountContent =>
      'Bist du sicher? Alle deine Daten (Einträge, Tags, Profil) werden unwiderruflich gelöscht.';

  @override
  String get deleteAccountBtn => 'Konto endgültig löschen';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authResetSuccess => 'Link gesendet! Prüfe deine E-Mails.';

  @override
  String get authEnterEmail => 'Bitte gib deine E-Mail-Adresse ein.';

  @override
  String get inputDateLabel => 'Datum';

  @override
  String inputCycleDay(int day) {
    return 'Tag $day';
  }

  @override
  String get btnAddEntry => 'Weiteren Eintrag (+)';

  @override
  String get proDialogTitle => 'Pro-Feature';

  @override
  String get proDialogDesc =>
      'Dieses Feature ist exklusiv für Pro-Nutzer. Möchtest du upgraden?';

  @override
  String get btnShop => 'ZUM SHOP';

  @override
  String get partnerLabelConnected => 'Verbunden mit:';

  @override
  String get partnerLabelMyEmail => 'Deine E-Mail (Automatisch)';

  @override
  String get partnerHintEmail => 'z.B. partner@example.com';

  @override
  String get partnerTitleLocked => 'Partner Connect';

  @override
  String get partnerDescLocked =>
      'Verbinde dich für mehr Verständnis & Harmonie.';

  @override
  String get adviceSick =>
      'Partner ist krank. Tee, Suppe oder Medikamente wären lieb!';

  @override
  String get adviceCycle =>
      'Vorsicht: Zyklus-Beschwerden. Wärmflasche & Schokolade bereitstellen!';

  @override
  String get adviceStress =>
      'Hohes Stresslevel. Nimm dem Partner heute vielleicht eine Pflicht ab.';

  @override
  String get adviceSleep =>
      'Massiver Schlafmangel. Sorge für einen ruhigen Abend.';

  @override
  String get adviceSad =>
      'Stimmung ist im Keller. Eine Umarmung oder Zuhören hilft oft mehr als Lösungen.';

  @override
  String get adviceHappy =>
      'Super Stimmung! Perfekter Zeitpunkt für gemeinsame Unternehmungen.';

  @override
  String get lockedInsightsTitle => 'Schalte Premium-Insights frei';

  @override
  String get lockedInsightsDesc =>
      'Erfahre genau, was deine Stimmung beeinflusst. Unsere KI analysiert deine Muster.';

  @override
  String get btnUnlock => 'Jetzt Pro werden';

  @override
  String get insightTrackMore => 'Tracke mehr Tags, um Muster zu erkennen.';

  @override
  String get insightBasdOnPattern => 'Basierend auf deinen Mustern.';

  @override
  String get patternTitle => 'Muster erkannt 💡';

  @override
  String patternDrop(String tag, String delta) {
    return 'Immer wenn du \'$tag\' trackst, sinkt deine Stimmung am nächsten Tag um durchschnittlich $delta Punkte.';
  }

  @override
  String patternCycle(String tag1, String tag2) {
    return 'Oft folgt auf \'$tag1\' am nächsten Tag \'$tag2\'.';
  }

  @override
  String patternCount(int count) {
    return '(Basiert auf $count Ereignissen)';
  }

  @override
  String get me => 'Ich';
}

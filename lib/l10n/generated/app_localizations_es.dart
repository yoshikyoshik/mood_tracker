// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LuvioSphere';

  @override
  String get today => 'Hoy';

  @override
  String get moodEntry => 'Entrada';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get profile => 'Perfil';

  @override
  String get newProfile => 'Nuevo...';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String streakMessage(int count) {
    return '¡Racha de $count días! ¡Sigue así! 🔥';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get becomePro => 'Hazte Pro';

  @override
  String get manageSub => 'Gestionar suscripción';

  @override
  String get contactSupport => 'Contactar soporte';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get version => 'Versión';

  @override
  String get proMember => 'MIEMBRO PRO';

  @override
  String get freeUser => 'USUARIO GRATUITO';

  @override
  String get achievements => 'Tus logros';

  @override
  String get badgeStart => 'El comienzo';

  @override
  String get badgeStartDesc => 'Tu primera entrada.';

  @override
  String get badgeStreak => 'Constante';

  @override
  String get badgeStreakDesc => 'Registrado en 7 días diferentes.';

  @override
  String get badgeWeekend => 'Héroe de fin de semana';

  @override
  String get badgeWeekendDesc => '10 entradas en fines de semana.';

  @override
  String get badgeVeteran => 'Veterano';

  @override
  String get badgeVeteranDesc => '100 entradas en total.';

  @override
  String get badgeNightOwl => 'Noctámbulo';

  @override
  String get badgeNightOwlDesc => '20 entradas tarde en la noche.';

  @override
  String get badgeSleep => 'Guardián del sueño';

  @override
  String get badgeSleepDesc => 'Sueño registrado 30 veces.';

  @override
  String get badgeJournal => 'Periodista';

  @override
  String get badgeJournalDesc => '50 notas detalladas escritas.';

  @override
  String get badgeContext => 'Pro del contexto';

  @override
  String get badgeContextDesc => '20 entradas con muchas etiquetas.';

  @override
  String get badgeOptimist => 'Optimista';

  @override
  String get badgeOptimistDesc => '50x estado de ánimo muy bueno (8+).';

  @override
  String get inputHowAreYou => '¿Cómo estás?';

  @override
  String get inputSleep => 'Registrar sueño';

  @override
  String get inputNoteHint => 'Añadir nota...';

  @override
  String get inputNoTags => 'Sin etiquetas';

  @override
  String get inputAddTag => 'Añadir etiqueta';

  @override
  String get inputEdit => 'Editar etiqueta';

  @override
  String get statsAnalysis => 'Analizar semana';

  @override
  String get statsAnalysisWait => 'Analizando...';

  @override
  String get statsAnalysisError => 'Error de análisis';

  @override
  String get statsChartTitle => 'Ánimo y Sueño';

  @override
  String get statsMood => 'Ánimo';

  @override
  String get statsSleep => 'Sueño';

  @override
  String get inputMoodTerrible => 'Terrible';

  @override
  String get inputMoodBad => 'Mal';

  @override
  String get inputMoodOkay => 'Regular';

  @override
  String get inputMoodGood => 'Bien';

  @override
  String get inputMoodFantastic => 'Fantástico';

  @override
  String get dialogNewProfileTitle => 'Crear nuevo perfil';

  @override
  String get dialogEditProfileTitle => 'Editar perfil';

  @override
  String get dialogNameLabel => 'Nombre';

  @override
  String get dialogCycleTracking => 'Seguimiento del ciclo';

  @override
  String get dialogCycleDesc => 'Calcula los días del ciclo';

  @override
  String get dialogPeriodStart => 'Inicio del último periodo';

  @override
  String get dialogSelectDate => 'Seleccionar fecha';

  @override
  String get dialogAdd => 'Añadir';

  @override
  String get dialogMoveCategory => 'Mover categoría';

  @override
  String get dialogRenameTag => 'Renombrar etiqueta';

  @override
  String dialogDeleteTagTitle(String tag) {
    return '¿Eliminar etiqueta \'$tag\'?';
  }

  @override
  String get dialogDeleteTagContent =>
      'Esta etiqueta se eliminará de la selección.';

  @override
  String dialogEditTagTitle(String tag) {
    return 'Opciones para \'$tag\'';
  }

  @override
  String get statsYearly => 'Resumen anual';

  @override
  String get statsNoData => 'Aún no hay datos.';

  @override
  String get statsPatternDay => 'Patrones por día';

  @override
  String get statsInsights => 'Factores influyentes';

  @override
  String get statsAiIntro => 'Deja que la IA analice tu semana.';

  @override
  String get statsAiButton => 'Analizar semana';

  @override
  String get statsAiButtonUpdate => 'Actualizar análisis';

  @override
  String get statsTrendTitle => 'Pronóstico para mañana';

  @override
  String get statsTrendGood => '¡Buen panorama! ☀️';

  @override
  String get statsTrendNormal => 'Día sólido por delante 🌱';

  @override
  String get statsTrendBad => 'Sé consciente 💜';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryBodyMind => 'Cuerpo y Mente';

  @override
  String get categoryObligations => 'Obligaciones';

  @override
  String get categoryLeisure => 'Ocio y Entorno';

  @override
  String get categoryCycle => 'Ciclo y Cuerpo';

  @override
  String get categoryOther => 'Otros';

  @override
  String get tagFamily => 'Familia';

  @override
  String get tagRelationship => 'Pareja';

  @override
  String get tagFriends => 'Amigos';

  @override
  String get tagParty => 'Fiesta';

  @override
  String get tagSport => 'Deporte';

  @override
  String get tagSleep => 'Sueño';

  @override
  String get tagFood => 'Comida';

  @override
  String get tagHealth => 'Salud';

  @override
  String get tagMeditation => 'Meditación';

  @override
  String get tagWork => 'Trabajo';

  @override
  String get tagSchool => 'Escuela';

  @override
  String get tagHomework => 'Tareas';

  @override
  String get tagUni => 'Uni';

  @override
  String get tagHousehold => 'Hogar';

  @override
  String get tagHobby => 'Hobby';

  @override
  String get tagTravel => 'Viajes';

  @override
  String get tagWeather => 'Clima';

  @override
  String get tagGaming => 'Gaming';

  @override
  String get tagReading => 'Lectura';

  @override
  String get tagMusic => 'Música';

  @override
  String get tagPeriodLight => 'Periodo (Leve)';

  @override
  String get tagPeriodMedium => 'Periodo (Medio)';

  @override
  String get tagPeriodHeavy => 'Periodo (Fuerte)';

  @override
  String get tagSpotting => 'Manchado';

  @override
  String get tagCramps => 'Cólicos';

  @override
  String get tagPMS => 'SPM';

  @override
  String get tagOvulation => 'Ovulación';

  @override
  String get unknownProfile => 'Desconocido';

  @override
  String get btnSelect => 'SELECCIONAR';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get premiumTeaserTitle => 'Varios perfiles';

  @override
  String get premiumTeaserMessage =>
      'En la versión gratuita tienes un perfil.\n¿Quieres añadir perfiles para tu pareja, hijos o mascotas?';

  @override
  String get snackSaved => 'Guardado';

  @override
  String get snackDeleted => 'Eliminado';

  @override
  String get snackTagDeleted => 'Etiqueta eliminada';

  @override
  String snackError(String error) {
    return 'Error: $error';
  }

  @override
  String get dialogNewTagName => 'Nuevo nombre';

  @override
  String get dialogNewTagPlaceholder => 'Nombre (ej. Yoga)';

  @override
  String get labelCategory => 'Categoría';

  @override
  String get labelDescription => 'Descripción';

  @override
  String predTextGood(String day, String score) {
    return 'Mañana es $day. Tus datos y entorno sugieren un día fuerte por delante (Ø $score).';
  }

  @override
  String predTextBad(String day, String score) {
    return 'Para el $day, los datos predicen niveles de energía un poco más bajos (Ø $score).';
  }

  @override
  String predTextNormal(String day, String score) {
    return 'El pronóstico para el $day es equilibrado (Ø $score).';
  }

  @override
  String get tipSleep => 'Consejo: Ve a dormir más temprano hoy.';

  @override
  String get tipFamilyBad => 'El ambiente en casa ha estado tenso últimamente.';

  @override
  String get tipFamilyGood => '¡El buen ambiente en casa te da impulso!';

  @override
  String get authLoginTitle => 'Bienvenido de nuevo';

  @override
  String get authRegisterTitle => 'Crear cuenta nueva';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authLoginButton => 'Iniciar sesión';

  @override
  String get authRegisterButton => 'Registrarse';

  @override
  String get authHaveAccount => 'Ya tengo una cuenta';

  @override
  String get authNoAccount => 'Registrarse';

  @override
  String get authLoading => 'Cargando...';

  @override
  String authError(String message) {
    return 'Error: $message';
  }

  @override
  String get authSuccessVerify => '¡Por favor verifica tu correo!';

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

  @override
  String get tutorialStart => 'Start Tutorial';

  @override
  String get exportPdf => 'Create Report (PDF)';

  @override
  String get predCycleRest => 'Your cycle might demand some rest.';

  @override
  String get predCyclePower => 'Your cycle gives you extra power!';

  @override
  String get predSentimentStress => 'Your notes seemed stressed lately.';

  @override
  String get predSleepTip => 'Tip: Go to sleep earlier today.';

  @override
  String get aiCalibration => 'AI Calibration...';

  @override
  String aiCalibrationText(int missing) {
    return 'Setting up your Smart Forecast. We need $missing more entries.';
  }

  @override
  String aiEntriesCount(int count, int target) {
    return '$count / $target entries';
  }

  @override
  String get lockedPredTitle => 'How will your day be tomorrow?';

  @override
  String get lockedPredDesc => 'Based on your sleep, trend, and weekday.';

  @override
  String get lockedAiTitle => 'Deep analysis of your week';

  @override
  String get errorNoEntries7Days => 'No entries found in the last 7 days.';

  @override
  String errorAnalysisFailed(Object code) {
    return 'Analysis failed: $code';
  }

  @override
  String get sentimentNegativeWords =>
      'Stress,Fight,Sick,Pain,Tired,Anxiety,Sad,Bad';

  @override
  String get sentimentPositiveWords =>
      'Vacation,Love,Success,Sport,Happy,Great,Relaxed,Party';
}

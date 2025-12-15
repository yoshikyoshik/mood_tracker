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
  String get imprint => 'Aviso legal';

  @override
  String get privacy => 'Política de privacidad';

  @override
  String get tutorialMoodTitle => 'Tu estado de ánimo';

  @override
  String get tutorialMoodDesc =>
      'Mueve el control deslizante para capturar cómo te sientes ahora.';

  @override
  String get tutorialSaveTitle => 'Guardar entrada';

  @override
  String get tutorialSaveDesc =>
      'Toca aquí para escribir tu entrada en el diario.';

  @override
  String get tutorialStatsTitle => 'Tus estadísticas';

  @override
  String get tutorialStatsDesc =>
      'Descubre gráficos y patrones sobre tu estado de ánimo aquí.';

  @override
  String get tutorialProfileTitle => 'Tu perfil';

  @override
  String get tutorialProfileDesc =>
      'Gestiona tus datos, ajustes y exportaciones aquí.';

  @override
  String get tutorialStart => 'Iniciar tutorial';

  @override
  String get exportPdf => 'Crear informe (PDF)';

  @override
  String get predCycleRest => 'Tu ciclo podría requerir algo de descanso.';

  @override
  String get predCyclePower => '¡Tu ciclo te da energía extra!';

  @override
  String get predSentimentStress => 'Tus notas parecen estresadas últimamente.';

  @override
  String get predSleepTip => 'Consejo: Ve a dormir más temprano hoy.';

  @override
  String get aiCalibration => 'Calibración de IA...';

  @override
  String aiCalibrationText(int missing) {
    return 'Configurando tu Pronóstico Inteligente. Necesitamos $missing entradas más.';
  }

  @override
  String aiEntriesCount(int count, int target) {
    return '$count / $target entradas';
  }

  @override
  String get lockedPredTitle => '¿Cómo será tu día mañana?';

  @override
  String get lockedPredDesc =>
      'Basado en tu sueño, tendencia y día de la semana.';

  @override
  String get lockedAiTitle => 'Análisis profundo de tu semana';

  @override
  String get errorNoEntries7Days =>
      'No se encontraron entradas en los últimos 7 días.';

  @override
  String errorAnalysisFailed(Object code) {
    return 'Falló el análisis: $code';
  }

  @override
  String get sentimentNegativeWords =>
      'Estrés,Pelea,Enfermo,Dolor,Cansado,Ansiedad,Triste,Mal';

  @override
  String get sentimentPositiveWords =>
      'Vacaciones,Amor,Éxito,Deporte,Feliz,Genial,Relajado,Fiesta';

  @override
  String get statsAiCoachTitle => 'Coach Semanal IA';

  @override
  String labelDataFor(String name) {
    return 'Datos para $name:';
  }

  @override
  String get labelNote => 'Nota';

  @override
  String get exportPdfButton => 'Crear informe (PDF)';

  @override
  String get pdfTitle => 'Informe LuvioSphere';

  @override
  String pdfProfile(String name) {
    return 'Perfil: $name';
  }

  @override
  String get pdfPeriod => 'Periodo: Últimos 30 días';

  @override
  String get pdfAvgMood => 'Ø Ánimo';

  @override
  String get pdfAvgSleep => 'Ø Sueño';

  @override
  String get pdfEntriesCount => 'Entradas';

  @override
  String get pdfHeaderDate => 'Fecha';

  @override
  String get pdfHeaderTime => 'Hora';

  @override
  String get pdfHeaderMood => 'Ánimo';

  @override
  String get pdfHeaderSleep => 'Sueño';

  @override
  String get pdfHeaderTags => 'Etiquetas';

  @override
  String get pdfHeaderNote => 'Nota';

  @override
  String get pdfFooter => 'Creado con LuvioSphere';

  @override
  String get predWeatherGood => '¡El sol de mañana aumenta tu energía!';

  @override
  String get predWeatherBad => 'Pronóstico de lluvia: ponte cómodo.';

  @override
  String get partnerTitle => 'Conexión en pareja ❤️';

  @override
  String get partnerDesc =>
      'Conéctate con tu pareja para ver su estado de ánimo.';

  @override
  String get partnerEmailLabel => 'Email de tu pareja';

  @override
  String get partnerConnectBtn => 'Conectar';

  @override
  String partnerConnected(String name) {
    return 'Conectado con $name';
  }

  @override
  String partnerStatus(String score) {
    return 'Ánimo actual: $score';
  }

  @override
  String partnerNeedsLove(String name) {
    return '⚠️ $name tiene un día difícil. ¡Envíale amor!';
  }

  @override
  String get partnerWait => 'Esperando confirmación...';

  @override
  String get partnerDisconnectTitle => '¿Desconectar pareja?';

  @override
  String partnerDisconnectMessage(String partnerEmail) {
    return '¿Realmente quieres desconectarte de $partnerEmail?';
  }

  @override
  String get partnerDisconnectConfirm => 'Sí, desconectar';

  @override
  String get partnerDisconnectCancel => 'Cancelar';

  @override
  String get partnerDisconnectSuccess => 'Conexión eliminada.';

  @override
  String get partnerDisconnectTooltip => 'Desconectar pareja';

  @override
  String get tagAlcohol => 'Alcohol';

  @override
  String get tagFastFood => 'Fast Food';

  @override
  String get tagScreenTime => 'High Screen Time';

  @override
  String get tagWater => 'Little Water';

  @override
  String get tagNature => 'Nature';

  @override
  String get tagSauna => 'Sauna/Wellness';

  @override
  String get tagHealthyFood => 'Healthy Food';

  @override
  String get tagSex => 'Intimacy';

  @override
  String get tagStress => 'Stress';

  @override
  String get predSeasonTip => 'Soaking up light helps!';

  @override
  String get predPersonalized => 'Based on your patterns.';

  @override
  String get labelFactors => 'Factors';

  @override
  String get labelAiVersion => 'AI 2.0';

  @override
  String get deleteAccountTitle => 'Delete Account?';

  @override
  String get deleteAccountContent =>
      'Are you sure? All your data (entries, tags, profile) will be permanently deleted.';

  @override
  String get deleteAccountBtn => 'Delete account permanently';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetSuccess => 'Link sent! Check your emails.';

  @override
  String get authEnterEmail => 'Please enter your email address.';
}

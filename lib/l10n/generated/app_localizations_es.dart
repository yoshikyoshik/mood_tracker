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
}

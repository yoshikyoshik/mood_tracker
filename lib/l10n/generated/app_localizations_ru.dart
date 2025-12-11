// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'LuvioSphere';

  @override
  String get today => 'Сегодня';

  @override
  String get moodEntry => 'Запись';

  @override
  String get statistics => 'Статистика';

  @override
  String get profile => 'Профиль';

  @override
  String get newProfile => 'Новый...';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String streakMessage(int count) {
    return '$count дн. подряд! Так держать! 🔥';
  }
}

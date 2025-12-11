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
  String get edit => 'Изменить';

  @override
  String streakMessage(int count) {
    return 'Серия: $count дн.! Так держать! 🔥';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get becomePro => 'Стать Pro';

  @override
  String get manageSub => 'Управление подпиской';

  @override
  String get contactSupport => 'Написать в поддержку';

  @override
  String get logout => 'Выйти';

  @override
  String get version => 'Версия';

  @override
  String get proMember => 'PRO АККАУНТ';

  @override
  String get freeUser => 'БЕСПЛАТНЫЙ АККАУНТ';

  @override
  String get achievements => 'Твои достижения';

  @override
  String get badgeStart => 'Начало';

  @override
  String get badgeStartDesc => 'Твоя первая запись.';

  @override
  String get badgeStreak => 'Постоянство';

  @override
  String get badgeStreakDesc => 'Записи в 7 разных дней.';

  @override
  String get badgeWeekend => 'Герой выходных';

  @override
  String get badgeWeekendDesc => '10 записей в выходные.';

  @override
  String get badgeVeteran => 'Ветеран';

  @override
  String get badgeVeteranDesc => 'Всего 100 записей.';

  @override
  String get badgeNightOwl => 'Сова';

  @override
  String get badgeNightOwlDesc => '20 записей поздно ночью.';

  @override
  String get badgeSleep => 'Хранитель сна';

  @override
  String get badgeSleepDesc => 'Сон записан 30 раз.';

  @override
  String get badgeJournal => 'Журналист';

  @override
  String get badgeJournalDesc => '50 подробных заметок.';

  @override
  String get badgeContext => 'Профи контекста';

  @override
  String get badgeContextDesc => '20 записей с множеством тегов.';

  @override
  String get badgeOptimist => 'Оптимист';

  @override
  String get badgeOptimistDesc => '50x отл. настроение (8+).';

  @override
  String get inputHowAreYou => 'Как ты?';

  @override
  String get inputSleep => 'Записать сон';

  @override
  String get inputNoteHint => 'Добавить заметку...';

  @override
  String get inputNoTags => 'Теги не выбраны';

  @override
  String get inputAddTag => 'Добавить тег';

  @override
  String get inputEdit => 'Изменить тег';

  @override
  String get statsAnalysis => 'Анализ недели';

  @override
  String get statsAnalysisWait => 'Анализирую...';

  @override
  String get statsAnalysisError => 'Ошибка анализа';

  @override
  String get statsChartTitle => 'Настроение и сон';

  @override
  String get statsMood => 'Настроение';

  @override
  String get statsSleep => 'Сон';

  @override
  String get inputMoodTerrible => 'Ужасно';

  @override
  String get inputMoodBad => 'Плохо';

  @override
  String get inputMoodOkay => 'Нормально';

  @override
  String get inputMoodGood => 'Хорошо';

  @override
  String get inputMoodFantastic => 'Отлично';

  @override
  String get dialogNewProfileTitle => 'Создать профиль';

  @override
  String get dialogEditProfileTitle => 'Редактировать профиль';

  @override
  String get dialogNameLabel => 'Имя';

  @override
  String get dialogCycleTracking => 'Отслеживать цикл';

  @override
  String get dialogCycleDesc => 'Считает дни цикла';

  @override
  String get dialogPeriodStart => 'Начало последних месячных';

  @override
  String get dialogSelectDate => 'Выбрать дату';

  @override
  String get dialogAdd => 'Добавить';

  @override
  String get dialogMoveCategory => 'Переместить категорию';

  @override
  String get dialogRenameTag => 'Переименовать тег';

  @override
  String dialogDeleteTagTitle(String tag) {
    return 'Удалить тег \'$tag\'?';
  }

  @override
  String get dialogDeleteTagContent => 'Этот тег будет убран из выбранного.';

  @override
  String dialogEditTagTitle(String tag) {
    return 'Опции для \'$tag\'';
  }

  @override
  String get statsYearly => 'Обзор года';

  @override
  String get statsNoData => 'Нет данных.';

  @override
  String get statsPatternDay => 'Паттерны по дням';

  @override
  String get statsInsights => 'Влияющие факторы';

  @override
  String get statsAiIntro => 'Пусть ИИ проанализирует неделю.';

  @override
  String get statsAiButton => 'Анализ недели';

  @override
  String get statsAiButtonUpdate => 'Обновить анализ';

  @override
  String get statsTrendTitle => 'Прогноз на завтра';

  @override
  String get statsTrendGood => 'Хороший прогноз! ☀️';

  @override
  String get statsTrendNormal => 'Стабильный день 🌱';

  @override
  String get statsTrendBad => 'Будь внимательнее 💜';

  @override
  String get categorySocial => 'Общение';

  @override
  String get categoryBodyMind => 'Тело и разум';

  @override
  String get categoryObligations => 'Обязанности';

  @override
  String get categoryLeisure => 'Досуг и среда';

  @override
  String get categoryCycle => 'Цикл и тело';

  @override
  String get categoryOther => 'Другое';

  @override
  String get tagFamily => 'Семья';

  @override
  String get tagRelationship => 'Отношения';

  @override
  String get tagFriends => 'Друзья';

  @override
  String get tagParty => 'Вечеринка';

  @override
  String get tagSport => 'Спорт';

  @override
  String get tagSleep => 'Сон';

  @override
  String get tagFood => 'Еда';

  @override
  String get tagHealth => 'Здоровье';

  @override
  String get tagMeditation => 'Медитация';

  @override
  String get tagWork => 'Работа';

  @override
  String get tagSchool => 'Школа';

  @override
  String get tagHomework => 'Дом. задание';

  @override
  String get tagUni => 'Универ';

  @override
  String get tagHousehold => 'Быт';

  @override
  String get tagHobby => 'Хобби';

  @override
  String get tagTravel => 'Путешествия';

  @override
  String get tagWeather => 'Погода';

  @override
  String get tagGaming => 'Игры';

  @override
  String get tagReading => 'Чтение';

  @override
  String get tagMusic => 'Музыка';

  @override
  String get tagPeriodLight => 'Месячные (Скудные)';

  @override
  String get tagPeriodMedium => 'Месячные (Умеренные)';

  @override
  String get tagPeriodHeavy => 'Месячные (Обильные)';

  @override
  String get tagSpotting => 'Мажущие';

  @override
  String get tagCramps => 'Спазмы';

  @override
  String get tagPMS => 'ПМС';

  @override
  String get tagOvulation => 'Овуляция';

  @override
  String get unknownProfile => 'Неизвестно';

  @override
  String get btnSelect => 'ВЫБРАТЬ';

  @override
  String get maybeLater => 'Может позже';

  @override
  String get premiumTeaserTitle => 'Несколько профилей';

  @override
  String get premiumTeaserMessage =>
      'В бесплатной версии у тебя один профиль.\nХочешь добавить профили для партнера, детей или питомцев?';

  @override
  String get snackSaved => 'Сохранено';

  @override
  String get snackDeleted => 'Удалено';

  @override
  String get snackTagDeleted => 'Тег удален';

  @override
  String snackError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get dialogNewTagName => 'Новое имя';

  @override
  String get dialogNewTagPlaceholder => 'Имя (напр. Йога)';

  @override
  String get labelCategory => 'Категория';

  @override
  String get labelDescription => 'Описание';

  @override
  String predTextGood(String day, String score) {
    return 'Завтра $day. Данные и среда обещают сильный день (Ø $score).';
  }

  @override
  String predTextBad(String day, String score) {
    return 'На $day прогноз показывает уровень энергии чуть ниже (Ø $score).';
  }

  @override
  String predTextNormal(String day, String score) {
    return 'Прогноз на $day сбалансированный (Ø $score).';
  }

  @override
  String get tipSleep => 'Совет: Ляг спать пораньше сегодня.';

  @override
  String get tipFamilyBad => 'Дома было напряженно в последнее время.';

  @override
  String get tipFamilyGood => 'Позитив дома придает тебе сил!';

  @override
  String get authLoginTitle => 'С возвращением';

  @override
  String get authRegisterTitle => 'Создать аккаунт';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authRegisterButton => 'Регистрация';

  @override
  String get authHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get authNoAccount => 'Регистрация';

  @override
  String get authLoading => 'Загрузка...';

  @override
  String authError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get authSuccessVerify => 'Пожалуйста, подтверди email!';

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

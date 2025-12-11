// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LuvioSphere';

  @override
  String get today => '今天';

  @override
  String get moodEntry => '条目';

  @override
  String get statistics => '统计';

  @override
  String get profile => '个人资料';

  @override
  String get newProfile => '新...';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String streakMessage(int count) {
    return '连续 $count 天！继续加油！🔥';
  }
}

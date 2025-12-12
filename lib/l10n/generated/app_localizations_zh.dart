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
  String get moodEntry => '记录';

  @override
  String get statistics => '统计';

  @override
  String get profile => '档案';

  @override
  String get newProfile => '新建...';

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
    return '连续打卡 $count 天！继续保持！🔥';
  }

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get becomePro => '成为 Pro 会员';

  @override
  String get manageSub => '管理订阅';

  @override
  String get contactSupport => '联系客服';

  @override
  String get logout => '退出登录';

  @override
  String get version => '版本';

  @override
  String get proMember => 'PRO 会员';

  @override
  String get freeUser => '免费用户';

  @override
  String get achievements => '你的成就';

  @override
  String get badgeStart => '起步';

  @override
  String get badgeStartDesc => '你的第一条记录。';

  @override
  String get badgeStreak => '持之以恒';

  @override
  String get badgeStreakDesc => '在 7 个不同的日子进行了记录。';

  @override
  String get badgeWeekend => '周末英雄';

  @override
  String get badgeWeekendDesc => '周末共记录 10 次。';

  @override
  String get badgeVeteran => '老手';

  @override
  String get badgeVeteranDesc => '累计 100 条记录。';

  @override
  String get badgeNightOwl => '夜猫子';

  @override
  String get badgeNightOwlDesc => '深夜记录 20 次。';

  @override
  String get badgeSleep => '睡眠守护者';

  @override
  String get badgeSleepDesc => '记录睡眠 30 次。';

  @override
  String get badgeJournal => '记录员';

  @override
  String get badgeJournalDesc => '写了 50 条详细笔记。';

  @override
  String get badgeContext => '情境大师';

  @override
  String get badgeContextDesc => '20 条包含多个标签的记录。';

  @override
  String get badgeOptimist => '乐观主义者';

  @override
  String get badgeOptimistDesc => '50 次心情极好 (8+)。';

  @override
  String get inputHowAreYou => '你感觉如何？';

  @override
  String get inputSleep => '记录睡眠';

  @override
  String get inputNoteHint => '添加笔记...';

  @override
  String get inputNoTags => '未选择标签';

  @override
  String get inputAddTag => '添加标签';

  @override
  String get inputEdit => '编辑标签';

  @override
  String get statsAnalysis => '分析本周';

  @override
  String get statsAnalysisWait => '正在分析...';

  @override
  String get statsAnalysisError => '分析出错';

  @override
  String get statsChartTitle => '心情与睡眠';

  @override
  String get statsMood => '心情';

  @override
  String get statsSleep => '睡眠';

  @override
  String get inputMoodTerrible => '极差';

  @override
  String get inputMoodBad => '不好';

  @override
  String get inputMoodOkay => '一般';

  @override
  String get inputMoodGood => '不错';

  @override
  String get inputMoodFantastic => '超棒';

  @override
  String get dialogNewProfileTitle => '创建新档案';

  @override
  String get dialogEditProfileTitle => '编辑档案';

  @override
  String get dialogNameLabel => '名称';

  @override
  String get dialogCycleTracking => '追踪经期';

  @override
  String get dialogCycleDesc => '计算周期天数';

  @override
  String get dialogPeriodStart => '上次经期开始日';

  @override
  String get dialogSelectDate => '选择日期';

  @override
  String get dialogAdd => '添加';

  @override
  String get dialogMoveCategory => '移动类别';

  @override
  String get dialogRenameTag => '重命名标签';

  @override
  String dialogDeleteTagTitle(String tag) {
    return '删除标签 “$tag”？';
  }

  @override
  String get dialogDeleteTagContent => '此标签将从选项中移除。';

  @override
  String dialogEditTagTitle(String tag) {
    return '“$tag” 选项';
  }

  @override
  String get statsYearly => '年度概览';

  @override
  String get statsNoData => '暂无数据。';

  @override
  String get statsPatternDay => '每日模式';

  @override
  String get statsInsights => '影响因素';

  @override
  String get statsAiIntro => '让 AI 分析你的一周。';

  @override
  String get statsAiButton => '分析本周';

  @override
  String get statsAiButtonUpdate => '更新分析';

  @override
  String get statsTrendTitle => '明日预测';

  @override
  String get statsTrendGood => '前景不错！☀️';

  @override
  String get statsTrendNormal => '平稳的一天 🌱';

  @override
  String get statsTrendBad => '注意身心 💜';

  @override
  String get categorySocial => '社交';

  @override
  String get categoryBodyMind => '身心';

  @override
  String get categoryObligations => '责任';

  @override
  String get categoryLeisure => '休闲与环境';

  @override
  String get categoryCycle => '生理周期';

  @override
  String get categoryOther => '其他';

  @override
  String get tagFamily => '家人';

  @override
  String get tagRelationship => '伴侣';

  @override
  String get tagFriends => '朋友';

  @override
  String get tagParty => '聚会';

  @override
  String get tagSport => '运动';

  @override
  String get tagSleep => '睡眠';

  @override
  String get tagFood => '饮食';

  @override
  String get tagHealth => '健康';

  @override
  String get tagMeditation => '冥想';

  @override
  String get tagWork => '工作';

  @override
  String get tagSchool => '学校';

  @override
  String get tagHomework => '作业';

  @override
  String get tagUni => '大学';

  @override
  String get tagHousehold => '家务';

  @override
  String get tagHobby => '爱好';

  @override
  String get tagTravel => '旅行';

  @override
  String get tagWeather => '天气';

  @override
  String get tagGaming => '游戏';

  @override
  String get tagReading => '阅读';

  @override
  String get tagMusic => '音乐';

  @override
  String get tagPeriodLight => '经期 (少量)';

  @override
  String get tagPeriodMedium => '经期 (中量)';

  @override
  String get tagPeriodHeavy => '经期 (大量)';

  @override
  String get tagSpotting => '点滴出血';

  @override
  String get tagCramps => '痛经';

  @override
  String get tagPMS => '经前综合症';

  @override
  String get tagOvulation => '排卵期';

  @override
  String get unknownProfile => '未知';

  @override
  String get btnSelect => '选择';

  @override
  String get maybeLater => '以后再说';

  @override
  String get premiumTeaserTitle => '多用户档案';

  @override
  String get premiumTeaserMessage => '免费版仅限一个档案。\n想要为伴侣、孩子或宠物添加档案吗？';

  @override
  String get snackSaved => '已保存';

  @override
  String get snackDeleted => '已删除';

  @override
  String get snackTagDeleted => '标签已删除';

  @override
  String snackError(String error) {
    return '错误: $error';
  }

  @override
  String get dialogNewTagName => '新名称';

  @override
  String get dialogNewTagPlaceholder => '名称 (例如: 瑜伽)';

  @override
  String get labelCategory => '类别';

  @override
  String get labelDescription => '描述';

  @override
  String predTextGood(String day, String score) {
    return '明天是 $day。数据和环境显示明天将会很棒 (Ø $score)。';
  }

  @override
  String predTextBad(String day, String score) {
    return '关于 $day，数据显示能量水平可能稍低 (Ø $score)。';
  }

  @override
  String predTextNormal(String day, String score) {
    return '$day 的预测显示平稳 (Ø $score)。';
  }

  @override
  String get tipSleep => '提示：今天早点休息吧。';

  @override
  String get tipFamilyBad => '最近家庭氛围比较紧张。';

  @override
  String get tipFamilyGood => '家庭氛围很好，给你带来了动力！';

  @override
  String get authLoginTitle => '欢迎回来';

  @override
  String get authRegisterTitle => '创建新账号';

  @override
  String get authEmailLabel => '邮箱';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authLoginButton => '登录';

  @override
  String get authRegisterButton => '注册';

  @override
  String get authHaveAccount => '我已有账号';

  @override
  String get authNoAccount => '注册';

  @override
  String get authLoading => '加载中...';

  @override
  String authError(String message) {
    return '错误: $message';
  }

  @override
  String get authSuccessVerify => '请验证你的邮箱！';

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

  @override
  String get statsAiCoachTitle => 'AI Weekly Coach';

  @override
  String labelDataFor(String name) {
    return 'Data for $name:';
  }

  @override
  String get labelNote => 'Note';

  @override
  String get exportPdfButton => 'Create Report (PDF)';

  @override
  String get pdfTitle => 'LuvioSphere Report';

  @override
  String pdfProfile(String name) {
    return 'Profile: $name';
  }

  @override
  String get pdfPeriod => 'Period: Last 30 days';

  @override
  String get pdfAvgMood => 'Ø Mood';

  @override
  String get pdfAvgSleep => 'Ø Sleep';

  @override
  String get pdfEntriesCount => 'Entries';

  @override
  String get pdfHeaderDate => 'Date';

  @override
  String get pdfHeaderTime => 'Time';

  @override
  String get pdfHeaderMood => 'Mood';

  @override
  String get pdfHeaderSleep => 'Sleep';

  @override
  String get pdfHeaderTags => 'Tags';

  @override
  String get pdfHeaderNote => 'Note';

  @override
  String get pdfFooter => 'Created with LuvioSphere';

  @override
  String get predWeatherGood => 'Tomorrow\'s sun boosts your energy!';

  @override
  String get predWeatherBad => 'Rain forecast – make yourself cozy.';
}

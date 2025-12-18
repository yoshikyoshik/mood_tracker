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
  String get legal => '法律信息';

  @override
  String get imprint => '版本说明';

  @override
  String get privacy => '隐私政策';

  @override
  String get tutorialMoodTitle => '你的心情';

  @override
  String get tutorialMoodDesc => '拖动滑块来记录你现在的感受。';

  @override
  String get tutorialSaveTitle => '保存记录';

  @override
  String get tutorialSaveDesc => '点击这里将记录写入日记。';

  @override
  String get tutorialStatsTitle => '你的洞察';

  @override
  String get tutorialStatsDesc => '在这里发现关于你心情的图表和模式。';

  @override
  String get tutorialProfileTitle => '你的档案';

  @override
  String get tutorialProfileDesc => '在这里管理你的数据、设置和导出。';

  @override
  String get tutorialStart => '开始教程';

  @override
  String get exportPdf => '创建报告 (PDF)';

  @override
  String get predCycleRest => '你的生理周期表明你需要休息。';

  @override
  String get predCyclePower => '你的生理周期给了你额外的能量！';

  @override
  String get predSentimentStress => '最近你的笔记看起来有些压力。';

  @override
  String get predSleepTip => '提示：今天早点休息吧。';

  @override
  String get aiCalibration => 'AI 校准中...';

  @override
  String aiCalibrationText(int missing) {
    return '正在设置你的智能预测。我们还需要 $missing 条记录。';
  }

  @override
  String aiEntriesCount(int count, int target) {
    return '$count / $target 条记录';
  }

  @override
  String get lockedPredTitle => '你明天的状态如何？';

  @override
  String get lockedPredDesc => '基于你的睡眠、趋势和星期几。';

  @override
  String get lockedAiTitle => '本周深度分析';

  @override
  String get errorNoEntries7Days => '过去 7 天内未找到记录。';

  @override
  String errorAnalysisFailed(Object code) {
    return '分析失败: $code';
  }

  @override
  String get sentimentNegativeWords => '压力,争吵,生病,疼痛,疲惫,焦虑,悲伤,糟糕';

  @override
  String get sentimentPositiveWords => '假期,爱,成功,运动,开心,很棒,放松,聚会';

  @override
  String get statsAiCoachTitle => 'AI 每周教练';

  @override
  String labelDataFor(String name) {
    return '$name 的数据：';
  }

  @override
  String get labelNote => '笔记';

  @override
  String get exportPdfButton => '创建报告 (PDF)';

  @override
  String get pdfTitle => 'LuvioSphere 报告';

  @override
  String pdfProfile(String name) {
    return '档案: $name';
  }

  @override
  String get pdfPeriod => '时期: 过去 30 天';

  @override
  String get pdfAvgMood => 'Ø 心情';

  @override
  String get pdfAvgSleep => 'Ø 睡眠';

  @override
  String get pdfEntriesCount => '条目数';

  @override
  String get pdfHeaderDate => '日期';

  @override
  String get pdfHeaderTime => '时间';

  @override
  String get pdfHeaderMood => '心情';

  @override
  String get pdfHeaderSleep => '睡眠';

  @override
  String get pdfHeaderTags => '标签';

  @override
  String get pdfHeaderNote => '笔记';

  @override
  String get pdfFooter => '由 LuvioSphere 创建';

  @override
  String get predWeatherGood => '明天的阳光会提升你的能量！';

  @override
  String get predWeatherBad => '预报有雨——让自己舒适一点。';

  @override
  String get partnerTitle => '伴侣连接 ❤️';

  @override
  String get partnerDesc => '与你的伴侣连接以查看TA的心情。';

  @override
  String get partnerEmailLabel => '伴侣的邮箱';

  @override
  String get partnerConnectBtn => '连接';

  @override
  String partnerConnected(String name) {
    return '已与 $name 连接';
  }

  @override
  String partnerStatus(String score) {
    return '当前心情: $score';
  }

  @override
  String partnerNeedsLove(String name) {
    return '⚠️ $name 今天过得很艰难。送点关爱吧！';
  }

  @override
  String get partnerWait => '等待确认中...';

  @override
  String get partnerDisconnectTitle => '断开伴侣连接？';

  @override
  String partnerDisconnectMessage(String partnerEmail) {
    return '你确定要断开与 $partnerEmail 的连接吗？';
  }

  @override
  String get partnerDisconnectConfirm => '是的，断开';

  @override
  String get partnerDisconnectCancel => '取消';

  @override
  String get partnerDisconnectSuccess => '连接已移除。';

  @override
  String get partnerDisconnectTooltip => '断开伴侣';

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

  @override
  String get inputDateLabel => '日期';

  @override
  String inputCycleDay(int day) {
    return '第 $day 天';
  }

  @override
  String get btnAddEntry => '添加记录 (+)';

  @override
  String get proDialogTitle => 'Pro 功能';

  @override
  String get proDialogDesc => '此功能仅限 Pro 会员。想要升级吗？';

  @override
  String get btnShop => '去商店';

  @override
  String get partnerLabelConnected => '已连接：';

  @override
  String get partnerLabelMyEmail => '你的邮箱 (自动)';

  @override
  String get partnerHintEmail => '例如: partner@example.com';

  @override
  String get partnerTitleLocked => '伴侣连接';

  @override
  String get partnerDescLocked => '建立连接，增进理解与和谐。';

  @override
  String get adviceSick => '伴侣生病了。送上茶、汤或药会很贴心！';

  @override
  String get adviceCycle => '注意：生理期不适。准备好热水袋和巧克力！';

  @override
  String get adviceStress => '压力很大。今天也许可以帮忙分担家务。';

  @override
  String get adviceSleep => '严重睡眠不足。确保今晚环境安静。';

  @override
  String get adviceSad => '心情低落。拥抱和倾听通常比给建议更有用。';

  @override
  String get adviceHappy => '心情超好！一起做点什么的好时机。';

  @override
  String get lockedInsightsTitle => '解锁高级洞察';

  @override
  String get lockedInsightsDesc => '找出影响心情的确切因素。我们的 AI 会分析你的模式。';

  @override
  String get btnUnlock => '立即升级 Pro';

  @override
  String get insightTrackMore => '记录更多标签以发现模式。';

  @override
  String get insightBasdOnPattern => '基于你的模式。';
}

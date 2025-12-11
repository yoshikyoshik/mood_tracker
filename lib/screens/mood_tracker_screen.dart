import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:showcaseview/showcaseview.dart';

// Import for Localization
import '../l10n/generated/app_localizations.dart';

import '../models/mood_entry.dart';
import '../models/profile.dart';
import '../models/subscription.dart';
import '../widgets/mood_input_view.dart';
import '../widgets/stats_view.dart';
import '../widgets/profile_view.dart';
import '../utils/mood_utils.dart';
import 'auth_gate.dart';

// 1. DER WRAPPER (Stellt sicher, dass ShowCaseWidget existiert)
class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return ShowCaseWidget(
      builder: (context) => const MoodTrackerContent(),
    );
  }
}

// 2. DER EIGENTLICHE CONTENT (Mit Logik)
class MoodTrackerContent extends StatefulWidget {
  const MoodTrackerContent({super.key});

  @override
  State<MoodTrackerContent> createState() => _MoodTrackerContentState();
}

class _MoodTrackerContentState extends State<MoodTrackerContent> {
  // State
  int _selectedIndex = 0;
  bool _showSuccessAnimation = false;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  double _currentMoodValue = 5.0;
  double _currentSleepValue = 5.0;
  bool _trackSleep = true; 
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();

  List<Profile> _profiles = [];
  String? _selectedProfileId;
  List<MoodEntry> _allEntries = [];
  
  bool _isPro = false;
  String? _stripeCustomerId;

  String _appVersion = "";

  final Set<String> _customTagNames = {};
  Map<String, List<String>> _combinedTagsByCategory = {};

  // Tutorial Keys
  final GlobalKey _one = GlobalKey();   // Slider
  final GlobalKey _two = GlobalKey();   // Save Button
  final GlobalKey _three = GlobalKey(); // Stats Tab
  final GlobalKey _four = GlobalKey();  // Profile Tab

  List<String> get _allAvailableTags {
    return _combinedTagsByCategory.values.expand((x) => x).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeAll();
    
    // Tutorial Prüfung nach dem Bauen des UIs
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartShowcase());
  }

  // --- TUTORIAL START LOGIK ---
  Future<void> _checkAndStartShowcase() async {
    // WICHTIG: Prüfen, ob der Screen noch existiert
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('tutorial_seen') ?? false;
    
    if (!seen) {
      if (mounted) {
        // ignore: deprecated_member_use
        ShowCaseWidget.of(context).startShowCase([_one, _two, _three, _four]);
        await prefs.setBool('tutorial_seen', true);
      }
    }
  }

  // WICHTIG: Wird aufgerufen, wenn sich Abhängigkeiten (wie Sprache) ändern
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tags neu laden, wenn sich die Sprache ändert
    if (_profiles.isNotEmpty) {
      _initializeTagsMap();
    }
  }

  // --- LOGIC HELPERS ---

  Map<String, List<String>> _getLocalizedBaseTags(AppLocalizations l10n) {
    return {
      l10n.categorySocial: [l10n.tagFamily, l10n.tagRelationship, l10n.tagFriends, l10n.tagParty],
      l10n.categoryBodyMind: [l10n.tagSport, l10n.tagSleep, l10n.tagFood, l10n.tagHealth, l10n.tagMeditation],
      l10n.categoryObligations: [l10n.tagWork, l10n.tagSchool, l10n.tagHomework, l10n.tagUni, l10n.tagHousehold],
      l10n.categoryLeisure: [l10n.tagHobby, l10n.tagTravel, l10n.tagWeather, l10n.tagGaming, l10n.tagReading, l10n.tagMusic],
      l10n.categoryOther: [],
    };
  }

  // Hilfsmethode: Ordnet alte DB-Strings der aktuellen Sprache zu
  String _mapDbCategoryToCurrent(String dbCategory, AppLocalizations l10n) {
    if (_combinedTagsByCategory.containsKey(dbCategory)) return dbCategory;

    // Legacy Mapping
    if (dbCategory == 'Soziales' || dbCategory == 'Social') return l10n.categorySocial;
    if (dbCategory == 'Körper & Geist' || dbCategory == 'Body & Mind') return l10n.categoryBodyMind;
    if (dbCategory == 'Pflichten' || dbCategory == 'Obligations') return l10n.categoryObligations;
    if (dbCategory == 'Freizeit & Umwelt' || dbCategory == 'Leisure & Nature') return l10n.categoryLeisure;
    if (dbCategory == 'Zyklus & Körper' || dbCategory == 'Cycle & Body') return l10n.categoryCycle;

    return l10n.categoryOther;
  }

  void _initializeTagsMap() {
    final l10n = AppLocalizations.of(context)!;
    final baseTags = _getLocalizedBaseTags(l10n);

    final newMap = Map<String, List<String>>.from(
      baseTags.map((k, v) => MapEntry(k, List<String>.from(v)))
    );

    if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: ''));
      
      if (profile.isCycleTracking) {
        final cycleTags = [
          l10n.tagPeriodLight, l10n.tagPeriodMedium, l10n.tagPeriodHeavy, 
          l10n.tagSpotting, l10n.tagCramps, l10n.tagPMS, l10n.tagOvulation
        ];
        
        final combined = <String, List<String>>{
          l10n.categoryCycle: cycleTags,
          ...newMap 
        };
        
        setState(() { _combinedTagsByCategory = combined; });
        return;
      }
    }
    setState(() { _combinedTagsByCategory = newMap; });
  }

  // --- ACTIONS ---

  Future<void> _startCheckout() async {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser; if (user == null) return;
    setState(() => _isLoading = true);
    final String returnUrl = kIsWeb ? 'https://celadon-pasca-8b960a.netlify.app/' : 'moodtracker://home';
    try {
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-checkout'), body: jsonEncode({'userEmail': user.email, 'userId': user.id, 'priceId': 'price_1SbFNUFoVhyNl27phao8dSGu', 'returnUrl': returnUrl}));
      if (response.statusCode == 200) { final url = Uri.parse(jsonDecode(response.body)['url']); if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); } 
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _openCustomerPortal() async {
    final l10n = AppLocalizations.of(context)!;
    if (_stripeCustomerId == null) return;
    setState(() => _isLoading = true);
    final String returnUrl = kIsWeb ? 'https://celadon-pasca-8b960a.netlify.app/' : 'moodtracker://home';
    try {
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-portal'), body: jsonEncode({'customerId': _stripeCustomerId, 'returnUrl': returnUrl}));
      if (response.statusCode == 200) { final url = Uri.parse(jsonDecode(response.body)['url']); if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _showPremiumSheet(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)]), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20), const Icon(Icons.diamond, size: 40, color: Colors.indigo), const SizedBox(height: 15), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), const SizedBox(height: 10), Text(message, style: TextStyle(fontSize: 15, color: Colors.black87.withValues(alpha: 0.7), height: 1.5), textAlign: TextAlign.center), const SizedBox(height: 30), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); _startCheckout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: Colors.indigo.withValues(alpha: 0.4)), child: Text(l10n.becomePro.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)))), const SizedBox(height: 10), TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.maybeLater, style: const TextStyle(color: Colors.grey)))])));
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; 
    final bgColor = _selectedIndex == 0 ? MoodUtils.getBackgroundColor(_currentMoodValue) : const Color(0xFFF2F4F8); 
    final headerTextColor = Colors.black87;
    final dateString = DateUtils.isSameDay(_selectedDate, DateTime.now()) ? l10n.today : DateFormat('dd.MM.yyyy').format(_selectedDate);

    final relevantEntries = (_selectedProfileId == null) ? <MoodEntry>[] : _allEntries.where((e) => e.profileId == _selectedProfileId).toList();
    final entriesForDate = relevantEntries.where((entry) => DateUtils.isSameDay(entry.timestamp, _selectedDate)).toList();
    final currentProfileName = _profiles.isNotEmpty && _selectedProfileId != null
        ? _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: '')).name
        : l10n.unknownProfile;
    
    int? currentCycleDay;
     if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
      if (profile.isCycleTracking && profile.lastPeriodDate != null) {
        final diff = _selectedDate.difference(profile.lastPeriodDate!).inDays;
        if (diff >= 0) currentCycleDay = diff + 1;
      }
    }

    if (_selectedProfileId != null && !_profiles.any((p) => p.id == _selectedProfileId) && _selectedProfileId != 'new') {
       if (_profiles.isNotEmpty) _selectedProfileId = _profiles.first.id;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Date & Profile
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateString.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              color: headerTextColor.withValues(alpha: 0.6),
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 2), 
                          
                          if (_profiles.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedProfileId,
                                icon: const SizedBox.shrink(),
                                isDense: true,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                elevation: 4,
                                onChanged: (String? newValue) {
                                  if (newValue == 'new') {
                                    _createNewProfile();
                                  } else if (newValue != null) {
                                    _changeProfile(newValue);
                                  }
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return [
                                    ..._profiles.map((p) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              p.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800, 
                                                color: headerTextColor,
                                                fontSize: 22, 
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.keyboard_arrow_down, size: 22, color: headerTextColor.withValues(alpha: 0.5)),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: _editCurrentProfileDialog,
                                            child: Icon(Icons.edit_outlined, size: 18, color: headerTextColor.withValues(alpha: 0.4)),
                                          ),
                                        ],
                                      );
                                    }),
                                    Text(l10n.newProfile), 
                                  ];
                                },
                                items: [
                                  ..._profiles.map((p) => DropdownMenuItem(
                                    value: p.id, 
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(p.name, style: const TextStyle(fontSize: 16)),
                                    ),
                                  )),
                                  DropdownMenuItem(
                                    value: 'new',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            (!_isPro && _profiles.isNotEmpty) ? Icons.lock_outline : Icons.add_circle_outline, 
                                            size: 18, 
                                            color: (!_isPro && _profiles.isNotEmpty) ? Colors.grey : Colors.indigo
                                          ),
                                          const SizedBox(width: 10),
                                          Text(l10n.newProfile, style: TextStyle(color: (!_isPro && _profiles.isNotEmpty) ? Colors.grey : Colors.indigo)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      // Right: Icons
                      Row(
                        children: [
                          _buildStreakBadge(),
                          if (!_isPro) 
                            IconButton(
                              icon: const Icon(Icons.diamond_outlined), 
                              color: primaryColor,
                              onPressed: _startCheckout
                            ),
                          
                          IconButton(icon: Icon(Icons.calendar_today_outlined, color: headerTextColor), onPressed: _pickDate),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- CONTENT SHEET ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    child: _selectedIndex == 0 
                      ? MoodInputView(
                          isPro: _isPro,
                          selectedDate: _selectedDate,
                          currentMoodValue: _currentMoodValue,
                          currentSleepValue: _currentSleepValue,
                          trackSleep: _trackSleep,
                          selectedTags: _selectedTags,
                          categorizedTags: _combinedTagsByCategory,
                          customTagNames: _customTagNames,
                          cycleDay: currentCycleDay,
                          noteController: _noteController,
                          entriesForDate: entriesForDate,
                          showSuccessAnimation: _showSuccessAnimation,
                          isLoading: _isLoading,
                          onMoodChanged: (val) => setState(() => _currentMoodValue = val),
                          onSleepChanged: (val) => setState(() => _currentSleepValue = val),
                          onTrackSleepChanged: (val) => setState(() => _trackSleep = val),
                          onTagToggle: _toggleTag,
                          onAddTag: _addNewTagDialog,
                          onSave: _saveEntry,
                          onDeleteEntry: _deleteEntry,
                          onEditEntry: _showEditSheet,
                          onManageCustomTag: _showTagOptions,
                          // Tutorial Keys übergeben
                          showcaseKeySlider: _one,
                          showcaseKeySave: _two,
                        )
                      : _selectedIndex == 1 
                        ? StatsView(
                            entries: relevantEntries,
                            allEntries: _allEntries,
                            profileName: currentProfileName,
                            isPro: _isPro,
                            onUnlockPressed: _startCheckout,
                          )
                        : ProfileView(
                            profileName: currentProfileName,
                            email: Supabase.instance.client.auth.currentUser?.email ?? "Keine E-Mail",
                            version: _appVersion,
                            entries: _allEntries,
                            isPro: _isPro,
                            onLogout: _signOut,
                            onManageSubscription: _isPro ? _openCustomerPortal : _startCheckout,
                            onContactSupport: () {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contactSupport)));
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (_showSuccessAnimation)
            IgnorePointer(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Lottie.asset('assets/success.json', repeat: false, width: 250),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12, width: 0.5))),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.add_reaction_outlined), selectedIcon: Icon(Icons.add_reaction, color: primaryColor), label: l10n.moodEntry),
            NavigationDestination(
              // ignore: deprecated_member_use
              icon: Showcase(key: _three, title: l10n.tutorialStatsTitle, description: l10n.tutorialStatsDesc, child: const Icon(Icons.insights_outlined)),
              selectedIcon: Icon(Icons.insights, color: primaryColor), label: l10n.statistics),
            NavigationDestination(
              // ignore: deprecated_member_use
              icon: Showcase(key: _four, title: l10n.tutorialProfileTitle, description: l10n.tutorialProfileDesc, child: const Icon(Icons.person_outline)),
              selectedIcon: Icon(Icons.person, color: primaryColor), label: l10n.profile),
          ],
        ),
      ),
    );
  }

  // --- DATA LOADING ---

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = "v${info.version} (${info.buildNumber})";
      });
    }
  }

  Future<void> _initializeAll() async {
    Timer(const Duration(seconds: 3), () {
      debugPrint("⏰ Safety Timeout: Splash Screen entfernt.");
      FlutterNativeSplash.remove();
    });

    try {
      debugPrint("🚀 Starte Initialisierung...");
      await _loadAppVersion();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint("ℹ️ Kein User eingeloggt. Breche Datenladen ab.");
        return; 
      }

      await _loadProfiles();
      
      await Future.wait([
        _loadEntries(),
        _loadCustomTags(),
        _checkSubscription(),
      ]);
      
      if (mounted) _initializeTagsMap();

    } catch (e) {
      debugPrint("🛑 Kritischer Ladefehler: $e");
    } finally {
      FlutterNativeSplash.remove(); 
    }
  }

  Future<void> _loadProfiles() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final response = await Supabase.instance.client.from('profiles').select().order('created_at');
      final data = response as List<dynamic>;
      if (data.isEmpty) { await Supabase.instance.client.from('profiles').insert({'user_id': userId, 'name': 'Ich', 'is_cycle_tracking': false}); if (mounted) _loadProfiles(); return; }
      
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getString('last_profile_id');

      setState(() {
        _profiles = data.map((json) => Profile.fromJson(json)).toList();
        if (lastProfileId != null && _profiles.any((p) => p.id == lastProfileId)) { _selectedProfileId = lastProfileId; } 
        else if (_selectedProfileId == null && _profiles.isNotEmpty) { _selectedProfileId = _profiles.first.id; }
        _initializeTagsMap();
      });
      if (_selectedProfileId != null) _loadEntries();
    } catch (e) { 
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); 
    }
  }

  Future<void> _loadCustomTags() async {
    try {
      final response = await Supabase.instance.client.from('user_tags').select('name, category').order('name'); 
      final data = response as List<dynamic>;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _initializeTagsMap(); _customTagNames.clear();
        for (var item in data) {
          final tagName = item['name']; 
          String category = _mapDbCategoryToCurrent(item['category'] ?? '', l10n);
          if (!_combinedTagsByCategory.containsKey(category)) { category = l10n.categoryOther; if (!_combinedTagsByCategory.containsKey(category)) _combinedTagsByCategory[category] = []; }
          _combinedTagsByCategory[category]?.add(tagName); _customTagNames.add(tagName);
        }
      });
    } catch (e) { debugPrint("Tags Error: $e"); }
  }

  Future<void> _checkSubscription() async {
    try {
      final user = Supabase.instance.client.auth.currentUser; if (user == null) return;
      final data = await Supabase.instance.client.from('subscriptions').select().eq('user_id', user.id).maybeSingle();
      if (data != null && mounted) { final sub = Subscription.fromMap(data); setState(() { _isPro = sub.isPro; _stripeCustomerId = sub.customerId; }); }
    } catch (e) { debugPrint("Sub Error: $e"); }
  }

  // --- ACTIONS ---

  void _toggleTag(String tag) {
    if (_showSuccessAnimation) return;
    setState(() { if (_selectedTags.contains(tag)) { _selectedTags.remove(tag); } else { _selectedTags.add(tag); } });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await _showModernDatePicker(_selectedDate);
    if (picked != null && picked != _selectedDate) { setState(() => _selectedDate = picked); }
  }

  Future<DateTime?> _showModernDatePicker(DateTime initialDate) async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true, 
      builder: (ctx) => StatefulBuilder(builder: (context, setSheetState) {
          return Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20),
            Text(l10n.dialogSelectDate, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
            Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.indigo, onPrimary: Colors.white, onSurface: Colors.black87)), child: CalendarDatePicker(initialDate: initialDate, firstDate: DateTime(2023), lastDate: DateTime.now(), onDateChanged: (newDate) { setSheetState(() => initialDate = newDate); })),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx, initialDate), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(l10n.btnSelect, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(height: 10), 
          ]));
      })
    );
  }

  Future<void> _loadEntries() async {
    try {
      final response = await Supabase.instance.client.from('mood_entries').select().order('created_at', ascending: false);
      setState(() { _allEntries = (response as List).map((json) => MoodEntry.fromMap(json)).toList(); _isLoading = false; });
    } catch (e) { if(mounted) setState(() => _isLoading = false); }
  }

  // --- CRUD OPERATIONS ---

  Future<void> _saveEntry() async {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;
    final newEntry = MoodEntry(timestamp: DateTime.now(), score: _currentMoodValue, sleepRating: _trackSleep ? _currentSleepValue : null, tags: Set.from(_selectedTags), note: _noteController.text.trim(), profileId: _selectedProfileId!);
    try {
      final res = await Supabase.instance.client.from('mood_entries').insert({'user_id': user.id, 'profile_id': _selectedProfileId, 'score': newEntry.score, 'sleep_rating': newEntry.sleepRating, 'tags': newEntry.tags.toList(), 'note': newEntry.note}).select().single();
      setState(() { _allEntries.insert(0, MoodEntry.fromMap(res)); _showSuccessAnimation = true; _selectedTags.clear(); _noteController.clear(); });
      Timer(const Duration(seconds: 2), () { if (mounted) setState(() => _showSuccessAnimation = false); });
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
  }

  Future<void> _deleteEntry(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await Supabase.instance.client.from('mood_entries').delete().eq('id', id); 
      setState(() => _allEntries.removeWhere((e) => e.id == id));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.delete), duration: const Duration(seconds: 1)));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
  }

  Future<void> _updateEntry(String id, double s, double sl, Set<String> t, String? n) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await Supabase.instance.client.from('mood_entries').update({'score': s, 'sleep_rating': sl, 'tags': t.toList(), 'note': n}).eq('id', id);
      _loadEntries(); if(mounted) Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
  }

  void _showEditSheet(MoodEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    double editScore = entry.score; double editSleep = entry.sleepRating ?? 5.0; Set<String> editTags = Set.from(entry.tags); final TextEditingController editNoteCtrl = TextEditingController(text: entry.note);
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
            final moodData = MoodUtils.getMoodData(editScore, l10n);
            return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.edit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(height: 20),
                  Text(moodData['emoji']!, style: const TextStyle(fontSize: 40)),
                  Slider(value: editScore, min: 0.0, max: 10.0, onChanged: (val) => setSheetState(() => editScore = val)), const SizedBox(height: 20),
                  Slider(value: editSleep, min: 0.0, max: 10.0, activeColor: Colors.indigo, onChanged: (val) => setSheetState(() => editSleep = val)), const SizedBox(height: 20),
                  Wrap(spacing: 6, children: _allAvailableTags.map((tag) { final isSelected = editTags.contains(tag); return ChoiceChip(label: Text(tag), selected: isSelected, onSelected: (s) => setSheetState(() => s ? editTags.add(tag) : editTags.remove(tag))); }).toList()), const SizedBox(height: 20),
                  TextField(controller: editNoteCtrl, decoration: InputDecoration(hintText: l10n.inputNoteHint)), const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => _updateEntry(entry.id!, editScore, editSleep, editTags, editNoteCtrl.text.trim()), child: Text(l10n.save))
                ]));
        });
      });
  }

  void _createNewProfile() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isPro && _profiles.isNotEmpty) { _showPremiumSheet(context, l10n.premiumTeaserTitle, l10n.premiumTeaserMessage); return; }
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) { 
      final controller = TextEditingController();
      return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l10n.dialogNewProfileTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
        TextField(controller: controller, decoration: InputDecoration(hintText: l10n.dialogNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), autofocus: true), const SizedBox(height: 25),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
          if (controller.text.isNotEmpty) {
            await Supabase.instance.client.from('profiles').insert({'user_id': Supabase.instance.client.auth.currentUser!.id, 'name': controller.text.trim()});
            if (mounted) { Navigator.pop(context); _loadProfiles(); }
          }
        }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(l10n.save)))
      ]));
    });
  }

  Future<void> _editCurrentProfileDialog() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedProfileId == null) return;
    final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
    final nameCtrl = TextEditingController(text: profile.name);
    bool tracking = profile.isCycleTracking;
    DateTime? lastPeriod = profile.lastPeriodDate;

    await showModalBottomSheet(
      context: context, isScrollControlled: true, 
      builder: (ctx) => StatefulBuilder(builder: (innerCtx, setDialogState) {
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.dialogEditProfileTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.dialogNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(Icons.water_drop, color: Colors.pinkAccent), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.dialogCycleTracking, style: const TextStyle(fontWeight: FontWeight.bold)), Text(l10n.dialogCycleDesc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])), Switch(value: tracking, activeTrackColor: Colors.pinkAccent, onChanged: (v) => setDialogState(() => tracking = v))]),
          ),
          if (tracking) InkWell(onTap: () async { final d = await _showModernDatePicker(lastPeriod ?? DateTime.now()); if (d != null) setDialogState(() => lastPeriod = d); }, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today, color: Colors.grey), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.dialogPeriodStart, style: const TextStyle(fontWeight: FontWeight.bold)), Text(lastPeriod == null ? l10n.dialogSelectDate : DateFormat('dd.MM.yyyy').format(lastPeriod!), style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.bold))])]))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
             await _updateProfile(profile.id, nameCtrl.text, tracking, lastPeriod);
             if (mounted) Navigator.pop(context);
          }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(l10n.save)))
        ]));
      })
    );
  }

  Future<void> _updateProfile(String id, String name, bool tracking, DateTime? lastPeriod) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await Supabase.instance.client.from('profiles').update({'name': name, 'is_cycle_tracking': tracking, 'last_period_date': lastPeriod?.toIso8601String()}).eq('id', id);
      await _loadProfiles(); 
      await _loadCustomTags();
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if(mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AuthGate()), (route) => false);
  }

  Future<void> _changeProfile(String id) async {
    setState(() => _selectedProfileId = id);
    final prefs = await SharedPreferences.getInstance(); prefs.setString('last_profile_id', id);
    _loadCustomTags(); _loadEntries();
  }

  // --- TAG HELPERS ---

  void _showTagOptions(String tagName) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.only(top: 10), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), Padding(padding: const EdgeInsets.all(20.0), child: Text(l10n.dialogEditTagTitle(tagName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: Text(l10n.edit), onTap: () { Navigator.pop(ctx); _editCustomTagName(tagName); }), ListTile(leading: const Icon(Icons.drive_file_move, color: Colors.orange), title: Text(l10n.dialogMoveCategory), onTap: () { Navigator.pop(ctx); _moveCustomTagCategory(tagName); }), ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(l10n.delete, style: const TextStyle(color: Colors.red)), onTap: () { Navigator.pop(ctx); _deleteCustomTag(tagName); }), const SizedBox(height: 20)]))));
  }

  void _addNewTagDialog() async {
    final l10n = AppLocalizations.of(context)!;
    String newTag = ""; final categories = _combinedTagsByCategory.keys.where((k) => k != l10n.categoryCycle).toList(); String selectedCategory = categories.isNotEmpty ? categories.first : l10n.categoryOther;
    await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) { return StatefulBuilder(builder: (context, setDialogState) { return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.dialogNewProfileTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), TextField(autofocus: true, decoration: InputDecoration(hintText: l10n.dialogNewTagPlaceholder, labelText: l10n.labelDescription, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (val) => newTag = val), const SizedBox(height: 20), InputDecorator(decoration: InputDecoration(labelText: l10n.labelCategory, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedCategory, isDense: true, items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (val) { if (val != null) { setDialogState(() => selectedCategory = val); } }))), const SizedBox(height: 25), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { if (newTag.trim().isNotEmpty) { final user = Supabase.instance.client.auth.currentUser; if (user != null) { await Supabase.instance.client.from('user_tags').insert({'user_id': user.id, 'name': newTag.trim(), 'category': selectedCategory }); if (!context.mounted) return; await _loadCustomTags(); if (!context.mounted) return; Navigator.pop(context); } } }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(l10n.dialogAdd))) ])); }); });
  }

  Future<void> _deleteCustomTag(String tagName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(l10n.dialogDeleteTagTitle(tagName)), content: Text(l10n.dialogDeleteTagContent), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red)))]));
    if (confirm != true) return;
    try { final user = Supabase.instance.client.auth.currentUser; if (user == null) return; await Supabase.instance.client.from('user_tags').delete().eq('user_id', user.id).eq('name', tagName); if (_selectedTags.contains(tagName)) setState(() => _selectedTags.remove(tagName)); await _loadCustomTags(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackTagDeleted))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString())))); }
  }

  Future<void> _editCustomTagName(String oldName) async {
    final l10n = AppLocalizations.of(context)!; String newName = oldName;
    await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.dialogRenameTag, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 15), TextField(autofocus: true, controller: TextEditingController(text: oldName), onChanged: (val) => newName = val, decoration: InputDecoration(labelText: l10n.dialogNewTagName, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { if (newName.trim().isNotEmpty && newName != oldName) { final user = Supabase.instance.client.auth.currentUser; if (user != null) { await Supabase.instance.client.from('user_tags').update({'name': newName.trim()}).eq('user_id', user.id).eq('name', oldName); if (_selectedTags.contains(oldName)) { setState(() { _selectedTags.remove(oldName); _selectedTags.add(newName.trim()); }); } await _loadCustomTags(); if (mounted) Navigator.of(context).pop(); } } }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(l10n.save)))])));
  }

  Future<void> _moveCustomTagCategory(String tagName) async {
    final l10n = AppLocalizations.of(context)!; final categories = _combinedTagsByCategory.keys.toList(); String selectedCategory = categories.isNotEmpty ? categories.first : l10n.categoryOther;
    await showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) { return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.dialogMoveCategory, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), InputDecorator(decoration: InputDecoration(labelText: l10n.labelCategory, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedCategory, isDense: true, items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (val) { if (val != null) setDialogState(() => selectedCategory = val); }))), const SizedBox(height: 25), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { final user = Supabase.instance.client.auth.currentUser; if (user != null) { await Supabase.instance.client.from('user_tags').update({'category': selectedCategory}).eq('user_id', user.id).eq('name', tagName); await _loadCustomTags(); if (mounted) Navigator.of(this.context).pop(); } }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(l10n.save)))])); }));
  }

  int _calculateStreak() {
    if (_allEntries.isEmpty) return 0;
    final uniqueDates = _allEntries.map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)).toSet().toList()..sort((a, b) => b.compareTo(a));
    if (uniqueDates.isEmpty) return 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (uniqueDates.first.isBefore(yesterday)) { return 0; }
    int streak = 0;
    DateTime checkDate = uniqueDates.first; 
    for (var date in uniqueDates) {
      if (DateUtils.isSameDay(date, checkDate)) { streak++; checkDate = checkDate.subtract(const Duration(days: 1)); } else { break; }
    }
    return streak;
  }

  Widget _buildStreakBadge() {
    final l10n = AppLocalizations.of(context)!;
    final int streak = _calculateStreak();
    Color color; IconData icon = Icons.local_fire_department_outlined; bool isLegendary = false; 
    if (streak < 3) { color = Colors.grey.shade400; } else if (streak < 8) { color = Colors.amber.shade700; icon = Icons.local_fire_department; } else if (streak < 15) { color = Colors.orange.shade700; icon = Icons.local_fire_department; } else if (streak < 29) { color = Colors.redAccent.shade700; icon = Icons.whatshot; } else { color = Colors.deepPurpleAccent; isLegendary = true; icon = Icons.auto_awesome; }
    return InkWell(onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.streakMessage(streak)))); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: isLegendary ? null : Colors.white, gradient: isLegendary ? LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]) : null, borderRadius: BorderRadius.circular(20), border: isLegendary ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: isLegendary ? Colors.white : color), const SizedBox(width: 5), Text("$streak", style: TextStyle(fontWeight: FontWeight.w800, color: isLegendary ? Colors.white : color, fontSize: 13))])));
  }
}
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
import 'package:home_widget/home_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:table_calendar/table_calendar.dart';

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
import '../services/entry_service.dart';

// 1. DER WRAPPER
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

// 2. DER EIGENTLICHE CONTENT
class MoodTrackerContent extends StatefulWidget {
  const MoodTrackerContent({super.key});

  @override
  State<MoodTrackerContent> createState() => _MoodTrackerContentState();
}

class _MoodTrackerContentState extends State<MoodTrackerContent> with WidgetsBindingObserver {
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
  final EntryService _entryService = EntryService();

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

  Timer? _dayCheckTimer;

  String? _currentPingAnimation; // null = keine Animation
  RealtimeChannel? _pingSubscription;

  // 1. VARIABLE FÜR DEN LISTENER
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; // Beachte: neuerdings List<ConnectivityResult> in v6

  @override
  void initState() {
    super.initState();

    // --- NEU: Lifecycle & Timer ---
    WidgetsBinding.instance.addObserver(this);
    _startDayCheckTimer();
    // -----------------------------

    _initializeAll();
        
    // 2. LISTENER STARTEN (Automatischer Sync)
    // LISTENER STARTEN (Automatischer Sync)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      bool hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        // Sync über Service aufrufen
        final count = await _entryService.syncOfflineEntries();
        if (count > 0 && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$count Offline-Einträge synchronisiert!"), backgroundColor: Colors.green));
           _loadEntries(); // UI aktualisieren
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartShowcase());
  }

  @override
  void dispose() {

    // --- NEU: Aufräumen ---
    WidgetsBinding.instance.removeObserver(this);
    _dayCheckTimer?.cancel();
    // ----------------------

    // 3. LISTENER AUFRÄUMEN
    _connectivitySubscription.cancel();
    super.dispose();
    _pingSubscription?.unsubscribe();
  }

  // --- TUTORIAL START LOGIK ---
  Future<void> _checkAndStartShowcase() async {
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
    if (_profiles.isNotEmpty) {
      // 1. Standard-Tags neu laden
      _initializeTagsMap();
      // 2. FIX: Custom Tags sofort wieder aus der DB holen und einsortieren!
      _loadCustomTags();
    }
  }

  // --- LIFECYCLE & DAY CHECK ---
  
  void _startDayCheckTimer() {
    // Jede Minute prüfen
    _dayCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForDayChange();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Wenn App aufwacht
    if (state == AppLifecycleState.resumed) {
      _checkForDayChange();
    }
  }

  void _checkForDayChange() {
    // Zwingt die UI zum Neu-Zeichnen, damit DateTime.now() aktualisiert wird.
    if (mounted) {
      setState(() {
        // Hier passiert nichts, aber das setState sorgt dafür, 
        // dass die build-Methode neu läuft und das aktuelle Datum prüft.
      });
    }
  }

  // --- LOGIC HELPERS ---

  Map<String, List<String>> _getLocalizedBaseTags(AppLocalizations l10n) {
    return {
      // SOZIALES
      l10n.categorySocial: [
        l10n.tagFamily, 
        l10n.tagRelationship, 
        l10n.tagFriends, 
        l10n.tagParty, 
        l10n.tagSex // NEU: Intimität
      ],
      
      // KÖRPER & GEIST
      l10n.categoryBodyMind: [
        l10n.tagSport, 
        l10n.tagSleep, 
        l10n.tagFood, 
        l10n.tagHealthyFood, // NEU: Gesund gegessen
        l10n.tagFastFood, // NEU: Fast Food
        l10n.tagWater, // NEU: Wenig Wasser
        l10n.tagAlcohol, // NEU: Alkohol
        l10n.tagHealth, 
        l10n.tagMeditation,
        l10n.tagNature, // NEU: Natur
        l10n.tagSauna // NEU: Wellness
      ],
      
      // PFLICHTEN
      l10n.categoryObligations: [
        l10n.tagWork, 
        l10n.tagSchool, 
        l10n.tagHomework, 
        l10n.tagUni, 
        l10n.tagHousehold
      ],
      
      // FREIZEIT
      l10n.categoryLeisure: [
        l10n.tagHobby, 
        l10n.tagScreenTime, // NEU: Viel Handy (passt hier oder bei Other gut)
        l10n.tagTravel, 
        l10n.tagWeather, 
        l10n.tagGaming, 
        l10n.tagReading, 
        l10n.tagMusic
      ],
      
      l10n.categoryOther: [],
    };
  }

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

  void _subscribeToPings() {
    final user = Supabase.instance.client.auth.currentUser;
    // Debug 1: Prüfen, ob wir überhaupt starten
    debugPrint("🔍 PING SETUP: User: ${user?.email}, ProfileSelected: $_selectedProfileId");

    if (user == null || _profiles.isEmpty) {
      debugPrint("❌ PING ABBRUCH: Keine Profile geladen.");
      return;
    }

    // Wir suchen das Hauptprofil
    final mainProfile = _profiles.firstWhere(
      (p) => p.isMain, 
      orElse: () => _profiles.first
    );
    
    debugPrint("👂 PING LISTENER: Ich höre auf Pings für Profil-ID: ${mainProfile.id} (${mainProfile.name})");

    _pingSubscription = Supabase.instance.client
        .channel('my_pings')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'partner_pings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_profile_id',
            value: mainProfile.id, // <--- Auf diese ID hören wir
          ),
          callback: (payload) {
            debugPrint("✨ PING EMPFANGEN! Payload: ${payload.newRecord}");
            final newPing = payload.newRecord;
            if (newPing['ping_type'] != null) {
              _triggerPingAnimation(newPing['ping_type']);
            }
          },
        )
        .subscribe((status, error) {
           // Debug 3: Status der Verbindung
           debugPrint("📡 PING CHANNEL STATUS: $status ${error != null ? '- Error: $error' : ''}");
        });
  }

void _triggerPingAnimation(String type) {
    String animFile = 'assets/anim_heart.json'; // Fallback

    // HIER WAREN DIE KLAMMERN FEHLEND:
    if (type == 'hug') {
      animFile = 'assets/anim_hug.json';
    } else if (type == 'energy') {
      animFile = 'assets/anim_fire.json';
    } else if (type == 'poke') {
      animFile = 'assets/anim_ghost.json';
    }

    if (mounted) {
      setState(() {
        _currentPingAnimation = animFile;
      });

      // Nach 3 Sekunden Animation wieder ausblenden
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _currentPingAnimation = null);
        }
      });
    }
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
    
    // FIX: Unused Variable entfernt!
    // final currentProfileName = ... (wird nicht mehr gebraucht)
    
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
                                icon: const SizedBox.shrink(), // Standard-Icon verstecken, wir bauen ein eigenes
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
                                // 1. HEADER ANZEIGE (Zugeklappt)
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
                                                // HAUPTPROFIL: Indigo Farbe, ANDERE: Schwarz
                                                color: p.isMain ? theme.colorScheme.primary : headerTextColor,
                                                fontSize: 22,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          
                                          // --- ICON FÜR HAUPTPROFIL ---
                                          if (p.isMain) ...[
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.verified, // Oder Icons.star_rounded
                                              size: 20, 
                                              color: theme.colorScheme.primary
                                            ),
                                          ],
                                          // ----------------------------

                                          const SizedBox(width: 4),
                                          Icon(Icons.keyboard_arrow_down, size: 22, color: headerTextColor.withValues(alpha: 0.5)),
                                          
                                          // Nur anzeigen, wenn ausgewählt, damit man editieren kann
                                          if (p.id == _selectedProfileId) ...[
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: _editCurrentProfileDialog,
                                              child: Icon(Icons.edit_outlined, size: 18, color: headerTextColor.withValues(alpha: 0.4)),
                                            ),
                                          ]
                                        ],
                                      );
                                    }),
                                    // Fallback für 'new' item (wird technisch hier nie angezeigt, aber nötig für Array-Länge)
                                    Text(l10n.newProfile), 
                                  ];
                                },
                                // 2. LISTEN ANZEIGE (Aufgeklappt)
                                items: [
                                  ..._profiles.map((p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      // Optional: Hauptprofil leicht hervorheben im Hintergrund
                                      decoration: p.isMain ? BoxDecoration(
                                        border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3))
                                      ) : null,
                                      child: Row(
                                        children: [
                                          // Kleines Icon auch in der Liste
                                          if (p.isMain) 
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: Icon(Icons.verified, size: 16, color: theme.colorScheme.primary),
                                            )
                                          else 
                                            // --- HIER IST DIE ÄNDERUNG ---
                                            // Statt leerem Platz ein dezentes Icon für Beobachter
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: Icon(Icons.visibility_outlined, size: 16, color: Colors.grey.withValues(alpha: 0.5)),
                                            ),
                                            
                                          Text(
                                            p.name, 
                                            style: TextStyle(
                                              fontSize: 16,
                                              // Hauptprofil fett gedruckt
                                              fontWeight: p.isMain ? FontWeight.bold : FontWeight.normal,
                                              color: p.isMain ? theme.colorScheme.primary : Colors.black87
                                            )
                                          ),
                                          
                                          if (p.isMain) 
                                             Padding(
                                               padding: const EdgeInsets.only(left: 6),
                                               child: Text("(${l10n.me})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                             ),
                                        ],
                                      ),
                                    ),
                                  )),
                                  // "Neues Profil" Eintrag
                                  DropdownMenuItem(
                                    value: 'new',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8), // Einrücken passend zu oben
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
                          onPreviousDay: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    // Optional: Reset der Slider, wenn man den Tag wechselt? 
                    // Meistens besser, die Werte stehen zu lassen oder auf 5.0 zu setzen.
                    // Ich lasse sie stehen, das fühlt sich flüssiger an.
                  });
                },
                onNextDay: () {
                  setState(() {
                    final nextDay = _selectedDate.add(const Duration(days: 1));
                    if (!nextDay.isAfter(DateTime.now())) {
                       _selectedDate = nextDay;
                    }
                  });
                },
                        )
                      : _selectedIndex == 1 
                        ? StatsView(
                            entries: relevantEntries,
                            allEntries: _allEntries,
                            currentProfile: _profiles.firstWhere(
                                (p) => p.id == _selectedProfileId, 
                                orElse: () => Profile(id: 'dummy', name: 'Gast')
                            ),
                            isPro: _isPro,
                            onUnlockPressed: _startCheckout,
                          )
                        : ProfileView(
                            // FIX: Wir übergeben das GANZE Profile Objekt
                            currentProfile: _profiles.firstWhere(
                                (p) => p.id == _selectedProfileId, 
                                orElse: () => Profile(id: 'dummy', name: 'Gast')
                            ),
                            
                            email: Supabase.instance.client.auth.currentUser?.email ?? "Keine E-Mail",
                            version: _appVersion,
                            
                            // 1. Das bleibt (gefiltert für PDF)
                            entries: relevantEntries, 
                            
                            // 2. FIX: Nur Einträge vom Hauptprofil für die Badges zählen!
                            // Wir suchen die ID des Hauptprofils (oder Fallback auf das erste)
                            allEntries: _allEntries.where((e) {
                              final mainProfile = _profiles.firstWhere(
                                (p) => p.isMain, 
                                orElse: () => _profiles.first
                              );
                              return e.profileId == mainProfile.id;
                            }).toList(), 
                            
                            isPro: _isPro,
                            onLogout: _signOut,
                            onManageSubscription: _isPro ? _openCustomerPortal : _startCheckout,
                            onStartTutorial: () async {
                              setState(() => _selectedIndex = 0);
                              await Future.delayed(const Duration(milliseconds: 300));
                              if (!context.mounted) return;
                              // ignore: deprecated_member_use
                              ShowCaseWidget.of(context).startShowCase([_one, _two, _three, _four]);
                            },
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

            // --- NEU: PING ANIMATION OVERLAY ---
      if (_currentPingAnimation != null)
        Positioned.fill(
          child: IgnorePointer( // Damit man durchklicken kann (optional, oder blocken)
            child: Container(
              color: Colors.black.withValues(alpha: 0.3), // Leicht abdunkeln
              child: Center(
                child: Lottie.asset(
                  _currentPingAnimation!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  repeat: false, // Oder true, wenn es loopen soll bis Timer endet
                ),
              ),
            ),
          ),
        ),
       // ----------------------------------

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

  // --- OFFLINE SYNC LOGIK ---

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
      
      // NEU: Service Aufruf
      final count = await _entryService.syncOfflineEntries();
      if (count > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$count Offline-Einträge nachgeladen."), backgroundColor: Colors.green));
      }

      await Future.wait([
        _loadEntries(),
        _loadCustomTags(),
        _checkSubscription(),
      ]);

      if (mounted) {
         _initializeTagsMap();
         _updateHomeWidget(); // <--- Aktualisiert das Widget beim App-Start
      }

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
      
      // FIX: Wir laden NUR die Profile, die dem eingeloggten User gehören!
      // Vorher fehlte .eq('user_id', userId), deshalb wurden ALLE Profile geladen.
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId) // <--- WICHTIGSTER FIX
          .order('created_at');
          
      final data = response as List<dynamic>;
      
      if (data.isEmpty) { 
        await Supabase.instance.client.from('profiles').insert({'user_id': userId, 'name': 'Ich', 'is_cycle_tracking': false}); 
        if (mounted) _loadProfiles(); 
        return; 
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getString('last_profile_id');

      if (mounted) {
        setState(() {
          _profiles = data.map((json) => Profile.fromJson(json)).toList();
          
          if (lastProfileId != null && _profiles.any((p) => p.id == lastProfileId)) { 
            _selectedProfileId = lastProfileId; 
          } else if (_profiles.isNotEmpty) { 
            _selectedProfileId = _profiles.first.id; 
          }
          _initializeTagsMap();
        });
        
        if (_selectedProfileId != null) _loadEntries();

        // --- HIER IST DER NEUE PLATZ ---
        // Jetzt sind _profiles zu 100% gefüllt, also können wir den Listener starten.
        _subscribeToPings(); 
        // -------------------------------
      }
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
    
    // Temporärer State für die Auswahl im Dialog
    DateTime tempDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Griff oben
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header Zeile mit "Heute" Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.dialogSelectDate,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            tempDate = DateTime.now();
                          });
                        },
                        icon: const Icon(Icons.today, size: 18),
                        label: Text(l10n.today.toUpperCase()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  TableCalendar(
                    firstDay: DateTime(2023),
                    lastDay: DateTime.now(),
                    focusedDay: tempDate,
                    currentDay: DateTime.now(),
                    
                    locale: Localizations.localeOf(context).languageCode,
                    
                    // 1. ÄNDERUNG: Woche beginnt am Montag
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    
                    // 2. ÄNDERUNG: Wochentage (Kopfzeile) stylen
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      // Wochenende (Sa, So) rot färben
                      weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      // Werktage (Mo-Fr) normal schwarz
                      weekdayStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),

                    eventLoader: (day) {
                      return _allEntries.where((entry) {
                        final matchProfile = entry.profileId == _selectedProfileId;
                        final matchDate = isSameDay(entry.timestamp, day);
                        return matchProfile && matchDate;
                      }).toList();
                    },

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.indigo),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.indigo),
                    ),
                    
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.indigo.shade300,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      
                      todayTextStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      defaultTextStyle: const TextStyle(color: Colors.black87),
                      
                      // Auch die Zahlen im Kalender (Tage) am Wochenende rot färben
                      weekendTextStyle: const TextStyle(color: Colors.redAccent),
                    ),

                    selectedDayPredicate: (day) => isSameDay(tempDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (selectedDay.isAfter(DateTime.now())) return;
                      setSheetState(() {
                        tempDate = selectedDay;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, tempDate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.btnSelect,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadEntries() async {
    try {
      // HIER RUFEN WIR JETZT DEN SERVICE
      // (Später fügen wir hier einfach limit/offset hinzu für Pagination)
      final entries = await _entryService.getEntries();
      
      setState(() {
        _allEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Load Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntry() async {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;

    // --- LOGIK ÄNDERUNG START ---
    // Wir nehmen Jahr/Monat/Tag vom ausgewählten Datum (kalender)
    // Aber Stunde/Minute von JETZT, damit die Sortierung stimmt
    final now = DateTime.now();
    final entryTimestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    // --- LOGIK ÄNDERUNG ENDE ---

    final newEntry = MoodEntry(
      timestamp: entryTimestamp, // Hier die neue Variable nutzen
      score: _currentMoodValue,
      sleepRating: _trackSleep ? _currentSleepValue : null,
      tags: Set.from(_selectedTags),
      note: _noteController.text.trim(),
      profileId: _selectedProfileId!
    );

    setState(() => _showSuccessAnimation = true);

    try {
      final savedEntry = await _entryService.saveEntry(newEntry, user.id);

      setState(() {
        // Wir sortieren neu, da der Eintrag jetzt evtl. nicht ganz oben steht (wenn Datum in Vergangenheit)
        _allEntries.add(savedEntry);
        _allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // UI Reset
        _selectedTags.clear();
        _noteController.clear();
        // Mood lassen wir vielleicht stehen oder resetten auf 5.0, Geschmackssache
      });

      if (savedEntry.id != null && savedEntry.id!.startsWith('offline_') && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Kein Internet. Eintrag lokal gespeichert."), backgroundColor: Colors.orange)
         );
      } else {
        _updateHomeWidget();
      }

      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccessAnimation = false);
      });

    } catch (e) {
      if (mounted) {
        setState(() => _showSuccessAnimation = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString()))));
      }
    }
  }

  Future<void> _deleteEntry(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _entryService.deleteEntry(id);
      setState(() => _allEntries.removeWhere((e) => e.id == id));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.delete), duration: const Duration(seconds: 1)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString()))));
    }
  }

  // Signatur angepasst: Nimmt jetzt 'originalTimestamp' entgegen
  Future<void> _updateEntry(String id, double s, double sl, Set<String> t, String? n, DateTime originalTimestamp) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      final tempEntry = MoodEntry(
          id: id,
          score: s,
          sleepRating: sl,
          tags: t,
          note: n,
          timestamp: originalTimestamp, // Datum beibehalten
          profileId: _selectedProfileId!,
          userId: userId
      );

      // 1. Update an Service
      final updatedEntry = await _entryService.updateEntry(tempEntry);

      // 2. UI Update & Animation
      if (mounted) {
        // Erst den Dialog schließen, damit man die Animation auf dem Hauptscreen sieht
        Navigator.pop(context);

        setState(() {
          // Lokales Listen-Update
          final index = _allEntries.indexWhere((e) => e.id == id);
          if (index != -1) {
            _allEntries[index] = updatedEntry;
          } else {
            _allEntries.add(updatedEntry);
            _allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }

          // --- NEU: Animation starten ---
          _showSuccessAnimation = true; 
        });

        // Offline Check (wie gehabt)
        final connectivityResult = await Connectivity().checkConnectivity();
        if (!mounted) return;

        if (connectivityResult.contains(ConnectivityResult.none)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Offline gespeichert. Wird später synchronisiert."),
              backgroundColor: Colors.orange
            )
          );
        }

        // --- NEU: Timer zum Ausblenden der Animation (nach 2 Sek) ---
        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSuccessAnimation = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackError(e.toString()))));
      }
    }
  }

  Future<void> _updateHomeWidget() async {
    // PRÜFUNG: Wenn wir im Web sind, brechen wir sofort ab.
    // Web-Browser haben keine Homescreen-Widgets -> Fehler vermieden!
    if (kIsWeb) return;

    try {
      // 1. Streak berechnen (Code hast du schon, evtl. in separate Methode auslagern)
      final streak = _calculateStreak();
      
      // 2. Daten an Android senden
      // Die IDs ('tv_streak_value') müssen exakt mit dem XML aus Schritt 2 übereinstimmen!
      await HomeWidget.saveWidgetData<String>('tv_streak_value', streak.toString());
      
      // 3. Widget aktualisieren erzwingen
      await HomeWidget.updateWidget(
        name: 'MoodWidgetProvider',
        androidName: 'MoodWidgetProvider',
        iOSName: 'MoodWidget', // Kommt später
      );
    } catch (e) {
      // Falls auf dem Handy etwas schiefgeht (z.B. Widget noch nicht installiert),
      // fangen wir den Fehler ab, damit die App weiterläuft.
      debugPrint("Fehler beim Aktualisieren des HomeWidgets: $e");
    }
  }

  void _showEditSheet(MoodEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    double editScore = entry.score;
    double editSleep = entry.sleepRating ?? 5.0;
    Set<String> editTags = Set.from(entry.tags);
    final TextEditingController editNoteCtrl = TextEditingController(text: entry.note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      useSafeArea: true,
      backgroundColor: const Color(0xFFF5F7FA), // <--- HIER IST DIE NEUE FARBE (Cool Grey)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final moodData = MoodUtils.getMoodData(editScore, l10n);
          // Tastatur-Höhe holen
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            // Padding unten = Tastaturhöhe (damit nichts verdeckt wird)
            padding: EdgeInsets.only(bottom: bottomInset),
            // Maximale Höhe begrenzen, damit es oben nicht überlappt
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                // --- 1. HEADER (Mit mehr Abstand oben) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Mehr Platz oben
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                        child: Text(l10n.cancel),
                      ),
                      Text(
                        l10n.edit,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () => _updateEntry(
                          entry.id!, 
                          editScore, 
                          editSleep, 
                          editTags, 
                          editNoteCtrl.text.trim(),
                          entry.timestamp // <--- HIER übergeben wir das Original-Datum
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo, 
                          textStyle: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        child: Text(l10n.save),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // --- 2. SCROLLBARER INHALT ---
                Flexible(
                  child: SingleChildScrollView(
                    // WICHTIG: Padding für den Inhalt selbst (Abstand zu den Rändern & unten Platz zum Scrollen)
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood
                        Center(
                          child: Column(
                            children: [
                              Text(moodData['emoji']!, style: const TextStyle(fontSize: 48)),
                              const SizedBox(height: 5),
                              Text(moodData['label']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: editScore, 
                          min: 0.0, 
                          max: 10.0, 
                          onChanged: (val) => setSheetState(() => editScore = val)
                        ),
                        
                        const SizedBox(height: 25), // Mehr Abstand
                        
                        // Schlaf
                        Row(
                          children: [
                            const Icon(Icons.bed, size: 20, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text("${l10n.inputSleep}: ${editSleep.toStringAsFixed(1)}h", style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Slider(
                          value: editSleep, 
                          min: 0.0, 
                          max: 10.0, 
                          activeColor: Colors.indigo, 
                          onChanged: (val) => setSheetState(() => editSleep = val)
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // --- 3. KATEGORISIERTE TAGS (Wie im Main Screen) ---
                        ..._combinedTagsByCategory.entries.map((entry) { 
                          if (entry.value.isEmpty) return const SizedBox.shrink(); 
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              // Kategorie-Titel
                              Text(
                                entry.key.toUpperCase(), 
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w800, 
                                  color: Colors.grey.shade500, 
                                  letterSpacing: 1.1
                                )
                              ), 
                              const SizedBox(height: 10), 
                              
                              // Tags
                              Wrap(
                                spacing: 8.0, 
                                runSpacing: 8.0, 
                                children: entry.value.map((tag) {
                                  final isSelected = editTags.contains(tag);
                                  return ChoiceChip(
                                    label: Text(tag), 
                                    selected: isSelected,
                                    selectedColor: Colors.black87,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: isSelected ? 2 : 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected ? Colors.transparent : Colors.grey.shade300
                                      )
                                    ),
                                    onSelected: (s) => setSheetState(() => s ? editTags.add(tag) : editTags.remove(tag))
                                  );
                                }).toList()
                              ),
                              const SizedBox(height: 20), // Abstand zur nächsten Kategorie
                            ]
                          ); 
                        }),
                        
                        const SizedBox(height: 10),
                        
                        // Notizfeld
                        TextField(
                          controller: editNoteCtrl,
                          decoration: InputDecoration(
                            hintText: l10n.inputNoteHint,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.newline, 
                        ),
                        // Extra Platz unten, damit man bequem scrollen kann
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
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
  // 1. Widget leeren (nur auf Handy)
  // Wir überschreiben den alten Streak-Wert mit "--" oder "0", damit der nächste User
  // nicht die Daten des Vorgängers sieht.
  if (!kIsWeb) {
    try {
      await HomeWidget.saveWidgetData<String>('tv_streak_value', '--'); 
      await HomeWidget.updateWidget(
        name: 'MoodWidgetProvider',
        androidName: 'MoodWidgetProvider',
        iOSName: 'MoodWidget',
      );
    } catch (e) {
      debugPrint("Fehler beim Widget-Reset: $e");
    }
  }

  // 2. Supabase Logout
  await Supabase.instance.client.auth.signOut();

  // 3. Navigation zurück zum Login
  if (mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthGate()), 
      (route) => false
    );
  }
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
    
    // 1. Eigene ID holen
    final myUserId = Supabase.instance.client.auth.currentUser?.id;
    if (myUserId == null) return 0;

    // 2. FILTERN: Nur Einträge nehmen, die MIR gehören.
    // Partner-Einträge (die eine andere user_id haben) werden hier ignoriert.
    final myEntriesOnly = _allEntries.where((entry) {
      return entry.userId == myUserId; 
    }).toList();

    if (myEntriesOnly.isEmpty) return 0;

    // 3. Berechnung NUR mit den eigenen Einträgen fortsetzen
    final uniqueDates = myEntriesOnly
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (uniqueDates.first.isBefore(yesterday)) { return 0; }
    
    int streak = 0;
    DateTime checkDate = uniqueDates.first; 
    
    for (var date in uniqueDates) {
      if (DateUtils.isSameDay(date, checkDate)) { 
        streak++; 
        checkDate = checkDate.subtract(const Duration(days: 1)); 
      } else { 
        break; 
      }
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
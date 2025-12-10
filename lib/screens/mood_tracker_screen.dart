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

import '../models/mood_entry.dart';
import '../models/profile.dart';
import '../models/subscription.dart';
import '../widgets/mood_input_view.dart';
import '../widgets/stats_view.dart';
import '../widgets/profile_view.dart'; // <--- WICHTIG: Der neue Import
import '../utils/mood_utils.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
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

  final Set<String> _customTagNames = {};

  final Map<String, List<String>> _baseTagsByCategory = {
    'Soziales': ['Familie', 'Beziehung', 'Freunde', 'Party'],
    'Körper & Geist': ['Sport', 'Schlaf', 'Essen', 'Gesundheit', 'Meditation'],
    'Pflichten': ['Arbeit', 'Schule', 'Hausaufgaben', 'Uni', 'Haushalt'],
    'Freizeit & Umwelt': ['Hobby', 'Reisen', 'Wetter', 'Gaming', 'Lesen', 'Musik'],
    'Sonstiges': [],
  };

  Map<String, List<String>> _combinedTagsByCategory = {};

  List<String> get _allAvailableTags {
    return _combinedTagsByCategory.values.expand((x) => x).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeTagsMap();
    _initializeData();
    _checkSubscription();
  }

  void _initializeTagsMap() {
    final newMap = Map<String, List<String>>.from(
      _baseTagsByCategory.map((k, v) => MapEntry(k, List<String>.from(v)))
    );

    if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: ''));
      
      if (profile.isCycleTracking) {
        final cycleTags = [
          'Periode (Leicht)', 'Periode (Mittel)', 'Periode (Stark)', 
          'Schmierblutung', 'Regelschmerzen', 'PMS', 'Ovulation'
        ];
        
        final combined = <String, List<String>>{
          'Zyklus & Körper': cycleTags,
          ...newMap 
        };
        
        _combinedTagsByCategory = combined;
        return;
      }
    }
    _combinedTagsByCategory = newMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; 
        
    final bgColor = _selectedIndex == 0 
        ? MoodUtils.getBackgroundColor(_currentMoodValue) 
        : const Color(0xFFF2F4F8); 

    final headerTextColor = Colors.black87;

    final dateString = DateUtils.isSameDay(_selectedDate, DateTime.now()) 
        ? "Heute" : DateFormat('dd.MM.yyyy').format(_selectedDate);

    final relevantEntries = (_selectedProfileId == null) 
        ? <MoodEntry>[] 
        : _allEntries.where((e) => e.profileId == _selectedProfileId).toList();

    final entriesForDate = relevantEntries.where((entry) {
      return DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList();

    final currentProfileName = _profiles.isNotEmpty && _selectedProfileId != null
        ? _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: '')).name
        : "Unbekannt";
    
    int? currentCycleDay;
     if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
      if (profile.isCycleTracking && profile.lastPeriodDate != null) {
        final difference = _selectedDate.difference(profile.lastPeriodDate!).inDays;
        if (difference >= 0) currentCycleDay = difference + 1;
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
              // --- HEADER BEREICH ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linke Seite: Datum & Profil
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
                                        children: [
                                          Text(
                                            p.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800, 
                                              color: headerTextColor,
                                              fontSize: 22, 
                                              height: 1.2,
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
                                    const Text("Neu..."), 
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
                                          Text("Neu...", style: TextStyle(color: (!_isPro && _profiles.isNotEmpty) ? Colors.grey : Colors.indigo)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      // Rechte Seite: Icons
                      Row(
                        children: [
                          // Streak Badge (Flamme)
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
                            entries: _allEntries,
                            isPro: _isPro,
                            onLogout: _signOut,
                            onManageSubscription: _isPro ? _openCustomerPortal : _startCheckout,
                            onContactSupport: () {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Support-Feature kommt bald!")));
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Lottie
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
      
      // Navbar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.add_reaction_outlined),
              selectedIcon: Icon(Icons.add_reaction, color: primaryColor),
              label: 'Eintrag',
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights, color: primaryColor),
              label: 'Statistik',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeData() async {
    await _loadProfiles();
    await _loadEntries();
    await _loadCustomTags();
  }

  Future<void> _loadCustomTags() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client.from('user_tags').select('name, category').order('name'); 
      final data = response as List<dynamic>;
      
      setState(() {
        _initializeTagsMap(); 
        _customTagNames.clear();
        for (var item in data) {
          final tagName = item['name'] as String;
          String category = item['category'] ?? 'Sonstiges';
          if (!_combinedTagsByCategory.containsKey(category)) {
            if (_combinedTagsByCategory.containsKey('Sonstiges')) {
              category = 'Sonstiges';
            } else {
              _combinedTagsByCategory[category] = [];
            }
          }
          _combinedTagsByCategory[category]?.add(tagName);
          _customTagNames.add(tagName); 
        }
      });
    } catch (e) { debugPrint("Tag-Fehler: $e"); }
  }

  // --- TAG MANAGEMENT ---
  void _showTagOptions(String tagName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Padding(padding: const EdgeInsets.all(20.0), child: Text("Optionen für '$tagName'", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Umbenennen"), onTap: () { Navigator.pop(ctx); _editCustomTagName(tagName); }),
              ListTile(leading: const Icon(Icons.drive_file_move, color: Colors.orange), title: const Text("Kategorie verschieben"), onTap: () { Navigator.pop(ctx); _moveCustomTagCategory(tagName); }),
              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Löschen", style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(ctx); _deleteCustomTag(tagName); }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCustomTag(String tagName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Tag '$tagName' löschen?"),
        content: const Text("Dieser Tag wird aus der Auswahl entfernt."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Abbrechen")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Löschen", style: TextStyle(color: Colors.red)))],
      ),
    );
    if (confirm != true) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client.from('user_tags').delete().eq('user_id', user.id).eq('name', tagName);
      if (_selectedTags.contains(tagName)) setState(() => _selectedTags.remove(tagName));
      await _loadCustomTags();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tag gelöscht")));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
  }

  Future<void> _editCustomTagName(String oldName) async {
    String newName = oldName;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tag umbenennen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(autofocus: true, controller: TextEditingController(text: oldName), onChanged: (val) => newName = val, decoration: InputDecoration(labelText: "Neuer Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () async {
                  if (newName.trim().isNotEmpty && newName != oldName) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await Supabase.instance.client.from('user_tags').update({'name': newName.trim()}).eq('user_id', user.id).eq('name', oldName);
                      if (_selectedTags.contains(oldName)) { setState(() { _selectedTags.remove(oldName); _selectedTags.add(newName.trim()); }); }
                      await _loadCustomTags();
                      if (mounted) Navigator.of(context).pop();
                    }
                  }
                }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Speichern")),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _moveCustomTagCategory(String tagName) async {
    String selectedCategory = _baseTagsByCategory.keys.first;
    final categories = _baseTagsByCategory.keys.toList();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kategorie für '$tagName'", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                InputDecorator(decoration: InputDecoration(labelText: "Neue Kategorie", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedCategory, isDense: true, items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (val) { if (val != null) setDialogState(() => selectedCategory = val); }))),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () async {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        await Supabase.instance.client.from('user_tags').update({'category': selectedCategory}).eq('user_id', user.id).eq('name', tagName);
                        await _loadCustomTags();
                        if (mounted) Navigator.of(this.context).pop();
                      }
                    }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Verschieben")),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _addNewTagDialog() async {
    String newTag = "";
    String selectedCategory = "Freizeit & Umwelt";
    final categories = _baseTagsByCategory.keys.toList();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Neuen Tag erstellen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(autofocus: true, decoration: InputDecoration(hintText: "Name (z.B. Yoga)", labelText: "Bezeichnung", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (val) => newTag = val),
                  const SizedBox(height: 20),
                  InputDecorator(decoration: InputDecoration(labelText: "Kategorie", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedCategory, isDense: true, items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (val) { if (val != null) { setDialogState(() => selectedCategory = val); } }))),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: () async {
                        if (newTag.trim().isNotEmpty) {
                          final user = Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            await Supabase.instance.client.from('user_tags').insert({'user_id': user.id, 'name': newTag.trim(), 'category': selectedCategory });
                            if (!context.mounted) return;
                            await _loadCustomTags();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }
                        }
                      }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Hinzufügen")),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  // --- LOGIC ---
  Future<void> _checkSubscription() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client.from('subscriptions').select().eq('user_id', user.id).maybeSingle(); 
      if (data != null) {
        final sub = Subscription.fromMap(data);
        if (mounted) setState(() { _isPro = sub.isPro; _stripeCustomerId = sub.customerId; });
      }
    } catch (e) { debugPrint("Fehler beim Abo-Check: $e"); }
  }

  Future<void> _loadProfiles() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final response = await Supabase.instance.client.from('profiles').select().order('created_at');
      final data = response as List<dynamic>;

      if (data.isEmpty) {
        await Supabase.instance.client.from('profiles').insert({'user_id': userId, 'name': 'Ich', 'is_cycle_tracking': false });
        if (mounted) _loadProfiles(); 
        return;
      }

      setState(() {
        _profiles = data.map((json) => Profile.fromJson(json)).toList();
        if (_selectedProfileId == null && _profiles.isNotEmpty) {
          _selectedProfileId = _profiles.first.id;
          _initializeTagsMap(); 
        }
      });
      if (_selectedProfileId != null) _loadEntries();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler beim Laden: $e"))); }
  }

  Future<void> _changeProfile(String? newId) async {
    if (newId != null) {
      setState(() => _selectedProfileId = newId);
      await _loadCustomTags(); 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_profile_id', newId);
      _loadEntries(); 
    }
  }

  Future<void> _loadEntries() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final response = await Supabase.instance.client.from('mood_entries').select().order('created_at', ascending: false);
      final data = response as List<dynamic>;
      setState(() { _allEntries = data.map((json) => MoodEntry.fromMap(json)).toList(); _isLoading = false; });
    } catch (e) { debugPrint("Lade-Fehler: $e"); if (mounted) setState(() => _isLoading = false); }
  }

  void _createNewProfile() {
    if (!_isPro && _profiles.isNotEmpty) {
      _showPremiumSheet(context, "Mehrere Profile", "In der Free-Version hast du ein Profil.\nMöchtest du Profile für Partner, Kinder oder Haustiere anlegen?");
      setState(() {}); 
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogCtx) { 
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Neues Profil erstellen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: controller, decoration: InputDecoration(hintText: "Name (z.B. Kind 1, Partner)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), autofocus: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;
                      await Supabase.instance.client.from('profiles').insert({'user_id': userId, 'name': name});
                      if (mounted) { Navigator.of(context).pop(); _loadProfiles(); }
                    }
                  }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Erstellen")),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editCurrentProfileDialog() async {
    if (_selectedProfileId == null) return;
    final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
    final nameCtrl = TextEditingController(text: profile.name);
    bool tracking = profile.isCycleTracking;
    DateTime? lastPeriod = profile.lastPeriodDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (innerCtx, setDialogState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text("Profil bearbeiten", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [const Icon(Icons.water_drop, color: Colors.pinkAccent), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Zyklus tracken", style: TextStyle(fontWeight: FontWeight.bold)), Text("Berechnet Zyklustage", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])), Switch(value: tracking, activeTrackColor: Colors.pinkAccent, thumbColor: const WidgetStatePropertyAll(Colors.white), onChanged: (val) => setDialogState(() => tracking = val))]),
                ),

                if (tracking) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await _showModernDatePicker(lastPeriod ?? DateTime.now()); 
                      if (picked != null) setDialogState(() => lastPeriod = picked); 
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [const Icon(Icons.calendar_today, color: Colors.grey), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Start letzte Periode", style: TextStyle(fontWeight: FontWeight.bold)), Text(lastPeriod == null ? "Bitte wählen" : DateFormat('dd.MM.yyyy').format(lastPeriod!), style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.bold))])]),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { final newName = nameCtrl.text.trim(); if (newName.isNotEmpty) { await _updateProfile(profile.id, newName, tracking, lastPeriod); if (mounted) Navigator.of(context).pop(); } }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Speichern")))
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _updateProfile(String id, String name, bool tracking, DateTime? lastPeriod) async {
    try {
      await Supabase.instance.client.from('profiles').update({'name': name, 'is_cycle_tracking': tracking, 'last_period_date': lastPeriod?.toIso8601String()}).eq('id', id);
      await _loadProfiles(); 
      await _loadCustomTags();
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
  }

  Future<void> _saveEntry() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;
    final newEntry = MoodEntry(timestamp: DateTime.now(), score: _currentMoodValue, sleepRating: _trackSleep ? _currentSleepValue : null, tags: Set.from(_selectedTags), note: _noteController.text.trim(), profileId: _selectedProfileId);
    try {
      final res = await Supabase.instance.client.from('mood_entries').insert({'user_id': user.id, 'profile_id': _selectedProfileId, 'score': newEntry.score, 'sleep_rating': newEntry.sleepRating, 'tags': newEntry.tags.toList(), 'note': newEntry.note}).select().single();
      final savedEntry = MoodEntry.fromMap(res);
      setState(() { _allEntries.insert(0, savedEntry); _showSuccessAnimation = true; });
      Timer(const Duration(milliseconds: 2000), () { if (mounted) { setState(() { _showSuccessAnimation = false; _selectedTags.clear(); _noteController.clear(); }); } });
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
  }

  Future<void> _deleteEntry(String entryId) async {
    try {
      await Supabase.instance.client.from('mood_entries').delete().eq('id', entryId); 
      setState(() => _allEntries.removeWhere((e) => e.id == entryId));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gelöscht"), duration: Duration(seconds: 1)));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
  }

  Future<void> _updateEntry(String entryId, double newScore, double newSleep, Set<String> newTags, String? newNote) async {
    try {
      final res = await Supabase.instance.client.from('mood_entries').update({'score': newScore, 'sleep_rating': newSleep, 'tags': newTags.toList(), 'note': newNote}).eq('id', entryId).select().single();
      final updatedEntry = MoodEntry.fromMap(res);
      setState(() { final index = _allEntries.indexWhere((e) => e.id == entryId); if (index != -1) _allEntries[index] = updatedEntry; });
      if (mounted) Navigator.pop(context); 
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
  }

  void _showEditSheet(MoodEntry entry) {
    double editScore = entry.score;
    double editSleep = entry.sleepRating ?? 5.0; 
    Set<String> editTags = Set.from(entry.tags);
    final TextEditingController editNoteCtrl = TextEditingController(text: entry.note);

    showModalBottomSheet(
      context: context, isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
            final moodData = MoodUtils.getMoodData(editScore);
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text("Bearbeiten", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(height: 20),
                  Text(moodData['emoji']!, style: const TextStyle(fontSize: 40)),
                  Slider(value: editScore, min: 0.0, max: 10.0, onChanged: (val) => setSheetState(() => editScore = val)), const SizedBox(height: 20),
                  Slider(value: editSleep, min: 0.0, max: 10.0, activeColor: Colors.indigo, onChanged: (val) => setSheetState(() => editSleep = val)), const SizedBox(height: 20),
                  Wrap(spacing: 6, children: _allAvailableTags.map((tag) { final isSelected = editTags.contains(tag); return ChoiceChip(label: Text(tag), selected: isSelected, onSelected: (s) => setSheetState(() => s ? editTags.add(tag) : editTags.remove(tag))); }).toList()), const SizedBox(height: 20),
                  TextField(controller: editNoteCtrl, decoration: const InputDecoration(hintText: "Notiz...")), const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => _updateEntry(entry.id!, editScore, editSleep, editTags, editNoteCtrl.text.trim()), child: const Text("Speichern"))
                ],
              ),
            );
        });
      },
    );
  }

  Future<void> _signOut() async { await Supabase.instance.client.auth.signOut(); }

  Future<void> _startCheckout() async {
    final user = Supabase.instance.client.auth.currentUser; if (user == null) return;
    setState(() => _isLoading = true);
    final String returnUrl = kIsWeb ? 'https://celadon-pasca-8b960a.netlify.app/' : 'moodtracker://home';
    try {
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-checkout'), body: jsonEncode({'userEmail': user.email, 'userId': user.id, 'priceId': 'price_1SbFNUFoVhyNl27phao8dSGu', 'returnUrl': returnUrl}));
      if (response.statusCode == 200) { final url = Uri.parse(jsonDecode(response.body)['url']); if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); } 
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _openCustomerPortal() async {
    if (_stripeCustomerId == null) return;
    setState(() => _isLoading = true);
    final String returnUrl = kIsWeb ? 'https://celadon-pasca-8b960a.netlify.app/' : 'moodtracker://home';
    try {
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-portal'), body: jsonEncode({'customerId': _stripeCustomerId, 'returnUrl': returnUrl}));
      if (response.statusCode == 200) { final url = Uri.parse(jsonDecode(response.body)['url']); if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _toggleTag(String tag) {
    if (_showSuccessAnimation) return;
    setState(() { if (_selectedTags.contains(tag)) { _selectedTags.remove(tag); } else { _selectedTags.add(tag); } });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await _showModernDatePicker(_selectedDate);
    if (picked != null && picked != _selectedDate) { setState(() => _selectedDate = picked); }
  }

  Future<DateTime?> _showModernDatePicker(DateTime initialDate) async {
    DateTime tempDate = initialDate;
    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text("Datum wählen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Theme(
                  data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.indigo, onPrimary: Colors.white, onSurface: Colors.black87)),
                  child: CalendarDatePicker(initialDate: tempDate, firstDate: DateTime(2023), lastDate: DateTime.now(), onDateChanged: (newDate) { setSheetState(() => tempDate = newDate); }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => Navigator.pop(ctx, tempDate), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("AUSWÄHLEN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(height: 10), 
              ],
            ),
          );
        }
      ),
    );
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
    final int streak = _calculateStreak();
    Color color;
    IconData icon = Icons.local_fire_department_outlined; 
    bool isLegendary = false; 

    if (streak < 3) { color = Colors.grey.shade400; } 
    else if (streak < 8) { color = Colors.amber.shade700; icon = Icons.local_fire_department; } 
    else if (streak < 15) { color = Colors.orange.shade700; icon = Icons.local_fire_department; } 
    else if (streak < 29) { color = Colors.redAccent.shade700; icon = Icons.whatshot; } 
    else { color = Colors.deepPurpleAccent; isLegendary = true; icon = Icons.auto_awesome; }

    return InkWell(
      onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$streak Tage in Folge! Weiter so! 🔥"))); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
        margin: const EdgeInsets.only(right: 8), 
        decoration: BoxDecoration(
          color: isLegendary ? null : Colors.white,
          gradient: isLegendary ? LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]) : null,
          borderRadius: BorderRadius.circular(20), 
          border: isLegendary ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isLegendary ? Colors.white : color),
            const SizedBox(width: 5),
            Text("$streak", style: TextStyle(fontWeight: FontWeight.w800, color: isLegendary ? Colors.white : color, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showPremiumSheet(BuildContext context, String title, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20),
            const Icon(Icons.diamond, size: 40, color: Colors.indigo), const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), const SizedBox(height: 10),
            Text(message, style: TextStyle(fontSize: 15, color: Colors.black87.withValues(alpha: 0.7), height: 1.5), textAlign: TextAlign.center), const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); _startCheckout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: Colors.indigo.withValues(alpha: 0.4)), child: const Text("JETZT PRO WERDEN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vielleicht später", style: TextStyle(color: Colors.grey))),
          ]),
      ),
    );
  }
}
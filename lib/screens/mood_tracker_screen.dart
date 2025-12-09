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

  // Diese Methode muss angepasst werden, um dynamisch zu reagieren
  void _initializeTagsMap() {
    // 1. Basis kopieren
    final newMap = Map<String, List<String>>.from(
      _baseTagsByCategory.map((k, v) => MapEntry(k, List<String>.from(v)))
    );

    // 2. Prüfen: Zyklus aktiv?
    if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: ''));
      
      if (profile.isCycleTracking) {
        // 3. Zyklus-Kategorie EINFÜGEN (am besten ganz vorne oder an 2. Stelle)
        // Da Maps ungeordnet sein können, erstellen wir eine neue LinkedHashMap oder fügen es einfach hinzu.
        // Für die einfache Anzeige reicht 'putIfAbsent' oder direktes Setzen.
        
        final cycleTags = [
          'Periode (Leicht)', 
          'Periode (Mittel)', 
          'Periode (Stark)', 
          'Schmierblutung',
          'Regelschmerzen',
          'PMS',
          'Ovulation'
        ];
        
        // Trick: Damit es oben steht, bauen wir die Map neu zusammen
        final combined = <String, List<String>>{
          'Zyklus & Körper': cycleTags, // Neue Kategorie ganz oben
          ...newMap // Der Rest danach
        };
        
        _combinedTagsByCategory = combined;
        return;
      }
    }

    _combinedTagsByCategory = newMap;
  }

  @override
  Widget build(BuildContext context) {
    // Wir holen uns deine Farben aus dem Theme (AppTheme)
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Dein dunkles Grau
        
    // Stimmungshintergrund:
    // Wenn Statistik tab: neutrales Grau. Sonst: Stimmungsfarbe.
    final bgColor = _selectedIndex == 0 
        ? MoodUtils.getBackgroundColor(_currentMoodValue) 
        : const Color(0xFFF2F4F8); 

    // Header Text Farbe (Dunkelgrau für guten Kontrast)
    final headerTextColor = Colors.black87;

    final dateString = DateUtils.isSameDay(_selectedDate, DateTime.now()) 
        ? "Heute" : DateFormat('dd.MM.yyyy').format(_selectedDate);

    // ... (Filterlogik & Zyklus bleibt gleich wie vorher) ...
    final relevantEntries = (_selectedProfileId == null) 
        ? <MoodEntry>[] 
        : _allEntries.where((e) => e.profileId == _selectedProfileId).toList();

    final entriesForDate = relevantEntries.where((entry) {
      return DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList();

    final currentProfileName = _profiles.isNotEmpty && _selectedProfileId != null
        ? _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: '')).name
        : "Unbekannt";
    
    // (Hier deine Zyklus-Logik einfügen/behalten, falls nicht im Snippet)
    int? currentCycleDay;
     if (_profiles.isNotEmpty && _selectedProfileId != null) {
      final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
      if (profile.isCycleTracking && profile.lastPeriodDate != null) {
        final difference = _selectedDate.difference(profile.lastPeriodDate!).inDays;
        if (difference >= 0) currentCycleDay = difference + 1;
      }
    }

    return Scaffold(
      backgroundColor: bgColor, // Der Hintergrund atmet die Stimmung
      
      // KEINE Standard-AppBar! Wir bauen das Layout selbst.
      body: Stack(
        children: [
          Column(
            children: [
              // --- HEADER BEREICH (Farbig) ---
              // Dieser Bereich löst dein "Klebt oben"-Problem
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20), // Mehr Abstand oben (20)
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const SizedBox(height: 4),
                          if (_profiles.isNotEmpty)
                            InkWell(
                              onTap: null, 
                              child: Row(
                                children: [
                                  // Profil Name
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedProfileId,
                                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                      // Nutzt deine Poppins Schriftart automatisch via Theme
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: headerTextColor
                                      ),
                                      isDense: true,
                                      onChanged: (String? newValue) {
                                        if (newValue == 'new') {
                                          _createNewProfile();
                                        } else if (newValue != null) {
                                          _changeProfile(newValue);
                                        }
                                      },
                                      items: [
                                        ..._profiles.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                                        const DropdownMenuItem(value: 'new', child: Text("+ Neu...")),
                                      ],
                                    ),
                                  ),
                                  // Edit Stift
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, size: 18, color: headerTextColor.withValues(alpha: 0.5)),
                                    onPressed: _editCurrentProfileDialog,
                                    tooltip: "Profil bearbeiten",
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      // Rechte Seite: Icons
                      Row(
                        children: [
                          if (!_isPro) 
                            IconButton(
                              icon: const Icon(Icons.diamond_outlined), 
                              color: primaryColor, // Deine Farbe
                              onPressed: _startCheckout
                            ),
                          if (_isPro) 
                            IconButton(
                              icon: const Icon(Icons.settings_outlined), 
                              color: headerTextColor, 
                              onPressed: _openCustomerPortal
                            ),
                          
                          IconButton(icon: Icon(Icons.calendar_today_outlined, color: headerTextColor), onPressed: _pickDate),
                          IconButton(icon: Icon(Icons.logout, color: headerTextColor), onPressed: _signOut),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 10),

              // --- CONTENT SHEET (Weiß, Runde Ecken oben) ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white, // Das Blatt Papier
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
                      : StatsView(
                          entries: relevantEntries,
                          profileName: currentProfileName,
                          isPro: _isPro,
                          onUnlockPressed: _startCheckout,
                        ),
                  ),
                ),
              ),
            ],
          ),

          // Lottie Animation
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
      
      // Navigation Bar unten
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.3), // Dein Amber, soft
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

      final response = await Supabase.instance.client
          .from('user_tags')
          .select('name, category')
          .order('name'); 

      final data = response as List<dynamic>;
      
      setState(() {
        // 1. Basis-Struktur (Standard-Kategorien + Zyklus) neu laden (Reset)
        _initializeTagsMap(); 
        _customTagNames.clear();

        for (var item in data) {
          final tagName = item['name'] as String;
          // Falls in der DB 'null' steht, nehmen wir 'Sonstiges' als Fallback
          String category = item['category'] ?? 'Sonstiges';
          
          // 2. Sicherheits-Check: Gibt es diese Kategorie in unserer aktuellen Map?
          // (Falls du z.B. eine Kategorie im Code umbenannt hast, aber in der DB noch der alte Name steht)
          if (!_combinedTagsByCategory.containsKey(category)) {
            // Fallback A: Wenn wir eine "Sonstiges"-Box haben, packen wir es da rein.
            if (_combinedTagsByCategory.containsKey('Sonstiges')) {
              category = 'Sonstiges';
            } else {
              // Fallback B: Wenn gar nichts passt, erstellen wir die Kategorie dynamisch,
              // damit der Tag auf keinen Fall verloren geht.
              _combinedTagsByCategory[category] = [];
            }
          }

          // 3. Tag einsortieren
          _combinedTagsByCategory[category]?.add(tagName);
          
          // Merken, dass es ein eigener Tag ist (für Delete-Option)
          _customTagNames.add(tagName); 
        }
      });
    } catch (e) {
      debugPrint("Tag-Fehler: $e");
    }
  }

  // --- TAG MANAGEMENT ---

  void _showTagOptions(String tagName) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Optionen für '$tagName'", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Umbenennen"),
              onTap: () {
                Navigator.pop(ctx);
                _editCustomTagName(tagName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move, color: Colors.orange),
              title: const Text("Kategorie verschieben"),
              onTap: () {
                Navigator.pop(ctx);
                _moveCustomTagCategory(tagName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Löschen", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteCustomTag(tagName);
              },
            ),
            const SizedBox(height: 10),
          ],
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Abbrechen")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Löschen", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('user_tags').delete().eq('user_id', user.id).eq('name', tagName);

      if (_selectedTags.contains(tagName)) {
        setState(() => _selectedTags.remove(tagName));
      }
      
      await _loadCustomTags();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tag gelöscht")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    }
  }

  Future<void> _editCustomTagName(String oldName) async {
    String newName = oldName;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tag umbenennen"),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: oldName),
          onChanged: (val) => newName = val,
          decoration: const InputDecoration(labelText: "Neuer Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Abbrechen")),
          ElevatedButton(
            onPressed: () async {
              if (newName.trim().isNotEmpty && newName != oldName) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  await Supabase.instance.client
                      .from('user_tags')
                      .update({'name': newName.trim()})
                      .eq('user_id', user.id)
                      .eq('name', oldName);
                  
                  if (_selectedTags.contains(oldName)) {
                    setState(() {
                      _selectedTags.remove(oldName);
                      _selectedTags.add(newName.trim());
                    });
                  }
                  
                  await _loadCustomTags();
                  
                  // FIX: Wir nutzen 'context' (vom Screen) statt 'ctx' (vom Dialog)
                  // zusammen mit dem mounted check des Screens.
                  if (mounted) Navigator.of(context).pop();
                }
              }
            },
            child: const Text("Speichern"),
          )
        ],
      ),
    );
  }

  Future<void> _moveCustomTagCategory(String tagName) async {
    String selectedCategory = _baseTagsByCategory.keys.first;
    final categories = _baseTagsByCategory.keys.toList();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Kategorie für '$tagName'"),
            content: InputDecorator(
              decoration: const InputDecoration(labelText: "Neue Kategorie", border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isDense: true,
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Abbrechen")),
              ElevatedButton(
                onPressed: () async {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    await Supabase.instance.client
                        .from('user_tags')
                        .update({'category': selectedCategory})
                        .eq('user_id', user.id)
                        .eq('name', tagName);
                    
                    await _loadCustomTags();
                    
                    // FIX: Auch hier 'Navigator.of(context).pop()' nutzen
                    if (mounted) Navigator.of(this.context).pop();
                  }
                },
                child: const Text("Verschieben"),
              )
            ],
          );
        }
      ),
    );
  }

  Future<void> _addNewTagDialog() async {
    String newTag = "";
    String selectedCategory = "Freizeit & Umwelt";
    
    final categories = _baseTagsByCategory.keys.toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Neuen Tag erstellen"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Name (z.B. Yoga)", labelText: "Bezeichnung"),
                    onChanged: (val) => newTag = val,
                  ),
                  const SizedBox(height: 20),
                  
                  InputDecorator(
                    decoration: const InputDecoration(labelText: "Kategorie", border: OutlineInputBorder()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isDense: true,
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCategory = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
                ElevatedButton(
                  onPressed: () async {
                    if (newTag.trim().isNotEmpty) {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        await Supabase.instance.client.from('user_tags').insert({
                          'user_id': user.id,
                          'name': newTag.trim(),
                          'category': selectedCategory 
                        });
                        
                        if (!context.mounted) return;
                        await _loadCustomTags();
                        
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text("Hinzufügen"),
                )
              ],
            );
          }
        );
      },
    );
  }

  // --- RESTLICHE LOGIK ---
  
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
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final response = await Supabase.instance.client.from('profiles').select().order('created_at');
      final data = response as List<dynamic>;
      final profiles = data.map((json) => Profile.fromMap(json)).toList();
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getString('last_profile_id');
      setState(() {
        _profiles = profiles;
        if (_profiles.isNotEmpty) {
          if (lastProfileId != null && _profiles.any((p) => p.id == lastProfileId)) {
            _selectedProfileId = lastProfileId;
          } else {
            _selectedProfileId = _profiles.first.id;
          }
        }

      _initializeTagsMap();

      });
    } catch (e) { debugPrint("Profil-Lade-Fehler: $e"); }
  }

  Future<void> _changeProfile(String? newId) async {
    if (newId != null) {
      setState(() => _selectedProfileId = newId);
      _initializeTagsMap();
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

  Future<void> _createNewProfile() async {
    final TextEditingController nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Neue Person hinzufügen"),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
          ElevatedButton(onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  final res = await Supabase.instance.client.from('profiles').insert({'user_id': user.id, 'name': name}).select().single();
                  if (!context.mounted) return;
                  final newProfile = Profile.fromMap(res);
                  setState(() => _profiles.add(newProfile));
                  _changeProfile(newProfile.id);
                  Navigator.pop(context);
                }
              }
            }, child: const Text("Erstellen"))
        ],
      ),
    );
  }

  Future<void> _editCurrentProfileDialog() async {
    if (_selectedProfileId == null) return;
    
    final profile = _profiles.firstWhere((p) => p.id == _selectedProfileId);
    
    final nameCtrl = TextEditingController(text: profile.name);
    bool tracking = profile.isCycleTracking;
    DateTime? lastPeriod = profile.lastPeriodDate;

    await showDialog(
      context: context,
      // FIX 1: Wir nennen das hier 'dialogCtx' statt 'context', um Verwirrung zu vermeiden
      builder: (dialogCtx) => StatefulBuilder(
        builder: (innerCtx, setDialogState) {
          return AlertDialog(
            title: const Text("Profil bearbeiten"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 20),
                const Divider(),
                
                SwitchListTile(
                  title: const Text("Zyklus tracken?"),
                  subtitle: const Text("Berechnet den Zyklustag"),
                  value: tracking,
                  activeTrackColor: Colors.pinkAccent, 
                  onChanged: (val) => setDialogState(() => tracking = val),
                ),

                if (tracking)
                  ListTile(
                    title: const Text("Start letzte Periode"),
                    subtitle: Text(lastPeriod == null 
                        ? "Bitte wählen" 
                        : DateFormat('dd.MM.yyyy').format(lastPeriod!)),
                    trailing: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
                    onTap: () async {
                      // Hier nutzen wir 'context' vom Haupt-Screen für den DatePicker, das ist ok
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: lastPeriod ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => lastPeriod = picked);
                      }
                    },
                  ),
              ],
            ),
            actions: [
              // Abbrechen: Hier ist es egal, welchen Context wir nehmen, da kein Async
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("Abbrechen")),
              
              ElevatedButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    // Async Operation
                    await _updateProfile(profile.id, newName, tracking, lastPeriod);
                    
                    // FIX 2: 'mounted' gehört zum State. 'context' gehört AUCH zum State.
                    // Da wir die inneren Variablen umbenannt haben, greift 'context' jetzt 
                    // automatisch auf den State-Context zu. Der Linter ist zufrieden.
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text("Speichern"),
              )
            ],
          );
        }
      ),
    );
  }

  Future<void> _updateProfile(String id, String name, bool tracking, DateTime? lastPeriod) async {
    try {
      await Supabase.instance.client.from('profiles').update({
        'name': name,
        'is_cycle_tracking': tracking,
        'last_period_date': lastPeriod?.toIso8601String(), // Datum formatieren
      }).eq('id', id);
      
      await _loadProfiles(); // Neu laden, damit die UI updated
      setState(() {
   _initializeTagsMap(); // <--- HIER AUFRUFEN, falls Tracking an/aus geschaltet wurde
});
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    }
  }

  Future<void> _saveEntry() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;
    final newEntry = MoodEntry(
      timestamp: DateTime.now(), score: _currentMoodValue, sleepRating: _trackSleep ? _currentSleepValue : null,
      tags: Set.from(_selectedTags), note: _noteController.text.trim(), profileId: _selectedProfileId,
    );
    try {
      final res = await Supabase.instance.client.from('mood_entries').insert({
        'user_id': user.id, 'profile_id': _selectedProfileId, 'score': newEntry.score,
        'sleep_rating': newEntry.sleepRating, 'tags': newEntry.tags.toList(), 'note': newEntry.note,
      }).select().single();
      final savedEntry = MoodEntry.fromMap(res);
      setState(() { _allEntries.insert(0, savedEntry); _showSuccessAnimation = true; });
      Timer(const Duration(milliseconds: 2000), () { 
        if (mounted) { 
          setState(() { _showSuccessAnimation = false; _selectedTags.clear(); _noteController.clear(); }); 
        } 
      });
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
      final res = await Supabase.instance.client.from('mood_entries').update({
        'score': newScore, 'sleep_rating': newSleep, 'tags': newTags.toList(), 'note': newNote,
      }).eq('id', entryId).select().single();
      final updatedEntry = MoodEntry.fromMap(res);
      setState(() {
        final index = _allEntries.indexWhere((e) => e.id == entryId);
        if (index != -1) _allEntries[index] = updatedEntry;
      });
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Bearbeiten", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  Text(moodData['emoji']!, style: const TextStyle(fontSize: 40)),
                  Slider(value: editScore, min: 0.0, max: 10.0, onChanged: (val) => setSheetState(() => editScore = val)),
                  const SizedBox(height: 20),
                  Slider(value: editSleep, min: 0.0, max: 10.0, activeColor: Colors.indigo, onChanged: (val) => setSheetState(() => editSleep = val)),
                  const SizedBox(height: 20),
                  Wrap(spacing: 6, children: _allAvailableTags.map((tag) {
                    final isSelected = editTags.contains(tag);
                    return ChoiceChip(label: Text(tag), selected: isSelected, onSelected: (s) => setSheetState(() => s ? editTags.add(tag) : editTags.remove(tag)));
                  }).toList()),
                  const SizedBox(height: 20),
                  TextField(controller: editNoteCtrl, decoration: const InputDecoration(hintText: "Notiz...")),
                  const SizedBox(height: 20),
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
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-checkout'),
        body: jsonEncode({'userEmail': user.email, 'userId': user.id, 'priceId': 'price_1SbFNUFoVhyNl27phao8dSGu', 'returnUrl': returnUrl}));
      if (response.statusCode == 200) {
        final url = Uri.parse(jsonDecode(response.body)['url']);
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); } 
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _openCustomerPortal() async {
    if (_stripeCustomerId == null) return;
    setState(() => _isLoading = true);
    final String returnUrl = kIsWeb ? 'https://celadon-pasca-8b960a.netlify.app/' : 'moodtracker://home';
    try {
      final response = await http.post(Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-portal'),
        body: jsonEncode({'customerId': _stripeCustomerId, 'returnUrl': returnUrl}));
      if (response.statusCode == 200) {
        final url = Uri.parse(jsonDecode(response.body)['url']);
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _toggleTag(String tag) {
    if (_showSuccessAnimation) return;
    setState(() { 
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag); 
      } else {
        _selectedTags.add(tag); 
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2023), lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }
}
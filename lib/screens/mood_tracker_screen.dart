import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Für kIsWeb
import 'package:shared_preferences/shared_preferences.dart';

// Modelle
import '../models/mood_entry.dart';
import '../models/profile.dart';
import '../models/subscription.dart';

// Widgets & Utils (Die neuen ausgelagerten Dateien)
import '../widgets/mood_input_view.dart';
import '../widgets/stats_view.dart';
import '../utils/mood_utils.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // --- 1. STATE VARIABLEN ---
  int _selectedIndex = 0;
  bool _showSuccessAnimation = false;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  // Eingabe State
  double _currentMoodValue = 5.0;
  double _currentSleepValue = 5.0;
  bool _trackSleep = true; 
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();

  // Daten State
  List<Profile> _profiles = [];
  String? _selectedProfileId;
  List<MoodEntry> _allEntries = [];
  
  // Abo State
  bool _isPro = false;
  String? _stripeCustomerId;

  // Tag State
  List<String> _customTags = [];
  final List<String> _defaultTags = [
    'Arbeit', 'Familie', 'Beziehung', 'Sport', 'Hobby',
    'Schlaf', 'Essen', 'Wetter', 'Gesundheit', 'Reisen', 'Schule', 'Hausaufgaben'
  ];

  List<String> get _allAvailableTags => [..._defaultTags, ..._customTags];

  // --- 2. INIT & BUILD ---

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkSubscription();
  }

  @override
  Widget build(BuildContext context) {
    // Hilfsdaten berechnen
    final bgColor = MoodUtils.getBackgroundColor(_currentMoodValue);
    final dateString = DateUtils.isSameDay(_selectedDate, DateTime.now()) 
        ? "Heute" 
        : DateFormat('dd.MM.yyyy').format(_selectedDate);

    final currentProfileName = _profiles.isNotEmpty && _selectedProfileId != null
        ? _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: '')).name
        : "Unbekannt";

    // Daten filtern
    final relevantEntries = (_selectedProfileId == null) 
        ? <MoodEntry>[] 
        : _allEntries.where((e) => e.profileId == _selectedProfileId).toList();

    final entriesForDate = relevantEntries.where((entry) {
      return DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList();

    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? bgColor : Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            
            if (_profiles.isNotEmpty)
              DropdownButton<String>(
                value: _selectedProfileId,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                underline: const SizedBox(), 
                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                isDense: true,
                onChanged: (String? newValue) {
                  if (newValue == 'new') {
                    _createNewProfile();
                  } else if (newValue != null) {
                    _changeProfile(newValue);
                  }
                },
                items: [
                  ..._profiles.map<DropdownMenuItem<String>>((Profile profile) {
                    return DropdownMenuItem<String>(
                      value: profile.id,
                      child: Text(profile.name),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: 'new',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text("Neu...", style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (!_isPro) 
            IconButton(
              icon: const Icon(Icons.diamond, color: Colors.indigo),
              onPressed: _startCheckout,
              tooltip: "Pro werden",
            ),
          if (_isPro)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black87),
              onPressed: _openCustomerPortal,
              tooltip: "Abo verwalten",
            ),
          
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut)
        ],
      ),

      body: Stack(
        children: [
          SafeArea(
            child: _selectedIndex == 0 
                // TAB 1: EINGABE (Ausgelagert in Widget)
                ? MoodInputView(
                    currentMoodValue: _currentMoodValue,
                    currentSleepValue: _currentSleepValue,
                    trackSleep: _trackSleep,
                    selectedTags: _selectedTags,
                    allAvailableTags: _allAvailableTags,
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
                  ) 
                // TAB 2: STATISTIK (Ausgelagert in Widget)
                : StatsView(
                    entries: relevantEntries,
                    profileName: currentProfileName,
                    isPro: _isPro,
                    onUnlockPressed: _startCheckout,
                  ),
          ),

          if (_showSuccessAnimation)
            Container(
              color: Colors.black45,
              child: Center(
                child: Lottie.asset('assets/success.json', repeat: false, width: 200),
              ),
            ),
        ],
      ),
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_reaction_outlined),
            selectedIcon: Icon(Icons.add_reaction),
            label: 'Eintrag',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  // --- 3. CONTROLLER / LOGIK METHODEN ---

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
          .select('name')
          .order('name'); 

      final data = response as List<dynamic>;
      setState(() {
        _customTags = data.map((e) => e['name'] as String).toList();
      });
    } catch (e) {
      debugPrint("Tag-Fehler: $e");
    }
  }

  Future<void> _checkSubscription() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .maybeSingle(); 

      if (data != null) {
        final sub = Subscription.fromMap(data);
        if (mounted) {
          setState(() {
            _isPro = sub.isPro;
            _stripeCustomerId = sub.customerId;
          });
        }
      }
    } catch (e) {
      debugPrint("Fehler beim Abo-Check: $e");
    }
  }

  Future<void> _loadProfiles() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('created_at');

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
      });
    } catch (e) {
      debugPrint("Profil-Lade-Fehler: $e");
    }
  }

  Future<void> _changeProfile(String? newId) async {
    if (newId != null) {
      setState(() {
        _selectedProfileId = newId;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_profile_id', newId);
      
      _loadEntries(); 
    }
  }

  Future<void> _loadEntries() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('mood_entries')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      
      setState(() {
        _allEntries = data.map((json) => MoodEntry.fromMap(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lade-Fehler: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewProfile() async {
    final TextEditingController nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Neue Person hinzufügen"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Name (z.B. Kind 1)"),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  final res = await Supabase.instance.client.from('profiles').insert({
                    'user_id': user.id,
                    'name': name
                  }).select().single();
                  
                  if (!context.mounted) return;
                  
                  final newProfile = Profile.fromMap(res);
                  setState(() {
                    _profiles.add(newProfile);
                  });
                  _changeProfile(newProfile.id);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Erstellen"),
          )
        ],
      ),
    );
  }

  Future<void> _addNewTagDialog() async {
    String newTag = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Neuen Tag erstellen"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "z.B. Gaming, Yoga..."),
          onChanged: (val) => newTag = val,
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
                    'name': newTag.trim()
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
      ),
    );
  }

  Future<void> _saveEntry() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;

    final newEntry = MoodEntry(
      timestamp: DateTime.now(),
      score: _currentMoodValue,
      sleepRating: _trackSleep ? _currentSleepValue : null,
      tags: Set.from(_selectedTags),
      note: _noteController.text.trim(),
      profileId: _selectedProfileId,
    );

    try {
      final res = await Supabase.instance.client.from('mood_entries').insert({
        'user_id': user.id,
        'profile_id': _selectedProfileId,
        'score': newEntry.score,
        'sleep_rating': newEntry.sleepRating,
        'tags': newEntry.tags.toList(),
        'note': newEntry.note,
      }).select().single();
      
      final savedEntry = MoodEntry.fromMap(res);

      setState(() {
        _allEntries.insert(0, savedEntry);
        _showSuccessAnimation = true;
      });

      Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
            _selectedTags.clear();
            _noteController.clear();
          });
        }
      });

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    try {
      await Supabase.instance.client
          .from('mood_entries')
          .delete()
          .eq('id', entryId); 

      setState(() {
        _allEntries.removeWhere((e) => e.id == entryId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eintrag gelöscht"), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler beim Löschen: $e")));
      }
    }
  }

  Future<void> _updateEntry(String entryId, double newScore, double newSleep, Set<String> newTags, String? newNote) async {
    try {
      final res = await Supabase.instance.client
          .from('mood_entries')
          .update({
            'score': newScore,
            'sleep_rating': newSleep,
            'tags': newTags.toList(),
            'note': newNote,
          })
          .eq('id', entryId)
          .select()
          .single();

      final updatedEntry = MoodEntry.fromMap(res);
      setState(() {
        final index = _allEntries.indexWhere((e) => e.id == entryId);
        if (index != -1) {
          _allEntries[index] = updatedEntry;
        }
      });
      
      if (mounted) Navigator.pop(context); 
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler beim Update: $e")));
    }
  }

  void _showEditSheet(MoodEntry entry) {
    double editScore = entry.score;
    double editSleep = entry.sleepRating ?? 5.0; 
    Set<String> editTags = Set.from(entry.tags);
    final TextEditingController editNoteCtrl = TextEditingController(text: entry.note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final moodData = MoodUtils.getMoodData(editScore);
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
                left: 20, 
                right: 20, 
                top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Eintrag bearbeiten", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  Text(moodData['emoji']!, style: const TextStyle(fontSize: 40)),
                  Slider(
                    value: editScore,
                    min: 0.0,
                    max: 10.0,
                    onChanged: (val) {
                      setSheetState(() => editScore = val); 
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bedtime, color: Colors.indigoAccent),
                      const SizedBox(width: 8),
                      Text(
                        "Schlaf: ${editSleep.toStringAsFixed(1)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10.0,
                      activeTrackColor: Colors.indigoAccent,
                      thumbColor: Colors.indigo,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    ),
                    child: Slider(
                      value: editSleep,
                      min: 0.0, max: 10.0,
                      onChanged: (val) => setSheetState(() => editSleep = val),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 6.0,
                    children: _allAvailableTags.map((tag) {
                      final isSelected = editTags.contains(tag);
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              editTags.add(tag);
                            } else {
                              editTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),

                  TextField(
                    controller: editNoteCtrl,
                    decoration: const InputDecoration(
                      hintText: "Notiz bearbeiten...",
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                    minLines: 1,
                  ),

                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () => _updateEntry(
                      entry.id!, 
                      editScore, 
                      editSleep, 
                      editTags, 
                      editNoteCtrl.text.trim()
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Änderungen speichern"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> _startCheckout() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final String returnUrl = kIsWeb 
        ? 'https://celadon-pasca-8b960a.netlify.app/' // Deine Netlify URL
        : 'moodtracker://home';

    try {
      final response = await http.post(
        Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-checkout'),
        body: jsonEncode({
          'userEmail': user.email,
          'userId': user.id,
          'priceId': 'price_1SbFNUFoVhyNl27phao8dSGu', 
          'returnUrl': returnUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = Uri.parse(data['url']);
        
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: ${response.body}")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCustomerPortal() async {
    if (_stripeCustomerId == null) return;
    
    setState(() => _isLoading = true);
    
    final String returnUrl = kIsWeb 
        ? 'https://celadon-pasca-8b960a.netlify.app/' 
        : 'moodtracker://home';

    try {
      final response = await http.post(
        Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-portal'),
        body: jsonEncode({
          'customerId': _stripeCustomerId,
          'returnUrl': returnUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = Uri.parse(data['url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: ${response.body}")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
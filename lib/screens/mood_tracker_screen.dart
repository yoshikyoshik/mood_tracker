import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

// Wir importieren unsere ausgelagerten Modelle
import '../models/mood_entry.dart';
import '../models/profile.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _selectedIndex = 0;
  
  double _currentMoodValue = 5.0;
  double _currentSleepValue = 5.0;
  final Set<String> _selectedTags = {};
  bool _showSuccessAnimation = false;
  DateTime _selectedDate = DateTime.now();
  
  List<Profile> _profiles = [];
  String? _selectedProfileId;
  
  List<MoodEntry> _allEntries = [];
  bool _isLoading = true;

  final List<String> _availableTags = [
    'Arbeit', 'Familie', 'Beziehung', 'Sport', 
    'Schlaf', 'Essen', 'Wetter', 'Gesundheit', 'Reisen', 'Schule', 'Hausaufgaben'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProfiles();
    await _loadEntries();
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

      setState(() {
        _profiles = profiles;
        if (_profiles.isNotEmpty && _selectedProfileId == null) {
          _selectedProfileId = _profiles.first.id;
        }
      });
    } catch (e) {
      debugPrint("Profil-Lade-Fehler: $e");
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
                    _selectedProfileId = newProfile.id;
                  });
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
  
  List<MoodEntry> get _filteredEntries {
    if (_selectedProfileId == null) return [];
    return _allEntries.where((e) => e.profileId == _selectedProfileId).toList();
  }

  List<MoodEntry> get _entriesForSelectedDate {
    return _filteredEntries.where((entry) {
      return DateUtils.isSameDay(entry.timestamp, _selectedDate);
    }).toList();
  }

  Future<void> _saveEntry() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _selectedProfileId == null) return;

    final newEntry = MoodEntry(
      timestamp: DateTime.now(),
      score: _currentMoodValue,
      sleepRating: _currentSleepValue,
      tags: Set.from(_selectedTags),
      profileId: _selectedProfileId,
    );

    try {
      final res = await Supabase.instance.client.from('mood_entries').insert({
        'user_id': user.id,
        'profile_id': _selectedProfileId,
        'score': newEntry.score,
        'sleep_rating': newEntry.sleepRating,
        'tags': newEntry.tags.toList(),
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

  Future<void> _updateEntry(String entryId, double newScore, double newSleep, Set<String> newTags) async {
    try {
      final res = await Supabase.instance.client
          .from('mood_entries')
          .update({
            'score': newScore,
            'sleep_rating': newSleep,
            'tags': newTags.toList(),
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
    // KORRIGIERT: Schlaf-Wert initialisieren
    double editScore = entry.score;
    double editSleep = entry.sleepRating ?? 5.0; 
    Set<String> editTags = Set.from(entry.tags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final moodData = _getMoodData(editScore);
            
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
                  
                  // 1. Slider Stimmung
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

                  // KORRIGIERT: 2. Slider Schlaf auch hier anzeigen
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

                  // 3. Tags
                  Wrap(
                    spacing: 6.0,
                    children: _availableTags.map((tag) {
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
                  
                  // 4. Speichern Button
                  ElevatedButton(
                    // KORRIGIERT: Hier auch editSleep übergeben
                    onPressed: () => _updateEntry(entry.id!, editScore, editSleep, editTags),
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

    try {
      // 1. Netlify Function aufrufen
      // WICHTIG: Ersetze dies mit DEINER echten Netlify-URL!
      final response = await http.post(
        Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/create-checkout'),
        body: jsonEncode({
          'userEmail': user.email,
          'userId': user.id,
          'priceId': 'price_1SbFNUFoVhyNl27phao8dSGu', // WICHTIG: Deine Stripe Price ID hier rein!
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = Uri.parse(data['url']);
        
        // 2. Stripe Checkout im Browser öffnen
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else {
        // FIX: Check if mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: ${response.body}")));
        }
      }
    } catch (e) {
      // FIX: Check if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
      }
    } finally {
      // FIX: Check if mounted
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getBackgroundColor(double value) {
    if (value <= 5.0) {
      return Color.lerp(Colors.redAccent.withValues(alpha: 0.5), Colors.amber.withValues(alpha: 0.5), value / 5.0)!;
    } else {
      return Color.lerp(Colors.amber.withValues(alpha: 0.5), Colors.greenAccent.withValues(alpha: 0.5), (value - 5.0) / 5.0)!;
    }
  }

  Map<String, String> _getMoodData(double value) {
    if (value < 2.0) return {'emoji': '😫', 'label': 'Schrecklich'};
    if (value < 4.0) return {'emoji': '😟', 'label': 'Nicht gut'};
    if (value < 6.0) return {'emoji': '😐', 'label': 'Neutral'};
    if (value < 8.0) return {'emoji': '🙂', 'label': 'Gut'};
    return {'emoji': '🤩', 'label': 'Fantastisch'};
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

  Widget _buildInputPage(Map<String, String> moodData) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      moodData['emoji']!,
                      key: ValueKey(moodData['emoji']),
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                  Text(
                    moodData['label']!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87.withValues(alpha: 0.7)),
                  ),
                  
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10.0,
                      activeTrackColor: Colors.black12,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    ),
                    child: Slider(
                      value: _currentMoodValue,
                      min: 0.0,
                      max: 10.0,
                      onChanged: _showSuccessAnimation ? null : (val) => setState(() => _currentMoodValue = val),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bedtime, color: Colors.indigoAccent),
                      const SizedBox(width: 8),
                      Text(
                        "Schlaf: ${_currentSleepValue.toStringAsFixed(1)}",
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
                      value: _currentSleepValue,
                      min: 0.0, max: 10.0,
                      onChanged: _showSuccessAnimation ? null : (val) => setState(() => _currentSleepValue = val),
                    ),
                  ),

                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    alignment: WrapAlignment.center,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => _toggleTag(tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black87 : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? Colors.black87 : Colors.white.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  ElevatedButton(
                    onPressed: _showSuccessAnimation ? null : _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Speichern"),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Colors.black12),
        
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white.withValues(alpha: 0.3),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _entriesForSelectedDate.isEmpty 
                ? const Center(child: Text("Keine Einträge für diese Person an diesem Tag."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _entriesForSelectedDate.length,
                    itemBuilder: (context, index) {
                    final entry = _entriesForSelectedDate[index];
                    final color = _getBackgroundColor(entry.score);

                    return Dismissible(
                      key: Key(entry.id ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) {
                        if (entry.id != null) {
                          _deleteEntry(entry.id!);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () => _showEditSheet(entry),

                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                entry.score.toStringAsFixed(1),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            "${DateFormat('HH:mm').format(entry.timestamp)} Uhr",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: entry.tags.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                                ),
                                child: Text(
                                  t, 
                                  style: TextStyle(fontSize: 10, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPage() {
    final chartData = _getChartData();
    final currentProfileName = _profiles.isNotEmpty && _selectedProfileId != null
        ? _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => Profile(id: '', name: '')).name
        : "Unbekannt";

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text("Woche von $currentProfileName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Tagesdurchschnitt der letzten 7 Tage"),
        const SizedBox(height: 20),
        
        SizedBox(
          height: 250,
          child: chartData.isEmpty 
            ? const Center(child: Text("Nicht genug Daten für eine Grafik."))
            : LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                minX: -0.5,
                maxX: 6.5,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, reservedSize: 30)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const SizedBox.shrink();
                        final dayIndex = value.toInt();
                        if (dayIndex < 0 || dayIndex > 6) return const SizedBox.shrink();
                        final date = DateTime.now().subtract(Duration(days: 6 - dayIndex));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: Colors.black87,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withValues(alpha: 0.3),
                          Colors.amber.withValues(alpha: 0.3),
                          Colors.redAccent.withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
        
        const SizedBox(height: 40),

        // KORRIGIERT: Diese Methode existiert jetzt
        _buildWeekdayStats(),

        const SizedBox(height: 40),
        
        _buildInsightsSection(),
        
        const SizedBox(height: 50),
      ],
    );
  }

  // KORRIGIERT: Die fehlende Methode für das Balkendiagramm hinzugefügt
  Widget _buildWeekdayStats() {
    final entries = _filteredEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    // 1. Daten aggregieren
    final Map<int, List<double>> dayScores = {};
    for (var i = 1; i <= 7; i++) {
      dayScores[i] = [];
    }

    for (var e in entries) {
      dayScores[e.timestamp.weekday]!.add(e.score);
    }

    // 2. Chart Daten bauen
    final List<BarChartGroupData> barGroups = [];
    for (var i = 1; i <= 7; i++) {
      final scores = dayScores[i]!;
      final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0.0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: _getBackgroundColor(avg),
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Colors.grey.withValues(alpha: 0.1)),
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Wochentags-Muster", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: 10,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                      final index = value.toInt() - 1;
                      if (index < 0 || index >= days.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(days[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getChartData() {
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    final relevantEntries = _filteredEntries;

    for (int i = 6; i >= 0; i--) {
      final dateToCheck = now.subtract(Duration(days: i));
      final entriesForDay = relevantEntries.where((e) => DateUtils.isSameDay(e.timestamp, dateToCheck)).toList();

      if (entriesForDay.isNotEmpty) {
        final double avgScore = entriesForDay.map((e) => e.score).reduce((a, b) => a + b) / entriesForDay.length;
        spots.add(FlSpot((6 - i).toDouble(), avgScore));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final moodData = _getMoodData(_currentMoodValue);
    final bgColor = _getBackgroundColor(_currentMoodValue);
    final dateString = DateUtils.isSameDay(_selectedDate, DateTime.now()) 
        ? "Heute" 
        : DateFormat('dd.MM.yyyy').format(_selectedDate);

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
                    setState(() {
                      _selectedProfileId = newValue;
                    });
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
          // NEU: Der Abo-Button
          IconButton(
            icon: const Icon(Icons.diamond, color: Colors.indigo),
            onPressed: _startCheckout, // Hier rufen wir die Funktion auf!
            tooltip: "Pro werden",
          ),
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut)
        ],
      ),

      body: Stack(
        children: [
          SafeArea(
            child: _selectedIndex == 0 
                ? _buildInputPage(moodData) 
                : _buildStatsPage(),
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

  Widget _buildInsightsSection() {
    final entries = _filteredEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    final totalSum = entries.fold(0.0, (sum, e) => sum + e.score);
    final globalAvg = totalSum / entries.length;

    final Map<String, List<double>> tagScores = {};

    for (var entry in entries) {
      for (var tag in entry.tags) {
        if (!tagScores.containsKey(tag)) {
          tagScores[tag] = [];
        }
        tagScores[tag]!.add(entry.score);
      }
    }

    final List<Map<String, dynamic>> impacts = [];

    tagScores.forEach((tag, scores) {
      if (scores.length >= 2) {
        final tagAvg = scores.reduce((a, b) => a + b) / scores.length;
        final impact = tagAvg - globalAvg;
        impacts.add({
          'tag': tag,
          'avg': tagAvg,
          'impact': impact,
          'count': scores.length,
        });
      }
    });

    impacts.sort((a, b) => (b['impact'].abs() as double).compareTo((a['impact'].abs() as double)));

    if (impacts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("Nutze Tags häufiger, um Muster zu erkennen.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deine Einflussfaktoren", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text("Basierend auf ${entries.length} Einträgen (Ø ${globalAvg.toStringAsFixed(1)})", 
             style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 15),
        
        ...impacts.map((item) {
          final impact = item['impact'] as double;
          final isPositive = impact > 0;
          final color = isPositive ? Colors.green : Colors.redAccent;
          final icon = isPositive ? Icons.trending_up : Icons.trending_down;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))
              ]
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${item['count']} Einträge", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isPositive ? '+' : ''}${impact.toStringAsFixed(1)}", 
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                    Text("Ø ${item['avg'].toStringAsFixed(1)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}
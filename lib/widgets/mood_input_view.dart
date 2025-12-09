import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart';
import 'package:record/record.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert';

import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';

class MoodInputView extends StatefulWidget {
  final double currentMoodValue;
  final double currentSleepValue;
  final bool trackSleep;
  final Set<String> selectedTags;
  final Map<String, List<String>> categorizedTags;
  final Set<String> customTagNames;
  final int? cycleDay; 
  final TextEditingController noteController;
  final List<MoodEntry> entriesForDate;
  final bool showSuccessAnimation;
  final bool isLoading;
  final bool isPro;
  final DateTime selectedDate; // <--- WICHTIG: Datum für den Header-Text

  final ValueChanged<double> onMoodChanged;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<bool> onTrackSleepChanged;
  final ValueChanged<String> onTagToggle;
  final VoidCallback onAddTag;
  final VoidCallback onSave;
  final Function(String) onDeleteEntry;
  final Function(MoodEntry) onEditEntry;
  final Function(String) onManageCustomTag;

  const MoodInputView({
    super.key,
    required this.currentMoodValue,
    required this.currentSleepValue,
    required this.trackSleep,
    required this.selectedTags,
    required this.categorizedTags,
    required this.customTagNames,
    this.cycleDay,
    required this.noteController,
    required this.entriesForDate,
    required this.showSuccessAnimation,
    required this.isLoading,
    required this.isPro,
    required this.selectedDate, // <--- NEU
    required this.onMoodChanged,
    required this.onSleepChanged,
    required this.onTrackSleepChanged,
    required this.onTagToggle,
    required this.onAddTag,
    required this.onSave,
    required this.onDeleteEntry,
    required this.onEditEntry,
    required this.onManageCustomTag,
  });

  @override
  State<MoodInputView> createState() => _MoodInputViewState();
}

class _MoodInputViewState extends State<MoodInputView> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordDuration = 0;
  Timer? _timer;
  static const int _maxDuration = 60;
  bool _isHistoryOpen = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        String path = ''; 
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/audio_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }
        await _audioRecorder.start(config, path: path);
        setState(() { _isRecording = true; _recordDuration = 0; });
        _startTimer();
      }
    } catch (e) { debugPrint("Fehler beim Starten: $e"); }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() { _isRecording = false; _isProcessing = true; });
    if (path != null) { await _uploadAndTranscribe(path); } 
    else { setState(() => _isProcessing = false); }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() { _recordDuration++; });
      if (_recordDuration >= _maxDuration) { _stopRecording(); }
    });
  }

  Future<void> _uploadAndTranscribe(String filePath) async {
    try {
      final url = Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/transcribe'); 
      var request = http.MultipartRequest('POST', url);
      if (kIsWeb) {
        final blobResponse = await http.get(Uri.parse(filePath));
        final bytes = blobResponse.bodyBytes;
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'recording.m4a'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        final text = data['text'];
        if (mounted) {
          final currentText = widget.noteController.text;
          widget.noteController.text = currentText.isEmpty ? text : "$currentText $text";
        }
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konnte Audio nicht verstehen.")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verbindungsfehler: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _toggleRecording() {
    if (_isProcessing) return;
    if (_isRecording) { _stopRecording(); } else { _startRecording(); }
  }

  @override
  Widget build(BuildContext context) {
    final moodData = MoodUtils.getMoodData(widget.currentMoodValue);
    final screenHeight = MediaQuery.of(context).size.height;
    final double historyHeight = _isHistoryOpen ? screenHeight * 0.4 : 60.0;

    // Logik für den Header Text (aus dem vorherigen Chat übernommen)
    final bool isToday = DateUtils.isSameDay(widget.selectedDate, DateTime.now());
    final String historyTitle = isToday 
        ? "HEUTIGE EINTRÄGE" 
        : "EINTRÄGE VOM ${DateFormat('dd.MM.yyyy').format(widget.selectedDate)}";

    return Column(
      children: [
        
        // ============================================================
        // 1. FIXIERTER HEADER BEREICH (Sliders & Metriken)
        // ============================================================
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), // Weniger Padding oben/unten
          child: Column(
            children: [
              // Zyklus Chip (Sehr kompakt)
              if (widget.cycleDay != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.pinkAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.water_drop, size: 12, color: Colors.pinkAccent), const SizedBox(width: 4), Text("Tag ${widget.cycleDay}", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 11))]),
                ),

              // Stimmung (Kompakter)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji & Text nebeneinander oder kompakt untereinander
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) => ScaleTransition(scale: animation, child: child),
                    child: Text(moodData['emoji']!, key: ValueKey(moodData['emoji']), style: const TextStyle(fontSize: 42)), // Kleiner (42)
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(moodData['label']!, key: ValueKey(moodData['label']), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: MoodUtils.getBackgroundColor(widget.currentMoodValue).withValues(alpha: 1.0).computeLuminance() > 0.5 ? Colors.black87 : MoodUtils.getBackgroundColor(widget.currentMoodValue))),
                  ),
                ],
              ),

              // Mood Slider (Kompakt)
              SizedBox(
                height: 30, // Erzwingt geringere Höhe für den Slider-Container
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8.0, // Dünner
                    trackShape: const RoundedRectSliderTrackShape(),
                    activeTrackColor: MoodUtils.getBackgroundColor(widget.currentMoodValue),
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 2), // Kleinerer Griff
                    thumbColor: Colors.white,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(value: widget.currentMoodValue, min: 0.0, max: 10.0, onChanged: widget.showSuccessAnimation ? null : (val) { if (val.floor() != widget.currentMoodValue.floor()) { HapticFeedback.selectionClick(); } widget.onMoodChanged(val); }),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Schlaf Header (Kompakt)
              Row(
                children: [
                  Transform.scale(
                    scale: 0.7, // Noch kleiner
                    child: Switch(value: widget.trackSleep, onChanged: widget.onTrackSleepChanged, activeTrackColor: Colors.indigo, thumbColor: const WidgetStatePropertyAll(Colors.white)),
                  ),
                  const SizedBox(width: 4),
                  Text("Schlaf", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const Spacer(),
                  if (widget.trackSleep) Text("${widget.currentSleepValue.toStringAsFixed(1)} h", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
              
              // Schlaf Slider (Kompakt & nur wenn aktiv)
              if (widget.trackSleep)
                SizedBox(
                  height: 30,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: Color.lerp(Colors.blueGrey.shade200, Colors.indigo, widget.currentSleepValue / 10),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 2),
                      thumbColor: Colors.white,
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(value: widget.currentSleepValue, min: 0.0, max: 10.0, onChanged: widget.showSuccessAnimation ? null : (val) { if (val.floor() != widget.currentSleepValue.floor()) { HapticFeedback.selectionClick(); } widget.onSleepChanged(val); }),
                  ),
                ),
            ],
          ),
        ),

        // Trennlinie zum Scrollbereich
        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // ============================================================
        // 2. SCROLLBARER BEREICH (Tags & Notizen)
        // ============================================================
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  ...widget.categorizedTags.entries.map((entry) { 
                    if (entry.value.isEmpty) return const SizedBox.shrink(); 
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.1)), 
                        const SizedBox(height: 8), 
                        Wrap(spacing: 8.0, runSpacing: 8.0, children: entry.value.map((tag) => _buildTagChip(tag)).toList()),
                        const SizedBox(height: 15), 
                      ]
                    ); 
                  }),
                  
                  const SizedBox(height: 5),
                  Center(child: TextButton.icon(onPressed: widget.isPro ? widget.onAddTag : _showProDialog, icon: Icon(widget.isPro ? Icons.add : Icons.lock, size: 16), label: const Text("Tag erstellen"), style: TextButton.styleFrom(foregroundColor: widget.isPro ? Colors.indigo : Colors.grey, visualDensity: VisualDensity.compact))),
                  const SizedBox(height: 15),

                  // Textfeld
                  TextField(
                    controller: widget.noteController,
                    decoration: InputDecoration(
                      hintText: "Erzähl mir von deinem Tag...", 
                      filled: true, 
                      fillColor: Colors.grey.shade50, 
                      prefixIcon: const Icon(Icons.edit_note),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Kompakter
                      suffixIcon: Padding(padding: const EdgeInsets.all(4.0), child: GestureDetector(onTap: widget.isPro ? _toggleRecording : _showProDialog, child: Stack(alignment: Alignment.center, children: [if (_isRecording) SizedBox(width: 36, height: 36, child: CircularProgressIndicator(value: _recordDuration / _maxDuration, strokeWidth: 3, backgroundColor: Colors.red.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.red))), if (_isProcessing) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)), if (!_isProcessing) Container(width: 30, height: 30, decoration: BoxDecoration(color: _isRecording ? Colors.red : Colors.transparent, shape: BoxShape.circle), child: !widget.isPro ? const Icon(Icons.lock, color: Colors.grey, size: 16) : Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.white : Colors.grey, size: 18))]))),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    maxLines: 3, minLines: 1,
                  ),
                  const SizedBox(height: 10), // Platz unten
                ],
              ),
            ),
          ),
        ),
        
        // ============================================================
        // 3. DOCK (Speichern Button)
        // ============================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Etwas kompakter
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4))], border: const Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1))),
          child: ElevatedButton(
            onPressed: widget.showSuccessAnimation ? null : widget.onSave, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87, 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), 
              padding: const EdgeInsets.symmetric(vertical: 16), 
              elevation: 4, 
              shadowColor: Colors.black.withValues(alpha: 0.2)
            ), 
            child: const Text("EINTRAG SPEICHERN", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5))
          ),
        ),

        // ============================================================
        // 4. VERLAUF (Klappbar)
        // ============================================================
        AnimatedContainer(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOutQuint, height: historyHeight, color: const Color(0xFFEDF2F7),
          child: Column(
            children: [
              InkWell(
                onTap: () { setState(() { _isHistoryOpen = !_isHistoryOpen; }); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                  decoration: BoxDecoration(color: const Color(0xFFEDF2F7), border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)))), 
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.history, size: 14, color: Colors.indigo)), 
                      const SizedBox(width: 10), 
                      // Dynamischer Titel (Datum oder "Heute")
                      Text(historyTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.indigo.shade900.withValues(alpha: 0.7), letterSpacing: 0.5)), 
                      const SizedBox(width: 8), 
                      AnimatedRotation(turns: _isHistoryOpen ? 0.5 : 0.0, duration: const Duration(milliseconds: 300), child: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.indigo.shade900.withValues(alpha: 0.5))), 
                      const Spacer(), 
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text("${widget.entriesForDate.length}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)))
                    ]
                  )
                ),
              ),

              Expanded(
                child: widget.isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : widget.entriesForDate.isEmpty 
                    ? Center(child: _isHistoryOpen ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notes, size: 30, color: Colors.grey.shade400), const SizedBox(height: 8), Text("Leer", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))]) : const SizedBox.shrink())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), itemCount: widget.entriesForDate.length, itemBuilder: (context, index) {
                          final entry = widget.entriesForDate[index];
                          final color = MoodUtils.getBackgroundColor(entry.score);
                          return Dismissible(
                            key: Key(entry.id ?? index.toString()), direction: DismissDirection.endToStart, background: Container(margin: const EdgeInsets.only(bottom: 10), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete_outline, color: Colors.white, size: 24)),
                            onDismissed: (direction) { if (entry.id != null) widget.onDeleteEntry(entry.id!); },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))]),
                              child: ListTile(
                                onTap: () => widget.onEditEntry(entry), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                                leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(entry.score.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)))), 
                                title: Text("${DateFormat('HH:mm').format(entry.timestamp)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), 
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (entry.note != null && entry.note!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)), Wrap(spacing: 4, children: entry.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text(t, style: TextStyle(fontSize: 9, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)))).toList())]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = widget.selectedTags.contains(tag);
    final isCustom = widget.customTagNames.contains(tag);

    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); widget.onTagToggle(tag); },
      onLongPress: isCustom ? () { HapticFeedback.mediumImpact(); widget.onManageCustomTag(tag); } : null,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0, duration: const Duration(milliseconds: 150), curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Etwas kleineres Padding
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? Colors.black87 : (isCustom ? Colors.indigoAccent.withValues(alpha: 0.5) : Colors.grey.shade200), width: isCustom && !isSelected ? 1.5 : 1.0),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Text(tag, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)), // Kleinere Schrift
        ),
      ),
    );
  }

  void _showProDialog() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)]), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20), const Icon(Icons.diamond, size: 40, color: Colors.indigo), const SizedBox(height: 15), const Text("Pro-Feature", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), const SizedBox(height: 10), Text("Dieses Feature ist exklusiv für Pro-Nutzer verfügbar. Möchtest du upgraden?", style: TextStyle(fontSize: 15, color: Colors.black87.withValues(alpha: 0.7), height: 1.5), textAlign: TextAlign.center), const SizedBox(height: 30), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bitte oben rechts auf den Diamanten klicken!"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: Colors.indigo.withValues(alpha: 0.4)), child: const Text("ZUM SHOP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)))), const SizedBox(height: 10), TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vielleicht später", style: TextStyle(color: Colors.grey)))])));
  }
}
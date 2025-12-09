import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- WICHTIG für Haptik/Vibration
import 'package:intl/intl.dart';
import 'package:record/record.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:flutter/foundation.dart'; // kIsWeb
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
  // Audio Variablen
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordDuration = 0;
  Timer? _timer;
  static const int _maxDuration = 60;

  // Layout Variable (Klappbare Liste)
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

  // --- AUDIO LOGIK START ---
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
      final url = Uri.parse('https://mood-tracker-rico.netlify.app/.netlify/functions/transcribe'); 
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
    if (_isProcessing) {
      return;
    }
    
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }
  // --- AUDIO LOGIK ENDE ---

  @override
  Widget build(BuildContext context) {
    final moodData = MoodUtils.getMoodData(widget.currentMoodValue);
    final screenHeight = MediaQuery.of(context).size.height;
    final double historyHeight = _isHistoryOpen ? screenHeight * 0.4 : 60.0;

    return Column(
      children: [
        // --- 1. EINGABE BEREICH ---
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    if (widget.cycleDay != null)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.pinkAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.water_drop, size: 14, color: Colors.pinkAccent), const SizedBox(width: 6), Text("Zyklustag ${widget.cycleDay}", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12))]),
                        ),
                      ),

                    // --- GIMMICK 1: Emoji Pop Animation ---
                    Center(
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            // POP EFFEKT: ScaleTransition
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Text(
                              moodData['emoji']!,
                              key: ValueKey(moodData['emoji']),
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                          const SizedBox(height: 5),
                          AnimatedSwitcher(
                             duration: const Duration(milliseconds: 200),
                             child: Text(
                              moodData['label']!,
                              key: ValueKey(moodData['label']),
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600, 
                                // Textfarbe passt sich leicht an
                                color: MoodUtils.getBackgroundColor(widget.currentMoodValue).withValues(alpha: 1.0).computeLuminance() > 0.5 ? Colors.black87 : MoodUtils.getBackgroundColor(widget.currentMoodValue)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- GIMMICK 2: Chamäleon Slider mit Haptik ---
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12.0,
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: MoodUtils.getBackgroundColor(widget.currentMoodValue), // LIVE FARBE
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0, elevation: 4),
                        thumbColor: Colors.white,
                        overlayColor: MoodUtils.getBackgroundColor(widget.currentMoodValue).withValues(alpha: 0.2),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                      ),
                      child: Slider(
                        value: widget.currentMoodValue,
                        min: 0.0, max: 10.0,
                        onChanged: widget.showSuccessAnimation ? null : (val) {
                          // HAPTIK BEI GANZEN ZAHLEN
                          if (val.floor() != widget.currentMoodValue.floor()) {
                            HapticFeedback.selectionClick();
                          }
                          widget.onMoodChanged(val);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Switch(value: widget.trackSleep, onChanged: widget.onTrackSleepChanged, activeTrackColor: Colors.indigo), const Icon(Icons.bedtime, color: Colors.indigoAccent), const SizedBox(width: 8), Text(widget.trackSleep ? "Schlaf: ${widget.currentSleepValue.toStringAsFixed(1)}" : "Schlaf nicht erfassen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.trackSleep ? Colors.black87.withValues(alpha: 0.6) : Colors.grey))]),
                    if (widget.trackSleep)
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12.0,
                          trackShape: const RoundedRectSliderTrackShape(),
                          // DYNAMISCHES BLAU: Von blassem Blau-Grau zu sattem Indigo
                          activeTrackColor: Color.lerp(
                            Colors.blueGrey.shade200, 
                            Colors.indigo, 
                            widget.currentSleepValue / 10
                          ),
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0, elevation: 4),
                          thumbColor: Colors.white,
                          // Auch der "Schatten" um den Griff passt sich farblich an
                          overlayColor: Color.lerp(
                            Colors.blueGrey, 
                            Colors.indigo, 
                            widget.currentSleepValue / 10
                          )?.withValues(alpha: 0.2),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                        ),
                        child: Slider(
                          value: widget.currentSleepValue,
                          min: 0.0, 
                          max: 10.0,
                          onChanged: widget.showSuccessAnimation ? null : (val) {
                            // Auch hier: Haptisches Feedback bei vollen Zahlen
                            if (val.floor() != widget.currentSleepValue.floor()) {
                              HapticFeedback.selectionClick();
                            }
                            widget.onSleepChanged(val);
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    const Divider(),

                    // Tags
                    ...widget.categorizedTags.entries.map((entry) { if (entry.value.isEmpty) return const SizedBox.shrink(); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 15), Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2)), const SizedBox(height: 8), Wrap(spacing: 8.0, runSpacing: 8.0, children: entry.value.map((tag) => _buildTagChip(tag)).toList())]); }),
                    
                    const SizedBox(height: 20),
                    Center(child: TextButton.icon(onPressed: widget.onAddTag, icon: const Icon(Icons.add), label: const Text("Eigenen Tag erstellen"), style: TextButton.styleFrom(foregroundColor: Colors.indigo))),
                    const SizedBox(height: 10),

                    // Textfeld (Bleibt unten!)
                    TextField(
                      controller: widget.noteController,
                      decoration: InputDecoration(
                        hintText: "Erzähl mir von deinem Tag...",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.edit_note),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            onTap: _toggleRecording,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_isRecording) SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: _recordDuration / _maxDuration, strokeWidth: 3, backgroundColor: Colors.red.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.red))),
                                if (_isProcessing) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                                if (!_isProcessing) Container(width: 32, height: 32, decoration: BoxDecoration(color: _isRecording ? Colors.red : Colors.transparent, shape: BoxShape.circle), child: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.white : Colors.grey, size: 20)),
                              ],
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      maxLines: 3, minLines: 1,
                    ),
                    const SizedBox(height: 20), 
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // --- 2. ACTION AREA (Dock) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, -5))],
            border: const Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          ),
          child: ElevatedButton(
            onPressed: widget.showSuccessAnimation ? null : widget.onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            child: const Text("EINTRAG SPEICHERN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
        ),

        // --- 3. VERLAUF AREA (Klappbar) ---
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutQuint,
          height: historyHeight, 
          color: const Color(0xFFEDF2F7),
          child: Column(
            children: [
              InkWell(
                onTap: () { setState(() { _isHistoryOpen = !_isHistoryOpen; }); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  decoration: BoxDecoration(color: const Color(0xFFEDF2F7), border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.history, size: 16, color: Colors.indigo)),
                      const SizedBox(width: 10),
                      Text("HEUTIGE EINTRÄGE", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.indigo.shade900.withValues(alpha: 0.7), letterSpacing: 0.5)),
                      const SizedBox(width: 8),
                      AnimatedRotation(turns: _isHistoryOpen ? 0.5 : 0.0, duration: const Duration(milliseconds: 300), child: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.indigo.shade900.withValues(alpha: 0.5))),
                      const Spacer(),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text("${widget.entriesForDate.length}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)))
                    ],
                  ),
                ),
              ),

              Expanded(
                child: widget.isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : widget.entriesForDate.isEmpty 
                    ? Center(child: _isHistoryOpen ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notes, size: 40, color: Colors.grey.shade400), const SizedBox(height: 10), Text("Noch leer heute", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))]) : const SizedBox.shrink())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        itemCount: widget.entriesForDate.length,
                        itemBuilder: (context, index) {
                          final entry = widget.entriesForDate[index];
                          final color = MoodUtils.getBackgroundColor(entry.score);
                          return Dismissible(
                            key: Key(entry.id ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(margin: const EdgeInsets.only(bottom: 12), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete_outline, color: Colors.white, size: 28)),
                            onDismissed: (direction) { if (entry.id != null) widget.onDeleteEntry(entry.id!); },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))]),
                              child: ListTile(
                                onTap: () => widget.onEditEntry(entry), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(entry.score.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)))),
                                title: Text("${DateFormat('HH:mm').format(entry.timestamp)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (entry.note != null && entry.note!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6, bottom: 6), child: Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)), Wrap(spacing: 4, children: entry.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text(t, style: TextStyle(fontSize: 10, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)))).toList())]),
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

  // --- GIMMICK 3: Haptik bei Tags ---
  Widget _buildTagChip(String tag) {
    final isSelected = widget.selectedTags.contains(tag);
    final isCustom = widget.customTagNames.contains(tag);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // HAPTIK!
        widget.onTagToggle(tag);
      },
      onLongPress: isCustom ? () {
        HapticFeedback.mediumImpact(); // HAPTIK!
        widget.onManageCustomTag(tag);
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? Colors.black87 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? Colors.black87 : (isCustom ? Colors.indigoAccent : Colors.grey.shade300), width: isCustom && !isSelected ? 1.5 : 1.0), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : []),
        child: Text(tag, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
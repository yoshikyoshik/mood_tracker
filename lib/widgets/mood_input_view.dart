import 'dart:async'; // Timer braucht das
import 'package:flutter/material.dart';
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
  // Recorder State
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false; // "KI denkt nach..."
  int _recordDuration = 0;
  Timer? _timer;
  
  // Max Zeit in Sekunden
  static const int _maxDuration = 60; 

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

  // Aufnahme starten
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        
        // FIX: Pfad-Logik trennen
        String path = ''; // Leer lassen für Web (wird automatisch im RAM/Blob gespeichert)
        
        if (!kIsWeb) {
          // Nur auf Mobile (Android/iOS) brauchen wir einen echten Ordner
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/audio_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        // Starten
        await _audioRecorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      debugPrint("Fehler beim Starten: $e");
    }
  }

  // Aufnahme stoppen & hochladen
  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _isProcessing = true; // Lade-Status an
    });

    if (path != null) {
      await _uploadAndTranscribe(path);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
      // Auto-Stop bei 60s
      if (_recordDuration >= _maxDuration) {
        _stopRecording();
      }
    });
  }

  // Der Upload zur Netlify Function
  Future<void> _uploadAndTranscribe(String filePath) async {
    try {
      // URL deiner Netlify Function
      final url = Uri.parse('https://mood-tracker-rico.netlify.app/.netlify/functions/transcribe'); 
      
      var request = http.MultipartRequest('POST', url);
      
      if (kIsWeb) {
        // FIX WEB: filePath ist hier eine Blob-URL (z.B. "blob:http://localhost...")
        // Wir müssen die Audiodaten erst aus dem Browser-Speicher holen
        final blobResponse = await http.get(Uri.parse(filePath));
        final bytes = blobResponse.bodyBytes;
        
        // Als Bytes anfügen
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          bytes, 
          filename: 'recording.m4a'
        ));
      } else {
        // FIX MOBILE: Echte Datei vom Speicherpfad laden
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        final text = data['text'];
        
        // Text einfügen
        if (mounted) {
          final currentText = widget.noteController.text;
          widget.noteController.text = currentText.isEmpty ? text : "$currentText $text";
        }
      } else {
        debugPrint("Fehler beim Transkribieren: $respStr");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konnte Audio nicht verstehen.")));
      }
    } catch (e) {
      debugPrint("Upload Fehler: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verbindungsfehler: $e")));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Toggle Logik für den Button
  void _toggleRecording() {
    if (_isProcessing) return; // Blockieren während Ladezeit
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodData = MoodUtils.getMoodData(widget.currentMoodValue);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... (Restlicher UI Code bleibt identisch wie vorher) ...
                        // KORZITAT für die Übersichtlichkeit: Hier oben hat sich nichts geändert
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
                        Center(child: Column(children: [AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(moodData['emoji']!, key: ValueKey(moodData['emoji']), style: const TextStyle(fontSize: 60))), Text(moodData['label']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87.withValues(alpha: 0.7)))])),
                        SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 10.0, activeTrackColor: Colors.black12, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0)), child: Slider(value: widget.currentMoodValue, min: 0.0, max: 10.0, onChanged: widget.showSuccessAnimation ? null : widget.onMoodChanged)),
                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Switch(value: widget.trackSleep, onChanged: widget.onTrackSleepChanged, activeTrackColor: Colors.indigo), const Icon(Icons.bedtime, color: Colors.indigoAccent), const SizedBox(width: 8), Text(widget.trackSleep ? "Schlaf: ${widget.currentSleepValue.toStringAsFixed(1)}" : "Schlaf nicht erfassen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.trackSleep ? Colors.black87.withValues(alpha: 0.6) : Colors.grey))]),
                        if (widget.trackSleep) SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 10.0, activeTrackColor: Colors.indigoAccent, thumbColor: Colors.indigo, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0)), child: Slider(value: widget.currentSleepValue, min: 0.0, max: 10.0, onChanged: widget.showSuccessAnimation ? null : widget.onSleepChanged)),
                        const SizedBox(height: 20),
                        const Divider(),
                        ...widget.categorizedTags.entries.map((entry) { if (entry.value.isEmpty) return const SizedBox.shrink(); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 15), Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2)), const SizedBox(height: 8), Wrap(spacing: 8.0, runSpacing: 8.0, children: entry.value.map((tag) => _buildTagChip(tag)).toList())]); }),
                        const SizedBox(height: 20),
                        Center(child: TextButton.icon(onPressed: widget.onAddTag, icon: const Icon(Icons.add), label: const Text("Eigenen Tag erstellen"), style: TextButton.styleFrom(foregroundColor: Colors.indigo))),
                        const SizedBox(height: 10),

                        // --- NEU: TEXTFELD MIT SMART RECORDER BUTTON ---
                        TextField(
                          controller: widget.noteController,
                          decoration: InputDecoration(
                            hintText: "Erzähl mir von deinem Tag...",
                            prefixIcon: const Icon(Icons.edit_note),
                            
                            // Hier ist der magische Button
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(4.0), // Etwas Abstand
                              child: GestureDetector(
                                onTap: _toggleRecording,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 1. Der Kreis-Fortschritt (Nur sichtbar bei Aufnahme)
                                    if (_isRecording)
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          value: _recordDuration / _maxDuration, // Füllt sich über 60s
                                          strokeWidth: 3,
                                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                        ),
                                      ),
                                    
                                    // 2. Der Lade-Kreis (Nur sichtbar beim Verarbeiten)
                                    if (_isProcessing)
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),

                                    // 3. Das Icon (Mikro oder Stopp)
                                    if (!_isProcessing)
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _isRecording ? Colors.red : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isRecording ? Icons.stop : Icons.mic,
                                          color: _isRecording ? Colors.white : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          maxLines: 3, 
                          minLines: 1,
                        ),
                        
                        const SizedBox(height: 20), 
                      ],
                    ),
                  ),
                ),
              ),
              
              // Speicher Button
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
                child: ElevatedButton(onPressed: widget.showSuccessAnimation ? null : widget.onSave, style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Speichern", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
        // ... (Restlicher UI Code)
        const Divider(height: 1, thickness: 1, color: Colors.black12),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white.withValues(alpha: 0.3),
            child: widget.isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : widget.entriesForDate.isEmpty 
                ? const Center(child: Text("Keine Einträge für diese Person an diesem Tag."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
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
                          margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))]),
                          child: ListTile(
                            onTap: () => widget.onEditEntry(entry), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(entry.score.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)))),
                            title: Text("${DateFormat('HH:mm').format(entry.timestamp)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (entry.note != null && entry.note!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)), Wrap(spacing: 4, children: entry.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text(t, style: TextStyle(fontSize: 10, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)))).toList())]),
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

  Widget _buildTagChip(String tag) {
    final isSelected = widget.selectedTags.contains(tag);
    final isCustom = widget.customTagNames.contains(tag);
    return GestureDetector(onTap: () => widget.onTagToggle(tag), onLongPress: isCustom ? () => widget.onManageCustomTag(tag) : null, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: isSelected ? Colors.black87 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? Colors.black87 : (isCustom ? Colors.indigoAccent : Colors.grey.shade300), width: isCustom && !isSelected ? 1.5 : 1.0), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : []), child: Text(tag, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))));
  }
}
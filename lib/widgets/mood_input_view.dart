import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // <--- NEU
import 'package:permission_handler/permission_handler.dart'; // <--- NEU
import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';
import 'package:flutter/foundation.dart';

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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  // Initialisierung der Spracherkennung
  void _initSpeech() async {
    try {
      // FIX: Auf dem Handy (Mobile) müssen wir explizit fragen.
      // Im Web (!kIsWeb) macht das der Browser automatisch beim Initialisieren.
      if (!kIsWeb) {
        var status = await Permission.microphone.status;
        if (!status.isGranted) {
          await Permission.microphone.request();
        }
      }

      _speechEnabled = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech Status: $status'),
        onError: (error) => debugPrint('Speech Error: $error'),
      );
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Speech Init Error: $e");
    }
  }

  // Start/Stop Aufnahme
  void _listen() async {
    if (!_speechEnabled) {
      _initSpeech(); // Versuch neu zu starten
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      
      final String existingText = widget.noteController.text;
      
      await _speech.listen(
        onResult: (val) {
          setState(() {
            String separator = (existingText.isNotEmpty && !existingText.endsWith(' ')) ? ' ' : '';
            if (val.recognizedWords.isNotEmpty) {
               widget.noteController.text = "$existingText$separator${val.recognizedWords}";
               
               widget.noteController.selection = TextSelection.fromPosition(
                 TextPosition(offset: widget.noteController.text.length)
               );
            }
          });
        },
        localeId: "de_DE",
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        // FIX: Veraltete Parameter in 'listenOptions' verschoben
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodData = MoodUtils.getMoodData(widget.currentMoodValue);

    return Column(
      children: [
        // --- SCROLL BEREICH ---
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
                        const SizedBox(height: 10),
                        
                        // ZYKLUS ANZEIGE (Falls vorhanden)
                        if (widget.cycleDay != null)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.water_drop, size: 14, color: Colors.pinkAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Zyklustag ${widget.cycleDay}",
                                    style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Center(
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                        
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 10.0,
                            activeTrackColor: Colors.black12,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          ),
                          child: Slider(
                            value: widget.currentMoodValue,
                            min: 0.0, max: 10.0,
                            onChanged: widget.showSuccessAnimation ? null : widget.onMoodChanged,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                              value: widget.trackSleep, 
                              onChanged: widget.onTrackSleepChanged,
                              activeTrackColor: Colors.indigo, 
                            ),
                            const Icon(Icons.bedtime, color: Colors.indigoAccent),
                            const SizedBox(width: 8),
                            Text(
                              widget.trackSleep 
                                ? "Schlaf: ${widget.currentSleepValue.toStringAsFixed(1)}"
                                : "Schlaf nicht erfassen",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.trackSleep ? Colors.black87.withValues(alpha: 0.6) : Colors.grey),
                            ),
                          ],
                        ),
                        
                        if (widget.trackSleep)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 10.0,
                              activeTrackColor: Colors.indigoAccent,
                              thumbColor: Colors.indigo,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                            ),
                            child: Slider(
                              value: widget.currentSleepValue,
                              min: 0.0, max: 10.0,
                              onChanged: widget.showSuccessAnimation ? null : widget.onSleepChanged,
                            ),
                          ),

                        const SizedBox(height: 20),
                        const Divider(),

                        ...widget.categorizedTags.entries.map((entry) {
                          if (entry.value.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                entry.key.toUpperCase(), 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: entry.value.map((tag) => _buildTagChip(tag)).toList(),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 20),
                        
                        Center(
                          child: TextButton.icon(
                            onPressed: widget.onAddTag, 
                            icon: const Icon(Icons.add), 
                            label: const Text("Eigenen Tag erstellen"),
                            style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // --- TEXTFELD MIT VOICE BUTTON ---
                        TextField(
                          controller: widget.noteController,
                          decoration: InputDecoration(
                            hintText: "Warum fühlst du dich so?",
                            prefixIcon: const Icon(Icons.edit_note),
                            // NEU: Mikrofon Button als Suffix
                            suffixIcon: GestureDetector(
                              onTap: _listen,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isListening ? Colors.redAccent : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic_off : Icons.mic,
                                  color: _isListening ? Colors.white : Colors.grey,
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
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                ),
                child: ElevatedButton(
                  onPressed: widget.showSuccessAnimation ? null : widget.onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Speichern", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

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
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (direction) {
                          if (entry.id != null) widget.onDeleteEntry(entry.id!);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: ListTile(
                            onTap: () => widget.onEditEntry(entry),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                              child: Center(child: Text(entry.score.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16))),
                            ),
                            title: Text("${DateFormat('HH:mm').format(entry.timestamp)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.note != null && entry.note!.isNotEmpty)
                                  Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                Wrap(spacing: 4, children: entry.tags.map((t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                                  child: Text(t, style: TextStyle(fontSize: 10, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                                )).toList()),
                              ],
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

  Widget _buildTagChip(String tag) {
    final isSelected = widget.selectedTags.contains(tag);
    final isCustom = widget.customTagNames.contains(tag);

    return GestureDetector(
      onTap: () => widget.onTagToggle(tag),
      onLongPress: isCustom ? () => widget.onManageCustomTag(tag) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? Colors.black87 
              : (isCustom ? Colors.indigoAccent : Colors.grey.shade300),
            width: isCustom && !isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13, 
            color: isSelected ? Colors.white : Colors.black87, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ),
    );
  }
}
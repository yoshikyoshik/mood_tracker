import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:showcaseview/showcaseview.dart';

import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';
import '../l10n/generated/app_localizations.dart';

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
  final DateTime selectedDate;
  
  final bool isEditing;

  final ValueChanged<double> onMoodChanged;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<bool> onTrackSleepChanged;
  final ValueChanged<String> onTagToggle;
  final VoidCallback onAddTag;
  final VoidCallback onSave;
  final Function(String) onDeleteEntry;
  final Function(MoodEntry) onEditEntry;
  final Function(String) onManageCustomTag;
  
  // --- NEUE CALLBACKS FÜR NAVIGATION ---
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  final GlobalKey showcaseKeySlider;
  final GlobalKey showcaseKeySave;

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
    required this.selectedDate,
    this.isEditing = false, 
    required this.onMoodChanged,
    required this.onSleepChanged,
    required this.onTrackSleepChanged,
    required this.onTagToggle,
    required this.onAddTag,
    required this.onSave,
    required this.onDeleteEntry,
    required this.onEditEntry,
    required this.onManageCustomTag,
    // --- NEU ---
    required this.onPreviousDay,
    required this.onNextDay,
    
    required this.showcaseKeySlider,
    required this.showcaseKeySave,
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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
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
      if (_recordDuration >= _maxDuration) {
        _stopRecording();
      }
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
          _scrollToBottom();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konnte Audio nicht verstehen.")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verbindungsfehler: $e")));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _toggleRecording() {
    if (_isProcessing) return;
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final moodData = MoodUtils.getMoodData(widget.currentMoodValue, l10n);
    final screenHeight = MediaQuery.of(context).size.height;
    final double historyHeight = _isHistoryOpen ? screenHeight * 0.4 : 60.0;

    final bool isToday = DateUtils.isSameDay(widget.selectedDate, DateTime.now());
    final String headerDateString = DateFormat('dd.MM.yyyy').format(widget.selectedDate);
    final bool hasEntries = widget.entriesForDate.isNotEmpty;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              // --- HEADER ZEILE ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LINKS: Navigation & Datum
                    // FIX: Expanded sorgt dafür, dass dieser Bereich den Platz nimmt, der übrig bleibt
                    // und nicht über den Rand hinauswächst.
                    if (widget.isEditing)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      )
                    else
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pfeil Links
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.indigo),
                              onPressed: widget.onPreviousDay,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(), // Macht den Button kompakter
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 4),
                            
                            // Datum Text (in Flexible verpackt, damit er notfalls umbricht oder ... zeigt)
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isToday ? l10n.today : 'Datum',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    headerDateString,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    maxLines: 1, // Wichtig: Nicht mehr als 1 Zeile
                                    overflow: TextOverflow.ellipsis, // Wichtig: "..." falls zu lang
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 4),
                            // Pfeil Rechts
                            IconButton(
                              icon: Icon(Icons.chevron_right, color: isToday ? Colors.grey.shade300 : Colors.indigo),
                              onPressed: isToday ? null : widget.onNextDay,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),

                    // MITTE: "Bearbeiten" nur im Edit-Modus
                    if (widget.isEditing)
                      Text(l10n.edit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),

                    // RECHTS: Speichern Button
                    // Ein kleiner Abstand nach links, damit Datum und Button nicht kleben
                    SizedBox(width: widget.isEditing ? 0 : 8),
                    
                    Showcase(
                      key: widget.showcaseKeySave,
                      title: l10n.tutorialSaveTitle,
                      description: l10n.tutorialSaveDesc,
                      child: TextButton(
                        onPressed: widget.showSuccessAnimation ? null : widget.onSave,
                        // Damit der Button nicht unnötig riesig ist:
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(50, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          hasEntries ? "Weiteren Eintrag (+)" : l10n.save,
                          style: TextStyle(
                            color: hasEntries ? Colors.grey.shade600 : Colors.blue, 
                            fontSize: hasEntries ? 13 : 16, // Schrift etwas kleiner bei langem Text
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Zyklus Chip
              if (widget.cycleDay != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.pinkAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.water_drop, size: 12, color: Colors.pinkAccent), const SizedBox(width: 4), Text("Tag ${widget.cycleDay}", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 11))]),
                ),

              // Stimmung
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) => ScaleTransition(scale: animation, child: child),
                    child: Text(moodData['emoji']!, key: ValueKey(moodData['emoji']), style: const TextStyle(fontSize: 42)),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(moodData['label']!, key: ValueKey(moodData['label']), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: MoodUtils.getBackgroundColor(widget.currentMoodValue).withValues(alpha: 1.0).computeLuminance() > 0.5 ? Colors.black87 : MoodUtils.getBackgroundColor(widget.currentMoodValue))),
                  ),
                ],
              ),

              // Mood Slider
              SizedBox(
                height: 30,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8.0,
                    trackShape: const RoundedRectSliderTrackShape(),
                    activeTrackColor: MoodUtils.getBackgroundColor(widget.currentMoodValue),
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 2),
                    thumbColor: Colors.white,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Showcase(
                    key: widget.showcaseKeySlider,
                    title: l10n.tutorialMoodTitle,
                    description: l10n.tutorialMoodDesc,
                    child: Slider(
                        value: widget.currentMoodValue,
                        min: 0.0,
                        max: 10.0,
                        onChanged: widget.showSuccessAnimation ? null : (val) {
                          if (val.floor() != widget.currentMoodValue.floor()) HapticFeedback.selectionClick();
                          widget.onMoodChanged(val);
                        }),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Schlaf
              Row(
                children: [
                  Transform.scale(scale: 0.7, child: Switch(value: widget.trackSleep, onChanged: widget.onTrackSleepChanged, activeTrackColor: Colors.indigo, thumbColor: const WidgetStatePropertyAll(Colors.white))),
                  const SizedBox(width: 4),
                  Text(l10n.inputSleep, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const Spacer(),
                  if (widget.trackSleep) Text("${widget.currentSleepValue.toStringAsFixed(1)} h", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),

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
                    child: Slider(
                        value: widget.currentSleepValue,
                        min: 0.0,
                        max: 10.0,
                        onChanged: widget.showSuccessAnimation ? null : (val) {
                          if (val.floor() != widget.currentSleepValue.floor()) HapticFeedback.selectionClick();
                          widget.onSleepChanged(val);
                        }),
                  ),
                ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // Scrollbarer Inhalt
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.categorizedTags.entries.map((entry) {
                    if (entry.value.isEmpty) return const SizedBox.shrink();
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8.0, runSpacing: 8.0, children: entry.value.map((tag) => _buildTagChip(tag)).toList()),
                      const SizedBox(height: 15),
                    ]);
                  }),
                  const SizedBox(height: 5),
                  Center(child: TextButton.icon(onPressed: widget.isPro ? widget.onAddTag : _showProDialog, icon: Icon(widget.isPro ? Icons.add : Icons.lock, size: 16), label: Text(l10n.inputAddTag), style: TextButton.styleFrom(foregroundColor: widget.isPro ? Colors.indigo : Colors.grey, visualDensity: VisualDensity.compact))),
                  const SizedBox(height: 15),
                  TextField(
                    controller: widget.noteController,
                    onTap: _scrollToBottom,
                    decoration: InputDecoration(
                      hintText: l10n.inputNoteHint,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.edit_note),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      suffixIcon: Padding(padding: const EdgeInsets.all(4.0), child: GestureDetector(onTap: widget.isPro ? _toggleRecording : _showProDialog, child: Stack(alignment: Alignment.center, children: [if (_isRecording) SizedBox(width: 36, height: 36, child: CircularProgressIndicator(value: _recordDuration / _maxDuration, strokeWidth: 3, backgroundColor: Colors.red.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.red))), if (_isProcessing) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)), if (!_isProcessing) Container(width: 30, height: 30, decoration: BoxDecoration(color: _isRecording ? Colors.red : Colors.transparent, shape: BoxShape.circle), child: !widget.isPro ? const Icon(Icons.lock, color: Colors.grey, size: 16) : Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.white : Colors.grey, size: 18))]))),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    maxLines: 3, minLines: 1,
                  ),
                  SizedBox(height: bottomInset > 0 ? 200 : 20),
                ],
              ),
            ),
          ),
        ),

        // Verlauf
        if (!widget.isEditing)
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFEDF2F7), border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.history, size: 14, color: Colors.indigo)),
                      const SizedBox(width: 10),
                      Text("$headerDateString • ${widget.entriesForDate.length} ${l10n.moodEntry.toUpperCase()}${widget.entriesForDate.length != 1 ? 'E' : ''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.indigo.shade900.withValues(alpha: 0.7), letterSpacing: 0.5)),
                      const Spacer(),
                      AnimatedRotation(turns: _isHistoryOpen ? 0.5 : 0.0, duration: const Duration(milliseconds: 300), child: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.indigo.shade900.withValues(alpha: 0.5))),
                    ])),
              ),
              Expanded(
                child: widget.isLoading ? const Center(child: CircularProgressIndicator()) : widget.entriesForDate.isEmpty ? Center(child: _isHistoryOpen ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notes, size: 30, color: Colors.grey.shade400), const SizedBox(height: 8), Text(l10n.statsNoData, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))]) : const SizedBox.shrink()) : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: widget.entriesForDate.length,
                  itemBuilder: (context, index) {
                    final entry = widget.entriesForDate[index];
                    final color = MoodUtils.getBackgroundColor(entry.score);
                    final bool isOffline = (entry.id != null && entry.id!.startsWith('offline_')) || entry.isLocallyModified;
                    return Dismissible(
                      key: Key(entry.id ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(margin: const EdgeInsets.only(bottom: 10), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.redAccent.shade100, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete_outline, color: Colors.white, size: 24)),
                      onDismissed: (direction) { if (entry.id != null) widget.onDeleteEntry(entry.id!); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))]),
                        child: ListTile(
                          onTap: () => widget.onEditEntry(entry),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(entry.score.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)))),
                          title: Text("${DateFormat('HH:mm').format(entry.timestamp)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (entry.note != null && entry.note!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(entry.note!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Wrap(spacing: 4, children: entry.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black.withValues(alpha: 0.05))), child: Text(MoodUtils.getLocalizedTagLabel(t, l10n), style: TextStyle(fontSize: 9, color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)))).toList())
                          ]),
                          trailing: isOffline ? Tooltip(message: "Nicht synchronisiert", triggerMode: TooltipTriggerMode.tap, child: Icon(Icons.cloud_off, color: Colors.orange.shade300, size: 20)) : null,
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
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? Colors.black87 : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? Colors.black87 : (isCustom ? Colors.indigoAccent.withValues(alpha: 0.5) : Colors.grey.shade200), width: isCustom && !isSelected ? 1.5 : 1.0), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, offset: const Offset(0, 1))]),
          child: Text(tag, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        ),
      ),
    );
  }

  void _showProDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)]), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20), const Icon(Icons.diamond, size: 40, color: Colors.indigo), const SizedBox(height: 15), const Text("Pro-Feature", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), const SizedBox(height: 10), const Text("Dieses Feature ist exklusiv für Pro-Nutzer verfügbar. Möchtest du upgraden?", style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5), textAlign: TextAlign.center), const SizedBox(height: 30), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bitte oben rechts auf den Diamanten klicken!"))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: Colors.indigo.withValues(alpha: 0.4)), child: const Text("ZUM SHOP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)))), const SizedBox(height: 10), TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.maybeLater, style: const TextStyle(color: Colors.grey)))])));
  }
}
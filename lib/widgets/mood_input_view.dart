import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';

class MoodInputView extends StatelessWidget {
  final double currentMoodValue;
  final double currentSleepValue;
  final bool trackSleep;
  final Set<String> selectedTags;
  
  final Map<String, List<String>> categorizedTags;
  final Set<String> customTagNames;
  
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

  final int? cycleDay;
  
  // UMBENANNT: Von onDelete... zu onManage...
  final Function(String) onManageCustomTag; 

  const MoodInputView({
    super.key,
    required this.currentMoodValue,
    required this.currentSleepValue,
    required this.trackSleep,
    required this.selectedTags,
    required this.categorizedTags,
    required this.customTagNames,
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
    required this.onManageCustomTag, // <--- HIER
    required this.cycleDay,
  });

  @override
  Widget build(BuildContext context) {
    final moodData = MoodUtils.getMoodData(currentMoodValue);

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
                        const SizedBox(height: 10),

                        // ZYKLUS ANZEIGE (Nur wenn aktiv und Tag berechnet)
                        if (cycleDay != null)
                          Container(
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
                                  "Zyklustag $cycleDay",
                                  style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
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
                            value: currentMoodValue,
                            min: 0.0, max: 10.0,
                            onChanged: showSuccessAnimation ? null : onMoodChanged,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                              value: trackSleep, 
                              onChanged: onTrackSleepChanged,
                              activeTrackColor: Colors.indigo, 
                            ),
                            const Icon(Icons.bedtime, color: Colors.indigoAccent),
                            const SizedBox(width: 8),
                            Text(
                              trackSleep 
                                ? "Schlaf: ${currentSleepValue.toStringAsFixed(1)}"
                                : "Schlaf nicht erfassen",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: trackSleep ? Colors.black87.withValues(alpha: 0.6) : Colors.grey),
                            ),
                          ],
                        ),
                        
                        if (trackSleep)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 10.0,
                              activeTrackColor: Colors.indigoAccent,
                              thumbColor: Colors.indigo,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                            ),
                            child: Slider(
                              value: currentSleepValue,
                              min: 0.0, max: 10.0,
                              onChanged: showSuccessAnimation ? null : onSleepChanged,
                            ),
                          ),

                        const SizedBox(height: 20),
                        const Divider(),

                        ...categorizedTags.entries.map((entry) {
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
                            onPressed: onAddTag, 
                            icon: const Icon(Icons.add), 
                            label: const Text("Eigenen Tag erstellen"),
                            style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            hintText: "Warum fühlst du dich so? (Optional)",
                            prefixIcon: Icon(Icons.edit_note),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          maxLines: 2, 
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
                  onPressed: showSuccessAnimation ? null : onSave,
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
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : entriesForDate.isEmpty 
                ? const Center(child: Text("Keine Einträge für diese Person an diesem Tag."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: entriesForDate.length,
                    itemBuilder: (context, index) {
                      final entry = entriesForDate[index];
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
                          if (entry.id != null) onDeleteEntry(entry.id!);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: ListTile(
                            onTap: () => onEditEntry(entry),
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
    final isSelected = selectedTags.contains(tag);
    final isCustom = customTagNames.contains(tag);

    return GestureDetector(
      onTap: () => onTagToggle(tag),
      onLongPress: isCustom ? () => onManageCustomTag(tag) : null, // UMBENANNT
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
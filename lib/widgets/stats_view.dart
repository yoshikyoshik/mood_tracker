import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../models/profile.dart';
import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/weather_service.dart';

class StatsView extends StatefulWidget {
  final List<MoodEntry> entries;
  final List<MoodEntry> allEntries;
  final Profile currentProfile;
  final bool isPro;
  final VoidCallback onUnlockPressed;

  const StatsView({
    super.key,
    required this.entries,
    required this.allEntries,
    required this.currentProfile,
    required this.isPro,
    required this.onUnlockPressed,
  });

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _isAnalyzing = false;
  String? _analysisResult;
  double _weatherImpact = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final impact = await WeatherService.getWeatherImpact();
    if (mounted) {
      setState(() {
        _weatherImpact = impact;
      });
    }
  }

  // ===========================================================================
  // 1. HELPER METHODEN FÜR DIE PREDICTION
  // ===========================================================================

  // Berechnet einen repräsentativen Schlaf-Wert für ein Datum (Durchschnitt aller Einträge des Tages)
  double? _getDailySleepValue(DateTime date, List<MoodEntry> history) {
    final entriesOfDay = history.where((e) => 
      DateUtils.isSameDay(e.timestamp, date) && e.sleepRating != null
    ).toList();

    if (entriesOfDay.isEmpty) return null;

    final sum = entriesOfDay.fold(0.0, (prev, e) => prev + e.sleepRating!);
    return sum / entriesOfDay.length;
  }

  // 2A. Schlaf-Schuld (Sleep Debt) über 3 Tage
  double _calculateSleepDebtImpact(List<MoodEntry> history) {
    double weightedSum = 0.0;
    int weights = 0;
    final now = DateTime.now();
    
    // Wir prüfen Heute (Gewicht 3), Gestern (2), Vorgestern (1)
    for (int i = 0; i < 3; i++) {
      final targetDate = now.subtract(Duration(days: i));
      final sleepValue = _getDailySleepValue(targetDate, history);
      
      if (sleepValue != null) {
        int weight = 3 - i; 
        weightedSum += sleepValue * weight;
        weights += weight;
      }
    }
    
    if (weights == 0) return 0.0;
    
    final avgSleep = weightedSum / weights;
    // Abweichung von 7.5 Stunden (Ideal). Bsp: 5h -> (5 - 7.5) * 0.4 = -1.0
    return (avgSleep - 7.5) * 0.4;
  }

  // 3-4. Jahreszeit / Licht
  double _getSeasonImpact() {
    final month = DateTime.now().month;
    // Winter (Nov - Feb) auf der Nordhalbkugel -> Malus
    if (month >= 11 || month <= 2) return -0.4; 
    // Sommer (Jun - Aug) -> Bonus
    if (month >= 6 && month <= 8) return 0.3; 
    return 0.0;
  }

  // 4. PRO: Personalisierte Wochentags-Korrelation
  double _getPersonalizedWeekdayImpact(int weekday, List<MoodEntry> history) {
    if (history.length < 10) return 0.0; // Braucht Mindestdatenmenge

    final avgTotal = history.fold(0.0, (sum, e) => sum + e.score) / history.length;
    final weekdayEntries = history.where((e) => e.timestamp.weekday == weekday).toList();
    
    if (weekdayEntries.isEmpty) return 0.0;
    
    final avgWeekday = weekdayEntries.fold(0.0, (sum, e) => sum + e.score) / weekdayEntries.length;
    
    // Differenz gedämpft (0.5), damit es nicht zu extrem ausschlägt
    return (avgWeekday - avgTotal) * 0.5;
  }

  // 4. PRO: Personalisierte Tag-Nachwirkungen (Lernende App)
  double _getPersonalizedTagImpact(Set<String> yesterdayTags, List<MoodEntry> history) {
    if (history.length < 20) return 0.0; 
    
    double totalImpact = 0.0;
    final avgTotal = history.fold(0.0, (sum, e) => sum + e.score) / history.length;

    for (var tag in yesterdayTags) {
      // Suche Tage in der Vergangenheit mit diesem Tag
      final daysWithTag = history.where((e) => e.tags.contains(tag)).toList();
      if (daysWithTag.length < 3) continue; 

      double sumNextDayScore = 0.0;
      int count = 0;

      for (var dayEntry in daysWithTag) {
        // Wie war die Stimmung am Tag DANACH?
        final nextDay = dayEntry.timestamp.add(const Duration(days: 1));
        // Wir suchen EINEN repräsentativen Score für den Folgetag (Durchschnitt falls mehrere Einträge)
        final nextDayEntries = history.where((e) => DateUtils.isSameDay(e.timestamp, nextDay)).toList();
        
        if (nextDayEntries.isNotEmpty) {
           final avgNext = nextDayEntries.fold(0.0, (s, e) => s + e.score) / nextDayEntries.length;
           sumNextDayScore += avgNext;
           count++;
        }
      }

      if (count > 0) {
        final avgAfterTag = sumNextDayScore / count;
        // Einfluss addieren (gewichtet mit 0.3)
        totalImpact += (avgAfterTag - avgTotal) * 0.3; 
      }
    }
    return totalImpact.clamp(-2.0, 2.0);
  }

  // Sentiment Analyse (Existierend)
  double _calculateSentimentImpact(List<MoodEntry> recentEntries, AppLocalizations l10n) {
    double impact = 0.0;
    final negativeWords = l10n.sentimentNegativeWords.split(',').map((s) => s.trim()).toList();
    final positiveWords = l10n.sentimentPositiveWords.split(',').map((s) => s.trim()).toList();

    for (var entry in recentEntries) {
      if (entry.note == null) continue;
      final noteLower = entry.note!.toLowerCase();
      
      for (var word in negativeWords) {
        if (noteLower.contains(word.toLowerCase())) impact -= 0.3;
      }
      for (var word in positiveWords) {
        if (noteLower.contains(word.toLowerCase())) impact += 0.3;
      }
    }
    return impact.clamp(-1.5, 1.5);
  }

  // Zyklus Faktor (Existierend)
  double _calculateCycleImpact(DateTime targetDate) {
    if (!widget.currentProfile.isCycleTracking || widget.currentProfile.lastPeriodDate == null) {
      return 0.0;
    }
    final daysSincePeriod = targetDate.difference(widget.currentProfile.lastPeriodDate!).inDays;
    final cycleDay = (daysSincePeriod % 28) + 1;

    if (cycleDay >= 1 && cycleDay <= 5) return -0.8; // Periode
    if (cycleDay >= 12 && cycleDay <= 16) return 0.8; // Eisprung
    if (cycleDay >= 24 && cycleDay <= 28) return -0.6; // PMS
    return 0.0;
  }

  // ===========================================================================
  // 2. HAUPT UI & CARDS
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFFF5F7FA), 
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          // PREDICTION CARD
          if (!widget.isPro)
            _buildLockedPredictionCard(l10n)
          else if (widget.entries.length < 5)
            _buildEmptyPredictionCard(l10n)
          else
            _buildPredictionCard(l10n),

          const SizedBox(height: 16),

          // HEATMAP
          _buildCard(
            title: l10n.statsYearly,
            icon: Icons.calendar_month,
            child: widget.entries.isEmpty 
              ? Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(l10n.statsNoData)))
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10), 
                    child: HeatMap(
                      datasets: _getHeatmapData(),
                      startDate: DateTime.now().subtract(const Duration(days: 90)), 
                      endDate: DateTime.now(),
                      colorMode: ColorMode.opacity, 
                      showText: false,
                      scrollable: false, 
                      margin: const EdgeInsets.all(2), 
                      size: 18, 
                      fontSize: 12,
                      colorsets: const {
                        1: Colors.red,
                        3: Colors.orange,
                        5: Colors.yellow,
                        7: Colors.lightGreen,
                        9: Colors.green,
                        10: Colors.indigo, 
                      },
                      onClick: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Einträge am ${DateFormat('dd.MM.yyyy').format(value)}")));
                      },
                    ),
                  ),
                ),
          ),

          const SizedBox(height: 16),

          // CHART
          _buildCard(
            title: l10n.statsChartTitle,
            icon: Icons.show_chart,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: widget.entries.isEmpty 
                    ? Center(child: Text(l10n.statsNoData))
                    : _buildInteractiveChart(l10n),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(l10n.statsMood, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 20),
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.indigoAccent.withValues(alpha: 0.5), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(l10n.statsSleep, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // AI COACH
          if (widget.isPro)
            _buildAICard(l10n)
          else
            _buildLockedAICard(l10n),

          const SizedBox(height: 16),

          // BAR CHART
          _buildCard(
            title: l10n.statsPatternDay,
            icon: Icons.bar_chart,
            child: SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildBarChart(l10n),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // INSIGHTS
          if (widget.entries.isNotEmpty)
            _buildInsightsCard(l10n),
            
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. WIDGET BUILDER
  // ===========================================================================

  Widget _buildPredictionCard(AppLocalizations l10n) {
    // 1. SETUP
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final sortedHistory = List<MoodEntry>.from(widget.entries)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Daten von "Heute" (die letzten 24h), da diese "Morgen" beeinflussen
    final todayEntries = sortedHistory.where((e) => DateUtils.isSameDay(e.timestamp, DateTime.now())).toList();
    final Set<String> todayTags = todayEntries.expand((e) => e.tags).toSet();
    
    // 2. FAKTOREN BERECHNEN
    
    // 2.1 Basis & Personalisierter Wochentag
    double baseScore = 6.0 + _getPersonalizedWeekdayImpact(tomorrow.weekday, widget.entries);

    // 2.2 Trend (Letzte 3 Einträge)
    double trendImpact = 0.0;
    if (sortedHistory.length >= 3) {
      final last3Avg = sortedHistory.take(3).fold(0.0, (sum, e) => sum + e.score) / 3;
      trendImpact = (last3Avg - baseScore) * 0.3;
    }

    // 2.3 Schlaf-Schuld (Über 3 Tage gewichtet)
    double sleepImpact = _calculateSleepDebtImpact(sortedHistory);

    // 2.4 Statische Tag-Effekte (Hangover / Afterglow)
    double tagsStaticImpact = 0.0;
    List<String> activeFactors = []; 

    for (var tag in todayTags) {
      double impact = MoodUtils.getTagImpact(tag, l10n);
      if (impact != 0) {
        tagsStaticImpact += impact;
        // Wir fügen den Tag-Namen zur Info hinzu (wenn Platz ist)
        if (activeFactors.length < 3) {
          activeFactors.add(tag);
        }
      }
    }

    // 2.5 Personalisierte Tag-Effekte (Lernende App)
    double tagsPersonalImpact = _getPersonalizedTagImpact(todayTags, widget.entries);

    // 2.6 Saison & Wetter
    double seasonImpact = _getSeasonImpact() + _weatherImpact; 

    // 2.7 Zyklus
    double cycleImpact = _calculateCycleImpact(tomorrow);
    
    // 2.8 Household / Partner Vibe (SMART V2)
    final myEntryIds = widget.entries.map((e) => e.id).toSet();
    
    // Suche Partner-Einträge der letzten 24h
    final otherEntriesRecent = widget.allEntries.where((e) {
      final isNotMine = !myEntryIds.contains(e.id);
      final isRecent = DateTime.now().difference(e.timestamp).inHours < 24;
      return isNotMine && isRecent;
    }).toList();

    double householdImpact = 0.0;
    if (otherEntriesRecent.isNotEmpty) {
      // A) Stimmung
      final householdAvg = otherEntriesRecent.fold(0.0, (sum, e) => sum + e.score) / otherEntriesRecent.length;
      
      // Stimmung ist ansteckend: Wir gleichen uns an.
      // Wenn Partner schlecht drauf (<4), zieht es uns runter (-0.6).
      // Wenn Partner super drauf (>8), zieht es uns hoch (+0.4).
      if (householdAvg < 4.0) {
        householdImpact -= 0.6; 
      } else if (householdAvg > 8.0) {
        householdImpact += 0.4; 
      }

      // B) Partner Tags (NEU!)
      // Wir prüfen, ob der Partner "anstrengende" Tags gesetzt hat
      final partnerTags = otherEntriesRecent.expand((e) => e.tags).toSet();
      
      // Krank = Sorgen / Pflegeaufwand -> Stress für mich
      if (partnerTags.contains('Krank') || partnerTags.contains('Sick')) {
         householdImpact -= 0.4;
         if (!activeFactors.contains('Partner krank')) activeFactors.add('Partner krank');
      }
      
      // Party = Partner vielleicht verkatert/müde -> Stress
      if (partnerTags.contains('Party') || partnerTags.contains(l10n.tagParty)) {
         householdImpact -= 0.2;
      }
    }

    // 2.9 Sentiment (aus den Notizen der letzten 3 Einträge)
    final last3 = sortedHistory.take(3).toList();
    double sentimentImpact = _calculateSentimentImpact(last3, l10n);

    // --- ZUSAMMENFÜHRUNG ---
    double rawScore = baseScore 
                    + trendImpact 
                    + sleepImpact 
                    + tagsStaticImpact 
                    + tagsPersonalImpact
                    + seasonImpact 
                    + cycleImpact
                    + householdImpact
                    + sentimentImpact;

    // 3. WECHSELWIRKUNGEN (Multiplikatoren)
    
    // Doppelte Belastung: Zyklus + Schlafmangel
    if (cycleImpact < -0.5 && sleepImpact < -0.5) {
      rawScore -= 1.0; 
      if (!activeFactors.contains(l10n.predCycleRest)) {
        activeFactors.add(l10n.predCycleRest);
      }
    }
    // Ausgleich: Sport + Müdigkeit
    if (tagsStaticImpact > 0.5 && sleepImpact < 0) {
      rawScore += 0.5; // Sport federt Müdigkeit ab
    }

    final double finalScore = rawScore.clamp(1.0, 10.0);

    // --- UI DARSTELLUNG ---
    String title;
    List<Color> colors;
    IconData icon;

    if (finalScore >= 7.5) {
      title = l10n.statsTrendGood;
      icon = Icons.wb_sunny_rounded;
      colors = [Colors.orange.shade400, Colors.deepOrange.shade600];
    } else if (finalScore <= 4.5) {
      title = l10n.statsTrendBad;
      icon = Icons.spa_rounded;
      colors = [Colors.purple.shade300, Colors.deepPurple.shade700];
    } else {
      title = l10n.statsTrendNormal;
      icon = Icons.insights_rounded;
      colors = [Colors.teal.shade400, Colors.teal.shade700];
    }

    // Tips zusammenbauen (auch hier Klammern hinzugefügt)
    String tips = "";
    if (activeFactors.isNotEmpty) {
      tips += "${l10n.labelCategory}: ${activeFactors.join(', ')}. ";
    }
    if (sleepImpact < -0.5) {
      tips += "${l10n.predSleepTip} ";
    }
    if (householdImpact < -0.3) {
      tips += "${l10n.tipFamilyBad} ";
    }
    if (tagsPersonalImpact.abs() > 0.5) {
      tips += "Basierend auf deinen Mustern.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), 
            child: Icon(icon, color: Colors.white, size: 28)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.statsTrendTitle.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    Text("AI 2.0", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                // Score Indikator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(finalScore.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.0)),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text("/ 10", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (tips.isNotEmpty)
                  Text(tips, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.4, fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- ANDERE UI WIDGETS (Unverändert aber notwendig) ---

  Widget _buildEmptyPredictionCard(AppLocalizations l10n) {
    final int count = widget.entries.length;
    final int target = 5; 
    final double progress = count / target.toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.cyan.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.show_chart, color: Colors.white, size: 24), const SizedBox(width: 15), Text(l10n.aiCalibration, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 12),
          Text(l10n.aiCalibrationText(target - count), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4)),
          const SizedBox(height: 15),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.black.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 6)),
        ],
      ),
    );
  }

  Widget _buildLockedPredictionCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onUnlockPressed,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.deepPurple.shade900.withValues(alpha: 0.8), Colors.indigo.shade900.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_outline, color: Colors.white, size: 28)),
            const SizedBox(width: 16),
             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.lockedPredTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(l10n.lockedPredDesc, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))])),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedAICard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onUnlockPressed,
      child: _buildCard(
        title: l10n.statsAiCoachTitle,
        icon: Icons.auto_awesome, 
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_outlined, size: 48, color: Colors.indigo),
              const SizedBox(height: 15),
              Text(l10n.lockedAiTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.statsAiIntro, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: widget.onUnlockPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.becomePro))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(icon, size: 20, color: Colors.indigo)), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))])),
          const Divider(height: 1, thickness: 0.5),
          Padding(padding: const EdgeInsets.all(0), child: child),
        ],
      ),
    );
  }

  // HEATMAP DATEN
  Map<DateTime, int> _getHeatmapData() {
    final Map<DateTime, int> data = {};
    for (var entry in widget.entries) {
      final dateOnly = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      data[dateOnly] = entry.score.round();
    }
    return data;
  }

  // WOCHE ANALYSIEREN
  Future<void> _analyzeWeek() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() { _isAnalyzing = true; _analysisResult = null; });
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final weekEntries = widget.entries.where((e) => e.timestamp.isAfter(sevenDaysAgo)).toList();
      if (weekEntries.isEmpty) { setState(() { _isAnalyzing = false; _analysisResult = l10n.errorNoEntries7Days; }); return; }
      weekEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      StringBuffer sb = StringBuffer();
      sb.writeln("Daten für ${widget.currentProfile.name}:");
      for (var e in weekEntries) {
        final date = DateFormat('dd.MM.').format(e.timestamp);
        sb.writeln("- $date: Stimmung ${e.score.toStringAsFixed(1)}, Schlaf ${e.sleepRating?.toStringAsFixed(1) ?? '-'}, Tags: ${e.tags.join(', ')}. Notiz: ${e.note ?? ''}");
      }

      final url = Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/analyze');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'entriesText': sb.toString()}));
      if (response.statusCode == 200) { final data = jsonDecode(utf8.decode(response.bodyBytes)); setState(() { _analysisResult = data['result']; }); } else { setState(() { _analysisResult = l10n.errorAnalysisFailed(response.statusCode); }); }
    } catch (e) { setState(() { _analysisResult = l10n.snackError(e.toString()); }); } finally { if (mounted) { setState(() => _isAnalyzing = false); } }
  }

  Widget _buildAICard(AppLocalizations l10n) {
    return _buildCard(
      title: l10n.statsAiCoachTitle,
      icon: Icons.auto_awesome,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_analysisResult == null && !_isAnalyzing) Text(l10n.statsAiIntro, style: TextStyle(color: Colors.black87.withValues(alpha: 0.7), height: 1.5)),
            if (_isAnalyzing) const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),
            if (_analysisResult != null) Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.withValues(alpha: 0.1))), child: Text(_analysisResult!, style: const TextStyle(fontSize: 15, height: 1.5))),
            if (!_isAnalyzing) Padding(padding: const EdgeInsets.only(top: 20.0), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _analyzeWeek, icon: const Icon(Icons.psychology), label: Text(_analysisResult == null ? l10n.statsAiButton : l10n.statsAiButtonUpdate), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveChart(AppLocalizations l10n) {
    final sorted = List<MoodEntry>.from(widget.entries)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final chartData = sorted.length > 14 ? sorted.sublist(sorted.length - 14) : sorted;

    List<FlSpot> moodSpots = [];
    List<FlSpot> sleepSpots = [];

    for (int i = 0; i < chartData.length; i++) {
      moodSpots.add(FlSpot(i.toDouble(), chartData[i].score));
      if (chartData[i].sleepRating != null) {
        sleepSpots.add(FlSpot(i.toDouble(), chartData[i].sleepRating!));
      }
    }

    return LineChart(
      LineChartData(
        minY: 0, maxY: 10,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { final index = value.toInt(); if (index >= 0 && index < chartData.length) { if (chartData.length > 7 && index % 2 != 0) return const SizedBox.shrink(); return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(DateFormat('dd.').format(chartData[index].timestamp), style: TextStyle(fontSize: 10, color: Colors.grey.shade500))); } return const SizedBox.shrink(); })),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.black87,
            tooltipRoundedRadius: 12, tooltipPadding: const EdgeInsets.all(12), fitInsideHorizontally: true, fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isMood = spot.barIndex == 1; 
                final entry = chartData[spot.x.toInt()];
                if (isMood) {
                  final mood = MoodUtils.getMoodData(spot.y, l10n); 
                  return LineTooltipItem("${DateFormat('dd.MM').format(entry.timestamp)}\n", const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold), children: [TextSpan(text: "${mood['emoji']} ${mood['label']}: ${spot.y.toStringAsFixed(1)}\n", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), if (entry.note != null && entry.note!.isNotEmpty) TextSpan(text: "\"${entry.note!.length > 20 ? '${entry.note!.substring(0, 20)}...' : entry.note}\"", style: const TextStyle(color: Colors.white70, fontSize: 10, fontStyle: FontStyle.italic))]);
                } else {
                  return LineTooltipItem("${l10n.statsSleep}: ${spot.y.toStringAsFixed(1)} h", const TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold));
                }
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(spots: sleepSpots, isCurved: true, color: Colors.indigoAccent.withValues(alpha: 0.3), barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: moodSpots, isCurved: true, color: Colors.black87, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [MoodUtils.getBackgroundColor(8.0).withValues(alpha: 0.3), MoodUtils.getBackgroundColor(2.0).withValues(alpha: 0.1)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
        ],
      ),
    );
  }

  Widget _buildBarChart(AppLocalizations l10n) {
    final Map<int, List<double>> dayScores = {};
    for (var i = 1; i <= 7; i++) { dayScores[i] = []; }
    for (var e in widget.entries) { dayScores[e.timestamp.weekday]!.add(e.score); }

    List<BarChartGroupData> barGroups = [];
    for (var i = 1; i <= 7; i++) {
      final scores = dayScores[i]!;
      final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0.0;
      barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: avg, color: MoodUtils.getBackgroundColor(avg), width: 12, borderRadius: BorderRadius.circular(4), backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Colors.grey.withValues(alpha: 0.05)))]));
    }

    return BarChart(BarChartData(maxY: 10, titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { final dayName = DateFormat('EEE', l10n.localeName).format(DateTime(2023, 10, 2 + value.toInt())); final index = value.toInt() - 1; if (index < 0 || index >= 7) return const SizedBox.shrink(); return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(dayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600))); }))), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), barGroups: barGroups));
  }

  Widget _buildInsightsCard(AppLocalizations l10n) {
    // 1. Basisdaten berechnen
    final totalSum = widget.entries.fold(0.0, (sum, e) => sum + e.score);
    final globalAvg = totalSum / widget.entries.length;
    final Map<String, List<double>> tagScores = {};

    // 2. Scores pro Tag sammeln
    for (var entry in widget.entries) {
      for (var tag in entry.tags) {
        if (!tagScores.containsKey(tag)) tagScores[tag] = [];
        tagScores[tag]!.add(entry.score);
      }
    }

    final List<Map<String, dynamic>> impacts = [];

    // 3. HIER IST DIE NEUE LOGIK EINGEBAUT:
    tagScores.forEach((tag, scores) {
      
      // A) KI-Wissen abfragen (Hat dieser Tag generell eine starke Auswirkung?)
      final knownImpact = MoodUtils.getTagImpact(tag, l10n);
      
      // B) Anzeigen, wenn:
      //    1. Wir genug Daten haben (>= 2 Einträge)
      //    2. ODER wenn es zwar nur 1 Eintrag ist, aber der Tag eine starke bekannte Wirkung hat (>= 0.5)
      if (scores.length >= 2 || (scores.isNotEmpty && knownImpact.abs() >= 0.5)) {
        
        final tagAvg = scores.reduce((a, b) => a + b) / scores.length;
        
        // Normalfall: Impact ist die Abweichung vom globalen Durchschnitt
        double calculatedImpact = tagAvg - globalAvg;
        
        // Spezialfall: Wenn wir nur 1 Eintrag haben, vertrauen wir dem KI-Wissen mehr als der Statistik
        // (Sonst wäre der Impact oft zufällig 0 oder sehr klein)
        if (scores.length == 1 && knownImpact != 0) {
           calculatedImpact = knownImpact; 
        }

        impacts.add({'tag': tag, 'avg': tagAvg, 'impact': calculatedImpact, 'count': scores.length});
      }
    });

    // Sortierung nach Stärke des Einflusses
    impacts.sort((a, b) => (b['impact'].abs() as double).compareTo((a['impact'].abs() as double)));

    return _buildCard(
      title: l10n.statsInsights,
      icon: Icons.trending_up,
      child: impacts.isEmpty 
        ? const Padding(padding: EdgeInsets.all(20), child: Text("Tracke mehr Tags, um Muster zu erkennen."))
        : Column(
            children: impacts.take(5).map((item) {
              final rawTag = item['tag'] as String;
              final localizedTagName = MoodUtils.getLocalizedTagLabel(rawTag, l10n); 
              final impact = item['impact'] as double;
              final isPositive = impact > 0;
              final color = isPositive ? Colors.green : Colors.redAccent;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 16)),
                    const SizedBox(width: 15),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(localizedTagName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text("${item['count']}x · Ø ${item['avg'].toStringAsFixed(1)}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])),
                    Text("${isPositive ? '+' : ''}${impact.toStringAsFixed(1)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
          ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // <--- NEU

import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';
import 'locked_insights.dart';

class StatsView extends StatefulWidget {
  final List<MoodEntry> entries;
  final String profileName;
  final bool isPro;
  final VoidCallback onUnlockPressed;

  const StatsView({
    super.key,
    required this.entries,
    required this.profileName,
    required this.isPro,
    required this.onUnlockPressed,
  });

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _isAnalyzing = false;
  String? _analysisResult;

  // --- LOGIK: WOCHE ANALYSIEREN ---
  Future<void> _analyzeWeek() async {
    setState(() { _isAnalyzing = true; _analysisResult = null; });
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final weekEntries = widget.entries.where((e) => e.timestamp.isAfter(sevenDaysAgo)).toList();
      
      if (weekEntries.isEmpty) {
        setState(() { _isAnalyzing = false; _analysisResult = "Keine Einträge in den letzten 7 Tagen gefunden."; });
        return;
      }
      weekEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      StringBuffer sb = StringBuffer();
      sb.writeln("Daten für ${widget.profileName}:");
      for (var e in weekEntries) {
        final date = DateFormat('dd.MM.').format(e.timestamp);
        sb.writeln("- $date: Stimmung ${e.score.toStringAsFixed(1)}, Schlaf ${e.sleepRating?.toStringAsFixed(1) ?? '-'}, Tags: ${e.tags.join(', ')}. Notiz: ${e.note ?? ''}");
      }

      final url = Uri.parse('https://celadon-pasca-8b960a.netlify.app/.netlify/functions/analyze');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'entriesText': sb.toString()}));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() { _analysisResult = data['result']; });
      } else {
        setState(() { _analysisResult = "Fehler bei der Analyse: ${response.statusCode}"; });
      }
    } catch (e) {
      setState(() { _analysisResult = "Verbindungsfehler: $e"; });
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // --- HEATMAP DATEN VORBEREITEN ---
  Map<DateTime, int> _getHeatmapData() {
    final Map<DateTime, int> data = {};
    for (var entry in widget.entries) {
      // Wir normalisieren das Datum (Uhrzeit entfernen), damit Heatmap es erkennt
      final dateOnly = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      // Wir nutzen den Mood-Score (gerundet) als Farbintensität
      // Oder einfach '1' für "Eintrag vorhanden", wenn man nur Frequenz will.
      // Hier nehmen wir den Score (1-10)
      data[dateOnly] = entry.score.round();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    // Hintergrund leicht grau, damit die weißen Karten "schweben"
    return Container(
      color: const Color(0xFFF5F7FA), 
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          // 1. HEATMAP CARD (Jahresübersicht)
          _buildCard(
            title: "Jahres-Verlauf",
            icon: Icons.calendar_month,
            child: widget.entries.isEmpty 
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Noch keine Daten.")))
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  // FIX: Wir machen den ganzen Container scrollbar, 
                  // damit Labels links nicht abgeschnitten werden.
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10), // Etwas Luft an den Seiten
                    child: HeatMap(
                      datasets: _getHeatmapData(),
                      startDate: DateTime.now().subtract(const Duration(days: 90)), 
                      endDate: DateTime.now(),
                      colorMode: ColorMode.opacity, 
                      showText: false,
                      scrollable: false, // <--- WICHTIG: Internes Scrollen aus!
                      margin: const EdgeInsets.all(2), // Engerer Abstand zwischen Kästchen
                      size: 18, // Feste, gut lesbare Größe (nicht zu klein)
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

          // 2. CHART CARD (Interaktiv)
          _buildCard(
            title: "Stimmung & Schlaf",
            icon: Icons.show_chart,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: widget.entries.isEmpty 
                    ? const Center(child: Text("Keine Daten"))
                    : _buildInteractiveChart(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Stimmung", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 20),
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.indigoAccent.withValues(alpha: 0.5), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Schlaf", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. AI COACH CARD
          if (widget.isPro)
            _buildAICard()
          else
            LockedInsights(onUnlockPressed: widget.onUnlockPressed),

          const SizedBox(height: 16),

          // 4. WOCHENTAGS STATS
          _buildCard(
            title: "Muster nach Wochentag",
            icon: Icons.bar_chart,
            child: SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildBarChart(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 5. INSIGHTS / TAGS
          if (widget.entries.isNotEmpty)
            _buildInsightsCard(),
            
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- HELPER: CARD BUILDER ---
  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.05), shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: Colors.indigo),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Content
          Padding(
            padding: const EdgeInsets.all(0),
            child: child,
          ),
        ],
      ),
    );
  }

  // --- HELPER: CHARTS ---
  Widget _buildInteractiveChart() {
    // Daten vorbereiten (Letzte 7 Tage oder mehr)
    // Wir sortieren erst mal
    final sorted = List<MoodEntry>.from(widget.entries)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Nehmen wir max die letzten 14 Einträge für Übersichtlichkeit, oder filtern nach Datum
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
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false, 
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Keine Achsenbeschriftung links für cleanen Look
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  // Nur jeden 2. Tag anzeigen wenn es viele sind
                  if (chartData.length > 7 && index % 2 != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd.').format(chartData[index].timestamp),
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        // INTERAKTIVITÄT
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.black87,
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isMood = spot.barIndex == 1; // Index 1 ist Mood (siehe unten bei lineBarsData)
                final entry = chartData[spot.x.toInt()];
                
                if (isMood) {
                  return LineTooltipItem(
                    "${DateFormat('dd.MM').format(entry.timestamp)}\n",
                    const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "Stimmung: ${spot.y.toStringAsFixed(1)}\n",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (entry.note != null && entry.note!.isNotEmpty)
                        TextSpan(
                          text: "\"${entry.note!.length > 20 ? '${entry.note!.substring(0, 20)}...' : entry.note}\"",
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontStyle: FontStyle.italic),
                        ),
                    ],
                  );
                } else {
                  // Schlaf Tooltip (nur wenn explizit berührt)
                  return LineTooltipItem(
                    "Schlaf: ${spot.y.toStringAsFixed(1)} h",
                    const TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  );
                }
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          // Schlaf Linie
          LineChartBarData(
            spots: sleepSpots, isCurved: true,
            color: Colors.indigoAccent.withValues(alpha: 0.3), 
            barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false), 
          ),
          // Stimmungs Linie
          LineChartBarData(
            spots: moodSpots, isCurved: true,
            color: Colors.black87,
            barWidth: 3, isStrokeCapRound: true, 
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  MoodUtils.getBackgroundColor(8.0).withValues(alpha: 0.3),
                  MoodUtils.getBackgroundColor(2.0).withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final Map<int, List<double>> dayScores = {};
    
    // FIX: Jetzt mit geschweiften Klammern
    for (var i = 1; i <= 7; i++) {
      dayScores[i] = [];
    }

    // FIX: Auch hier Klammern drum
    for (var e in widget.entries) {
      dayScores[e.timestamp.weekday]!.add(e.score);
    }

    List<BarChartGroupData> barGroups = [];
    for (var i = 1; i <= 7; i++) {
      final scores = dayScores[i]!;
      final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0.0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: MoodUtils.getBackgroundColor(avg),
              width: 12, borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Colors.grey.withValues(alpha: 0.05)),
            )
          ],
        ),
      );
    }

    return BarChart(
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
                return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)));
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildAICard() {
    return _buildCard(
      title: "AI Wochen-Coach",
      icon: Icons.auto_awesome,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_analysisResult == null && !_isAnalyzing)
              Text("Lass deine Woche von der KI analysieren. Sie findet Muster in deinem Schlaf, Zyklus und deinen Notizen.", style: TextStyle(color: Colors.black87.withValues(alpha: 0.7), height: 1.5)),

            if (_isAnalyzing)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),

            if (_analysisResult != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.withValues(alpha: 0.1))),
                child: Text(_analysisResult!, style: const TextStyle(fontSize: 15, height: 1.5)),
              ),

            if (!_isAnalyzing)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeWeek,
                    icon: const Icon(Icons.psychology),
                    label: Text(_analysisResult == null ? "Woche analysieren" : "Analyse aktualisieren"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final totalSum = widget.entries.fold(0.0, (sum, e) => sum + e.score);
    final globalAvg = totalSum / widget.entries.length;
    final Map<String, List<double>> tagScores = {};

    for (var entry in widget.entries) {
      for (var tag in entry.tags) {
        if (!tagScores.containsKey(tag)) tagScores[tag] = [];
        tagScores[tag]!.add(entry.score);
      }
    }

    final List<Map<String, dynamic>> impacts = [];
    tagScores.forEach((tag, scores) {
      if (scores.length >= 2) {
        final tagAvg = scores.reduce((a, b) => a + b) / scores.length;
        final impact = tagAvg - globalAvg;
        impacts.add({'tag': tag, 'avg': tagAvg, 'impact': impact, 'count': scores.length});
      }
    });
    impacts.sort((a, b) => (b['impact'].abs() as double).compareTo((a['impact'].abs() as double)));

    return _buildCard(
      title: "Einflussfaktoren",
      icon: Icons.trending_up,
      child: impacts.isEmpty 
        ? const Padding(padding: EdgeInsets.all(20), child: Text("Tracke mehr Tags, um Muster zu erkennen."))
        : Column(
            children: impacts.take(5).map((item) {
              final impact = item['impact'] as double;
              final isPositive = impact > 0;
              final color = isPositive ? Colors.green : Colors.redAccent;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 16),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("${item['count']}x · Ø ${item['avg'].toStringAsFixed(1)}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text("${isPositive ? '+' : ''}${impact.toStringAsFixed(1)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
          ),
    );
  }
}
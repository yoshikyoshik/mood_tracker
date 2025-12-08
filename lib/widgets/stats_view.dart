import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/mood_utils.dart';
import 'locked_insights.dart';

class StatsView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final moodData = _getChartData((e) => e.score); 
    final sleepData = _getChartData((e) => e.sleepRating ?? 5.0);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text("Woche von $profileName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Legende
        Row(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            const Text("Stimmung", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            const Text("Schlaf", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Line Chart
        SizedBox(
          height: 250,
          child: (moodData.isEmpty) 
            ? const Center(child: Text("Nicht genug Daten für eine Grafik."))
            : LineChart(
              LineChartData(
                minY: 0, maxY: 10, minX: -0.5, maxX: 6.5,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, reservedSize: 30)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, interval: 1,
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
                    spots: sleepData, isCurved: true,
                    color: Colors.indigoAccent.withValues(alpha: 0.5), 
                    barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false), 
                  ),
                  LineChartBarData(
                    spots: moodData, isCurved: true,
                    color: Colors.black87,
                    barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withValues(alpha: 0.2),
                          Colors.amber.withValues(alpha: 0.2),
                          Colors.redAccent.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
        
        const SizedBox(height: 40),

        _buildWeekdayStats(),

        const SizedBox(height: 40),
        
        if (isPro)
          _buildInsightsSection()
        else
          LockedInsights(onUnlockPressed: onUnlockPressed),
        
        const SizedBox(height: 50),
      ],
    );
  }

  // --- HELPER LOGIK ---

  List<FlSpot> _getChartData(double Function(MoodEntry) getValue) {
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final dateToCheck = now.subtract(Duration(days: i));
      final entriesForDay = entries.where((e) => DateUtils.isSameDay(e.timestamp, dateToCheck)).toList();

      if (entriesForDay.isNotEmpty) {
        final double avg = entriesForDay.map((e) => getValue(e)).reduce((a, b) => a + b) / entriesForDay.length;
        spots.add(FlSpot((6 - i).toDouble(), avg));
      }
    }
    return spots;
  }

  Widget _buildWeekdayStats() {
    if (entries.isEmpty) return const SizedBox.shrink();

    final Map<int, List<double>> dayScores = {};
    
    // FIX: Hier waren die fehlenden geschweiften Klammern
    for (var i = 1; i <= 7; i++) {
      dayScores[i] = [];
    }

    for (var e in entries) {
      dayScores[e.timestamp.weekday]!.add(e.score);
    }

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
              color: MoodUtils.getBackgroundColor(avg),
              width: 16, borderRadius: BorderRadius.circular(4),
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

  Widget _buildInsightsSection() {
    if (entries.isEmpty) return const SizedBox.shrink();

    final totalSum = entries.fold(0.0, (sum, e) => sum + e.score);
    final globalAvg = totalSum / entries.length;

    final Map<String, List<double>> tagScores = {};

    for (var entry in entries) {
      for (var tag in entry.tags) {
        // FIX: Auch hier saubere Klammern gesetzt
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
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))]
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
                    Text("${isPositive ? '+' : ''}${impact.toStringAsFixed(1)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
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
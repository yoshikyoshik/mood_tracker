import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class ProfileView extends StatelessWidget {
  final String profileName;
  final String email;   // <--- NEU
  final String version; // <--- NEU
  final List<MoodEntry> entries;
  final bool isPro;
  final VoidCallback onLogout;
  final VoidCallback onManageSubscription;
  final VoidCallback onContactSupport;

  const ProfileView({
    super.key,
    required this.profileName,
    required this.email,   // <--- NEU
    required this.version, // <--- NEU
    required this.entries,
    required this.isPro,
    required this.onLogout,
    required this.onManageSubscription,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. HEADER (Avatar & Name)
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(child: Text(profileName.isNotEmpty ? profileName[0].toUpperCase() : "?", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo))),
                ),
                const SizedBox(height: 15),
                Text(profileName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                
                // PRO BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: isPro ? Colors.indigo : Colors.grey, borderRadius: BorderRadius.circular(12)),
                  child: Text(isPro ? "PRO MITGLIED" : "FREE USER", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ),
                
                const SizedBox(height: 8),
                
                // EMAIL (NEU)
                Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                
                const SizedBox(height: 4),
                
                // VERSION (NEU)
                Text("Version $version", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. ERFOLGE
          const Text("Deine Erfolge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _buildBadgesGrid(context),

          const SizedBox(height: 30),

          // 3. EINSTELLUNGEN
          const Text("Einstellungen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _buildSettingsCard(context),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    final totalEntries = entries.length;
    
    // Bestehende Metriken
    final uniqueDaysCount = entries.map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)).toSet().length;
    final nightCount = entries.where((e) => e.timestamp.hour >= 22 || e.timestamp.hour < 4).length;
    final noteCount = entries.where((e) => e.note != null && e.note!.length > 10).length; 
    final highMoodCount = entries.where((e) => e.score >= 8.0).length;

    // --- NEUE METRIKEN FÜR NEUE BADGES ---
    // 1. Kontext-King: Einträge mit mehr als 2 Tags
    final detailedCount = entries.where((e) => e.tags.length >= 3).length;
    // 2. Schlaf-Wächter: Einträge mit Schlafdaten
    final sleepTrackedCount = entries.where((e) => e.sleepRating != null).length;
    // 3. Wochenend-Held: Einträge an Sa/So
    final weekendCount = entries.where((e) => e.timestamp.weekday >= 6).length;

    final badges = [
      // --- START ---
      {
        'title': 'Aller Anfang',
        'desc': 'Der erste Eintrag.',
        'icon': Icons.flag_rounded,
        'color': Colors.blue,
        'unlocked': totalEntries >= 1,
      },
      // --- DISZIPLIN ---
      {
        'title': 'Dranbleiber',
        'desc': 'Du hast an 7 verschiedenen Tagen getrackt.',
        'icon': Icons.directions_run_rounded,
        'color': Colors.orange,
        'unlocked': uniqueDaysCount >= 7,
      },
      {
        'title': 'Wochenend-Held', // NEU
        'desc': '10 Einträge am Wochenende. Du bleibst auch in der Freizeit dran.',
        'icon': Icons.weekend_rounded,
        'color': Colors.teal,
        'unlocked': weekendCount >= 10,
      },
      {
        'title': 'Veteran',
        'desc': '100 Einträge. Das ist echte Disziplin!',
        'icon': Icons.military_tech_rounded,
        'color': Colors.redAccent,
        'unlocked': totalEntries >= 100,
      },
      // --- VERHALTEN ---
      {
        'title': 'Nachteule',
        'desc': '20x spät abends getrackt.',
        'icon': Icons.nights_stay_rounded,
        'color': Colors.indigo,
        'unlocked': nightCount >= 20,
      },
      {
        'title': 'Schlaf-Wächter', // NEU
        'desc': '30x deinen Schlaf protokolliert. Gesundheit geht vor!',
        'icon': Icons.bedtime_rounded,
        'color': Colors.deepPurple,
        'unlocked': sleepTrackedCount >= 30,
      },
      // --- PERSÖNLICHKEIT ---
      {
        'title': 'Tagebuch',
        'desc': '50 ausführliche Notizen geschrieben.',
        'icon': Icons.menu_book_rounded,
        'color': Colors.brown,
        'unlocked': noteCount >= 50,
      },
      {
        'title': 'Kontext-Profi', // NEU
        'desc': '20 Einträge mit vielen Tags (3+). Du magst Details.',
        'icon': Icons.label_important_rounded,
        'color': Colors.cyan,
        'unlocked': detailedCount >= 20,
      },
      {
        'title': 'Optimist',
        'desc': '50x richtig gute Laune gehabt (8+).',
        'icon': Icons.sentiment_very_satisfied_rounded,
        'color': Colors.green,
        'unlocked': highMoodCount >= 50,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: badges.length,
      itemBuilder: (ctx, index) {
        final badge = badges[index];
        final isUnlocked = badge['unlocked'] as bool;
        final color = badge['color'] as Color;

        return Tooltip(
          message: badge['desc'] as String,
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
              border: isUnlocked ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge['icon'] as IconData,
                    color: isUnlocked ? color : Colors.grey.shade300,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  badge['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Etwas kleiner, falls Titel lang sind
                    color: isUnlocked ? Colors.black87 : Colors.grey.shade400
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          if (!isPro)
            ListTile(
              leading: const Icon(Icons.diamond, color: Colors.indigo),
              title: const Text("Pro werden"),
              subtitle: const Text("Schalte alle Features frei"),
              trailing: const Icon(Icons.chevron_right),
              onTap: onManageSubscription,
            ),
          if (isPro)
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text("Abo verwalten"),
              trailing: const Icon(Icons.chevron_right),
              onTap: onManageSubscription,
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Colors.black87),
            title: const Text("Support kontaktieren"),
            trailing: const Icon(Icons.chevron_right),
            onTap: onContactSupport, 
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Abmelden", style: TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
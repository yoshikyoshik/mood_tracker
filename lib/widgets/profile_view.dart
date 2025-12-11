import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/mood_entry.dart';
import '../l10n/generated/app_localizations.dart'; // Zugriff auf Texte
import '../main.dart'; // Zugriff auf MyApp für setLocale

class ProfileView extends StatelessWidget {
  final String profileName;
  final String email;
  final String version;
  final List<MoodEntry> entries;
  final bool isPro;
  final VoidCallback onLogout;
  final VoidCallback onManageSubscription;
  final VoidCallback onContactSupport;

  const ProfileView({
    super.key,
    required this.profileName,
    required this.email,
    required this.version,
    required this.entries,
    required this.isPro,
    required this.onLogout,
    required this.onManageSubscription,
    required this.onContactSupport,
  });

  // --- NEU: SPRACH-DIALOG ---
  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              // DEUTSCH
              ListTile(
                leading: const Text("🇩🇪", style: TextStyle(fontSize: 24)),
                title: const Text("Deutsch"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('de'));
                  Navigator.pop(ctx);
                },
              ),
              // ENGLISCH
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              // SPANISCH
               ListTile(
                leading: const Text("🇪🇸", style: TextStyle(fontSize: 24)),
                title: const Text("Español"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('es'));
                  Navigator.pop(ctx);
                },
              ),
              // RUSSISCH
               ListTile(
                leading: const Text("🇷🇺", style: TextStyle(fontSize: 24)),
                title: const Text("Русский"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('ru'));
                  Navigator.pop(ctx);
                },
              ),
              // CHINESISCH
               ListTile(
                leading: const Text("🇨🇳", style: TextStyle(fontSize: 24)),
                title: const Text("中文"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('zh'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback, falls der Browser nicht aufgeht
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konnte Webseite nicht öffnen")));
        }
      }
    } catch (e) {
      debugPrint("Fehler beim Öffnen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <--- Zugriff auf Texte

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
                  child: Text(isPro ? l10n.proMember : l10n.freeUser, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ),
                
                const SizedBox(height: 8),
                Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text("${l10n.version} $version", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. ERFOLGE
          Text(l10n.achievements, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _buildBadgesGrid(context),

          const SizedBox(height: 30),

          // 3. EINSTELLUNGEN
          Text(l10n.settings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _buildSettingsCard(context),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalEntries = entries.length;
    
    // Metriken
    final uniqueDaysCount = entries.map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)).toSet().length;
    final nightCount = entries.where((e) => e.timestamp.hour >= 22 || e.timestamp.hour < 4).length;
    final noteCount = entries.where((e) => e.note != null && e.note!.length > 10).length; 
    final highMoodCount = entries.where((e) => e.score >= 8.0).length;
    final detailedCount = entries.where((e) => e.tags.length >= 3).length;
    final sleepTrackedCount = entries.where((e) => e.sleepRating != null).length;
    final weekendCount = entries.where((e) => e.timestamp.weekday >= 6).length;

    final badges = [
      {
        'title': l10n.badgeStart,
        'desc': l10n.badgeStartDesc,
        'icon': Icons.flag_rounded,
        'color': Colors.blue,
        'unlocked': totalEntries >= 1,
      },
      {
        'title': l10n.badgeStreak,
        'desc': l10n.badgeStreakDesc,
        'icon': Icons.directions_run_rounded,
        'color': Colors.orange,
        'unlocked': uniqueDaysCount >= 7,
      },
      {
        'title': l10n.badgeWeekend, 
        'desc': l10n.badgeWeekendDesc,
        'icon': Icons.weekend_rounded,
        'color': Colors.teal,
        'unlocked': weekendCount >= 10,
      },
      {
        'title': l10n.badgeVeteran,
        'desc': l10n.badgeVeteranDesc,
        'icon': Icons.military_tech_rounded,
        'color': Colors.redAccent,
        'unlocked': totalEntries >= 100,
      },
      {
        'title': l10n.badgeNightOwl,
        'desc': l10n.badgeNightOwlDesc,
        'icon': Icons.nights_stay_rounded,
        'color': Colors.indigo,
        'unlocked': nightCount >= 20,
      },
      {
        'title': l10n.badgeSleep,
        'desc': l10n.badgeSleepDesc,
        'icon': Icons.bedtime_rounded,
        'color': Colors.deepPurple,
        'unlocked': sleepTrackedCount >= 30,
      },
      {
        'title': l10n.badgeJournal,
        'desc': l10n.badgeJournalDesc,
        'icon': Icons.menu_book_rounded,
        'color': Colors.brown,
        'unlocked': noteCount >= 50,
      },
      {
        'title': l10n.badgeContext, 
        'desc': l10n.badgeContextDesc,
        'icon': Icons.label_important_rounded,
        'color': Colors.cyan,
        'unlocked': detailedCount >= 20,
      },
      {
        'title': l10n.badgeOptimist,
        'desc': l10n.badgeOptimistDesc,
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
                    fontSize: 11,
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
    final l10n = AppLocalizations.of(context)!; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // SPRACHE
          ListTile(
            leading: const Icon(Icons.language, color: Colors.indigo),
            title: Text(l10n.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(height: 1),

          // PRO / ABO
          if (!isPro)
            ListTile(
              leading: const Icon(Icons.diamond, color: Colors.indigo),
              title: Text(l10n.becomePro),
              subtitle: const Text("Alle Features"), 
              trailing: const Icon(Icons.chevron_right),
              onTap: onManageSubscription,
            ),
          if (isPro)
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(l10n.manageSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: onManageSubscription,
            ),
          const Divider(height: 1),

          // SUPPORT
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Colors.black87),
            title: Text(l10n.contactSupport),
            trailing: const Icon(Icons.chevron_right),
            onTap: onContactSupport, 
          ),
          const Divider(height: 1),

          // --- NEU: RECHTLICHES ---
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.grey),
            title: Text(l10n.privacy),
            trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
            onTap: () => _launchURL(context, 'https://manabsphere.com/privacy.html'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: Text(l10n.imprint),
            trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
            onTap: () => _launchURL(context, 'https://manabsphere.com/imprint.html'),
          ),
          const Divider(height: 1),
          // ------------------------

          // LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
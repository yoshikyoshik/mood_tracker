import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/mood_entry.dart';
import '../models/profile.dart';
import '../l10n/generated/app_localizations.dart';
import '../main.dart';
import '../utils/report_generator.dart';
import 'partner_connect_card.dart';
import '../screens/auth_gate.dart'; 

class ProfileView extends StatefulWidget {
  final Profile currentProfile;
  final String email;
  final String version;
  final List<MoodEntry> entries;
  final List<MoodEntry> allEntries;
  final bool isPro;
  final VoidCallback onLogout;
  final VoidCallback onManageSubscription;
  final VoidCallback onContactSupport;
  final VoidCallback onStartTutorial;

  const ProfileView({
    super.key,
    required this.currentProfile,
    required this.email,
    required this.version,
    required this.entries,
    required this.allEntries,
    required this.isPro,
    required this.onLogout,
    required this.onManageSubscription,
    required this.onContactSupport,
    required this.onStartTutorial,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false; 

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
              ListTile(leading: const Text("🇩🇪", style: TextStyle(fontSize: 24)), title: const Text("Deutsch"), onTap: () { MyApp.setLocale(context, const Locale('de')); Navigator.pop(ctx); }),
              ListTile(leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)), title: const Text("English"), onTap: () { MyApp.setLocale(context, const Locale('en')); Navigator.pop(ctx); }),
              ListTile(leading: const Text("🇪🇸", style: TextStyle(fontSize: 24)), title: const Text("Español"), onTap: () { MyApp.setLocale(context, const Locale('es')); Navigator.pop(ctx); }),
              ListTile(leading: const Text("🇷🇺", style: TextStyle(fontSize: 24)), title: const Text("Русский"), onTap: () { MyApp.setLocale(context, const Locale('ru')); Navigator.pop(ctx); }),
              ListTile(leading: const Text("🇨🇳", style: TextStyle(fontSize: 24)), title: const Text("中文"), onTap: () { MyApp.setLocale(context, const Locale('zh')); Navigator.pop(ctx); }),
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
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konnte Webseite nicht öffnen")));
      }
    } catch (e) {
      debugPrint("Fehler: $e");
    }
  }

  // --- ACCOUNT LÖSCHEN LOGIK (MODERN) ---
  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Modernes Bottom Sheet statt altbackener Dialog
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kleiner grauer "Griff" oben
                Container(
                  width: 40, 
                  height: 4, 
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, 
                    borderRadius: BorderRadius.circular(2)
                  ),
                ),
                const SizedBox(height: 30),
                
                // Warn-Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
                ),
                const SizedBox(height: 20),
                
                // Titel
                Text(
                  l10n.deleteAccountTitle, 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                // Beschreibung
                Text(
                  l10n.deleteAccountContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 30),
                
                // Löschen Button (Rot & Breit)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true), // Gibt TRUE zurück
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.delete, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Abbrechen Button (Text)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false), // Gibt FALSE zurück
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Wenn Nutzer abgebrochen hat oder null zurückkommt (durch Klick daneben)
    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 2. Die SQL-Funktion aufrufen
      await Supabase.instance.client.rpc('delete_user');

      // 3. Logout clientseitig
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        // 4. Zurück zum Start
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()), 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler beim Löschen: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Falls gerade gelöscht wird, zeigen wir einen Spinner über allem
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // HEADER
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: Colors.white, width: 4)),
                  child: Center(child: Text(widget.currentProfile.name.isNotEmpty ? widget.currentProfile.name[0].toUpperCase() : "?", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo))),
                ),
                const SizedBox(height: 15),
                Text(widget.currentProfile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: widget.isPro ? Colors.indigo : Colors.grey, borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.isPro ? l10n.proMember : l10n.freeUser, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ),
                const SizedBox(height: 8),
                Text(widget.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text("${l10n.version} ${widget.version}", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // PARTNER CONNECT (NUR WENN HAUPTPROFIL)
          // --- HIER IST DER FIX ---
          if (widget.currentProfile.isMain) ...[
            PartnerConnectCard(
              currentProfile: widget.currentProfile,
              authEmail: widget.email,
              isPro: widget.isPro,
              onUnlockPressed: widget.onManageSubscription,
            ),
            const SizedBox(height: 30),
          ],
          // ------------------------

          // ERFOLGE (NUR BEIM HAUPTPROFIL ANZEIGEN)
          if (widget.currentProfile.isMain) ...[
            Text(l10n.achievements, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            _buildBadgesGrid(context),
            const SizedBox(height: 30),
          ],

          // EINSTELLUNGEN
          Text(l10n.settings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _buildSettingsCard(context, widget.currentProfile.name),
          
          const SizedBox(height: 40),

          // ACCOUNT LÖSCHEN (Ganz unten)
          Center(
            child: TextButton.icon(
              onPressed: _deleteAccount,
              // KORREKTUR: withValues statt withOpacity
              icon: Icon(Icons.delete_forever, color: Colors.red.withValues(alpha: 0.7), size: 20),
              label: Text(
                // KORREKTUR: ?? entfernt
                l10n.deleteAccountBtn, 
                // KORREKTUR: withValues statt withOpacity
                style: TextStyle(color: Colors.red.withValues(alpha: 0.7), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalEntries = widget.allEntries.length;
    final uniqueDaysCount = widget.allEntries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .length;
    final nightCount = widget.allEntries.where((e) => e.timestamp.hour >= 22 || e.timestamp.hour < 4).length;
    final noteCount = widget.allEntries.where((e) => e.note != null && e.note!.length > 10).length;
    final highMoodCount = widget.allEntries.where((e) => e.score >= 8.0).length;
    final detailedCount = widget.allEntries.where((e) => e.tags.length >= 3).length;
    final sleepTrackedCount = widget.allEntries.where((e) => e.sleepRating != null).length;
    final weekendCount = widget.allEntries.where((e) => e.timestamp.weekday >= 6).length;

    final badges = [
      { 'title': l10n.badgeStart, 'desc': l10n.badgeStartDesc, 'icon': Icons.flag_rounded, 'color': Colors.blue, 'unlocked': totalEntries >= 1 },
      { 'title': l10n.badgeStreak, 'desc': l10n.badgeStreakDesc, 'icon': Icons.directions_run_rounded, 'color': Colors.orange, 'unlocked': uniqueDaysCount >= 7 },
      { 'title': l10n.badgeWeekend, 'desc': l10n.badgeWeekendDesc, 'icon': Icons.weekend_rounded, 'color': Colors.teal, 'unlocked': weekendCount >= 10 },
      { 'title': l10n.badgeVeteran, 'desc': l10n.badgeVeteranDesc, 'icon': Icons.military_tech_rounded, 'color': Colors.redAccent, 'unlocked': totalEntries >= 100 },
      { 'title': l10n.badgeNightOwl, 'desc': l10n.badgeNightOwlDesc, 'icon': Icons.nights_stay_rounded, 'color': Colors.indigo, 'unlocked': nightCount >= 20 },
      { 'title': l10n.badgeSleep, 'desc': l10n.badgeSleepDesc, 'icon': Icons.bedtime_rounded, 'color': Colors.deepPurple, 'unlocked': sleepTrackedCount >= 30 },
      { 'title': l10n.badgeJournal, 'desc': l10n.badgeJournalDesc, 'icon': Icons.menu_book_rounded, 'color': Colors.brown, 'unlocked': noteCount >= 50 },
      { 'title': l10n.badgeContext, 'desc': l10n.badgeContextDesc, 'icon': Icons.label_important_rounded, 'color': Colors.cyan, 'unlocked': detailedCount >= 20 },
      { 'title': l10n.badgeOptimist, 'desc': l10n.badgeOptimistDesc, 'icon': Icons.sentiment_very_satisfied_rounded, 'color': Colors.green, 'unlocked': highMoodCount >= 50 },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemCount: badges.length,
      itemBuilder: (ctx, index) {
        final badge = badges[index];
        final isUnlocked = badge['unlocked'] as bool;
        final color = badge['color'] as Color;
        return Tooltip(
          message: badge['desc'] as String,
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))], border: isUnlocked ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.grey.shade100, shape: BoxShape.circle), child: Icon(badge['icon'] as IconData, color: isUnlocked ? color : Colors.grey.shade300, size: 30)),
                const SizedBox(height: 10),
                Text(badge['title'] as String, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isUnlocked ? Colors.black87 : Colors.grey.shade400)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context, String nameForPdf) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          ListTile(leading: const Icon(Icons.language, color: Colors.indigo), title: Text(l10n.language), trailing: const Icon(Icons.chevron_right), onTap: () => _showLanguageDialog(context)),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.indigo),
            title: Text(l10n.tutorialStart),
            trailing: const Icon(Icons.play_circle_outline, size: 20, color: Colors.indigo),
            onTap: widget.onStartTutorial,
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
            title: Text(l10n.exportPdfButton),
            trailing: Icon(widget.isPro ? Icons.chevron_right : Icons.lock, size: 20, color: widget.isPro ? Colors.grey : Colors.grey.shade400),
            onTap: () {
              if (widget.isPro) {
                ReportGenerator.generateAndPrint(widget.entries, nameForPdf, l10n);
              } else {
                widget.onManageSubscription();
              }
            },
          ),
          const Divider(height: 1),

          if (!widget.isPro) ListTile(leading: const Icon(Icons.diamond, color: Colors.indigo), title: Text(l10n.becomePro), subtitle: const Text("Alle Features"), trailing: const Icon(Icons.chevron_right), onTap: widget.onManageSubscription),
          if (widget.isPro) ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: Text(l10n.manageSub), trailing: const Icon(Icons.chevron_right), onTap: widget.onManageSubscription),
          const Divider(height: 1),

          ListTile(leading: const Icon(Icons.mail_outline, color: Colors.black87), title: Text(l10n.contactSupport), trailing: const Icon(Icons.chevron_right), onTap: widget.onContactSupport),
          const Divider(height: 1),

          ListTile(leading: const Icon(Icons.policy, color: Colors.grey), title: Text(l10n.privacy), trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey), onTap: () => _launchURL(context, 'https://manabsphere.com/privacy.html')),
          ListTile(leading: const Icon(Icons.info_outline, color: Colors.grey), title: Text(l10n.imprint), trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey), onTap: () => _launchURL(context, 'https://manabsphere.com/imprint.html')),
          const Divider(height: 1),

          ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)), onTap: widget.onLogout),
        ],
      ),
    );
  }
}
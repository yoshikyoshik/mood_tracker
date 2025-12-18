import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../services/partner_service.dart';
import '../models/profile.dart';
import '../l10n/generated/app_localizations.dart';

class PartnerConnectCard extends StatefulWidget {
  final Profile currentProfile;
  final String authEmail;
  final bool isPro; // <--- NEU
  final VoidCallback onUnlockPressed; // <--- NEU (für den Klick auf "Freischalten")

  const PartnerConnectCard({
    super.key, 
    required this.currentProfile, 
    required this.authEmail,
    required this.isPro, // <--- NEU
    required this.onUnlockPressed, // <--- NEU
  });

  @override
  State<PartnerConnectCard> createState() => _PartnerConnectCardState();
}

class _PartnerConnectCardState extends State<PartnerConnectCard> {
  final _partnerService = PartnerService();
  final _myEmailCtrl = TextEditingController();
  final _partnerEmailCtrl = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _partnerStatus;
  RealtimeChannel? _partnerSubscription;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _myEmailCtrl.dispose();
    _partnerEmailCtrl.dispose();
    _partnerSubscription?.unsubscribe();
    super.dispose();
  }

  void _initData() {
    // FIX: Wir nehmen IMMER die echte Auth-Email aus dem Login.
    // Das korrigiert auch Fehler, falls vorher etwas Falsches in der DB gespeichert wurde.
    _myEmailCtrl.text = widget.authEmail; 
    
    // Partner Email laden wir aus der DB
    _partnerEmailCtrl.text = widget.currentProfile.partnerEmail ?? '';
    
    if (_partnerEmailCtrl.text.isNotEmpty) {
      _loadPartnerStatus();
    }
  }

  // Realtime Subscription starten
  void _subscribeToPartner(String partnerProfileId) {
    // Falls wir schon lauschen, abbrechen (Sicherheit)
    if (_partnerSubscription != null) return;

    debugPrint("Starte Realtime für Partner: $partnerProfileId");

    _partnerSubscription = Supabase.instance.client
        .channel('partner_mood_$partnerProfileId') // Einzigartiger Kanalname
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Bei INSERT, UPDATE oder DELETE
          schema: 'public',
          table: 'mood_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, 
            column: 'profile_id', 
            value: partnerProfileId
          ),
          callback: (payload) {
            debugPrint("Realtime Event empfangen! Lade neu...");
            // Wenn was passiert, laden wir die Ansicht neu
            _loadPartnerStatus();
          },
        )
        .subscribe();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await _partnerService.updatePartnerSettings(
        widget.currentProfile.id,
        _myEmailCtrl.text.trim(), // Speichert jetzt die korrekte Auth-Email in die DB
        _partnerEmailCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gespeichert! Wir suchen den Partner...')),
        );
        _loadPartnerStatus();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPartnerStatus() async {
    if (!widget.isPro) return; // Free User brauchen keinen Sync

    // Nur Ladeanzeige zeigen, wenn wir noch GAR KEINE Daten haben (sonst flackert es bei Realtime)
    if (_partnerStatus == null) {
      setState(() => _isLoading = true);
    }

    final data = await _partnerService.getPartnerStatus(
      widget.authEmail, 
      widget.currentProfile.partnerEmail ?? ''
    );

    if (mounted) {
      setState(() {
        _partnerStatus = data;
        _isLoading = false;
      });

      // NEU: Wenn wir erfolgreich Daten haben, starten wir die Subscription
      if (data != null && data['partner_profile_id'] != null) {
        _subscribeToPartner(data['partner_profile_id'].toString());
      }
    }
  }

  // --- FÜGE DIESE FUNKTION HINZU (OPTIONAL), UM SICH ZU TRENNEN ---
  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!; // Zugriff auf Übersetzungen

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4, 
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))
                ),
                const SizedBox(height: 25),
                const Icon(Icons.link_off, size: 40, color: Colors.redAccent),
                const SizedBox(height: 15),
                
                // TEXT AUS L10N
                Text(
                  l10n.partnerDisconnectTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // TEXT MIT PLATZHALTER (E-Mail)
                Text(
                  l10n.partnerDisconnectMessage(_partnerEmailCtrl.text),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(l10n.partnerDisconnectConfirm, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.partnerDisconnectCancel, style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _partnerService.updatePartnerSettings(
        widget.currentProfile.id,
        _myEmailCtrl.text,
        "", 
      );
      
      if (mounted) {
         setState(() {
           _partnerEmailCtrl.clear();
           _partnerStatus = null;
         });
         // SNACKBAR TEXT AUS L10N
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.partnerDisconnectSuccess)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // --- 1. PRO-CHECK ---
    if (!widget.isPro) {
      return _buildLockedCard(l10n);
    }

    // --- 2. NORMALE LOGIK (wie bisher) ---
    final bool isConnected = _partnerStatus != null;
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pinkAccent),
                const SizedBox(width: 10),
                Text(l10n.partnerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(l10n.partnerDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 20),

            if (isConnected) ...[
              // ... Dein bestehender Code für "Verbunden" ...
              // (Kopiere hier deinen bestehenden Block rein: Container grün, _buildPartnerStatus etc.)
               Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.partnerLabelConnected, style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(_partnerEmailCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: l10n.partnerDisconnectTooltip,
                      child: IconButton(icon: const Icon(Icons.link_off, color: Colors.grey), onPressed: _disconnect),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPartnerStatus(l10n),

            ] else ...[
              // ... Dein bestehender Code für "Formular" ...
              TextField(
                controller: _myEmailCtrl,
                readOnly: true, 
                decoration: InputDecoration(labelText: l10n.partnerLabelMyEmail, prefixIcon: Icon(Icons.person, color: Colors.grey), filled: true, fillColor: Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _partnerEmailCtrl,
                decoration: InputDecoration(labelText: l10n.partnerEmailLabel, hintText: l10n.partnerHintEmail, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              if (_isLoading) const Center(child: CircularProgressIndicator())
              else SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.partnerConnectBtn))),
               if (_partnerEmailCtrl.text.isNotEmpty && !_isLoading && !isConnected) ...[ const SizedBox(height: 15), Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text(l10n.partnerWait, style: const TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic))]))]
            ],
          ],
        ),
      ),
    );
  }

  // --- NEUES WIDGET: DIE GESPERRTE KARTE ---
  Widget _buildLockedCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onUnlockPressed,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            // Der Inhalt (leicht ausgeblendet/unscharf suggeriert)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.favorite, color: Colors.pinkAccent), const SizedBox(width: 10), Text(l10n.partnerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 10),
                  Text(l10n.partnerDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),
                  // Fake UI für den Look
                  Container(height: 50, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 10),
                  Container(height: 50, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12))),
                ],
              ),
            ),
            
            // Der "Lock" Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6), // Milchglas-Effekt
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.pinkAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.lock_person, size: 40, color: Colors.pinkAccent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.partnerTitleLocked, // Oder l10n.partnerTitle
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        l10n.partnerDescLocked, // Könnte auch ins l10n
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onUnlockPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.becomePro),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getPartnerAdvice(double score, List<dynamic>? tagsRaw, double? sleep, AppLocalizations l10n) {
    final List<String> tags = tagsRaw?.map((e) => e.toString()).toList() ?? [];
    
    // 1. Spezifische Tags (Vergleich sprachunabhängig oder auf bekannte Keys)
    // Wir prüfen auf deutsche UND englische Keywords, falls die DB gemischte Daten hat
    if (tags.any((t) => ['Krank', 'Sick', 'Kopfschmerzen', 'Migräne'].contains(t))) {
      return l10n.adviceSick;
    }
    
    if (tags.any((t) => [l10n.tagPMS, l10n.tagPeriodHeavy, l10n.tagCramps, 'Regelschmerzen'].contains(t))) {
      return l10n.adviceCycle;
    }

    if (tags.contains(l10n.tagStress) || tags.contains('Stress')) {
      return l10n.adviceStress;
    }

    // 2. Schlaf-Check
    if (sleep != null && sleep < 5.0) {
      return l10n.adviceSleep;
    }

    // 3. Score-Basierte Tipps
    if (score < 4.0) {
      return l10n.adviceSad;
    }
    if (score > 8.5) {
      return l10n.adviceHappy;
    }

    return null;
  }

  Widget _buildPartnerStatus(AppLocalizations l10n) {
    final name = _partnerStatus!['name'] as String? ?? 'Partner';
    final score = _partnerStatus!['score'] as double?;
    
    // Daten holen (sicherstellen, dass wir nicht abstürzen, falls keys fehlen)
    final tags = _partnerStatus!['tags'] as List<dynamic>?;
    final sleep = _partnerStatus!['sleep'] as double?;

    if (score == null) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            const Icon(Icons.link, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.partnerConnected(name), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      );
    }

    // Basis-Farben und Icons wie bisher
    Color color = Colors.green;
    String msg = l10n.partnerStatus(score.toStringAsFixed(1));
    IconData icon = Icons.sentiment_satisfied_alt;

    if (score < 4.0) {
      color = Colors.redAccent;
      msg = l10n.partnerNeedsLove(name);
      icon = Icons.volunteer_activism;
    } else if (score < 7.0) {
      color = Colors.orange;
      icon = Icons.sentiment_neutral;
    }

    // --- NEU: TIPP GENERIEREN ---
    final String? advice = _getPartnerAdvice(score, tags, sleep, l10n);

    return Column(
      children: [
        // 1. Die normale Status-Box
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Text(msg, style: TextStyle(color: color.withValues(alpha: 1.0), fontWeight: FontWeight.bold)),
              ),
              // Kleiner Indikator für Schlaf, falls vorhanden
              if (sleep != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.bed, size: 16, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text("${sleep.toStringAsFixed(0)}h", style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)))
              ]
            ],
          ),
        ),

        // 2. Die neue "Smart Advice" Box (nur wenn Advice existiert)
        if (advice != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity, // Volle Breite
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    advice,
                    style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'; // <--- DIESE ZEILE HAT GEFEHLT!
import '../services/partner_service.dart';
import '../models/profile.dart';
import '../l10n/generated/app_localizations.dart';

class PartnerConnectCard extends StatefulWidget {
  final Profile currentProfile;
  final String authEmail;
  final bool isPro;
  final VoidCallback onUnlockPressed;

  const PartnerConnectCard({
    super.key, 
    required this.currentProfile, 
    required this.authEmail,
    required this.isPro,
    required this.onUnlockPressed,
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
    _myEmailCtrl.text = widget.authEmail; 
    
    // Partner Email laden wir aus der DB
    _partnerEmailCtrl.text = widget.currentProfile.partnerEmail ?? '';
    
    if (_partnerEmailCtrl.text.isNotEmpty) {
      _loadPartnerStatus();
    }
  }

  // Realtime Subscription starten
  void _subscribeToPartner(String partnerProfileId) {
    // Falls noch eine alte Verbindung besteht: Weg damit!
    if (_partnerSubscription != null) {
      debugPrint("Beende alte Subscription...");
      _partnerSubscription!.unsubscribe();
      _partnerSubscription = null;
    }

    debugPrint("Starte Realtime für Partner: $partnerProfileId"); // Jetzt muss diese Meldung kommen!

    _partnerSubscription = Supabase.instance.client
        .channel('partner_mood_$partnerProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mood_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, 
            column: 'profile_id', 
            value: partnerProfileId
          ),
          callback: (payload) {
            debugPrint("Realtime Event empfangen! Lade neu...");
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
        _myEmailCtrl.text.trim(), 
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
    // CHECK 1: Sind wir Pro?
    debugPrint("DEBUG: Starte _loadPartnerStatus. Pro? ${widget.isPro}");
    if (!widget.isPro) return; 

    if (_partnerStatus == null) {
      setState(() => _isLoading = true);
    }

    final data = await _partnerService.getPartnerStatus(
      widget.authEmail, 
      widget.currentProfile.partnerEmail ?? ''
    );

    // CHECK 2: Was kam zurück?
    debugPrint("DEBUG: Daten vom Service erhalten: $data");

    if (mounted) {
      setState(() {
        _partnerStatus = data;
        _isLoading = false;
      });

      // CHECK 3: Klappt die Bedingung?
      if (data != null && data['partner_profile_id'] != null) {
        debugPrint("DEBUG: Bedingung erfüllt! Rufe _subscribeToPartner auf...");
        _subscribeToPartner(data['partner_profile_id'].toString());
      } else {
        debugPrint("DEBUG: Bedingung NICHT erfüllt. Data null? ${data == null}. ID da? ${data?['partner_profile_id']}");
      }
    }
  }

  // --- TRENNEN ---
  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!;

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
                
                Text(
                  l10n.partnerDisconnectTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
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
      // 1. In der DB löschen
      await _partnerService.updatePartnerSettings(
        widget.currentProfile.id,
        _myEmailCtrl.text,
        "", 
      );
      
      // 2. WICHTIG: Realtime Abo beenden & Variable leeren!
      _partnerSubscription?.unsubscribe();  // <--- NEU
      _partnerSubscription = null;          // <--- NEU

      if (mounted) {
         setState(() {
           _partnerEmailCtrl.clear();
           _partnerStatus = null;
         });
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

    // --- 2. NORMALE LOGIK ---
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
              // VERBUNDEN STATUS
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
                          Text(l10n.partnerLabelConnected, style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
              // FORMULAR (Noch nicht verbunden)
              TextField(
                controller: _myEmailCtrl,
                readOnly: true, 
                decoration: InputDecoration(
                  labelText: l10n.partnerLabelMyEmail, 
                  prefixIcon: const Icon(Icons.person, color: Colors.grey), 
                  filled: true, 
                  fillColor: const Color(0xFFF5F7FA), 
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none), 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                ),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _partnerEmailCtrl,
                decoration: InputDecoration(
                  labelText: l10n.partnerEmailLabel, 
                  hintText: l10n.partnerHintEmail, 
                  prefixIcon: const Icon(Icons.search), 
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              
              if (_isLoading) const Center(child: CircularProgressIndicator())
              else SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.partnerConnectBtn))),
              
              if (_partnerEmailCtrl.text.isNotEmpty && !_isLoading && !isConnected) ...[ 
                const SizedBox(height: 15), 
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)), 
                  const SizedBox(width: 8), 
                  Text(l10n.partnerWait, style: const TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic))
                ]))
              ]
            ],
          ],
        ),
      ),
    );
  }

  // --- GESPERRTE KARTE (FREE) ---
  Widget _buildLockedCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onUnlockPressed,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.favorite, color: Colors.pinkAccent), const SizedBox(width: 10), Text(l10n.partnerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 10),
                  Text(l10n.partnerDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),
                  Container(height: 50, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 10),
                  Container(height: 50, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12))),
                ],
              ),
            ),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
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
                      l10n.partnerTitleLocked,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        l10n.partnerDescLocked,
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

  // --- ADVICE LOGIK ---
  String? _getPartnerAdvice(double score, List<dynamic>? tagsRaw, double? sleep, AppLocalizations l10n) {
    final List<String> tags = tagsRaw?.map((e) => e.toString()).toList() ?? [];
    
    if (tags.any((t) => ['Krank', 'Sick', 'Kopfschmerzen', 'Migräne'].contains(t))) {
      return l10n.adviceSick;
    }
    
    if (tags.any((t) => [l10n.tagPMS, l10n.tagPeriodHeavy, l10n.tagCramps, 'Regelschmerzen'].contains(t))) {
      return l10n.adviceCycle;
    }

    if (tags.contains(l10n.tagStress) || tags.contains('Stress')) {
      return l10n.adviceStress;
    }

    if (sleep != null && sleep < 5.0) {
      return l10n.adviceSleep;
    }

    if (score < 4.0) {
      return l10n.adviceSad;
    }
    if (score > 8.5) {
      return l10n.adviceHappy;
    }

    return null;
  }

  // --- PARTNER STATUS UI ---
  Widget _buildPartnerStatus(AppLocalizations l10n) {
    final name = _partnerStatus!['name'] as String? ?? 'Partner';
    final score = _partnerStatus!['score'] as double?;
    
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

    final String? advice = _getPartnerAdvice(score, tags, sleep, l10n);

    return Column(
      children: [
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
              if (sleep != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.bed, size: 16, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text("${sleep.toStringAsFixed(0)}h", style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)))
              ]
            ],
          ),
        ),

        if (advice != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
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
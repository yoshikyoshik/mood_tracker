import 'package:flutter/material.dart';
import 'dart:async';
import '../services/partner_service.dart';
import '../models/profile.dart';
import '../l10n/generated/app_localizations.dart';

class PartnerConnectCard extends StatefulWidget {
  final Profile currentProfile;
  final String authEmail;

  const PartnerConnectCard({
    super.key, 
    required this.currentProfile, 
    required this.authEmail
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _myEmailCtrl.dispose();
    _partnerEmailCtrl.dispose();
    _refreshTimer?.cancel();
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
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadPartnerStatus());
    }
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
    if (_myEmailCtrl.text.isEmpty || _partnerEmailCtrl.text.isEmpty) return;

    final status = await _partnerService.getPartnerStatus(
      _myEmailCtrl.text.trim(), 
      _partnerEmailCtrl.text.trim()
    );
    
    if (mounted) setState(() => _partnerStatus = status);
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
    // Wir prüfen: Gibt es Status-Daten? ODER steht eine E-Mail im Feld UND wir laden nicht mehr?
    // Der sicherste Indikator für "Verbunden" ist, wenn _partnerStatus Daten liefert (z.B. den Score).
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

            // --- HIER IST DER FIX: WEICHE ZWISCHEN "FORMULAR" UND "VERBUNDEN" ---
            
            if (isConnected) ...[
              // FALL A: BEREITS VERBUNDEN
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
                          const Text("Verbunden mit:", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(
                            _partnerEmailCtrl.text, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                        ],
                      ),
                    ),
                    // --- HIER IST DER NEUE BUTTON ---
                    // ... in der grünen Box ...
                    Tooltip(
                      message: l10n.partnerDisconnectTooltip, // HIER GEÄNDERT
                      child: IconButton(
                        icon: const Icon(Icons.link_off, color: Colors.grey),
                        onPressed: _disconnect, 
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // STATUS ANZEIGE (EXISTIERENDER CODE)
              _buildPartnerStatus(l10n),
            
            ] else ...[
              // FALL B: NICHT VERBUNDEN (FORMULAR ANZEIGEN)
              TextField(
                controller: _myEmailCtrl,
                readOnly: true, 
                decoration: const InputDecoration(
                  labelText: "Deine E-Mail (Automatisch)",
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xFFF5F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _partnerEmailCtrl,
                decoration: InputDecoration(
                  labelText: l10n.partnerEmailLabel,
                  hintText: "z.B. partner@example.com",
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.partnerConnectBtn), // Hier steht "Verbinden"
                  ),
                ),
                
               // WARTEMELDUNG (Falls gespeichert, aber noch keine Antwort vom Partner)
               if (_partnerEmailCtrl.text.isNotEmpty && !_isLoading && !isConnected) ...[
                 const SizedBox(height: 15),
                 Center(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                       const SizedBox(width: 8),
                       Text(l10n.partnerWait, style: const TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
                     ],
                   )
                 ),
               ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerStatus(AppLocalizations l10n) {
    final name = _partnerStatus!['name'] as String? ?? 'Partner';
    final score = _partnerStatus!['score'] as double?;
    
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

    return Container(
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
        ],
      ),
    );
  }
}
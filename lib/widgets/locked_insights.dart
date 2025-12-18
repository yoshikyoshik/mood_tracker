// lib/widgets/locked_insights.dart
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

class LockedInsights extends StatelessWidget {
  // Wir brauchen eine Funktion, die ausgeführt wird, wenn der Button gedrückt wird
  final VoidCallback onUnlockPressed;

  const LockedInsights({
    super.key,
    required this.onUnlockPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.indigo),
          const SizedBox(height: 16),
          Text(
            l10n.lockedInsightsTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lockedInsightsDesc,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onUnlockPressed, // Hier rufen wir die übergebene Funktion auf
            icon: const Icon(Icons.diamond, size: 18),
            label: Text(l10n.btnUnlock),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
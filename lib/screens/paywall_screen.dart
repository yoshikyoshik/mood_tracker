import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';
//import '../theme/app_theme.dart'; // Falls du Zugriff auf deine Farben brauchst

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  // Statische Methode, um die Paywall einfach aufzurufen
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Erlaubt Vollbild
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallScreen(),
    );
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage; // Welches Paket hat der User angeklickt?

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Wir holen das "current" (default) Offering
    final offerings = await PurchaseService.fetchOfferings();
    
    if (offerings != null && offerings.current != null) {
      setState(() {
        _offerings = offerings;
        // Wir versuchen, das Jahresabo vorauszusuchen (Best Value), sonst das Monatsabo
        _selectedPackage = offerings.current!.annual ?? offerings.current!.monthly;
        _isLoading = false;
      });
    } else {
      // Fehler beim Laden oder keine Angebote im Dashboard konfiguriert
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Keine Angebote gefunden. Bitte später versuchen.")));
        Navigator.pop(context); // Paywall schließen
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    bool success = await PurchaseService.purchasePackage(_selectedPackage!);

    if (mounted) {
      setState(() => _isPurchasing = false);
      if (success) {
        // Erfolgreich! Paywall schließen.
        // Hier könntest du auch zu einem "Danke"-Screen navigieren.
        Navigator.pop(context, true); // true zurückgeben, damit der Aufrufer weiß, dass es geklappt hat
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wir bauen einen Container mit abgerundeten Ecken oben, der fast den ganzen Screen füllt
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPaywallContent(context),
    );
  }

  Widget _buildPaywallContent(BuildContext context) {
    final currentOffering = _offerings?.current;
    if (currentOffering == null) return const SizedBox.shrink();

    // Wir suchen unsere spezifischen Pakete anhand der RevenueCat-Identifier
    final monthlyPackage = currentOffering.monthly;
    final annualPackage = currentOffering.annual;

    return Column(
      children: [
        // --- Header ---
        _buildHeader(context),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Vorteile ---
                _buildBenefitsList(context),
                const SizedBox(height: 32),

                // --- Abo Auswahl ---
                Text("Wähle deinen Plan", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                
                if (annualPackage != null) ...[
                   _buildPackageCard(context, annualPackage, isBestValue: true),
                   const SizedBox(height: 12),
                ],
                if (monthlyPackage != null)
                   _buildPackageCard(context, monthlyPackage),

                const SizedBox(height: 32),

                // --- Kaufen Button ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton( // Moderner Button-Stil (Material 3)
                    onPressed: _isPurchasing ? null : _handlePurchase,
                    child: _isPurchasing
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Jetzt upgraden", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                 const SizedBox(height: 16),
                // --- Footer Links (Wichtig für Google/Apple!) ---
                _buildLegalFooter(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... Helper Widgets für die UI-Bausteine folgen unten ...
  
  Widget _buildHeader(BuildContext context) {
     // Hier könnte man ein schönes Bild oder einen Farbverlauf einfügen
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
             color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Center(
            child: Icon(Icons.diamond_outlined, size: 60, color: Theme.of(context).primaryColor),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        )
      ],
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("Unlock Premium", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
         const SizedBox(height: 16),
         _buildBenefitRow(context, "Unbegrenzte Mood-Einträge"),
         _buildBenefitRow(context, "Detaillierte Statistiken & Charts"),
         _buildBenefitRow(context, "Werbefreie Erfahrung"),
         // Füge hier deine echten Vorteile hinzu
      ],
    );
  }

  Widget _buildBenefitRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package, {bool isBestValue = false}) {
    final isSelected = _selectedPackage == package;
    final product = package.storeProduct;

    // Titel basierend auf dem Paket-Typ bestimmen
    String title = "Abo";
    if (package.packageType == PackageType.monthly) title = "Monatlich";
    if (package.packageType == PackageType.annual) title = "Jährlich";

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Wenn ausgewählt, farbiger Rahmen, sonst grauer Rahmen
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    // Hier könnte man bei Jährlich noch "rechnerisch X pro Monat" anzeigen
                    if (isBestValue)
                       Text("Die beste Wahl", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                  ],
                ),
                // product.priceString liefert den fertigen Preis (z.B. "29,99 €")
                Text(product.priceString, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // "Best Value" Badge oben rechts
          if (isBestValue)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Text("Spare 40%", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLegalFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: () { /* TODO: URL öffnen */ }, child: const Text("AGB", style: TextStyle(fontSize: 12, color: Colors.grey))),
        const Text("|", style: TextStyle(color: Colors.grey)),
        TextButton(onPressed: () { /* TODO: URL öffnen */ }, child: const Text("Datenschutz", style: TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }
}
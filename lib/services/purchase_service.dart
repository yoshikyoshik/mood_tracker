import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Für PlatformException
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  
  static bool _isInitialized = false;

  /// Initialisiert RevenueCat mit aggressivem Logging
  static Future<void> init({required String googleApiKey}) async {
    if (kIsWeb) return;

    debugPrint("🔧 RC INIT: Starte Initialisierung...");

    // 1. LogLevel auf VERBOSE (Maximal) für Debugging
    await Purchases.setLogLevel(LogLevel.verbose);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      debugPrint("🔧 RC INIT: Erkenne Android. Nutze Key: $googleApiKey");
      configuration = PurchasesConfiguration(googleApiKey);
    } 

    if (configuration != null) {
      try {
        await Purchases.configure(configuration);
        _isInitialized = await Purchases.isConfigured;
        debugPrint("✅ RC INIT: Erfolgreich? $_isInitialized");
        
        // Test: Anonyme ID abrufen, um zu sehen, ob das SDK lebt
        var appUserID = await Purchases.appUserID;
        debugPrint("ℹ️ RC INIT: Vorläufige AppUserID: $appUserID");

      } catch (e) {
        debugPrint("❌ CRITICAL RC ERROR: Konfiguration fehlgeschlagen! $e");
      }
    }
  }

  /// Sicherer Login mit Fehler-Ausgabe
  static Future<void> login(String uuid) async {
    if (kIsWeb) return;
    
    debugPrint("🔑 RC LOGIN: Versuche Login für UUID: $uuid");
    
    try {
      if (!_isInitialized) {
         bool status = await Purchases.isConfigured;
         if (!status) {
           debugPrint("❌ RC LOGIN ABGEBROCHEN: SDK ist nicht konfiguriert!");
           return;
         }
      }

      LogInResult result = await Purchases.logIn(uuid);
      CustomerInfo customerInfo = result.customerInfo;

      debugPrint("✅ RC LOGIN ERFOLGREICH! User ist drin.");
      debugPrint("ℹ️ Entitlements: ${customerInfo.entitlements.all}");
      
    } on PlatformException catch (e) {
      debugPrint("❌ RC LOGIN FEHLER (Platform): Code=${e.code}, Msg=${e.message}, Details=${e.details}");
    } catch (e) {
      debugPrint("❌ RC LOGIN FEHLER (General): $e");
    }
  }

  /// Prüft, ob der User Premium hat
  static Future<bool> checkPremiumStatus() async {
    if (kIsWeb) return false;

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      debugPrint("🔍 CHECK STATUS für User: ${customerInfo.originalAppUserId}");
      
      if (customerInfo.entitlements.all["pro_access"]?.isActive == true) {
        debugPrint("👑 User ist PREMIUM (pro_access active)");
        return true;
      } else {
        debugPrint("mw User ist FREE. Aktive Entitlements: ${customerInfo.entitlements.active.keys}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Fehler beim Premium-Check: $e");
      return false;
    }
  }

  static Future<Offerings?> fetchOfferings() async {
    if (kIsWeb) return null;
    try {
      Offerings offerings = await Purchases.getOfferings();
      debugPrint("📦 Angebote geladen: ${offerings.current?.availablePackages.length} Pakete gefunden.");
      return offerings;
    } catch (e) {
      debugPrint("❌ Fehler beim Laden der Angebote: $e");
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    if (kIsWeb) return false;
    try {
      debugPrint("🛒 Starte Kauf für: ${package.storeProduct.identifier}");
      
      // ignore: deprecated_member_use
      PurchaseResult result = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo = result.customerInfo;
      
      if (customerInfo.entitlements.all["pro_access"]?.isActive == true) {
         debugPrint("✅ Kauf erfolgreich! Premium freigeschaltet.");
         return true;
      } else {
         debugPrint("⚠️ Kauf abgeschlossen, aber 'pro_access' ist nicht aktiv.");
         return false;
      }
    } catch (e) {
      debugPrint("Information: Kauf abgebrochen oder fehlgeschlagen ($e)");
      return false;
    }
  }

  /// Wrapper für Restore, damit main.dart kein import benötigt
  static Future<void> restore() async {
    if (kIsWeb) return;
    try {
      debugPrint("🔄 SERVICE: Starte Restore...");
      CustomerInfo info = await Purchases.restorePurchases();
      debugPrint("✅ SERVICE: Restore fertig. Aktive Rechte: ${info.entitlements.active.keys}");
    } catch (e) {
      debugPrint("❌ SERVICE: Restore fehlgeschlagen: $e");
    }
  }
}
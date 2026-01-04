import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

// Dein Service Import
import 'services/purchase_service.dart'; 

import 'screens/auth_gate.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/mood_tracker_screen.dart';
import 'theme/app_theme.dart';

// --- KONFIGURATION ---
const _revenueCatGoogleKey = 'goog_nPETWLBwVYDeuhfzHMkprFFdJUh'; 

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Supabase Init
  await Supabase.initialize(
    url: 'https://kbskcoyhqsnzoasntqlk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2tjb3locXNuem9hc250cWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NDc5MTEsImV4cCI6MjA4MDQyMzkxMX0.V8iEnHCb7PF3vFhY5ULUL5rbE0M_U73GYkV267BHKK0',
  );

  // 2. Datum-Formate
  try {
      await initializeDateFormatting('de_DE', null);
  } catch (e) {
      debugPrint("Fehler beim Laden der Datumsformate: $e");
  }

  // 3. Mobile Services
  if (!kIsWeb) {
    // OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("093f8b73-b8c8-4bb5-acab-796e58d22e4b");
    OneSignal.Notifications.requestPermission(true);

    // RevenueCat Init & Restore
    debugPrint("🚀 MAIN: Starte PurchaseService Init...");
    try {
      // Init
      await PurchaseService.init(googleApiKey: _revenueCatGoogleKey);
      
      // Zwangswiederherstellung der Käufe beim Start
      await PurchaseService.restore();

      debugPrint("🚀 MAIN: PurchaseService Init & Restore abgeschlossen.");
    } catch (e) {
      debugPrint("❌ MAIN FATAL: PurchaseService Init gecrasht: $e");
    }
  }

  runApp(const MyApp());

  Future.delayed(const Duration(milliseconds: 500), () {
    debugPrint("🚀 Splash Screen entfernt.");
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuvioSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
        Locale('ru'),
        Locale('es'),
        Locale('zh'),
      ],
      home: Supabase.instance.client.auth.currentUser == null 
          ? const AuthGate() 
          : const MoodTrackerScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wichtig für Speicher
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

import 'screens/auth_gate.dart';

// Import für die Lokalisierung (Plan B Pfad)
import 'l10n/generated/app_localizations.dart';

import 'screens/mood_tracker_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Splash Screen aktivieren
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // --- HIER DEINE SUPABASE INIT DATEN EINFÜGEN ---

  await Supabase.initialize(
    // URL und Key hier einfügen:
    url: 'https://kbskcoyhqsnzoasntqlk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2tjb3locXNuem9hc250cWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NDc5MTEsImV4cCI6MjA4MDQyMzkxMX0.V8iEnHCb7PF3vFhY5ULUL5rbE0M_U73GYkV267BHKK0',
  );
// 2. Datum-Formate laden (OHNE await, damit es nicht blockiert, falls Netzwerk langsam ist)
  // Oder wir setzen es in ein try-catch
  try {
      await initializeDateFormatting('de_DE', null);
  } catch (e) {
      debugPrint("Fehler beim Laden der Datumsformate: $e");
  }

  // FIX: OneSignal nur auf Mobile starten, nicht im Web!
  if (!kIsWeb) {
    // --- ONESIGNAL INIT ---
    // Ersetze das hier mit DEINER OneSignal App ID aus Schritt 2
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("093f8b73-b8c8-4bb5-acab-796e58d22e4b");
    
    // Um Erlaubnis fragen (wichtig für iOS & Android 13+)
    OneSignal.Notifications.requestPermission(true);
    // ---------------------
  }

  runApp(const MyApp());

  // 3. BRUTALES SICHERHEITSNETZ
  // Wir entfernen den Splash Screen nach 1 Sekunde, egal was passiert.
  // Damit wir sehen, ob die App weiß bleibt oder einen Fehler wirft.
  Future.delayed(const Duration(milliseconds: 500), () {
    debugPrint("🚀 FORCED REMOVE: Splash Screen entfernt.");
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Statische Methode, damit wir von überall die Sprache ändern können
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
      
      // Hier wird die Sprache gesetzt (oder null für System-Standard)
      locale: _locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'), // Deutsch
        Locale('en'), // Englisch
        Locale('ru'), // Russisch
        Locale('es'), // Spanisch
        Locale('zh'), // Chinesisch
      ],
      // Wir prüfen direkt beim Start: Ist jemand da?
home: Supabase.instance.client.auth.currentUser == null 
    ? const AuthGate() // Oder wie dein Login-Screen heißt
    : const MoodTrackerScreen(),
    );
  }
}
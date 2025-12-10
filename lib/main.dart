import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Wir importieren nur noch den "AuthGate" Screen, 
// alles andere ist hinter den Kulissen versteckt.
import 'screens/auth_gate.dart';

Future<void> main() async {
  // Bindung initialisieren, damit wir den Splash kontrollieren können
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Splash Screen "festhalten" bis wir sagen: "Weg damit!"
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    // URL und Key hier einfügen:
    url: 'https://kbskcoyhqsnzoasntqlk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2tjb3locXNuem9hc250cWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NDc5MTEsImV4cCI6MjA4MDQyMzkxMX0.V8iEnHCb7PF3vFhY5ULUL5rbE0M_U73GYkV267BHKK0',
  );

  runApp(const MoodApp());

  // --- FIX: DAS SICHERHEITSNETZ ---
  // Wir entfernen den Splash-Screen nach 2 Sekunden automatisch.
  // Das stellt sicher, dass man auch den Login-Screen sieht, 
  // falls man nicht direkt auf den MoodTracker kommt.
  Future.delayed(const Duration(seconds: 2), () {
    debugPrint("⏰ Main Timeout: Splash Screen entfernt.");
    FlutterNativeSplash.remove();
  });

}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker',
      theme: AppTheme.lightTheme, 
      
      home: const AuthGate(),
    );
  }
}
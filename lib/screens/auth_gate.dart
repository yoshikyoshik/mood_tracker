import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mood_tracker_screen.dart';
import '../l10n/generated/app_localizations.dart'; // WICHTIG: Lokalisierung

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // Steuert, ob wir Login oder Registrierung anzeigen

  // --- LOGIC ---

  Future<void> _authenticate() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authError("Bitte alles ausfüllen"))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIN
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // AuthStateChange in main.dart oder Navigator übernimmt den Rest
        if (mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
          );
        }
      } else {
        // REGISTRIEREN
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authSuccessVerify), backgroundColor: Colors.green));
          setState(() => _isLogin = true); // Zurück zum Login wechseln
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authError(e.message)), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authError(e.toString())), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Farben aus den Screenshots
    final bgColor = const Color(0xFFFFF8E1); // Helles Beige/Gelb
    final inputFillColor = Colors.white;
    final buttonColor = const Color(0xFF222222); // Fast Schwarz

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON (Smiley)
              const Icon(
                Icons.sentiment_satisfied_alt_rounded, 
                size: 80, 
                color: Colors.amber,
              ),
              const SizedBox(height: 30),

              // TITEL (Willkommen / Neuen Account)
              Text(
                _isLogin ? l10n.authLoginTitle : l10n.authRegisterTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // E-MAIL FELD
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  labelText: l10n.authEmailLabel,
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              const SizedBox(height: 16),

              // PASSWORT FELD
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                  labelText: l10n.authPasswordLabel,
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              const SizedBox(height: 30),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isLogin ? l10n.authLoginButton : l10n.authRegisterButton,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // SWITCH TEXT (Registrieren / Hab schon Account)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    // Optional: Fehler clearen
                  });
                },
                child: Text(
                  _isLogin ? l10n.authNoAccount : l10n.authHaveAccount,
                  style: TextStyle(
                    color: Colors.black87.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
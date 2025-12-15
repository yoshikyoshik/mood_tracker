import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mood_tracker_screen.dart';
import '../l10n/generated/app_localizations.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLogin = true; 
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _authenticate() async {
    FocusScope.of(context).unfocus(); // Tastatur schließen

    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authError("Bitte alles ausfüllen")))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- LOGIN ---
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
          );
        }
      } else {
        // --- REGISTRIEREN ---
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.authSuccessVerify), 
              backgroundColor: Colors.green
            )
          );
          setState(() => _isLogin = true); 
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authError(e.message)), 
            backgroundColor: Colors.red
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authError(e.toString())), 
            backgroundColor: Colors.red
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PASSWORT RESET LOGIK (NEU) ---
  Future<void> _sendPasswordReset() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    // 1. Validierung: E-Mail muss da sein
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authEnterEmail),
          backgroundColor: Colors.orange
        )
      );
      return;
    }

    try {
      // 2. Supabase Reset anstoßen
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authResetSuccess),
            backgroundColor: Colors.green
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Design Konstanten
    final bgColor = const Color(0xFF3F51B5); 
    final cardColor = Colors.white;
    final primaryColor = const Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // --- LOGO BEREICH ---
                Container(
                  height: 100,
                  width: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/icon/logo.png', 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.spa_rounded, size: 50, color: Colors.white);
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                const Text(
                  "LuvioSphere",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Verbinden. Verstehen. Wachsen.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade100,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40), 

                // --- CARD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isLogin ? l10n.authLoginTitle : l10n.authRegisterTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // EMAIL
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                          labelText: l10n.authEmailLabel,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          labelText: l10n.authPasswordLabel,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                      
                      // --- NEU: PASSWORT VERGESSEN BUTTON ---
                      // Nur anzeigen, wenn wir im Login-Modus sind
                      if (_isLogin) 
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _sendPasswordReset,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              minimumSize: Size.zero, // Kompakt
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.authForgotPassword,
                              style: TextStyle(
                                color: primaryColor, 
                                fontSize: 13, 
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                      
                      SizedBox(height: _isLogin ? 24 : 30), // Abstand anpassen

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _isLogin ? l10n.authLoginButton : l10n.authRegisterButton,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // TOGGLE LOGIN/REGISTER
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            children: [
                              TextSpan(text: _isLogin ? "Noch kein Konto? " : "Bereits registriert? "),
                              TextSpan(
                                text: _isLogin ? "Hier registrieren" : "Anmelden",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Unsere Hauptfarben
  static const primaryColor = Color(0xFF2E2E2E); // Fast Schwarz (edel)
  static const accentColor = Color(0xFFFFD54F);  // Unser Amber
  static const backgroundColor = Color(0xFFF9F9F9); // Sanftes Weiß
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Farben
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        surface: backgroundColor,
        primary: primaryColor,
      ),

      // Schriftart (Global für die ganze App)
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: primaryColor,
        displayColor: primaryColor,
      ),

      // Design der Eingabefelder
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Keine Linie, nur Schatten (kommt via Card)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Design der Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Design der Cards (Listen-Elemente)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }
}
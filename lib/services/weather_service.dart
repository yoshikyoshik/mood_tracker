import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // Holt Position und dann Wetter-Daten
  static Future<double> getWeatherImpact() async {
    try {
      // 1. Dürfen wir den Standort nutzen?
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 0.0;
      }
      if (permission == LocationPermission.deniedForever) return 0.0;

      // 2. Wo sind wir?
      // FIX: Neue Syntax mit LocationSettings statt desiredAccuracy
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.low, // Low reicht für Wetter & spart Akku
        distanceFilter: 1000,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings
      );

      // 3. OpenMeteo API fragen (WMO Code für morgen)
      // daily=weather_code&forecast_days=2 (Heute + Morgen)
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=weather_code&timezone=auto&forecast_days=2');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Wir wollen das Wetter für MORGEN (Index 1)
        final weatherCode = data['daily']['weather_code'][1] as int;
        
        return _getImpactFromWmoCode(weatherCode);
      }
    } catch (e) {
      debugPrint("Wetter-Fehler: $e");
    }
    return 0.0; // Fallback: Kein Einfluss
  }

  // WMO Codes interpretieren
  // Quelle: https://open-meteo.com/en/docs
  static double _getImpactFromWmoCode(int code) {
    // 0 = Klarer Himmel
    // 1, 2, 3 = Bewölkt
    // 45, 48 = Nebel
    // 51-67 = Nieselregen / Regen
    // 71-77 = Schnee
    // 95-99 = Gewitter

    if (code == 0) return 0.6; // Sonne pur -> Super!
    if (code == 1) return 0.3; // Leicht bewölkt -> Gut
    if (code == 2) return 0.0; // Bewölkt -> Neutral
    if (code == 3) return -0.2; // Bedeckt -> Naja
    
    if (code >= 51 && code <= 67) return -0.5; // Regen -> Stimmung drückt
    if (code >= 71 && code <= 77) return -0.3; // Schnee -> Kalt/Nass
    if (code >= 95) return -0.6; // Gewitter -> Stressig

    return 0.0;
  }
}
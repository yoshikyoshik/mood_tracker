import 'package:flutter/material.dart';

class MoodUtils {
  static Color getBackgroundColor(double value) {
    if (value <= 5.0) {
      return Color.lerp(Colors.redAccent.withValues(alpha: 0.5), Colors.amber.withValues(alpha: 0.5), value / 5.0)!;
    } else {
      return Color.lerp(Colors.amber.withValues(alpha: 0.5), Colors.greenAccent.withValues(alpha: 0.5), (value - 5.0) / 5.0)!;
    }
  }

  static Map<String, String> getMoodData(double value) {
    if (value < 2.0) return {'emoji': '😫', 'label': 'Schrecklich'};
    if (value < 4.0) return {'emoji': '😟', 'label': 'Nicht gut'};
    if (value < 6.0) return {'emoji': '😐', 'label': 'Neutral'};
    if (value < 8.0) return {'emoji': '🙂', 'label': 'Gut'};
    return {'emoji': '🤩', 'label': 'Fantastisch'};
  }
}
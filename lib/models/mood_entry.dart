import 'dart:convert';

class MoodEntry {
  final String? id;
  final DateTime timestamp;
  final double score;
  final double? sleepRating;
  final Set<String> tags;
  final String? note;
  final String? profileId;

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.score,
    this.sleepRating,
    required this.tags,
    this.note,
    this.profileId,
  });

  // WICHTIG FÜR DAS SPEICHERN (Fix für Zeit-Bug beim Schreiben)
  Map<String, dynamic> toMap() {
    return {
      // ID senden wir meist nicht beim Insert, aber beim Update nützlich
      if (id != null) 'id': id,
      
      // FIX BUG #2 (Schreiben): Wir wandeln VOR dem Speichern explizit in UTC um.
      // So weiß die Datenbank exakt, welcher Zeitpunkt gemeint ist.
      'created_at': timestamp.toUtc().toIso8601String(),
      
      'score': score,
      'sleep_rating': sleepRating,
      'tags': tags.toList(),
      'note': note,
      'profile_id': profileId,
    };
  }

  // WICHTIG FÜR DAS LADEN (Fix für Zeit-Bug beim Lesen)
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id']?.toString(),
      
      // FIX BUG #2 (Lesen): Datenbank liefert UTC -> Wir wandeln in Lokale Zeit
      timestamp: DateTime.parse(map['created_at']).toLocal(),
      
      score: (map['score'] as num).toDouble(),
      sleepRating: map['sleep_rating'] != null ? (map['sleep_rating'] as num).toDouble() : null,
      tags: Set<String>.from(List<String>.from(map['tags'] ?? [])),
      note: map['note'],
      profileId: map['profile_id']?.toString(),
    );
  }

  // Optional, aber gut für Debugging
  String toJson() => json.encode(toMap());

  factory MoodEntry.fromJson(String source) => MoodEntry.fromMap(json.decode(source));
}
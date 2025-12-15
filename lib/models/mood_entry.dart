import 'dart:convert';

class MoodEntry {
  final String? id;
  final String? userId; // <--- NEU: Damit wir wissen, wem der Eintrag gehört
  final DateTime timestamp;
  final double score;
  final double? sleepRating;
  final Set<String> tags;
  final String? note;
  final String? profileId;

  MoodEntry({
    this.id,
    this.userId, // <--- Im Konstruktor hinzufügen
    required this.timestamp,
    required this.score,
    this.sleepRating,
    required this.tags,
    this.note,
    this.profileId,
  });

  // WICHTIG FÜR DAS SPEICHERN
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      // userId müssen wir beim Speichern meist nicht senden (macht Supabase automatisch),
      // aber es schadet nicht, es konsistent zu halten.
      if (userId != null) 'user_id': userId, 
      
      'created_at': timestamp.toUtc().toIso8601String(),
      'score': score,
      'sleep_rating': sleepRating,
      'tags': tags.toList(),
      'note': note,
      'profile_id': profileId,
    };
  }

  // WICHTIG FÜR DAS LADEN
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString(), // <--- NEU: Hier holen wir die Info aus der DB
      
      timestamp: DateTime.parse(map['created_at']).toLocal(),
      score: (map['score'] as num).toDouble(),
      sleepRating: map['sleep_rating'] != null ? (map['sleep_rating'] as num).toDouble() : null,
      tags: Set<String>.from(List<String>.from(map['tags'] ?? [])),
      note: map['note'],
      profileId: map['profile_id']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());
  factory MoodEntry.fromJson(String source) => MoodEntry.fromMap(json.decode(source));
}
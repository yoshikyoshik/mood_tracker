class MoodEntry {
  final String? id;
  final DateTime timestamp;
  final double score;
  final double? sleepRating;
  final Set<String> tags;
  final String? note;
  final String profileId;
  final String? userId; // <--- WICHTIG für den Service

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.score,
    this.sleepRating,
    required this.tags,
    this.note,
    required this.profileId,
    this.userId,
  });

  // Factory für DB -> App
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id']?.toString(),
      // HIER ÄNDERN: von 'timestamp' zu 'created_at'
      timestamp: DateTime.parse(map['created_at']), 
      score: (map['score'] as num).toDouble(),
      sleepRating: map['sleep_rating'] != null ? (map['sleep_rating'] as num).toDouble() : null,
      tags: map['tags'] != null ? Set<String>.from(List<String>.from(map['tags'])) : {},
      note: map['note'],
      profileId: map['profile_id'] ?? '',
      userId: map['user_id'],
    );
  }

  // Für App -> DB
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, 
      // HIER ÄNDERN: von 'timestamp' zu 'created_at'
      'created_at': timestamp.toIso8601String(),
      'score': score,
      'sleep_rating': sleepRating,
      'tags': tags.toList(),
      'note': note,
      'profile_id': profileId,
      'user_id': userId,
    };
  }

  // --- HIER IST DIE FEHLENDE METHODE ---
  // Erlaubt uns, eine Kopie des Objekts zu erstellen und dabei nur bestimmte Felder zu ändern
  MoodEntry copyWith({
    String? id,
    DateTime? timestamp,
    double? score,
    double? sleepRating,
    Set<String>? tags,
    String? note,
    String? profileId,
    String? userId,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      sleepRating: sleepRating ?? this.sleepRating,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      profileId: profileId ?? this.profileId,
      userId: userId ?? this.userId,
    );
  }
}
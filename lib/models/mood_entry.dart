class MoodEntry {
  final String? id;
  final DateTime timestamp;
  final double score;
  final double? sleepRating;
  final Set<String> tags;
  final String? note;
  final String profileId;
  final String? userId; // <--- WICHTIG für den Service
  // NEU: Nur für die UI, wird nicht in DB gespeichert
  final bool isLocallyModified;

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.score,
    this.sleepRating,
    required this.tags,
    this.note,
    required this.profileId,
    this.userId,
    this.isLocallyModified = false, // Default false
  });

  // Factory für DB -> App
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id']?.toString(),
      timestamp: DateTime.parse(map['created_at']), 
      score: (map['score'] as num).toDouble(),
      sleepRating: map['sleep_rating'] != null ? (map['sleep_rating'] as num).toDouble() : null,
      tags: map['tags'] != null ? Set<String>.from(List<String>.from(map['tags'])) : {},
      note: map['note'],
      profileId: map['profile_id'] ?? '',
      userId: map['user_id'],
      isLocallyModified: map['is_locally_modified'] ?? false, // Falls wir es aus JSON (Queue) laden
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, 
      'created_at': timestamp.toIso8601String(),
      'score': score,
      'sleep_rating': sleepRating,
      'tags': tags.toList(),
      'note': note,
      'profile_id': profileId,
      'user_id': userId,
      // isLocallyModified speichern wir NICHT in die echte DB, 
      // aber wir brauchen es für die lokale Queue (SharedPrefs)
    };
  }
  
  // Wichtig für das Speichern in die lokale Queue
  Map<String, dynamic> toLocalJson() {
    final m = toMap();
    m['is_locally_modified'] = true; // Wenn wir es lokal speichern, ist es immer modified
    return m;
  }

  MoodEntry copyWith({
    String? id,
    DateTime? timestamp,
    double? score,
    double? sleepRating,
    Set<String>? tags,
    String? note,
    String? profileId,
    String? userId,
    bool? isLocallyModified,
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
      isLocallyModified: isLocallyModified ?? this.isLocallyModified,
    );
  }
}
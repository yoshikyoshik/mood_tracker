class MoodEntry {
  final String? id;
  final DateTime timestamp;
  final double score;
  final double? sleepRating; // NEU: Kann null sein (für alte Einträge)
  final Set<String> tags;
  final String? profileId;

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.score,
    this.sleepRating, // NEU
    required this.tags,
    this.profileId,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'].toString(),
      timestamp: DateTime.parse(map['created_at']),
      score: (map['score'] as num).toDouble(),
      // NEU: Sicherstellen, dass wir null handhaben oder 0.0 als Fallback
      sleepRating: map['sleep_rating'] != null ? (map['sleep_rating'] as num).toDouble() : null,
      tags: Set<String>.from(map['tags'] ?? []),
      profileId: map['profile_id'],
    );
  }
}
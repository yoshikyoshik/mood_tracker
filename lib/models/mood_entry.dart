class MoodEntry {
  final String? id;
  final DateTime timestamp;
  final double score;
  final Set<String> tags;
  final String? profileId;

  MoodEntry({
    this.id,
    required this.timestamp,
    required this.score,
    required this.tags,
    this.profileId,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'].toString(),
      timestamp: DateTime.parse(map['created_at']),
      score: (map['score'] as num).toDouble(),
      tags: Set<String>.from(map['tags'] ?? []),
      profileId: map['profile_id'],
    );
  }
}
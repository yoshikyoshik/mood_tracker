class Profile {
  final String id;
  final String name;
  final bool isCycleTracking; // NEU
  final DateTime? lastPeriodDate; // NEU

  Profile({
    required this.id, 
    required this.name,
    this.isCycleTracking = false,
    this.lastPeriodDate,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unbekannt',
      isCycleTracking: map['is_cycle_tracking'] ?? false,
      // Datum parsen, falls vorhanden
      lastPeriodDate: map['last_period_date'] != null 
          ? DateTime.parse(map['last_period_date']) 
          : null,
    );
  }

factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      isCycleTracking: json['is_cycle_tracking'] ?? false,
      lastPeriodDate: json['last_period_date'] != null 
          ? DateTime.tryParse(json['last_period_date']) 
          : null,
    );
  }
}
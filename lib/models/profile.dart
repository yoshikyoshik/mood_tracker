class Profile {
  final String id;
  final String name;
  final bool isCycleTracking;
  final DateTime? lastPeriodDate;
  final String? email;        // NEU: Eigene Email
  final String? partnerEmail; // NEU: Email des Partners

  Profile({
    required this.id,
    required this.name,
    this.isCycleTracking = false,
    this.lastPeriodDate,
    this.email,
    this.partnerEmail,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unbenannt',
      isCycleTracking: json['is_cycle_tracking'] ?? false,
      lastPeriodDate: json['last_period_date'] != null 
          ? DateTime.parse(json['last_period_date']) 
          : null,
      email: json['email'],             // NEU
      partnerEmail: json['partner_email'], // NEU
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_cycle_tracking': isCycleTracking,
      if (lastPeriodDate != null) 'last_period_date': lastPeriodDate!.toIso8601String(),
      if (email != null) 'email': email,             // NEU
      if (partnerEmail != null) 'partner_email': partnerEmail, // NEU
    };
  }
}
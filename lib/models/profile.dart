class Profile {
  final String id;
  final String name;
  final bool isCycleTracking;
  final DateTime? lastPeriodDate;
  final String? email;        
  final String? partnerEmail; 
  final bool isMain; // Das Feld war schon definiert, aber ungenutzt

  Profile({
    required this.id,
    required this.name,
    this.isCycleTracking = false,
    this.lastPeriodDate,
    this.email,
    this.partnerEmail,
    this.isMain = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unbenannt',
      isCycleTracking: json['is_cycle_tracking'] ?? false,
      lastPeriodDate: json['last_period_date'] != null 
          ? DateTime.parse(json['last_period_date']) 
          : null,
      email: json['email'],             
      partnerEmail: json['partner_email'], 
      
      // --- HIER WAR DER FEHLENDE TEIL ---
      isMain: json['is_main'] ?? false, // Liest aus DB, Standard: false
      // ----------------------------------
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_cycle_tracking': isCycleTracking,
      if (lastPeriodDate != null) 'last_period_date': lastPeriodDate!.toIso8601String(),
      if (email != null) 'email': email,            
      if (partnerEmail != null) 'partner_email': partnerEmail,
      // Optional: Falls du Profile bearbeitest und den Status zurückspeichern musst
      'is_main': isMain, 
    };
  }
}
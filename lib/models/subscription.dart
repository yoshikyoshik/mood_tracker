class Subscription {
  final String userId;
  final String status; // 'active', 'trialing', 'canceled', etc.
  final String? planType;

  Subscription({
    required this.userId,
    required this.status,
    this.planType,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      userId: map['user_id'],
      status: map['status'] ?? 'inactive',
      planType: map['plan_type'],
    );
  }

  // Hilfs-Getter: Ist der User "Pro"?
  bool get isPro => status == 'active' || status == 'trialing';
}
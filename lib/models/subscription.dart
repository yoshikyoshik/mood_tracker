class Subscription {
  final String userId;
  final String status;
  final String? planType;
  final String? customerId; // <--- NEU

  Subscription({
    required this.userId,
    required this.status,
    this.planType,
    this.customerId, // <--- NEU
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      userId: map['user_id'],
      status: map['status'] ?? 'inactive',
      planType: map['plan_type'],
      customerId: map['stripe_customer_id'], // <--- NEU: Aus DB lesen
    );
  }

  bool get isPro => status == 'active' || status == 'trialing';
}
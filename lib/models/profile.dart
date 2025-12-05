class Profile {
  final String id;
  final String name;

  Profile({required this.id, required this.name});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
    );
  }
}
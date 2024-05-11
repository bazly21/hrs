class UserProfile {
  final String name;
  final String phoneNumber;
  final List<String> role;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.role
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      role: List<String>.from(map['role'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role
    };
  }
}
class UserProfile {
  final String name;
  final String phoneNumber;
  final List<String> role;
  final String? profilePictureURL;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.profilePictureURL
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      role: List<String>.from(map['role']),
      profilePictureURL: map['profilePictureURL']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePictureURL': profilePictureURL
    };
  }
}
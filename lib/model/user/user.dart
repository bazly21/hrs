class UserProfile {
  final String? name;
  final String? phoneNumber;
  final List<String>? role;
  final String? profilePictureURL;
  final double? overallRating;
  final int? ratingCount;

  UserProfile(
      {this.name,
      this.phoneNumber,
      this.role,
      this.profilePictureURL,
      this.overallRating,
      this.ratingCount});

  factory UserProfile.fromMap(Map<String, dynamic> userMap, String role) {
    return UserProfile(
        name: userMap["name"] ?? "N/A",
        overallRating: (userMap["ratingAverage"]?[role.toLowerCase()]
                    ?["overallRating"] as num?)
                ?.toDouble() ??
            0.0,
        ratingCount: userMap["ratingCount"]?[role.toLowerCase()] ?? 0,
        profilePictureURL: userMap["profilePictureURL"]);
  }

  Map<String, dynamic> registerProfileMap() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "role": role,
      "profilePictureURL": profilePictureURL
    };
  }
}

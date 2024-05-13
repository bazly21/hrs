class LandlordProfile {
  final String name;
  final int ratingCount;
  final double overallCommunicationRating;
  final double overallSupportRating;
  final double overallMaintenanceRating;
  final List<Map<String, dynamic>?> ratings;

  LandlordProfile({
    required this.name,
    required this.ratingCount,
    required this.overallCommunicationRating,
    required this.overallSupportRating,
    required this.overallMaintenanceRating,
    required this.ratings,
  });

  factory LandlordProfile.fromMap(Map<String, dynamic> userData, List<Map<String, dynamic>?> ratings) {
    return LandlordProfile(
      name: userData["name"] ?? "N/A",
      ratingCount: userData["ratingCount"]?["landlord"] ?? 0,
      overallSupportRating: userData["ratingAverage"]?["landlord"]?["supportRating"] ?? 0.0,
      overallCommunicationRating: userData["ratingAverage"]?["landlord"]?["communicationRating"] ?? 0.0,
      overallMaintenanceRating: userData["ratingAverage"]?["landlord"]?["maintenanceRating"] ?? 0.0,
      ratings: ratings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "ratingCount": ratingCount,
      "overallCommunicationRating": overallCommunicationRating,
      "overallSupportRating": overallSupportRating,
      "overallMaintenanceRating": overallMaintenanceRating,
      "ratings": ratings,
    };
  }
}
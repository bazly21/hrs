class UserRating {
  final String? name;
  final int? ratingCount;
  final double? overallCommunicationRating;
  final double? overallSupportRating;
  final double? overallMaintenanceRating;
  final double? overallPaymentRating;
  final List<Map<String, dynamic>>? ratings;

  UserRating({
    this.name,
    this.ratingCount,
    this.overallCommunicationRating,
    this.overallSupportRating,
    this.overallMaintenanceRating,
    this.overallPaymentRating,
    this.ratings,
  });

  factory UserRating.fromMap(Map<String, dynamic> userData, List<Map<String, dynamic>> ratings) {
    return UserRating(
      name: userData["name"] ?? "N/A",
      ratingCount: userData["ratingCount"] ?? 0,
      overallCommunicationRating: userData["ratingAverage"]?["communicationRating"] ?? 0.0,
      overallSupportRating: userData["ratingAverage"]?["supportRating"] ?? 0.0,
      overallMaintenanceRating: userData["ratingAverage"]?["maintenanceRating"] ?? 0.0,
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
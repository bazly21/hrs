import 'package:hrs/model/rating/rating_details.dart';

class TenantProfile {
  final String name;
  final int ratingCount;
  final double overallPaymentRating;
  final double overallCommunicationRating;
  final double overallMaintenanceRating;
  final List<RatingDetails> ratings;

  TenantProfile({
    required this.name,
    required this.ratingCount,
    required this.overallCommunicationRating,
    required this.overallPaymentRating,
    required this.overallMaintenanceRating,
    required this.ratings,
  });

  factory TenantProfile.fromMap(Map<String, dynamic> userData, List<RatingDetails> ratings) {
    return TenantProfile(
      name: userData["name"] ?? "N/A",
      ratingCount: userData["ratingCount"]?["tenant"] ?? 0,
      overallPaymentRating: userData["ratingAverage"]?["tenant"]?["paymentRating"] ?? 0.0,
      overallCommunicationRating: userData["ratingAverage"]?["tenant"]?["communicationRating"] ?? 0.0,
      overallMaintenanceRating: userData["ratingAverage"]?["tenant"]?["maintenanceRating"] ?? 0.0,
      ratings: ratings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "ratingCount": ratingCount,
      "overallCommunicationRating": overallCommunicationRating,
      "overallPaymentRating": overallPaymentRating,
      "overallMaintenanceRating": overallMaintenanceRating,
      "ratings": ratings,
    };
  }
}
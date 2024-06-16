import 'package:hrs/model/rating/rating_details.dart';

class LandlordProfile {
  final String name;
  final String? profilePictureUrl;
  final int ratingCount;
  final double overallCommunicationRating;
  final double overallSupportRating;
  final double overallMaintenanceRating;
  final List<RatingDetails> ratings;

  LandlordProfile({
    required this.name,
    this.profilePictureUrl,
    required this.ratingCount,
    required this.overallCommunicationRating,
    required this.overallSupportRating,
    required this.overallMaintenanceRating,
    required this.ratings,
  });

  factory LandlordProfile.fromMap(Map<String, dynamic> userData, List<RatingDetails> ratings) {
    return LandlordProfile(
      name: userData["name"] ?? "N/A",
      profilePictureUrl: userData["profilePictureURL"],
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
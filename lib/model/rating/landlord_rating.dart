import 'package:cloud_firestore/cloud_firestore.dart';

class LandlordRating {
  final String reviewerID;
  final double supportRating;
  final double maintenanceRating;
  final double communicationRating;
  final String comments;

  LandlordRating({
    required this.reviewerID,
    required this.supportRating,
    required this.maintenanceRating,
    required this.communicationRating,
    required this.comments,
  });

  // Convert a rating object into a map
  Map<String, dynamic> toMap() {
    return {
      'reviewerID': reviewerID,
      'ratedAs': "Landlord",
      'supportRating': supportRating,
      'maintenanceRating': maintenanceRating,
      'communicationRating': communicationRating,
      'comments': comments,
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }
}
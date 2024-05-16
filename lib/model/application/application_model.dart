import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String? applicantID;
  final String? occupation;
  final String? profileType;
  final int? numberOfPax;
  final String? nationality;
  final DateTime? moveInDate;
  final int? tenancyDuration;
  final double? overallRating;
  final int? totalReviews;
  final String status;

  Application({
    this.applicantID,
    this.occupation,
    this.profileType,
    this.numberOfPax,
    this.nationality,
    this.moveInDate,
    this.tenancyDuration,
    this.overallRating,
    this.totalReviews,
    this.status = "Pending",
  });

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    if (applicantID == null ||
        occupation == null ||
        profileType == null ||
        numberOfPax == null ||
        nationality == null ||
        moveInDate == null ||
        tenancyDuration == null) {
      throw Exception("All variables must have non-null values");
    }

    return {
      "applicantID": applicantID,
      "occupation": occupation,
      "profileType": profileType,
      "numberOfPax": numberOfPax,
      "nationality": nationality,
      "moveInDate": Timestamp.fromDate(moveInDate!),
      "tenancyDuration": tenancyDuration,
      "status": status,
      "submittedAt": FieldValue.serverTimestamp(),
    };
  }
}

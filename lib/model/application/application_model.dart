import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/property/property_details.dart';

class Application {
  final String? applicantID;
  final int? criteriaScore;
  final String? occupation;
  final String? profileType;
  final int? numberOfPax;
  final String? nationality;
  final DateTime? moveInDate;
  final int? tenancyDuration;
  final String? applicationID;
  final String? applicantName;
  final String? applicantProfilePic;
  final double? applicantOverallRating;
  final int? applicantRatingCount;
  final PropertyDetails? propertyDetails;
  final String status;


  Application({
    this.applicantID,
    this.criteriaScore,
    this.occupation,
    this.profileType,
    this.numberOfPax,
    this.nationality,
    this.moveInDate,
    this.tenancyDuration,
    this.applicationID,
    this.applicantName,
    this.applicantProfilePic,
    this.applicantOverallRating,
    this.applicantRatingCount,
    this.propertyDetails,
    this.status = "Pending",
  });

  factory Application.fromMap(Map<String, dynamic> applicationMap) {
    return Application(
      applicantID: applicationMap["applicantID"],
      criteriaScore: applicationMap["criteriaScore"] ?? 0,
      moveInDate: applicationMap["moveInDate"],
      nationality: applicationMap["nationality"],
      numberOfPax: applicationMap["numberOfPax"],
      occupation: applicationMap["occupation"],
      profileType: applicationMap["profileType"],
      status: applicationMap["status"] ?? "Pending",
      tenancyDuration: applicationMap["tenancyDuration"],
      applicationID: applicationMap["applicationID"],
      applicantName: applicationMap["applicantName"] ?? "N/A",
      applicantProfilePic: applicationMap["applicantProfilePic"] ?? "https://via.placeholder.com/150",
      applicantOverallRating: applicationMap["applicantOverallRating"] ?? 0.0,
      applicantRatingCount: applicationMap["applicantRatingCount"] ?? 0,
    );
  }

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

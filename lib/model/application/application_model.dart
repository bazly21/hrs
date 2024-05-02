import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String propertyID;
  final String applicantID;
  final String occupation;
  final String profileType;
  final int numberOfPax;
  final String nationality;
  final DateTime moveInDate;
  final int tenancyDuration;
  final String status = "Pending";
  final FieldValue submittedAt = FieldValue.serverTimestamp();

  Application({
    required this.propertyID,
    required this.applicantID,
    required this.occupation,
    required this.profileType,
    required this.numberOfPax,
    required this.nationality,
    required this.moveInDate,
    required this.tenancyDuration,
  });

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    return {
      "propertyID": propertyID,
      "applicantID": applicantID,
      "occupation": occupation,
      "profileType": profileType,
      "numberOfPax": numberOfPax,
      "nationality": nationality,
      "moveInDate": Timestamp.fromDate(moveInDate), // Convert DateTime to Timestamp for Firestore
      "tenancyDuration": tenancyDuration,
      "status": status,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Tenancy {
  final String propertyID;
  final String tenantID;
  final String landlordID;
  final String status;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;

  Tenancy({
    required this.propertyID,
    required this.tenantID,
    required this.landlordID,
    required this.status,
    required this.duration,
    required this.startDate,
    required this.endDate,
  });

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    return {
      'propertyID': propertyID,
      'tenantID': tenantID,
      'landlordID': landlordID,
      'status': status,
      'duration': duration,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

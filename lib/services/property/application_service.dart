import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/model/tenant_criteria/tenant_criteria.dart';
import 'package:hrs/services/user_service.dart';
import 'package:intl/intl.dart';

class ApplicationService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  Future<Map<String, dynamic>> getPropertyApplication(String propertyID) async {
    Map<String, dynamic> applicationMap = {};
    bool hasAccepted = false;

    DocumentSnapshot<Map<String, dynamic>> propertyDoc =
        await _fireStore.collection('properties').doc(propertyID).get();
    Map<String, dynamic>? propertyData = propertyDoc.data();

    if (propertyData == null) throw Exception("Property data is not exist");

    // Fetch the rental property's applications
    QuerySnapshot applicationSnapshots = await _fireStore
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .where("status", isNotEqualTo: "Declined")
        .get();

    if (applicationSnapshots.docs.isNotEmpty) {
      // Fetch all applicant user documents in parallel
      List<Map<String, dynamic>?> applicationList = await Future.wait(
        applicationSnapshots.docs.map((appDoc) async {
          Map<String, dynamic> applicationData =
              appDoc.data() as Map<String, dynamic>;

          if (applicationData.isEmpty) return null;

          String applicantID = appDoc["applicantID"];
          DocumentSnapshot<Map<String, dynamic>> applicantDoc =
              await _userService.getUserDetails(applicantID);
          Map<String, dynamic>? applicantData = applicantDoc.data();

          // Return null if applicantData is empty
          if (applicantData == null) return null;

          DateTime moveInDate =
              (applicationData['moveInDate'] as Timestamp).toDate();
          String formattedDate = DateFormat('dd/MM/yyyy').format(moveInDate);

          return {
            ...applicationData,
            'applicationID': appDoc.id,
            'moveInDate': formattedDate,
            "applicantName": applicantData["name"] ?? "N/A",
          };
        }),
      ).then((list) => list.whereType<Map<String, dynamic>>().toList());

      hasAccepted = applicationList
          .any((application) => application?['status'] == 'Accepted');

      applicationList.sort((a, b) {
        num aScore = a?["criteriaScore"] ?? 0;
        num bScore = b?["criteriaScore"] ?? 0;
        return bScore.compareTo(aScore);
      });

      applicationMap = {
        "applicationList": applicationList,
        "hasAccepted": hasAccepted,
        "propertyStatus": propertyData["status"],
      };
    }

    return applicationMap;
  }

  // Save tenant criteria
  Future<void> saveTenantCriteria(
      String propertyID, TenantCriteria tenantCriteria) async {
    DocumentReference propertyDocRef =
        _fireStore.collection('properties').doc(propertyID);

    // Update the tenant criteria on property document
    await propertyDocRef.update({
      'tenantCriteria': tenantCriteria.toMap(),
    });
  }

  static Future<bool> checkUserApplication(
      String propertyID, String applicantID) async {
    QuerySnapshot applicationSnapshots = await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .where("applicantID", isEqualTo: applicantID)
        .get();

    return applicationSnapshots.docs.isNotEmpty;
  }

  // Save application
  Future saveApplication(String propertyID, Application applicationData) async {
    await _fireStore
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .add(applicationData.toMap());
  }
}

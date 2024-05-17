import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/model/tenant_criteria/tenant_criteria.dart';

class ApplicationService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> getPropertyApplication(String propertyID) async {
    Map<String, dynamic> applicationMap = {};
    bool containsAcceptedApplication = false;
    bool hasTenantCriteria = false;

    DocumentSnapshot<Map<String, dynamic>> propertyDoc =
        await FirebaseFirestore.instance.collection('properties').doc(propertyID).get();
    Map<String, dynamic>? propertyData = propertyDoc.data();

    if (propertyData == null) throw Exception("Property data is not exist");

    // Fetch the rental property's applications
    QuerySnapshot applicationSnapshots = await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .where("status", isNotEqualTo: "Declined")
        .orderBy("status")
        .orderBy("submittedAt", descending: true)
        .get();

    if (applicationSnapshots.docs.isNotEmpty) {
      // Fetch all applicant user documents in parallel
      List<Application?> applicationList = await Future.wait(
        applicationSnapshots.docs.map((appDoc) async {
          Map<String, dynamic>? applicationData =
              appDoc.data() as Map<String, dynamic>?;

          if (applicationData == null || appDoc["applicantID"] == null) return null;
          String applicantID = appDoc["applicantID"];

          // Fetch applicant user document
          DocumentSnapshot applicantDoc =
            await FirebaseFirestore.instance
              .collection('users')
              .doc(applicantID)
              .get();

          Map<String, dynamic>? applicantData = applicantDoc.data() as Map<String, dynamic>?;

          // Return null if applicantData or moveIndDate is not exist
          if (applicantData == null || applicationData['moveInDate'] == null) return null;

          DateTime formattedDate = (applicationData['moveInDate'] as Timestamp).toDate();

          Application application = Application.fromMap({
            ...applicationData,
            'applicationID': appDoc.id,
            'moveInDate': formattedDate,
            "applicantName": applicantData["name"],
            "applicantProfilePic": applicantData["profilePic"],
            "applicantOverallRating": applicantData["ratingAverage"]?["tenant"]?["overallRating"],
            "applicantRatingCount": applicantData["ratingCount"]?["tenant"],
          });

          return application;
        }),
      ).then((list) => list.whereType<Application>().toList());

      containsAcceptedApplication = applicationList
          .any((application) => application!.status == 'Accepted');

      hasTenantCriteria = propertyData.containsKey("tenantCriteria");

      if (hasTenantCriteria) {
        applicationList.sort((a, b) {
          num aScore = a!.criteriaScore ?? 0;
          num bScore = b!.criteriaScore ?? 0;
          return bScore.compareTo(aScore);
        });
      }

      applicationMap = {
        "applicationList": applicationList,
        "hasTenantCriteria": hasTenantCriteria,
        "containsAcceptedApplication": containsAcceptedApplication,
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

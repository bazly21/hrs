import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/model/tenant_criteria/tenant_criteria.dart';
import 'package:hrs/services/user_service.dart';
import 'package:intl/intl.dart';

class ApplicationService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Get property details
  // Future<List<Map<String, dynamic>>> getPropertyApplication(
  //     String propertyID) async {
  //   List<Map<String, dynamic>> applicationDataList = [];

  //   // Fetch the rental property's applications
  //   QuerySnapshot applicationSnapshots = await _fireStore
  //       .collection("properties")
  //       .doc(propertyID)
  //       .collection("applications")
  //       .where("status", isNotEqualTo: "Declined")
  //       .get();

  //   if (applicationSnapshots.docs.isNotEmpty) {
  //     // Fetch all applicant user documents in parallel
  //     List<DocumentSnapshot> userSnapshots = await Future.wait(
  //         applicationSnapshots.docs
  //             .map((appDoc) => appDoc["applicantID"] as String?)
  //             .whereNotNull()
  //             .map((applicantID) => _userService.getUserDetails(applicantID))
  //             .toList());

  //     // Map applicationData with corresponding user data
  //     for (int i = 0; i < applicationSnapshots.docs.length; i++) {
  //       Map<String, dynamic> applicationData =
  //           applicationSnapshots.docs[i].data() as Map<String, dynamic>;
  //       DocumentSnapshot userSnapshot = userSnapshots[i];

  //       if (userSnapshot.exists) {
  //         String? applicantName = userSnapshot["name"];
  //         if (applicantName != null && applicantName.isNotEmpty) {
  //           // Get the document ID
  //           applicationData["applicationID"] = applicationSnapshots.docs[i].id;

  //           // Create new property inside applicationData called applicantName
  //           applicationData["applicantName"] = applicantName;

  //           // Since applicationData['moveInDate'] is timestamp
  //           // type (Firestore only support timestamp type),
  //           // Then we need to convert it to DateTime format
  //           // to use the DateFormat object
  //           Timestamp timestamp = applicationData['moveInDate'];
  //           DateTime moveInDate = timestamp.toDate();
  //           String formattedDate = DateFormat('dd/MM/yyyy').format(moveInDate);
  //           applicationData['moveInDate'] = formattedDate;

  //           // Once all the processes are done, add the document
  //           // into applicationDataList
  //           applicationDataList.add(applicationData);
  //         }
  //       }
  //     }

  //     // Sort the applicationDataList based on the criteriaScore field in descending order
  //     applicationDataList
  //         .sort((a, b) => b["criteriaScore"].compareTo(a["criteriaScore"]));
  //   }

  //   print(applicationDataList);

  //   return applicationDataList;
  // }

  Future<Map<String, dynamic>> getPropertyApplication(String propertyID) async {
    Map<String, dynamic> applicationMap = {};
    bool hasAccepted = false;

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

  Future<bool> checkUserApplication(
      String propertyID, String applicantID) async {
    QuerySnapshot applicationSnapshots = await _fireStore
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

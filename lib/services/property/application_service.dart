import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hrs/services/user_service.dart';
import 'package:intl/intl.dart';

class ApplicationService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Get property details
  Future<List<Map<String, dynamic>>> getPropertyApplication(String propertyID) async {
    List<Map<String, dynamic>> applicationDataList = [];

    // Fetch the rental property's applications
    QuerySnapshot applicationSnapshots = await _fireStore
        .collection("applications")
        .where("propertyID", isEqualTo: propertyID)
        .where("status", isNotEqualTo: "Declined")
        .get();

    if (applicationSnapshots.docs.isNotEmpty) {
      // Fetch all applicant user documents in parallel
      List<DocumentSnapshot> userSnapshots = await Future.wait(
          applicationSnapshots.docs
              .map((appDoc) => appDoc["applicantID"] as String?)
              .whereNotNull()
              .map((applicantID) =>
                  _userService.getUserDetails(applicantID))
              .toList());

      // Map applicationData with corresponding user data
      for (int i = 0; i < applicationSnapshots.docs.length; i++) {
        Map<String, dynamic> applicationData =
            applicationSnapshots.docs[i].data() as Map<String, dynamic>;
        DocumentSnapshot userSnapshot = userSnapshots[i];

        if (userSnapshot.exists) {
          String? applicantName = userSnapshot["name"];
          if (applicantName != null && applicantName.isNotEmpty) {
            // Get the document ID
            applicationData["applicationID"] = applicationSnapshots.docs[i].id;

            // Create new property inside applicationData called applicantName
            applicationData["applicantName"] = applicantName;

            // Since applicationData['moveInDate'] is timestamp
            // type (Firestore only support timestamp type),
            // Then we need to convert it to DateTime format
            // to use the DateFormat object
            Timestamp timestamp = applicationData['moveInDate'];
            DateTime moveInDate = timestamp.toDate();
            String formattedDate = DateFormat('dd/MM/yyyy').format(moveInDate);
            applicationData['moveInDate'] = formattedDate;

            // Once all the processes are done, add the document
            // into applicationDataList
            applicationDataList.add(applicationData);
          }
        }
      }
    }

    return applicationDataList;
  }
}

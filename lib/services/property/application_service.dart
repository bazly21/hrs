import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/model/tenant_criteria/tenant_criteria.dart';

class ApplicationService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get application list by propertyID
  static Future<Map<String, dynamic>> getPropertyApplication(
    String propertyID,
  ) async {
    Map<String, dynamic> applicationMap = {};
    bool containsAcceptedApplication = false;
    bool hasTenantCriteria = false;

    // Fetch the property snapshot
    final propertyDoc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyID)
        .get();

    // Convert the property document to a map
    final propertyData = propertyDoc.data();

    // Throw exception if property data is null or not exist
    if (propertyData == null) {
      throw Exception("Property data is not exist");
    }

    // Fetch the property's applications where status is not Declined
    // and order in descending order by submittedAt
    QuerySnapshot applicationSnapshots = await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .where("status", isNotEqualTo: "Declined")
        .orderBy("status")
        .orderBy("submittedAt", descending: true)
        .get();

    // If there is application
    if (applicationSnapshots.docs.isNotEmpty) {
      // Fetch all applicant user documents in parallel
      final applicationList = await Future.wait(
        applicationSnapshots.docs.map((appDoc) async {
          // Convert the application document to a map
          final applicationData = appDoc.data() as Map<String, dynamic>?;

          // Return null if applicationData or applicantID is not exist
          if (applicationData == null || appDoc["applicantID"] == null) {
            return null;
          }

          // Get applicantID from application map
          String applicantID = appDoc["applicantID"];

          // Fetch applicant user document
          DocumentSnapshot applicantDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(applicantID)
              .get();

          // Convert the applicant document to a map
          final applicantData = applicantDoc.data() as Map<String, dynamic>?;

          // Return null if applicantData or moveIndDate is not exist
          if (applicantData == null || applicationData['moveInDate'] == null) {
            return null;
          }

          // Convert moveInDate from Timestamp to DateTime
          DateTime formattedDate =
              (applicationData['moveInDate'] as Timestamp).toDate();

          // Check if the application is accepted and the tenancy is ended
          // If so, exclude the application from the list
          if (applicationData["status"] == "Accepted") {
            QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
                .collection('properties')
                .doc(propertyID)
                .collection('tenancies')
                .where('applicationID', isEqualTo: appDoc.id)
                .get();

            // If there is tenancy
            if (tenancySnapshot.docs.isNotEmpty) {
              Map<String, dynamic>? tenancyData =
                  tenancySnapshot.docs.first.data() as Map<String, dynamic>?;
              if (tenancyData != null) {
                // If tenancy status is ended,
                // exclude the application from the list
                if (tenancyData["status"] == "Ended") {
                  return null;
                }
              }
            }
          }

          Application application = Application.fromMap({
            ...applicationData,
            'applicationID': appDoc.id,
            'moveInDate': formattedDate,
            "applicantName": applicantData["name"],
            "applicantProfilePic": applicantData["profilePictureURL"],
            "applicantOverallRating": applicantData["ratingAverage"]?["tenant"]
                ?["overallRating"],
            "applicantRatingCount": applicantData["ratingCount"]?["tenant"],
          });

          return application;
        }),
      ).then((list) => list.whereType<Application>().toList());

      // If application list is empty
      if (applicationList.isEmpty) {
        return applicationMap;
      }

      // Check if application list contains accepted application
      // This will be used to disable the other application
      // accept button if there is already
      containsAcceptedApplication = applicationList
          .any((application) => application.status == 'Accepted');

      hasTenantCriteria = propertyData.containsKey("tenantCriteria");

      if (hasTenantCriteria) {
        applicationList.sort((a, b) {
          num aScore = a.criteriaScore ?? 0;
          num bScore = b.criteriaScore ?? 0;
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
      String propertyID, TenantCriteria? tenantCriteria) async {
    DocumentReference propertyDocRef =
        _fireStore.collection('properties').doc(propertyID);

    // Update the tenant criteria on property document
    if (tenantCriteria == null) {
      await propertyDocRef.update({
        'tenantCriteria': null,
      });
    } else {
      await propertyDocRef.update({
        'tenantCriteria': tenantCriteria.toMap(),
      });
    }
  }

  static Future<bool> checkUserApplication(
      String propertyID, String applicantID) async {
    QuerySnapshot applicationSnapshots = await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .where("applicantID", isEqualTo: applicantID)
        .orderBy("submittedAt", descending: true)
        .get();

    // If no application found (not apply), return false
    if (applicationSnapshots.docs.isEmpty) return false;

    // Take the first application
    DocumentSnapshot applicationDoc = applicationSnapshots.docs.first;
    Map<String, dynamic>? applicationData =
        applicationDoc.data() as Map<String, dynamic>?;

    // If application data is null, return false
    if (applicationData == null) return false;

    // If application status is not Declined, return true
    if (applicationData["status"] != "Declined") return true;

    return false;
  }

  // Save application
  Future saveApplication(String propertyID, Application applicationData) async {
    await _fireStore
        .collection("properties")
        .doc(propertyID)
        .collection("applications")
        .add(applicationData.toMap());
  }

  // Get application list by tenantID
  Future<List<Application>> getApplicationListByTenantID() async {
    String? applicantID = _auth.currentUser?.uid;

    // Throw an error if tenantID is null
    if (applicantID == null) {
      throw FirebaseAuthException(
        code: 'invalid-access',
        message: 'User is not signed in.',
      );
    }

    QuerySnapshot applicationSnapshots = await _fireStore
        .collectionGroup("applications")
        .where("applicantID", isEqualTo: applicantID)
        .orderBy("submittedAt", descending: true)
        .get();

    // Return empty list if no application found
    if (applicationSnapshots.docs.isEmpty) {
      return [];
    }

    List<Application> applicationList = await Future.wait(
      applicationSnapshots.docs.map((appDoc) async {
        Map<String, dynamic>? applicationData =
            appDoc.data() as Map<String, dynamic>?;

        if (applicationData == null) return null;

        // Fetch property document
        DocumentSnapshot propertyDoc =
            await appDoc.reference.parent.parent!.get();
        Map<String, dynamic>? propertyData =
            propertyDoc.data() as Map<String, dynamic>?;

        if (propertyData == null || propertyData["landlordID"] == null) {
          return null;
        }

        String landlordID = propertyData["landlordID"];

        // Fetch landlord user document
        DocumentSnapshot landlordDoc =
            await _fireStore.collection('users').doc(landlordID).get();
        Map<String, dynamic>? landlordData =
            landlordDoc.data() as Map<String, dynamic>?;

        // Return null if landlordData is not exist
        // or landlordData is empty
        if (landlordData == null) return null;

        // Get landlord overall rating and rating count
        propertyData["landlordOverallRating"] =
            landlordData["ratingAverage"]?["landlord"]?["overallRating"];
        propertyData["landlordRatingCount"] =
            landlordData["ratingCount"]?["landlord"];

        // Get landlord name and profile picture
        propertyData["landlordName"] = landlordData["name"];
        propertyData["landlordProfilePictureURL"] =
            landlordData["profilePictureURL"];

        // Convert property data to PropertyFullDetails object
        PropertyDetails propertyDetails =
            PropertyDetails.fromMapHalfDetails(propertyData);

        Application application = Application(
          status: applicationData["status"] ?? "Pending",
          propertyDetails: propertyDetails,
        );

        return application;
      }),
    ).then((list) => list.whereType<Application>().toList());

    return applicationList;
  }
}

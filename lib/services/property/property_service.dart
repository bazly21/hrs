import "package:cloud_firestore/cloud_firestore.dart";
import "package:hrs/model/property/property_details.dart";
import "package:hrs/services/property/application_service.dart";
import "package:hrs/services/property/tenancy_service.dart";

class PropertyService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get property details
  Future<DocumentSnapshot<Map<String, dynamic>>> getPropertyDetails(
      String propertyID) async {
    return await _fireStore.collection("properties").doc(propertyID).get();
  }

  // Get property full details including landlord details
  Future<PropertyFullDetails> getPropertyFullDetails(
      String propertyID, String? applicantID) async {
    Map<String, dynamic> propertyFullDetails = {};
    bool hasApplication = false;
    bool hasTenancy = false;
    bool hasApplied = false;

    DocumentSnapshot<Map<String, dynamic>> propertyDoc =
        await getPropertyDetails(propertyID);
    Map<String, dynamic>? propertyData = propertyDoc.data();

    // Early return if property data is not exist
    if (propertyData == null) throw ("Property data is not exist");

    // Early return if landlord ID is not exist
    if (!propertyData.containsKey("landlordID") ||
        propertyData["landlordID"] == null) {
      throw ("Landlord ID does not exist");
    }

    // Get landlord details
    final String landlordID = propertyData["landlordID"];
    DocumentSnapshot<Map<String, dynamic>> landlordDoc =
        await _fireStore.collection("users").doc(landlordID).get();
    Map<String, dynamic>? landlordData = landlordDoc.data();

    // Early return if landlord data is not exist
    if (landlordData == null) throw ("Landlord data is not exist");

    // Check user application if applicant ID is not null
    if (applicantID != null) {
      hasApplication = await ApplicationService.checkUserApplication(
          propertyID, applicantID);
      hasTenancy = hasApplication ||
          await TenancyService.checkUserTenancy(propertyID, applicantID);
      hasApplied = hasTenancy;
    }

    // Collect all necessary data
    propertyFullDetails = {
      ...propertyData,
      "landlordName": landlordData["name"],
      "landlordRatingCount": landlordData["ratingCount"]?["landlord"],
      "landlordOverallRating": landlordData["ratingAverage"]?["landlord"]
          ?["overallRating"],
      "hasApplied": hasApplied,
    };

    PropertyFullDetails propertyDetails =
        PropertyFullDetails.fromMapFullDetails(propertyFullDetails);

    return propertyDetails;
  }

  // Convert property data into a map
  Map<String, dynamic> propertyDataToMap(DocumentSnapshot propertyData) {
    return propertyData.data() as Map<String, dynamic>;
  }

  static Future<List<PropertyFullDetails>?> fetchAvailableProperties() async {
    // Fetch all the data inside properties collection
    QuerySnapshot propertiesSnapshot = await FirebaseFirestore.instance
        .collection("properties")
        .where("status", isEqualTo: "Available")
        .get();

    if (propertiesSnapshot.docs.isEmpty) return null;

    List<PropertyFullDetails> propertiesDetailsList =
        await Future.wait(propertiesSnapshot.docs.map((propertyDoc) async {
      Map<String, dynamic>? propertyData =
          propertyDoc.data() as Map<String, dynamic>?;

      if (propertyData == null) return null;

      if (propertyData["landlordID"] == null) return null;

      String landlordID = propertyData["landlordID"];

      DocumentSnapshot landlordDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(landlordID)
          .get();

      Map<String, dynamic>? landlordData =
          landlordDoc.data() as Map<String, dynamic>?;

      if (landlordData == null) return null;

      Map<String, dynamic> propertyMap = {
        ...propertyData,
        "propertyID": propertyDoc.id,
        "landlordName": landlordData["name"],
        "landlordRatingCount": landlordData["ratingCount"]?["landlord"],
        "landlordOverallRating": landlordData["ratingAverage"]?["landlord"]
            ?["overallRating"],
      };

      return PropertyFullDetails.fromMapHalfDetails(propertyMap);
    })).then((noob) => noob
            .where((element) => element != null)
            .toList()
            .cast<PropertyFullDetails>());

    return propertiesDetailsList;
  }

  // Function to delete property
  static Future<void> deleteProperty(String propertyID) async {
    await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .delete();
  }
}

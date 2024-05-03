import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/services/property/application_service.dart';

class PropertyService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final ApplicationService _applicationService = ApplicationService();

  // Get property details
  Future<DocumentSnapshot<Map<String, dynamic>>> getPropertyDetails(String propertyID) async {
    return await _fireStore.collection('properties').doc(propertyID).get();
  }

  // Get property full details including landlord details
  Future<Map<String, dynamic>> getPropertyFullDetails(String propertyID, String? applicantID) async {
    Map<String, dynamic> propertyFullDetails = {};
    bool hasApplied = false;

    DocumentSnapshot<Map<String, dynamic>> propertyDoc = await getPropertyDetails(propertyID);
    Map<String, dynamic>? propertyData = propertyDoc.data();

    // Early return if property data is not exist
    if (propertyData == null) throw("Property data is not exist");

    // Early return if landlord ID is not exist
    if (!propertyData.containsKey("landlordID") || propertyData['landlordID'] == null) {
      throw("Landlord ID does not exist");
    }

    // Get landlord details
    final String landlordID = propertyData['landlordID'];
    DocumentSnapshot<Map<String, dynamic>> landlordDoc = await _fireStore.collection('users').doc(landlordID).get();
    Map<String, dynamic>? landlordData = landlordDoc.data();

    // Early return if landlord data is not exist
    if (landlordData == null) throw("Landlord data is not exist");

    // Check user application if applicant ID is not null
    if (applicantID != null) {
      hasApplied = await _applicationService.checkUserApplication(propertyID, applicantID);
    }

    // Collect all necessary data
    propertyFullDetails = {
      ...propertyData,
      "landlordName": landlordData["name"],
      "landlordRatingCount": landlordData["ratingCount"],
      "landlordOverallRating": landlordData["ratingAverage"]?["overallRating"],
      "hasApplied": hasApplied,
    };

    return propertyFullDetails;
  }

  // Convert property data into a map
  Map<String, dynamic> propertyDataToMap(DocumentSnapshot propertyData) {
    return propertyData.data() as Map<String, dynamic>;
  }
}

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:hrs/model/property/property_details.dart";
import "package:hrs/provider/wishlist_provider.dart";
import "package:hrs/services/property/application_service.dart";
import "package:hrs/services/property/tenancy_service.dart";
import "package:provider/provider.dart";

class PropertyService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get property details
  Future<DocumentSnapshot<Map<String, dynamic>>> getPropertyDetails(
      String propertyID) async {
    return await _fireStore.collection("properties").doc(propertyID).get();
  }

  // Get property full details including landlord details
  static Future<PropertyDetails> getPropertyFullDetails(
      String propertyID, String? applicantID) async {
    Map<String, dynamic> propertyFullDetails = {};
    bool enableApplyButton = true;
    bool hasApplied = false;

    DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyID)
        .get();

    Map<String, dynamic>? propertyData =
        propertyDoc.data() as Map<String, dynamic>?;

    // Early return if property data is not exist
    if (propertyData == null) throw Exception("Property data is not exist");

    // Early return if landlord ID is not exist
    if (!propertyData.containsKey("landlordID") ||
        propertyData["landlordID"] == null) {
      throw Exception("Landlord ID does not exist");
    }

    // Get landlord details
    final String landlordID = propertyData["landlordID"];
    DocumentSnapshot landlordDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(landlordID)
        .get();

    Map<String, dynamic>? landlordData =
        landlordDoc.data() as Map<String, dynamic>?;

    // Early return if landlord data is not exist
    if (landlordData == null) throw ("Landlord data is not exist");

    // Check user application if applicant ID is not null
    if (applicantID != null) {
      if (propertyData["status"] == "Rented") {
        enableApplyButton = false;
      } else {
        // First, check if the user already applied for the property
        hasApplied = await ApplicationService.checkUserApplication(
            propertyID, applicantID);

        // Then, if the user has applied, check tenancy status
        if (hasApplied) {
          enableApplyButton =
              await TenancyService.checkUserTenancy(propertyID, applicantID);
        } else {
          enableApplyButton = true;
        }
      }
    }

    // Collect all necessary data
    propertyFullDetails = {
      ...propertyData,
      "landlordName": landlordData["name"],
      "landlordProfilePictureURL": landlordData["profilePictureURL"],
      "landlordRatingCount": landlordData["ratingCount"]?["landlord"],
      "landlordOverallRating": landlordData["ratingAverage"]?["landlord"]
          ?["overallRating"],
      "enableApplyButton": enableApplyButton,
    };

    PropertyDetails propertyDetails =
        PropertyDetails.fromMapFullDetails(propertyFullDetails);

    return propertyDetails;
  }

  // Convert property data into a map
  Map<String, dynamic> propertyDataToMap(DocumentSnapshot propertyData) {
    return propertyData.data() as Map<String, dynamic>;
  }

  static Future<List<PropertyDetails>?> fetchAvailableProperties(
      BuildContext context,
      {String? searchQuery}) async {
    // Get current userID
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot propertiesSnapshot;
    WishlistProvider wishlistProvider = context.read<WishlistProvider>();

    // Initialize the Firestore query
    Query propertiesQuery = FirebaseFirestore.instance
        .collection("properties")
        .where("status", isEqualTo: "Available");

    // Add condition to exclude properties of the current user
    if (userID != null) {
      propertiesQuery =
          propertiesQuery.where("landlordID", isNotEqualTo: userID);
    }

    // Fetch the properties
    propertiesSnapshot = await propertiesQuery.get();

    // Return null if no properties found
    if (propertiesSnapshot.docs.isEmpty) return null;

    List<PropertyDetails> propertiesDetailsList =
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

      await wishlistProvider.fetchWishlistPropertyIDs();

      Map<String, dynamic> propertyMap = {
        ...propertyData,
        "propertyID": propertyDoc.id,
        "landlordName": landlordData["name"],
        "landlordProfilePictureURL": landlordData["profilePictureURL"],
        "landlordRatingCount": landlordData["ratingCount"]?["landlord"],
        "landlordOverallRating": landlordData["ratingAverage"]?["landlord"]
            ?["overallRating"],
      };

      return PropertyDetails.fromMapHalfDetails(propertyMap);
    })).then((list) => list.whereType<PropertyDetails>().toList());

    // Filter properties based on searchQuery if it is not null and not empty
    if (searchQuery != null && searchQuery.isNotEmpty) {
      propertiesDetailsList = propertiesDetailsList.where((property) {
        return property.propertyName!
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

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

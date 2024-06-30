import "package:cloud_firestore/cloud_firestore.dart";
import "package:hrs/model/rating/landlord_rating.dart";
import "package:hrs/model/rating/rating_details.dart";
import "package:hrs/model/rating/tenant_rating.dart";
import "package:hrs/model/user/landlord_profile.dart";
import "package:hrs/model/user/tenant_profile.dart";

class RatingService {
  // Submit rating to database
  static Future<void> submitLandlordRating({
    required LandlordRating landlordRating,
    required String landlordID,
    required String tenancyDocID,
    required String propertyID,
  }) async {
    // Create document reference for landlord's rating
    final DocumentReference ratingDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(landlordID)
        .collection("ratings")
        .doc();

    // Create document reference for landlord's profile
    final DocumentReference landlordDocRef =
        FirebaseFirestore.instance.collection("users").doc(landlordID);

    // Create document reference for tenancy document
    final DocumentReference tenancyDocRef = FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("tenancies")
        .doc(tenancyDocID);

    // Perform all operations within a single transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get landlord document snapshot
      DocumentSnapshot landlordSnapshot = await transaction.get(landlordDocRef);

      // Check if the document exists
      if (!landlordSnapshot.exists) {
        throw Exception("Landlord does not exist");
      }

      // Convert the landlord data to a map
      final landlordData = landlordSnapshot.data() as Map<String, dynamic>;

      // Calculate the average ratings
      double totalSupportRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = landlordData["ratingCount"]?["landlord"] ?? 0;

      // Get the total ratings for Support
      totalSupportRating = ((landlordData["ratingAverage"]?["landlord"]
                  ?["supportRating"] ??
              0.0) *
          ratingCount);

      // Get the total ratings for Communication
      totalCommunicationRating = ((landlordData["ratingAverage"]?["landlord"]
                  ?["communicationRating"] ??
              0.0) *
          ratingCount);

      // Get the total ratings for Maintenance
      totalMaintenanceRating = ((landlordData["ratingAverage"]?["landlord"]
                  ?["maintenanceRating"] ??
              0.0) *
          ratingCount);

      // Get new total ratings by adding the new ratings
      // to the current total ratings
      totalSupportRating += landlordRating.supportRating;
      totalCommunicationRating += landlordRating.communicationRating;
      totalMaintenanceRating += landlordRating.maintenanceRating;

      // Calculate the average ratings by dividing
      // updated total ratings by the new rating count
      // and rounding off to 1 decimal place
      double averageSupportRating = double.parse(
          (totalSupportRating / (ratingCount + 1)).toStringAsFixed(1));
      double averageCommunicationRating = double.parse(
          (totalCommunicationRating / (ratingCount + 1)).toStringAsFixed(1));
      double averageMaintenanceRating = double.parse(
          (totalMaintenanceRating / (ratingCount + 1)).toStringAsFixed(1));
      double overallRating = double.parse(((averageSupportRating +
                  averageCommunicationRating +
                  averageMaintenanceRating) /
              3)
          .toStringAsFixed(1));

      transaction.set(ratingDocRef, landlordRating.toMap());

      transaction.update(tenancyDocRef, {"isRated.rateLandlord": true});

      transaction.update(landlordDocRef, {
        "ratingCount.landlord": ratingCount + 1,
        "ratingAverage.landlord": {
          "supportRating": averageSupportRating,
          "communicationRating": averageCommunicationRating,
          "maintenanceRating": averageMaintenanceRating,
          "overallRating": overallRating,
        }
      });
    });
  }

  static Future<void> submitTenantRating({
    required TenantRating tenantRating,
    required String tenantID,
    required String tenancyDocID,
    required String propertyID,
  }) async {
    final DocumentReference ratingDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(tenantID)
        .collection("ratings")
        .doc();

    final DocumentReference tenantDocRef =
        FirebaseFirestore.instance.collection("users").doc(tenantID);
    final DocumentReference tenancyDocRef = FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("tenancies")
        .doc(tenancyDocID);

    // Perform all operations within a single transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Set operation: Save rating information in the database
      DocumentSnapshot tenantSnapshot = await transaction.get(tenantDocRef);

      // Convert the tenant data to a map
      Map<String, dynamic>? tenantData =
          tenantSnapshot.data() as Map<String, dynamic>?;

      if (tenantData == null) throw Exception("Landlord does not exist");

      // Calculate the average ratings
      double totalPaymentRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = tenantData["ratingCount"]?["Tenant"] ?? 0;

      // Get the total ratings
      totalPaymentRating =
          ((tenantData["ratingAverage"]?["Tenant"]?["paymentRating"] ?? 0.0) *
              ratingCount);
      totalCommunicationRating = ((tenantData["ratingAverage"]?["Tenant"]
                  ?["communicationRating"] ??
              0.0) *
          ratingCount);
      totalMaintenanceRating = ((tenantData["ratingAverage"]?["Tenant"]
                  ?["maintenanceRating"] ??
              0.0) *
          ratingCount);

      // Get new total ratings
      totalPaymentRating += tenantRating.paymentRating;
      totalCommunicationRating += tenantRating.communicationRating;
      totalMaintenanceRating += tenantRating.maintenanceRating;

      // Calculate the average ratings
      double averagePaymentRating = double.parse(
          (totalPaymentRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageCommunicationRating = double.parse(
          (totalCommunicationRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageMaintenanceRating = double.parse(
          (totalMaintenanceRating / (ratingCount + 1)).toStringAsFixed(2));
      double overallRating = double.parse(((averagePaymentRating +
                  averageCommunicationRating +
                  averageMaintenanceRating) /
              3)
          .toStringAsFixed(2));

      transaction.set(ratingDocRef, tenantRating.toMap());

      transaction.update(tenancyDocRef, {"isRated.rateTenant": true});

      transaction.update(tenantDocRef, {
        "ratingCount.tenant": ratingCount + 1,
        "ratingAverage.tenant": {
          "paymentRating": averagePaymentRating,
          "communicationRating": averageCommunicationRating,
          "maintenanceRating": averageMaintenanceRating,
          "overallRating": overallRating,
        }
      });
    });
  }

  static Future getUserRatings(String userID, String role) async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();

    final Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    // Early return if user data is not exist
    if (userData == null) throw Exception("User does not exist");

    // Fetch user ratings subcollection
    // based on the role of the user
    final QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("ratings")
        .where("ratedAs", isEqualTo: role)
        .get();

    List<RatingDetails> ratings = [];

    // If rating snapshot is not empty,
    // fetch the reviewer details
    if (ratingSnapshot.docs.isNotEmpty) {
      ratings = await Future.wait(ratingSnapshot.docs.map((ratingDoc) async {
        final Map<String, dynamic>? ratingData =
            ratingDoc.data() as Map<String, dynamic>?;

        // Early return if rating data is not exist
        // or reviewerID is empty
        if (ratingData == null ||
            !ratingData.containsKey("reviewerID") ||
            ratingData["reviewerID"].isEmpty) {
          return null;
        }

        String reviewerID = ratingData["reviewerID"];

        // Fetch reviewer details
        final DocumentSnapshot reviewerSnapshot = await FirebaseFirestore
            .instance
            .collection("users")
            .doc(reviewerID)
            .get();

        final Map<String, dynamic>? reviewerData =
            reviewerSnapshot.data() as Map<String, dynamic>?;

        // Early return if reviewer data is not exist
        if (reviewerData == null) return null;

        return RatingDetails(
          reviewerName: reviewerData["name"] ?? "N/A",
          profilePictureUrl: reviewerData["profilePictureURL"],
          communicationRating: ratingData["communicationRating"] ?? 0.0,
          maintenanceRating: ratingData["maintenanceRating"] ?? 0.0,
          comments: ratingData["comments"],
          supportRating:
              role == "Landlord" ? ratingData["supportRating"] ?? 0.0 : null,
          paymentRating:
              role == "Tenant" ? ratingData["paymentRating"] ?? 0.0 : null,
        );

        // return {
        //   "reviewerName": reviewerData["name"],
        //   "profilePictureUrl": reviewerData["profilePictureURL"],
        //   "communicationRating": ratingData["communicationRating"],
        //   "maintenanceRating": ratingData["maintenanceRating"],
        //   "comments": ratingData["comments"],
        //   ...role == "Landlord"
        //       ? {"supportRating": ratingData["supportRating"]}
        //       : {"paymentRating": ratingData["paymentRating"]}
      })).then((list) => list.whereType<RatingDetails>().toList());
    }

    if (role == "Landlord") {
      LandlordProfile userRating = LandlordProfile.fromMap(userData, ratings);
      return userRating;
    } else {
      TenantProfile userRating = TenantProfile.fromMap(userData, ratings);
      return userRating;
    }
  }
}

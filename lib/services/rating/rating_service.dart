import "package:cloud_firestore/cloud_firestore.dart";
import "package:hrs/model/rating/landlord_rating.dart";
import "package:hrs/model/rating/rating_details.dart";
import "package:hrs/model/rating/tenant_rating.dart";
import "package:hrs/model/user/landlord_profile.dart";
import "package:hrs/model/user/tenant_profile.dart";
import "package:intl/intl.dart";

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
    // to ensure data consistency
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

      // Set the rating document
      transaction.set(ratingDocRef, landlordRating.toMap());

      // Update the tenancy document to indicate
      // that the landlord has rated
      transaction.update(tenancyDocRef, {"isRated.rateLandlord": true});

      // Update the landlord document with
      // the new rating count and average ratings
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
    // Create document reference for tenant's rating
    final DocumentReference ratingDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(tenantID)
        .collection("ratings")
        .doc();

    // Create document reference for tenant's profile
    final DocumentReference tenantDocRef =
        FirebaseFirestore.instance.collection("users").doc(tenantID);

    // Create document reference for tenancy document
    final DocumentReference tenancyDocRef = FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("tenancies")
        .doc(tenancyDocID);

    // Perform all operations within a single transaction
    // to ensure data consistency
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get tenant document snapshot
      DocumentSnapshot tenantSnapshot = await transaction.get(tenantDocRef);

      // Check if the document exists
      if (!tenantSnapshot.exists) {
        throw Exception("Tenant does not exist");
      }

      // Convert the tenant data to a map
      final tenantData = tenantSnapshot.data() as Map<String, dynamic>;

      // Calculate the average ratings
      double totalPaymentRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = tenantData["ratingCount"]?["tenant"] ?? 0;

      // Get the total ratings for Payment
      totalPaymentRating =
          ((tenantData["ratingAverage"]?["tenant"]?["paymentRating"] ?? 0.0) *
              ratingCount);

      // Get the total ratings for Communication
      totalCommunicationRating = ((tenantData["ratingAverage"]?["tenant"]
                  ?["communicationRating"] ??
              0.0) *
          ratingCount);

      // Get the total ratings for Maintenance
      totalMaintenanceRating = ((tenantData["ratingAverage"]?["tenant"]
                  ?["maintenanceRating"] ??
              0.0) *
          ratingCount);

      // Get new total ratings by adding the new ratings
      // to the current total ratings
      totalPaymentRating += tenantRating.paymentRating;
      totalCommunicationRating += tenantRating.communicationRating;
      totalMaintenanceRating += tenantRating.maintenanceRating;

      // Calculate the average ratings by dividing
      // updated total ratings by the new rating count
      // and rounding off to 1 decimal place
      double averagePaymentRating = double.parse(
          (totalPaymentRating / (ratingCount + 1)).toStringAsFixed(1));
      double averageCommunicationRating = double.parse(
          (totalCommunicationRating / (ratingCount + 1)).toStringAsFixed(1));
      double averageMaintenanceRating = double.parse(
          (totalMaintenanceRating / (ratingCount + 1)).toStringAsFixed(1));
      double overallRating = double.parse(((averagePaymentRating +
                  averageCommunicationRating +
                  averageMaintenanceRating) /
              3)
          .toStringAsFixed(1));

      // Set the rating document
      transaction.set(ratingDocRef, tenantRating.toMap());

      // Update the tenancy document to indicate
      // that the tenant has rated
      transaction.update(tenancyDocRef, {"isRated.rateTenant": true});

      // Update the tenant document with
      // the new rating count and average ratings
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
    // and order by the date submitted
    final QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("ratings")
        .where("ratedAs", isEqualTo: role)
        .orderBy("submittedAt", descending: true)
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

        // Fetch review date
        final DateTime reviewDate = ratingData["submittedAt"].toDate();

        // Convert date to dd-MM-yyyy format and time to HH:mm format
        final String formattedDate = DateFormat("dd-MM-yyyy").format(reviewDate);
        final String formattedTime = DateFormat("HH:mm").format(reviewDate);

        // Combine date and time
        final String formattedReviewDate = "$formattedDate $formattedTime";

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
          reviewDate: formattedReviewDate,
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

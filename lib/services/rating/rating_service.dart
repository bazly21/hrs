import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:hrs/model/rating/landlord_rating.dart";
import "package:hrs/model/rating/tenant_rating.dart";
import "package:hrs/model/rating/user_rating.dart";

class RatingService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Submit rating to database
  Future<void> submitLandlordRating(
      LandlordRating landlordRating, String tenancyDocID) async {
    final DocumentReference ratingDocRef = _fireStore
        .collection("users")
        .doc(landlordRating.landlordID)
        .collection("ratings")
        .doc();

    final DocumentReference landlordDocRef =
        _fireStore.collection("users").doc(landlordRating.landlordID);
    final DocumentReference tenancyDocRef =
        _fireStore.collection("tenancies").doc(tenancyDocID);

    // Perform all operations within a single transaction
    await _fireStore.runTransaction((transaction) async {
      // Set operation: Save rating information in the database
      DocumentSnapshot landlordSnapshot = await transaction.get(landlordDocRef);

      // Check if the document exists
      if (!landlordSnapshot.exists) {
        throw Exception("Landlord does not exist");
      }

      // Convert the landlord data to a map
      Map<String, dynamic> landlordData =
          landlordSnapshot.data() as Map<String, dynamic>;

      // Calculate the average ratings
      double totalSupportRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = landlordData["ratingCount"] ?? 0;

      // Get the total ratings
      totalSupportRating =
          ((landlordData["ratingAverage"]?["supportRating"] ?? 0.0) *
              ratingCount);
      totalCommunicationRating =
          ((landlordData["ratingAverage"]?["communicationRating"] ?? 0.0) *
              ratingCount);
      totalMaintenanceRating =
          ((landlordData["ratingAverage"]?["maintenanceRating"] ?? 0.0) *
              ratingCount);

      // Get new total ratings
      totalSupportRating += landlordRating.supportRating;
      totalCommunicationRating += landlordRating.communicationRating;
      totalMaintenanceRating += landlordRating.maintenanceRating;

      // Calculate the average ratings
      double averageSupportRating = double.parse(
          (totalSupportRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageCommunicationRating = double.parse(
          (totalCommunicationRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageMaintenanceRating = double.parse(
          (totalMaintenanceRating / (ratingCount + 1)).toStringAsFixed(2));
      double overallRating = double.parse(((averageSupportRating +
                  averageCommunicationRating +
                  averageMaintenanceRating) /
              3)
          .toStringAsFixed(2));

      transaction.set(ratingDocRef, landlordRating.toMap());

      transaction.update(tenancyDocRef, {
        "isRated.rateLandlord": true
      });

      transaction.update(landlordDocRef, {
        "ratingCount": ratingCount + 1,
        "ratingAverage": {
          "supportRating": averageSupportRating,
          "communicationRating": averageCommunicationRating,
          "maintenanceRating": averageMaintenanceRating,
          "overallRating": overallRating,
        }
      });
    });
  }

  static Future<void> submitTenantRating(
      TenantRating tenantRating, String tenantID, String tenancyDocID) async {
    final DocumentReference ratingDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(tenantID)
        .collection("ratings")
        .doc();

    final DocumentReference tenantDocRef =
        FirebaseFirestore.instance.collection("users").doc(tenantID);
    final DocumentReference tenancyDocRef =
        FirebaseFirestore.instance.collection("tenancies").doc(tenancyDocID);

    // Perform all operations within a single transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Set operation: Save rating information in the database
      DocumentSnapshot tenantSnapshot = await transaction.get(tenantDocRef);

      // Convert the tenant data to a map
      Map<String, dynamic>? tenantData =
          tenantSnapshot.data() as Map<String, dynamic>?;

      if(tenantData == null) throw Exception("Landlord does not exist");

      // Calculate the average ratings
      double totalPaymentRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = tenantData["ratingCount"]?["Tenant"] ?? 0;

      // Get the total ratings
      totalPaymentRating =
          ((tenantData["ratingAverage"]?["Tenant"]?["paymentRating"] ?? 0.0) *
              ratingCount);
      totalCommunicationRating =
          ((tenantData["ratingAverage"]?["Tenant"]?["communicationRating"] ?? 0.0) *
              ratingCount);
      totalMaintenanceRating =
          ((tenantData["ratingAverage"]?["Tenant"]?["maintenanceRating"] ?? 0.0) *
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

      transaction.update(tenancyDocRef, {
        "isRated.rateTenant": true
      });

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

  // Fetch user ratings
  Future<UserRating> getUserRatings(String userID) async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _fireStore.collection("users").doc(userID).get();
    final Map<String, dynamic>? userData = userSnapshot.data();

    // Early return if user data is not exist
    if (userData == null) throw Exception("User does not exist");

    // Fetch user ratings
    final QuerySnapshot ratingSnapshot = await _fireStore
        .collection("users")
        .doc(userID)
        .collection("ratings")
        .get();

    List<Map<String, dynamic>?> ratings = [];

    if (ratingSnapshot.docs.isNotEmpty) {
      ratings = await Future.wait(ratingSnapshot.docs
          .map((ratingDoc) async {
            final Map<String, dynamic>? ratingData =
                ratingDoc.data() as Map<String, dynamic>?;

            if (ratingData == null) return null;
            if (!ratingData.containsKey("reviewerID") ||
                ratingData["reviewerID"].isEmpty) return null;

            final DocumentSnapshot<Map<String, dynamic>> reviewerSnapshot =
                await _fireStore
                    .collection("users")
                    .doc(ratingData["reviewerID"])
                    .get();
            final Map<String, dynamic>? reviewerData = reviewerSnapshot.data();

            if (reviewerData == null) return null;

            return {
              "reviewerName": reviewerData["name"],
              "supportRating": ratingData["supportRating"],
              "communicationRating": ratingData["communicationRating"],
              "maintenanceRating": ratingData["maintenanceRating"],
              "comments": ratingData["comments"],
            };
          })
          .whereNotNull()
          .toList());
    }

    UserRating userRating = UserRating.fromMap(userData, ratings);

    return userRating;
  }
}

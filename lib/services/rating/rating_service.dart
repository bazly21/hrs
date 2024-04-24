import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/rating/landlord_rating.dart';

class RatingService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Submit rating to database
  Future<void> submitLandlordRating(LandlordRating landlordRating, String tenancyDocID) async {
    final DocumentReference ratingDocRef = _fireStore
        .collection('users')
        .doc(landlordRating.landlordID)
        .collection('ratings')
        .doc();

    final DocumentReference landlordDocRef = _fireStore.collection('users').doc(landlordRating.landlordID);
    final DocumentReference tenancyDocRef = _fireStore.collection('tenancies').doc(tenancyDocID);

    // Perform all operations within a single transaction
    await _fireStore.runTransaction((transaction) async {
      // Set operation: Save rating information in the database
      DocumentSnapshot landlordSnapshot = await transaction.get(landlordDocRef);

      // Check if the document exists
      if (!landlordSnapshot.exists) {
        throw Exception('Landlord does not exist');
      }

      // Convert the landlord data to a map
      Map<String, dynamic> landlordData = landlordSnapshot.data() as Map<String, dynamic>;

      // Calculate the average ratings
      double totalSupportRating = 0.0;
      double totalCommunicationRating = 0.0;
      double totalMaintenanceRating = 0.0;
      int ratingCount = landlordData['ratingCount'] ?? 0;

      // Get the total ratings
      totalSupportRating = ((landlordData['ratingAverage']?['supportRating'] ?? 0.0) * ratingCount);
      totalCommunicationRating = ((landlordData['ratingAverage']?['communicationRating'] ?? 0.0) * ratingCount);
      totalMaintenanceRating = ((landlordData['ratingAverage']?['maintenanceRating'] ?? 0.0) * ratingCount);

      // Get new total ratings
      totalSupportRating += landlordRating.supportRating;
      totalCommunicationRating += landlordRating.communicationRating;
      totalMaintenanceRating += landlordRating.maintenanceRating;

      // Calculate the average ratings
      double averageSupportRating = double.parse((totalSupportRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageCommunicationRating = double.parse((totalCommunicationRating / (ratingCount + 1)).toStringAsFixed(2));
      double averageMaintenanceRating = double.parse((totalMaintenanceRating / (ratingCount + 1)).toStringAsFixed(2));
      double overallRating = double.parse(((averageSupportRating + averageCommunicationRating + averageMaintenanceRating) / 3).toStringAsFixed(2));

      transaction.set(ratingDocRef, landlordRating.toMap());
      transaction.update(tenancyDocRef, {
        'isRated': true,
      });
      transaction.update(landlordDocRef, {
        'ratingCount': ratingCount + 1,
        'ratingAverage': {
          'supportRating': averageSupportRating,
          'communicationRating': averageCommunicationRating,
          'maintenanceRating': averageMaintenanceRating,
          'overallRating': overallRating,
        }
      });
    });
  }
}
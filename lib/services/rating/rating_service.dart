import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/rating/landlord_rating.dart';

class RatingService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Submit rating to database
  Future<void> submitRating(LandlordRating landlordData, String tenancyDocID) async {
    final DocumentReference ratingDocRef = _fireStore
        .collection('users')
        .doc(landlordData.landlordID)
        .collection('ratings')
        .doc();

    final DocumentReference landlordDocRef = _fireStore.collection('users').doc(landlordData.landlordID);
    final DocumentReference tenancyDocRef = _fireStore.collection('tenancies').doc(tenancyDocID);

    // Perform all operations within a single transaction
    await _fireStore.runTransaction((transaction) async {
      // Set operation: Save rating information in the database
      transaction.set(ratingDocRef, landlordData.toMap());
      transaction.update(tenancyDocRef, {
        'isRated': true,
      });
    });

    // Update rating average and count
    await _updateRating(landlordDocRef);
  }

  // Update rating function
  Future<void> _updateRating(DocumentReference landlordDocRef) async {

    final QuerySnapshot ratingSnapshot = await landlordDocRef.collection('ratings').get();

    // Calculate the average ratings
    double totalSupportRating = 0;
    double totalCommunicationRating = 0;
    double totalMaintenanceRating = 0;
    int ratingCount = ratingSnapshot.size;

    for (final DocumentSnapshot doc in ratingSnapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      totalSupportRating += (data['supportRating'] ?? 0) as double;
      totalCommunicationRating += (data['communicationRating'] ?? 0) as double;
      totalMaintenanceRating += (data['maintenanceRating'] ?? 0) as double;
    }

    final double averageSupportRating = double.parse((ratingCount > 0 ? totalSupportRating / ratingCount : 0).toStringAsFixed(2));
    final double averageCommunicationRating = double.parse((ratingCount > 0 ? totalCommunicationRating / ratingCount : 0).toStringAsFixed(2));
    final double averageMaintenanceRating = double.parse((ratingCount > 0 ? totalMaintenanceRating / ratingCount : 0).toStringAsFixed(2));
    final double overallRating = double.parse(((averageSupportRating + averageCommunicationRating + averageMaintenanceRating) / 3).toStringAsFixed(2));

    // Update the landlord document with the new rating average and count
    await landlordDocRef.update({
      'ratingCount': ratingCount,
      'ratingAverage': {
        'supportRating': averageSupportRating,
        'communicationRating': averageCommunicationRating,
        'maintenanceRating': averageMaintenanceRating,
        'overallRating': overallRating,
      }
    });
  }
}
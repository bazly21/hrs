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
      // Read the landlord document
      DocumentSnapshot landlordSnapshot = await transaction.get(landlordDocRef);

      // Get the current rating average and count from the landlord document
      Map<String, dynamic>? data = landlordSnapshot.data() as Map<String, dynamic>?;
      double currentRatingAverage = data?['ratingAverage']?.toDouble() ?? 0.0;
      int currentRatingCount = data?['ratingCount'] ?? 0;

      // Calculate the new rating average and count
      double newTotalRating = (currentRatingAverage * currentRatingCount) +
          landlordData.supportRating +
          landlordData.maintenanceRating +
          landlordData.communicationRating;
      int newRatingCount = currentRatingCount + 1;
      double newRatingAverage = double.parse((newTotalRating / (newRatingCount * 3)).toStringAsFixed(2));

      // Save rating information in database
      transaction.set(ratingDocRef, landlordData.toMap());
      transaction.update(tenancyDocRef, {
        'isRated': true,
      });

      // Update the landlord document with the new rating average and count
      transaction.update(landlordDocRef, {
        'ratingAverage': newRatingAverage,
        'ratingCount': newRatingCount,
      });
    });
  }

  
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/tenancy.dart';

class RentalService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> saveTenancyInfo(String propertyID, String tenantID, int duration, DateTime startDate, DateTime endDate) async {
    // Get a DocumentReference to a new tenancy under the specific property
    final DocumentReference tenancyDocRef = _fireStore.collection('tenancies').doc();
    // Get a DocumentReference to the specific property
    final DocumentReference propertyDocRef = _fireStore.collection('properties').doc(propertyID);

    // Create a new tenancy
    Tenancy newTenancy = Tenancy(
      propertyID: propertyID,
      tenantID: tenantID,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
    );

    await _fireStore.runTransaction((transaction) async {
      // Save tenancy information in database
      transaction.set(tenancyDocRef, newTenancy.toMap());

      // Update the property's status to rented
      transaction.update(propertyDocRef, {'status': 'rented'});
    });
  }

}
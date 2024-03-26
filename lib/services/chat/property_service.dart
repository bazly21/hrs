import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get property details
  Future<DocumentSnapshot> getPropertyDetails(String propertyID) async {
    return await _fireStore.collection('properties').doc(propertyID).get();
  }

  // Convert property data into a map
  Map<String, dynamic> propertyDataToMap(DocumentSnapshot propertyData) {
    return propertyData.data() as Map<String, dynamic>;
  }
}

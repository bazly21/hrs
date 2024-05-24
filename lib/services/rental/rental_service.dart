import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/tenancy.dart';

class RentalService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  static Future<void> saveTenancyInfo(
      {required String propertyID,
      required String tenantID,
      required String landlordID,
      required String applicationID,
      required int duration,
      required DateTime startDate,
      required DateTime endDate}) async {
    // Get a DocumentReference to a new tenancy under the specific property
    // Get a DocumentReference to the specific property
    final DocumentReference propertyDocRef =
        FirebaseFirestore.instance.collection('properties').doc(propertyID);
    final DocumentReference tenancyDocRef =
        propertyDocRef.collection('tenancies').doc();

    // Create a new tenancy
    Tenancy newTenancy = Tenancy(
      tenantID: tenantID,
      landlordID: landlordID,
      applicationID: applicationID,
      status: 'Active',
      duration: duration,
      startDate: startDate,
      endDate: endDate,
    );

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Save tenancy information in database
      transaction.set(tenancyDocRef, newTenancy.toMap());

      // Update the property's status to rented
      transaction.update(propertyDocRef, {'status': 'Rented'});
    });
  }

  Future<Map<String, dynamic>?> fetchTenancyInfo(String tenantID) async {
    try {
      // Get a QuerySnapshot of tenancies with matching tenantID
      final QuerySnapshot tenancySnapshot = await _fireStore
          .collectionGroup('tenancies')
          .where('tenantID', isEqualTo: tenantID)
          .where('status', isEqualTo: 'Active')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (tenancySnapshot.docs.isEmpty)
        return null; // Early return if no tenancy found

      final DocumentSnapshot tenancyDoc = tenancySnapshot.docs.first;

      final Map<String, dynamic>? tenancyData =
          tenancyDoc.data() as Map<String, dynamic>?;
      if (tenancyData == null)
        return null; // Early return if tenancy data is null

      final String propertyID = tenancyDoc.reference.parent.parent!.id;
      final DocumentSnapshot<Map<String, dynamic>> propertyDoc =
          await _fireStore.collection('properties').doc(propertyID).get();
      final Map<String, dynamic>? propertyData = propertyDoc.data();
      if (propertyData == null)
        return null; // Early return if property data is null

      final String landlordID = propertyData['landlordID'];
      final DocumentSnapshot<Map<String, dynamic>> landlordDoc =
          await _fireStore.collection('users').doc(landlordID).get();
      final Map<String, dynamic>? landlordData = landlordDoc.data();
      if (landlordData == null)
        return null; // Early return if landlord data is null

      // Construct the response map
      return {
        'propertyName': propertyData['name'],
        'propertyAddress': propertyData['address'],
        'propertyImageURL':
            propertyData['image']?[0] ?? 'https://via.placeholder.com/150',
        'landlordID': landlordID,
        'landlordName': landlordData['name'] ?? 'N/A',
        'landlordRatingCount': landlordData['ratingCount']?['landlord'] ?? 0,
        'landlordRatingAverage': (landlordData['ratingAverage']?['landlord']
                    ?["overallRating"] as num?)
                ?.toDouble() ??
            0.0,
        'tenancyDuration': tenancyData['duration'],
        'tenancyStartDate': tenancyData['startDate'],
        'tenancyEndDate': tenancyData['endDate'],
      };
    } catch (e) {
      print("Error: $e ");
      return null; // Return null in case of any errors
    }
  }

  static Future<Map<String, dynamic>?> landlordFetchTenancyInfo(
      String propertyID) async {
    final DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyID)
        .get();

    final Map<String, dynamic>? propertyData =
        propertyDoc.data() as Map<String, dynamic>?;

    if (propertyData == null || propertyData["status"] == "Available")
      return null;

    // Get a QuerySnapshot of tenancies with matching tenantID
    final QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyID)
        .collection('tenancies')
        .where('status', isEqualTo: 'Active')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (tenancySnapshot.docs.isEmpty)
      throw Exception("Tenancy data is not exist");

    final DocumentSnapshot tenancyDoc = tenancySnapshot.docs.first;
    final Map<String, dynamic> tenancyData =
        tenancyDoc.data() as Map<String, dynamic>;

    final String? tenantID = tenancyData['tenantID'];

    if (tenantID == null) throw Exception("Tenant ID is not exist");

    final DocumentSnapshot tenantDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(tenantID)
        .get();
    final Map<String, dynamic>? tenantData =
        tenantDoc.data() as Map<String, dynamic>?;

    if (tenantData == null) throw Exception("Tenant data is not exist");

    // Construct the response map
    return {
      'propertyName': propertyData['name'],
      'propertyAddress': propertyData['address'],
      'propertyImageURL':
          propertyData['image'][0] ?? 'https://via.placeholder.com/150',
      'tenantID': tenantID,
      'tenantName': tenantData['name'] ?? 'N/A',
      'tenantRatingCount': tenantData['ratingCount']?["tenant"] ?? 0,
      'tenantRatingAverage':
          (tenantData['ratingAverage']?["tenant"]?["overallRating"] as num?)
                  ?.toDouble() ??
              0.0,
      'tenancyDuration': tenancyData['duration'],
      'tenancyStartDate': tenancyData['startDate'],
      'tenancyEndDate': tenancyData['endDate'],
    };
  }
}

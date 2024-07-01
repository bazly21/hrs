import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/tenancy.dart';

class RentalService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  static Future<void> saveTenancyInfo({
    required String propertyID,
    required String tenantID,
    required String landlordID,
    required String applicationID,
    required int duration,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get a DocumentReference to a new tenancy under the specific property
    final DocumentReference propertyDocRef =
        FirebaseFirestore.instance.collection('properties').doc(propertyID);

    // Get a DocumentReference to the specific property
    final DocumentReference tenancyDocRef =
        propertyDocRef.collection('tenancies').doc();

    // Get a DocumentReference to the applicant information
    final DocumentReference applicantDocRef =
        FirebaseFirestore.instance.collection('users').doc(tenantID);

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

      // Update hasTenancy field in the applicant's document
      transaction.update(applicantDocRef, {'hasActiveTenancy': true});
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

      // Early return if no tenancy found
      if (tenancySnapshot.docs.isEmpty) {
        return null;
      }

      final DocumentSnapshot tenancyDoc = tenancySnapshot.docs.first;

      // Convert the tenancy document to a Map
      final tenancyData = tenancyDoc.data() as Map<String, dynamic>?;

      // Early return if tenancy data is null
      // or not exist
      if (tenancyData == null) {
        return null;
      }

      // Get the propertyID
      final String propertyID = tenancyDoc.reference.parent.parent!.id;

      // Fetch the property document
      final propertyDoc =
          await _fireStore.collection('properties').doc(propertyID).get();

      // Convert property document to a Map
      final propertyData = propertyDoc.data();

      // Early return if property data is null
      // or not exist
      if (propertyData == null) {
        return null;
      }

      // Get the landlordID from property data
      final String landlordID = propertyData['landlordID'];

      // Fetch the landlord document
      final landlordDoc =
          await _fireStore.collection('users').doc(landlordID).get();

      // Convert landlord document to a Map
      final landlordData = landlordDoc.data();

      // Early return if landlord data is null
      // or not exist
      if (landlordData == null) {
        return null;
      }

      // Construct the response map
      return {
        'propertyName': propertyData['name'],
        'propertyAddress': propertyData['address'],
        'propertyImageURL':
            propertyData['image']?[0] ?? 'https://via.placeholder.com/150',
        'landlordID': landlordID,
        'landlordName': landlordData['name'] ?? 'N/A',
        'landlordProfilePictureUrl': landlordData['profilePictureURL'],
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

    if (propertyData == null || propertyData["status"] == "Available") {
      return null;
    }

    // Get a QuerySnapshot of tenancies with matching tenantID
    final QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyID)
        .collection('tenancies')
        .where('status', isEqualTo: 'Active')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (tenancySnapshot.docs.isEmpty) {
      throw Exception("Tenancy data is not exist");
    }

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
      'tenantProfilePictureUrl':
          tenantData['profilePictureURL'] ?? 'https://via.placeholder.com/150',
      'tenancyDuration': tenancyData['duration'],
      'tenancyStartDate': tenancyData['startDate'],
      'tenancyEndDate': tenancyData['endDate'],
    };
  }
}

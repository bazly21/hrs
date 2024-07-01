import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrs/model/tenancy/landlord_ended_tenancy.dart';
import 'package:hrs/model/tenancy/tenant_ended_tenancy.dart';

class TenancyService {
  static Future<bool> checkUserTenancy(
    String propertyID,
    String applicantID,
  ) async {
    QuerySnapshot tenancySnapshots = await FirebaseFirestore.instance
        .collection("properties")
        .doc(propertyID)
        .collection("tenancies")
        .where("tenantID", isEqualTo: applicantID)
        .where("status", isEqualTo: "Active")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    // If tenancy snapshot is not exist
    // Meaning there is no tenancy for the user
    // So, the apply button will be enabled
    if (tenancySnapshots.docs.isEmpty) return true;

    // If tenancy snapshot is exist
    // Meaning there is a tenancy for the user
    // So, the apply button will be disabled
    return false;

    // If tenancy snapshot is exist
    // Meaning there is a tenancy for the user
    // DocumentSnapshot tenancyDoc = tenancySnapshots.docs.first;

    // if (tenancyDoc.data() == null) return false;

    // Map<String, dynamic> tenancyData =
    //     tenancyDoc.data() as Map<String, dynamic>;

    // // If tenancy has ended, return true
    // // Meaning the apply button will be enabled
    // if (tenancyData["status"] == "Ended") return true;

    // // If tenancy is still active, return false
    // // Meaning the apply button will be disabled
    // return false;
  }

  // Get landlord ended tenancies
  static Future<List<LandlordEndedTenancy>>
      fetchLandlordEndedTenancies() async {
    final String landlordID = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collectionGroup("tenancies")
        .where("landlordID", isEqualTo: landlordID)
        .where("status", isEqualTo: "Ended")
        .orderBy("createdAt", descending: true)
        .get();

    if (tenancySnapshot.docs.isEmpty) return [];

    final List<LandlordEndedTenancy> expiredTenancies =
        await Future.wait(tenancySnapshot.docs.map((tenancyDoc) async {
      final Map<String, dynamic>? tenancyData =
          tenancyDoc.data() as Map<String, dynamic>?;

      // Skip iteration if tenancy data is null
      if (tenancyData == null) return null;

      final String propertyID = tenancyDoc.reference.parent.parent!.id;
      final DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyID)
          .get();
      final Map<String, dynamic>? propertyData =
          propertyDoc.data() as Map<String, dynamic>?;

      if (propertyData == null) return null;

      final String tenantID = tenancyData['tenantID'];
      final DocumentSnapshot tenantDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tenantID)
          .get();
      final Map<String, dynamic>? tenantData =
          tenantDoc.data() as Map<String, dynamic>?;

      if (tenantData == null) return null;

      final Map<String, dynamic> data = {
        'propertyID': propertyID,
        'propertyName': propertyData['name'] ?? 'N/A',
        'propertyAddress': propertyData['address'] ?? 'N/A',
        'rentalPrice': propertyData['rent'] ?? 0.0,
        'propertyImageURL':
            propertyData['image']?[0] ?? 'https://via.placeholder.com/150',
        'tenantID': tenantID,
        'tenantName': tenantData['name'],
        'tenantImageURL': tenantData['profilePictureURL'],
        'tenantRatingCount': tenantData['ratingCount']?["tenant"] ?? 0,
        'tenantRatingAverage': tenantData['ratingAverage']?["tenant"]
                ?['overallRating'] as double? ??
            0.0,
        'tenancyDocID': tenancyDoc.id,
        'tenancyStatus': tenancyData['status'] ?? 'Unknown',
        'isRated': tenancyData['isRated']?["rateTenant"] ?? false,
      };

      final LandlordEndedTenancy landlordEndedTenancy =
          LandlordEndedTenancy.fromMap(data);

      return landlordEndedTenancy;
    })).then((list) => list.whereType<LandlordEndedTenancy>().toList());

    return expiredTenancies;
  }

  static Future<List<TenantEndedTenancy>> fetchTenantEndedTenancies() async {
    final String tenantID = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collectionGroup("tenancies")
        .where("tenantID", isEqualTo: tenantID)
        .where("status", isEqualTo: "Ended")
        .orderBy("createdAt", descending: true)
        .get();

    if (tenancySnapshot.docs.isEmpty) return [];

    final List<TenantEndedTenancy> expiredTenancies = await Future.wait(
      tenancySnapshot.docs.map((tenancyDoc) async {
        final Map<String, dynamic>? tenancyData =
            tenancyDoc.data() as Map<String, dynamic>?;

        // Skip iteration if tenancy data is null
        if (tenancyData == null) return null;

        final String propertyID = tenancyDoc.reference.parent.parent!.id;

        final DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
            .collection('properties')
            .doc(propertyID)
            .get();

        final Map<String, dynamic>? propertyData =
            propertyDoc.data() as Map<String, dynamic>?;

        if (propertyData == null) return null;

        final String landlordID = tenancyData['landlordID'];

        final DocumentSnapshot tenantDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(landlordID)
            .get();

        final Map<String, dynamic>? landlordData =
            tenantDoc.data() as Map<String, dynamic>?;

        if (landlordData == null) return null;

        final Map<String, dynamic> data = {
          'propertyID': propertyID,
          'propertyName': propertyData['name'] ?? 'N/A',
          'propertyAddress': propertyData['address'] ?? 'N/A',
          'rentalPrice': propertyData['rent'] ?? 0.0,
          'propertyImageURL':
              propertyData['image'][0] ?? 'https://via.placeholder.com/150',
          'landlordID': landlordID,
          'landlordName': landlordData['name'] ?? 'N/A',
          'landlordImageURL': landlordData['profilePictureURL'],
          'landlordRatingCount': landlordData['ratingCount']?["landlord"] ?? 0,
          'landlordRatingAverage': landlordData['ratingAverage']?["landlord"]
                  ?['overallRating'] as double? ??
              0.0,
          'tenancyDocID': tenancyDoc.id,
          'tenancyStatus': tenancyData['status'] ?? 'Unknown',
          'isRated': tenancyData['isRated']?["rateLandlord"] ?? false,
        };

        final TenantEndedTenancy tenantEndedTenancy =
            TenantEndedTenancy.fromMap(data);

        return tenantEndedTenancy;
      }).toList(),
    ).then((list) => list.whereType<TenantEndedTenancy>().toList());

    return expiredTenancies;
  }
}

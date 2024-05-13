import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrs/model/tenancy/landlord_ended_tenancy.dart';
import 'package:hrs/model/tenancy/tenant_ended_tenancy.dart';

class TenancyService {
  static Future<bool> checkUserTenancy(
      String propertyID, String applicantID) async {
    QuerySnapshot tenancySnapshots = await FirebaseFirestore.instance
        .collection("tenancies")
        .where("tenantID", isEqualTo: applicantID)
        .where("propertyID", isEqualTo: propertyID)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (tenancySnapshots.docs.isEmpty) return false;

    DocumentSnapshot tenancyDoc = tenancySnapshots.docs.first;

    if (tenancyDoc.data() == null) return false;

    Map<String, dynamic> tenancyData =
        tenancyDoc.data() as Map<String, dynamic>;

    if (tenancyData["status"] == "Active") return true;

    return false;
  }

  // Get landlord ended tenancies
  static Future<List<LandlordEndedTenancy>> fetchLandlordEndedTenancies() async {
    final String landlordID = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collection("tenancies")
        .where("landlordID", isEqualTo: landlordID)
        .where("status", isEqualTo: "Ended")
        .orderBy("createdAt", descending: true)
        .get();

    if (tenancySnapshot.docs.isEmpty) throw Exception("No tenancies found");

    final List<LandlordEndedTenancy> expiredTenancies = await Future.wait(
      tenancySnapshot.docs.map((tenancyDoc) async {
        final Map<String, dynamic>? tenancyData =
            tenancyDoc.data() as Map<String, dynamic>?;

        // Skip iteration if tenancy data is null
        if (tenancyData == null) return null;

        final String propertyID = tenancyData['propertyID'];

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
              propertyData['image'][0] ?? 'https://via.placeholder.com/150',
          'tenantID': tenantID,
          'tenantImageURL':
              (tenantData['image'] != null && tenantData['image'].isNotEmpty)
                  ? tenantData['image'][0]
                  : 'https://via.placeholder.com/150',
          'tenantRatingCount': tenantData['ratingCount']?["tenant"] ?? 0,
          'tenantRatingAverage':
              tenantData['ratingAverage']?["tenant"]?['overallRating'] as double? ?? 0.0,
          'tenancyDocID': tenancyDoc.id,
          'tenancyStatus': tenancyData['status'] ?? 'Unknown',
          'isRated': tenancyData['isRated']?["rateTenant"] ?? false,
        };

        final LandlordEndedTenancy landlordEndedTenancy =
            LandlordEndedTenancy.fromMap(data);

        return landlordEndedTenancy;
      }).toList(),
    ).then((list) => list
        .where((element) => element != null)
        .toList()
        .cast<LandlordEndedTenancy>());

    return expiredTenancies;
  }

  static Future<List<TenantEndedTenancy>> fetchTenantEndedTenancies() async {
    final String tenantID = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot tenancySnapshot = await FirebaseFirestore.instance
        .collection("tenancies")
        .where("tenantID", isEqualTo: tenantID)
        .where("status", isEqualTo: "Ended")
        .orderBy("createdAt", descending: true)
        .get();

    if (tenancySnapshot.docs.isEmpty) throw Exception("No tenancies found");

    final List<TenantEndedTenancy> expiredTenancies = await Future.wait(
      tenancySnapshot.docs.map((tenancyDoc) async {
        final Map<String, dynamic>? tenancyData =
            tenancyDoc.data() as Map<String, dynamic>?;

        // Skip iteration if tenancy data is null
        if (tenancyData == null) return null;

        final String propertyID = tenancyData['propertyID'];

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
          'landlordImageURL':
              (landlordData['image'] != null && landlordData['image'].isNotEmpty)
                  ? landlordData['image'][0]
                  : 'https://via.placeholder.com/150',
          'landlordRatingCount': landlordData['ratingCount']?["landlord"] ?? 0,
          'landlordRatingAverage':
              landlordData['ratingAverage']?["landlord"]?['overallRating'] as double? ?? 0.0,
          'tenancyDocID': tenancyDoc.id,
          'tenancyStatus': tenancyData['status'] ?? 'Unknown',
          'isRated': tenancyData['isRated']?["rateLandlord"] ?? false,
        };

        final TenantEndedTenancy tenantEndedTenancy =
            TenantEndedTenancy.fromMap(data);

        return tenantEndedTenancy;
      }).toList(),
    ).then((list) => list
        .where((element) => element != null)
        .toList()
        .cast<TenantEndedTenancy>());

    return expiredTenancies;
  }
}

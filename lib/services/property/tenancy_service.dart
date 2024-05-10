import 'package:cloud_firestore/cloud_firestore.dart';

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

    if(tenancySnapshots.docs.isEmpty) return false;

    DocumentSnapshot tenancyDoc = tenancySnapshots.docs.first;

    if (tenancyDoc.data() == null) return false;

    Map<String, dynamic> tenancyData = tenancyDoc.data() as Map<String, dynamic>;

    if (tenancyData["status"] == "Active") return true;

    return false;
  }
}
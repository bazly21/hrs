import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hrs/model/user/user.dart';

class UserService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get user details
  Future<UserProfile> getUserDetails(String userID, String role) async {
    DocumentSnapshot userSnapshot = await _fireStore.collection('users').doc(userID).get();
    Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

    if (userData == null) {
      throw Exception('User not found');
    }

    return UserProfile.fromMap(userData, role);
  }
}

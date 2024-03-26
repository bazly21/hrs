import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Get instance of auth and firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get user details
  Future<DocumentSnapshot> getUserDetails(String userID) async {
    return await _fireStore.collection('users').doc(userID).get();
  }
}

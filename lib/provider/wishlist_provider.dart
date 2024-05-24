import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider with ChangeNotifier {
  List<String> _wishlistPropertyIDs = [];

  List<String> get wishlistPropertyIDs => _wishlistPropertyIDs;

  Future<void> fetchWishlistPropertyIDs() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID != null) {
      final wishlistedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('wishlist')
          .get();

      _wishlistPropertyIDs =
          wishlistedSnapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    }
    else {
      _wishlistPropertyIDs = [];
      notifyListeners();
    }
    // return _wishlistPropertyIDs;
  }

  Future<void> addToWishlist(String propertyID) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('wishlist')
          .doc(propertyID)
          .set({});

      _wishlistPropertyIDs.add(propertyID);
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String propertyID) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('wishlist')
          .doc(propertyID)
          .delete();

      _wishlistPropertyIDs.remove(propertyID);
      notifyListeners();
    }
  }
}

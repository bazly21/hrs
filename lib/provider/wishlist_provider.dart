import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrs/model/property/property_details.dart';

class WishlistProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
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

  Future<List<PropertyFullDetails>> getWishlist() async {
    final user = _auth.currentUser;

    // Check if user is logged in
    // If user is not logged in, throw an exception
    if (user == null) {
      throw FirebaseAuthException(
          code: 'invalid-access', message: 'User is not logged in');
    }

    // Get the user's wishlist
    final wishlistSnapshots = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .get();

    // If the user's wishlist is empty,
    // return an empty list
    if (wishlistSnapshots.docs.isEmpty) {
      return [];
    }

    // Get the property IDs from the user's wishlist
    final propertyIds = wishlistSnapshots.docs.map((e) => e.id).toList();

    // Get the property details from the list of property IDs
    final propertyDetails = await Future.wait(
      propertyIds.map((propertyId) async {
        final propertySnapshot =
            await _firestore.collection('properties').doc(propertyId).get();

        final propertyData = propertySnapshot.data();

        // If the property data is not exist or contains no field, return null
        if (propertyData == null) {
          return null;
        }

        propertyData['propertyID'] = propertyId;

        return PropertyFullDetails.fromMapHalfDetails(propertyData);
      }),
    ).then((list) => list.whereType<PropertyFullDetails>().toList());

    return propertyDetails;
  }
}

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
    } else {
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

  Future<List<PropertyDetails>> getWishlist() async {
    final user = _auth.currentUser;

    // Check if user is logged in
    // If user is not logged in, throw an exception
    if (user == null) {
      throw FirebaseAuthException(
        code: 'invalid-access',
        message: 'User is not logged in',
      );
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
        // Fetch property snapshot from Firestore
        final propertySnapshot =
            await _firestore.collection('properties').doc(propertyId).get();

        final propertyData = propertySnapshot.data();

        // If the property data is not exist or contains no field,
        // or the landlordID field is not exist, return null
        if (propertyData == null || propertyData['landlordID'] == null) {
          return null;
        }

        // Add the propertyID to the propertyData map
        propertyData['propertyID'] = propertyId;

        // Then, fetch landlord snapshot from Firestore
        final landlordSnapshot = await _firestore
            .collection('users')
            .doc(propertyData['landlordID'])
            .get();

        // Convert snapshot to map
        final landlordData = landlordSnapshot.data();

        // If the landlord data is not exist or contains no field, return null
        if (landlordData == null) {
          return null;
        }

        // Return the PropertyDetails object
        return PropertyDetails(
          propertyID: propertyData['propertyID'],
          propertyName: propertyData['name'] ?? 'N/A',
          address: propertyData['address'] ?? 'N/A',
          rentalPrice: propertyData['rent'] ?? 0.0,
          bathrooms: propertyData['bathrooms'] ?? 0,
          bedrooms: propertyData['bedrooms'] ?? 0,
          size: propertyData['size'] ?? 0.0,
          image: List<String>.from(propertyData['image']),
          landlordID: landlordSnapshot.id,
          landlordName: landlordData['name'] ?? 'N/A',
          landlordProfilePic: landlordData['profilePictureURL'],
          landlordRatingCount: landlordData['ratingCount']?['landlord'] ?? 0,
          landlordOverallRating: landlordData['ratingAverage']?['landlord']?['overallRating'] ?? 0.0,
        );
      }),
    ).then((list) => list.whereType<PropertyDetails>().toList());

    return propertyDetails;
  }
}

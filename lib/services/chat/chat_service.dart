import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/model/message.dart';

class ChatService extends ChangeNotifier {
  // Get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage(String receiverID, String message) async {
    // Get current user info / sender info
    final String userID = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderID: userID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room ID from sender and receiver ID
    String chatRoomID = _getChatRoomID(userID, receiverID); 

    // Add new message to database
    await _fireStore
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userID, String receiverID) {
    // Construct chat room ID from sender and receiver ID
    String chatRoomID = _getChatRoomID(userID, receiverID); 

    // Get messages from database
    return _fireStore
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get chat room ID
  String _getChatRoomID(String userID, String receiverID) {
    List<String> ids = [userID, receiverID];
    ids.sort(); // Sort the IDs to ensure consistency
    return ids.join('_'); // Join the IDs with an underscore
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/model/chat_metadata.dart';
import 'package:hrs/model/message.dart';

class ChatService extends ChangeNotifier {
  // Get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage(String receiverID, String message) async {
    // Get current user info / sender info
    final String userID = _firebaseAuth.currentUser!.uid;
    // Get current timestamp
    final Timestamp timestamp = Timestamp.now();
    // Construct chat room ID from sender and receiver ID
    String chatRoomID = _getChatRoomID(userID, receiverID);
    // Check if chat room exists
    final bool ischatRoomExists =
        await _chatRoomExists(userID, receiverID, chatRoomID);
    // Reference to the chat document
    DocumentReference chatDocRef =
        _fireStore.collection('chats').doc(chatRoomID);

    // If chat room does not exist, create a new chat room
    if (!ischatRoomExists) {
      await _createChatRoom(userID, receiverID, chatRoomID);
    }

    // Create chat metadata
    ChatMetaData chatMetaData = ChatMetaData(
      lastMessage: message,
      lastMessageTimestamp: timestamp,
    );

    // Create a new message
    Message newMessage = Message(
      senderID: userID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Run a transaction to add message and update chat metadata
    await _fireStore.runTransaction((transaction) async {
      DocumentReference messageDocRef =
          chatDocRef.collection('messages').doc();
      transaction.set(messageDocRef, newMessage.toMap());
      transaction.set(
          chatDocRef, chatMetaData.toMap(), SetOptions(merge: true));
    });
  
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

  // Get chat list
  Stream<QuerySnapshot> getChatList(String userID) {
    // Get chat list from database
    return _fireStore
        .collection('chats')
        .where('users', arrayContains: userID)
        .snapshots();
  }

  // Check if chat room exists
  Future<bool> _chatRoomExists(
      String userID, String receiverID, chatRoomID) async {
    // Get chat room from database
    final DocumentSnapshot chatRoom =
        await _fireStore.collection('chats').doc(chatRoomID).get();

    return chatRoom.exists;
  }

  // Create chat room
  Future<void> _createChatRoom(
      String userID, String receiverID, String chatRoomID) async {
    // Create list of users in the chat room
    List<String> users = [userID, receiverID];

    // Add chat room to database
    await _fireStore.collection('chats').doc(chatRoomID).set({'users': users});
  }
}

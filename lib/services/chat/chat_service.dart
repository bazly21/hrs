import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/model/chat_list_item.dart';
import 'package:hrs/model/chat_metadata.dart';
import 'package:hrs/model/message.dart';

class ChatService extends ChangeNotifier {
  // Get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage(String receiverID, String message) async {
    final String userID = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    String chatRoomID = _getChatRoomID(userID, receiverID);
    DocumentReference chatDocRef =
        _fireStore.collection('chats').doc(chatRoomID);

    // Check if chat room exists
    final bool ischatRoomExists = await _chatRoomExists(chatDocRef);

    // If chat room does not exist, create a new chat room
    if (!ischatRoomExists) {
      await _createChatRoom(userID, receiverID, chatDocRef);
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
      DocumentReference messageDocRef = chatDocRef.collection('messages').doc();
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
  Stream<List<ChatListItem>> getChatList(String userID) {
    // Get chat list from database
    return _fireStore
        .collection('chats')
        .where('users', arrayContains: userID)
        .snapshots()
        .asyncMap((querySnapshot) async {
      // Get list of chat list items
      // by iterating through each chat room using map function
      final chatListItems =
          await Future.wait(querySnapshot.docs.map((doc) async {
        // Convert chat room data to map
        final chatData = doc.data();

        // Get list of users from users array
        final users = List<String>.from(chatData['users']);

        // Get receiverID from users array
        String receiverID = users.firstWhere((userId) => userId != userID);

        // Get last message time and content
        Timestamp lastMessageTime = chatData['lastMessageTimestamp'];
        String lastMessage = chatData['lastMessage'];

        // Get receiver's name from users collection
        final receiverSnapshot =
            await _fireStore.collection('users').doc(receiverID).get();

        // Convert receiverSnapshot to map
        final receiverData = receiverSnapshot.data();

        // Get receiver's name
        // and profile picture URL
        // from receiverData
        String receiverName = receiverData!['name'];
        String? receiverProfilePicUrl = receiverData['profilePictureURL'];

        // Create and return ChatListItem
        return ChatListItem(
          receiverID: receiverID,
          receiverName: receiverName,
          receiverProfilePicUrl: receiverProfilePicUrl,
          lastMessageTime: lastMessageTime,
          lastMessage: lastMessage,
        );
      }).toList());

      // Sort chat list items by latest message time
      chatListItems
          .sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!));

      return chatListItems;
    });
  }

  // Check if chat room exists
  Future<bool> _chatRoomExists(DocumentReference chatDocRef) async {
    // Get chat room from database
    final DocumentSnapshot chatRoom = await chatDocRef.get();

    return chatRoom.exists;
  }

  // Create chat room
  Future<void> _createChatRoom(
      String userID, String receiverID, DocumentReference chatDocRef) async {
    // Create list of users in the chat room
    List<String> users = [userID, receiverID];

    // Add chat room to database
    await chatDocRef.set({'users': users});
  }
}

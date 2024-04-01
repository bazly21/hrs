import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMetaData {
  final String lastMessage;
  final Timestamp lastMessageTimestamp;

  ChatMetaData({
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  // Convert a message object into a map
  Map<String, dynamic> toMap() {
    return {
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }
}

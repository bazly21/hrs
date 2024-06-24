import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem {
  final String? receiverID;
  final String? receiverName;
  final String? receiverProfilePicUrl;
  final String? lastMessage;
  final Timestamp? lastMessageTime;

  ChatListItem({
    this.receiverID,
    this.receiverName,
    this.receiverProfilePicUrl,
    this.lastMessageTime,
    this.lastMessage,
  });
}

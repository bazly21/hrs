import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListItem {
  final String chatID;
  final String receiverID;
  final String receiverName;
  final Timestamp lastMessageTime;
  final String lastMessage;

  ChatListItem({
    required this.chatID,
    required this.receiverID,
    required this.receiverName,
    required this.lastMessageTime,
    required this.lastMessage,
  });
}
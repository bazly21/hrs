import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_chatbubble.dart';
import 'package:hrs/services/chat/chat_service.dart'; // Ensure this import path matches your file structure

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverID,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Send message function
  void sendMessage() async {
    final String message = messageController.text.trim();
    if (message.isNotEmpty) {
      await chatService.sendMessage(widget.receiverID, message);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: widget.receiverName, hasImage: true),
      body: Column(
        children: [
          // ********* Chat Bubble (Start) ********* **Database Required**
          Expanded(
            child: _buildMessageList(),
          ),
          // ********* Chat Bubble (End) *********

          // ********* Chat Input Textfield and Send Button (Start) *********
          _messageTexfield(),
          // ********* Chat Input Textfield and Send Button (End) *********
        ],
      ),
    );
  }

  Container _messageTexfield() {
    return Container(
      height: 70.0,
      padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 16.0, top: 16.0),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
          color: Colors.white),
      child: Row(
        children: [
          // Chat Input Textfield
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                fillColor: const Color(0xFFececec),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.96),
                    borderSide: BorderSide.none),
                hintText: "Type a message",
                hintStyle: const TextStyle(
                    color: Color(0xFF858585),
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
              controller: messageController,
              style: const TextStyle(fontSize: 16),
              cursorColor: Colors.black54,
            ),
          ),

          // Send Button
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xFF765CF8),
            ),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getMessages(
          firebaseAuth.currentUser!.uid, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, 'Something went wrong. Please try again.');
          });
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _buildChatBubble(snapshot.data!.docs[index]);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  // Build chat bubble
  Widget _buildChatBubble(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Align the message to the right if it was sent by the current user
    // Align the message to the left if it was sent by the receiver
    bool isSentByUser = data['senderID'] == firebaseAuth.currentUser!.uid;

    return ChatBubble(message: data['message'], isSentByUser: isSentByUser);
  }
}

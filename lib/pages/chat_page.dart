import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_chatbubble.dart'; // Ensure this import path matches your file structure

class ChatPage extends StatelessWidget {
  final String chatRoomId;

  const ChatPage({
    super.key,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    // Dummy conversation data
    List<Map<String, dynamic>> messages = [
      {"text": "Hey, how's it going?", "isSentByUser": false, "isLastMessage": false},
      {"text": "Okay bro asfasfasfsafasf", "isSentByUser": true, "isLastMessage": false},
      {"text": "Sure, see you then!", "isSentByUser": false, "isLastMessage": true},
    ];

    // Check if the keyboard is visible
    // var keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom < 0.0;
    // double bottomPadding = keyboardIsOpen ? 16.0 : 8.0;

    return Scaffold(
      appBar: const CustomAppBar(text: "Abdul Hakim", hasImage: true),
      body: Column(
        children: [
          // ********* Chat Bubble (Start) ********* **Database Required**
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  message: message["text"],
                  isSentByUser: message["isSentByUser"],
                  isLastMessage: message["isLastMessage"],
                );
              },
            ),
          ),
          // ********* Chat Bubble (End) *********

          // ********* Chat Input Textfield and Send Button (Start) *********
          Container(
            height: 80,
            decoration: BoxDecoration( // Box shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Shadow color.
                  spreadRadius: 2,
                  blurRadius: 3, // Shadow blur radius.
                  offset: const Offset(0, 2), // Vertical offset for the shadow.
                ),
              ],
              color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  // Chat Input Textfield
                  Expanded(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFececec),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.96), 
                          borderSide: BorderSide.none
                        ),
                        hintText: "Type a message",
                        hintStyle: const TextStyle(color: Color(0xFF858585), fontWeight: FontWeight.normal, fontSize: 16),
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
                      color:  Color(0xFF765CF8),
                    ),
                    onPressed: () {
                      print("Sending message: ${messageController.text}");
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
          // ********* Chat Input Textfield and Send Button (End) *********
        ],
      ),
    );
  }
}

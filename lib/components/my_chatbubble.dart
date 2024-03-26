import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByUser,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSentByUser ? const Color(0xFF765CF8) : Colors.grey[300],
          borderRadius: isSentByUser
              ? borderRadius.subtract(const BorderRadius.only(bottomRight: Radius.circular(12)))
              : borderRadius.subtract(const BorderRadius.only(bottomLeft: Radius.circular(12))),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSentByUser ? Colors.white : Colors.black,
            fontSize: 16.0
          ),
        ),
      ),
    );
  }
}

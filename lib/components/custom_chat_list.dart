import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hrs/model/chat_list_item.dart';
import 'package:hrs/pages/chat_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomChatList extends StatefulWidget {
  const CustomChatList({
    super.key,
    required this.chatRoom,
  });

  final ChatListItem chatRoom;

  @override
  State<CustomChatList> createState() => _CustomChatListState();
}

class _CustomChatListState extends State<CustomChatList> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        // This empty setState call is used to trigger a rebuild
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final String receiverName = widget.chatRoom.receiverName;
    final String receiverID = widget.chatRoom.receiverID;
    final String lastMessage = widget.chatRoom.lastMessage;
    final String lastMessageTimeAgo = timeago.format(widget.chatRoom.lastMessageTime.toDate());

    return ListTile(
      leading: const CircleAvatar(
        backgroundImage:
            NetworkImage('https://via.placeholder.com/150'), // Example URL
        backgroundColor:
            Colors.transparent, // Make background transparent if using image
      ),
      title: Text(
        receiverName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(lastMessage),
      trailing: Text(
        lastMessageTimeAgo,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // Go to chat page
          NavigationUtils.pushPageWithSlideLeftAnimation(
            context,
            ChatPage(
              receiverID: receiverID,
              receiverName: receiverName,
            ),
          );
      }
    );
  }
}
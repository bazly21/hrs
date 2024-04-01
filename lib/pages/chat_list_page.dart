import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/services/chat/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: "Search chat",
        appBarType: "Search",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: StreamBuilder(
          stream: chatService.getChatList(firebaseAuth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load chat rooms. Please try again.'),
                  ),
                );
              });
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  double indentValue = 40.0 + 16.0 * 2;

                  return Column(
                    children: <Widget>[
                      _buildChatList(snapshot.data!.docs[index]),
                      Divider(indent: indentValue), // Indent the divider to start after the profile image
                    ],
                  );
                },
              );
            }

            // If no chat rooms found
            return const Center(
              child: Text('No chat rooms found.'),
            );
          },
        ),
      ),
    );
  }

  ListTile _buildChatList(DocumentSnapshot chatRoom) {
    // Inside your build method or a function
    final Timestamp lastMessageTimestamp = chatRoom['lastMessageTimestamp'];
    final DateTime lastMessageDateTime = lastMessageTimestamp.toDate();

    // Convert DateTime to a formatted string (e.g., 5 min ago)
    final String lastMessageTimeAgo = timeago.format(lastMessageDateTime);

    return ListTile(
      leading: const CircleAvatar(
        backgroundImage:
            NetworkImage('https://via.placeholder.com/150'), // Example URL
        backgroundColor:
            Colors.transparent, // Make background transparent if using image
      ),
      title: const Text(
        "Chat Room Name", 
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(chatRoom['lastMessage']),
      trailing: Text(
        lastMessageTimeAgo,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // Go to chat page
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChatPage(
        //       chatRoomId: chatRoom['id'],
        //     ),
        //   )
        // );
      },
    );
  }


}

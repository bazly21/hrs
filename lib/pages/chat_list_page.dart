import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_chat_list.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/services/chat/chat_service.dart';


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
      appBar: const MyAppBar(
        text: "Search chat",
        appBarType: "Search",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: StreamBuilder(
          stream: chatService.getChatList(firebaseAuth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Failed to load chat rooms. Please try again.'),
                  ),
                );
              });
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return CustomChatList(chatRoom: snapshot.data![index]);
                },
                separatorBuilder: (context, index) {
                  double indentValue = 40.0 + 16.0 * 2;
                  return Divider(
                    // Indent the divider to start after the profile image
                    indent: indentValue
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
}



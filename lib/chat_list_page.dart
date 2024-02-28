import 'package:flutter/material.dart';
import 'package:hrs/chat_page.dart';
import 'package:hrs/components/my_appbar.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  // Dummy Chat Data
  final List<Map<String, dynamic>> chatRooms = [
    {
      'id': '1',
      'name': 'Abdul Hakim',
      'lastMessage': 'That works for me. See you then!',
      'time': '5 min ago',
    },
    {
      'id': '2',
      'name': 'Dart Enthusiasts',
      'lastMessage': 'Dart is awesome!',
      'time': '10 min ago',
    },
    // Add more chat rooms as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Search chat", appBarType: "Search",),
      //const MyAppBar(text: "Search chat", appBarContent: "Search"),
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            double indentValue = 40.0 + 16.0 * 2; // Avatar diameter + padding on both sides
        
            return Column(
              children: <Widget>[      
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Example URL
                    backgroundColor: Colors.transparent, // Make background transparent if using image
                  ),
                  title: Text(
                    chatRoom['name'], 
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(chatRoom['lastMessage']),
                  trailing: Text(
                    chatRoom['time'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // Go to chat page
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatRoomId: chatRoom['id'],
                        ),
                      )
                    );
                  },
                ),
                Divider(indent: indentValue), // Indent the divider to start after the profile image
              ],
            );
          },
        ),
      ),
    );
  }
} 
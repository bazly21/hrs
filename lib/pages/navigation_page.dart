import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/pages/chat_list_page.dart';
import 'package:hrs/pages/notification_page.dart';
import 'package:hrs/pages/profile_page_login.dart';
import 'package:hrs/pages/profile_page_no_login.dart';
import 'package:hrs/pages/rental_details_page.dart';
import 'package:hrs/pages/rental_list_page.dart';
import 'package:hrs/components/my_bottomnavigationbar.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}

class _NavigationPage extends State<NavigationPage> {
  
  int _selectedIndex = 0; // Assuming Home is the central item

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Determine the current user's authentication state
          final User? user = snapshot.data;

          // Define pages based on user's authentication state
          final List<Widget> pages = [
            const RentalListPage(),
            ChatListPage(),
            const RentalDetailsPage(),
            const NotificationPage(),
            user != null ? const ProfilePage() : const ProfilePageNoAccount(),
          ];

          return IndexedStack(
            index: _selectedIndex,
            children: pages,
          );
        },
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

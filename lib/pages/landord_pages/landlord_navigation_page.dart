import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_bottomnavigationbar.dart';

class LandlordNavigationPage extends StatefulWidget {
  const LandlordNavigationPage({super.key});

  @override
  State<LandlordNavigationPage> createState() => _LandlordNavigationPageState();
}

class _LandlordNavigationPageState extends State<LandlordNavigationPage> {
  int _selectedIndex = 0; // Assuming Home is the central item

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Text("Test"),
      
      // StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     // Determine the current user's authentication state
      //     final User? user = snapshot.data;

      //     // Define pages based on user's authentication state
      //     final List<Widget> pages = [
      //       const RentalListPage(),
      //       ChatListPage(),
      //       const RentalDetailsPage(),
      //       const NotificationPage(),
      //       user != null ? const ProfilePage() : const ProfilePageNoAccount(),
      //     ];

      //     return IndexedStack(
      //       index: _selectedIndex,
      //       children: pages,
      //     );
      //   },
      // ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_bottomnavigationbar.dart';
import 'package:hrs/pages/chat_list_page.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details.dart';
import 'package:hrs/pages/landord_pages/landlord_property_list.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/notification_page.dart';
import 'package:hrs/pages/profile_page_login.dart';
import 'package:hrs/pages/rental_details_page.dart';

class LandlordNavigationPage extends StatefulWidget {
  const LandlordNavigationPage({super.key});

  @override
  State<LandlordNavigationPage> createState() => _LandlordNavigationPageState();
}

class _LandlordNavigationPageState extends State<LandlordNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // StreamBuilder is used to determine screen content
    // based on the login status of the landlord
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          // user = null;

          // If user is logged in
          if (user != null) {
            final String uid = user.uid;

            final List<Widget> pages = [
              LandlordPropertyListPage(uid: uid),
              ChatListPage(),
              const RentalDetailsPage(),
              const NotificationPage(),
              const ProfilePage(),
            ];
            
            return Scaffold(  
              body: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
              bottomNavigationBar: MyBottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            );
          }
          else{
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const NavigationPage(),
              ));
            });

            // Return a placeholder or loading indicator while waiting for navigation
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If user is not logged in
          // return const NavigationPage();
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

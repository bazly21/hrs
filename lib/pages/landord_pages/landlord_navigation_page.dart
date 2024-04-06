import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/landlord_navigation_bar.dart';
import 'package:hrs/pages/chat_list_page.dart';
import 'package:hrs/pages/landord_pages/landlord_add_property_page.dart';
import 'package:hrs/pages/landord_pages/landlord_property_list.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/notification_page.dart';
import 'package:hrs/pages/profile_page_login.dart';

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
            
            final List<Widget> pages = [
              const LandlordPropertyListPage(),
              const ChatListPage(),
              // Placeholder for AddPropertyPage
              Container(),
              const NotificationPage(),
              const ProfilePage(),
            ];
            
            return Scaffold(  
              body: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
              bottomNavigationBar: LandlordNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  if (index == 2) {
                    // Navigate to the AddPropertyPage without showing bottom navigation bar
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPropertyPage()));
                  } else {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
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

        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

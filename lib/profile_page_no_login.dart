import 'package:flutter/material.dart';
import 'package:hrs/components/my_profilemenu.dart';

class ProfilePageNoAccount extends StatelessWidget {
  const ProfilePageNoAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Example URL
                  backgroundColor: Colors.transparent, // Make background transparent if using image
                ),

                // Add space between elements
                SizedBox(height: 25.0),

                Divider(),

                // Add space between elements
                SizedBox(height: 20.0),

                ProfileMenu(text: "Settings", icon: Icons.settings),

                // Add space between elements
                SizedBox(height: 20.0),

                ProfileMenu(text: "Login", icon: Icons.login),

                // Add space between elements
                SizedBox(height: 20.0),

                Divider(),

                // Add space between elements
                SizedBox(height: 20.0),

                ProfileMenu(text: "Login as Landlord", icon: Icons.login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
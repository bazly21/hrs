import 'package:flutter/material.dart';
import 'package:hrs/components/my_profilemenu.dart';
import 'package:hrs/components/my_starrating.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Picture
                const CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Example URL
                  backgroundColor: Colors.transparent, // Make background transparent if using image
                ),

                // Add space between elements
                const SizedBox(height: 14),

                // Profile Name
                const Text(
                  "Abdul Hakim",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24
                  ),
                ),

                // Add space between elements
                const SizedBox(height: 3.0),

                // Rating Icon
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const StarRating(rating: 5.0),

                      // Expand More Button
                      InkWell(
                        onTap: () {
                          // Handle tap
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3.0), // Set your desired padding
                          child: const Icon(Icons.expand_more), // Replace with your icon
                        ),
                      ),                     
                    ],
                  ),              
                ),

                // Add space between elements
                const SizedBox(height: 3.0),

                // Number of Reviews 
                const Text(
                  "(3 reviews)",
                  style: TextStyle(
                    color: Color(0xFF7D7F88),
                    fontSize: 16.0,
                  ),
                ),

                // Add space between elements
                const SizedBox(height: 25.0),

                const Divider(),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Personal Details", icon: Icons.person),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Wishlist", icon: Icons.favorite_rounded),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Rental History", icon: Icons.wallet),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Settings", icon: Icons.settings),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Logout", icon: Icons.logout),

                // Add space between elements
                const SizedBox(height: 20.0),

                const Divider(),

                // Add space between elements
                const SizedBox(height: 20.0),

                const ProfileMenu(text: "Login as Landlord", icon: Icons.login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
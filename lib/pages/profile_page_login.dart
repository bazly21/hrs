import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_profilemenu.dart';
import 'package:hrs/components/my_starrating.dart';
import 'package:hrs/pages/landord_pages/landlord_rental_history_list.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/rental_history_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/user_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  late Future<DocumentSnapshot> _userDetails;
  String? _role;

  @override
  void initState() {
    super.initState();
    _userDetails =
        _userService.getUserDetails(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    _role = context.read<AuthService>().userRole;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
          child: FutureBuilder<DocumentSnapshot>(
              future: _userDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  // Show error message through snackbar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${snapshot.error}"),
                      ),
                    );
                  });
                } else if (!snapshot.hasData || snapshot.data!.exists) {
                  return _buildProfile(context, snapshot.data!);
                }

                return const Center(
                  child: Text("No data found"),
                );
              }),
        ),
      ),
    );
  }

  Column _buildProfile(BuildContext context, DocumentSnapshot profile) {
    Map<String, dynamic>? profileData = profile.data() as Map<String, dynamic>?;
    String name = profileData?['name'] ?? 'N/A';
    int ratingCount = profileData?['ratingCount'] ?? 0;
    double ratingAverage =
        profileData?['ratingAverage']?['overallRating'] ?? 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Profile Picture
        const CircleAvatar(
          radius: 50.0,
          backgroundImage:
              NetworkImage('https://via.placeholder.com/150'), // Example URL
          backgroundColor:
              Colors.transparent, // Make background transparent if using image
        ),

        // Add space between elements
        const SizedBox(height: 14),

        // Profile Name
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),

        // Add space between elements
        const SizedBox(height: 3.0),

        // Rating Icon
        if (ratingCount != 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                StarRating(rating: ratingAverage),

                // Expand More Button
                InkWell(
                  onTap: () {
                    // Handle tap
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.all(3.0), // Set your desired padding
                    child:
                        const Icon(Icons.expand_more), // Replace with your icon
                  ),
                ),
              ],
            ),
          ),

        // Add space between elements
        if (ratingCount != 0) const SizedBox(height: 3.0),

        // Number of Reviews
        Text(
          ratingCount != 0 ? "($ratingCount reviews)" : "No reviews yet",
          style: const TextStyle(
            color: Color(0xFF7D7F88),
            fontSize: 16.0,
          ),
        ),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

        const Divider(),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

        const ProfileMenu(text: "Personal Details", icon: Icons.person),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

        const ProfileMenu(text: "Wishlist", icon: Icons.favorite_rounded),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

        ProfileMenu(
            text: "Rental History",
            icon: Icons.wallet,
            onPressed: () {
              // Navigate to Rental History Page
              if (_role == "Tenant") {
                NavigationUtils.pushPage(
                  context,
                  const RentalHistoryPage(),
                  SlideDirection.left,
                );
              }
              else if (_role == "Landlord") {
                // Navigate to Landlord Rental History Page
                NavigationUtils.pushPage(
                  context,
                  const LandlordRentalHistoryList(),
                  SlideDirection.left,
                );
              }
            }),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

        const ProfileMenu(text: "Settings", icon: Icons.settings),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

        ProfileMenu(
          text: "Logout",
          icon: Icons.logout,
          onPressed: () => showLogoutConfirmationDialog(context),
        ),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

        const Divider(),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),

        ProfileMenu(
          text: "Login as Landlord",
          icon: Icons.login,
          onPressed: () => NavigationUtils.pushPage(
            context,
            const LoginPage(role: "Landlord"),
            SlideDirection.left,
          ),
        ),
      ],
    );
  }

  // Function to show confirmation dialog before logging out
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the logout operation
                // FirebaseAuth.instance.signOut().then((value) {
                //   Navigator.of(context).pop(); // Dismiss the dialog
                // });
                context
                    .read<AuthService>()
                    .signOut()
                    .then((_) => Navigator.of(context).pop());
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_rating_bar.dart';
import 'package:hrs/components/my_profilemenu.dart';
import 'package:hrs/model/user/user.dart';
import 'package:hrs/pages/accout_page.dart';
import 'package:hrs/pages/landord_pages/landlord_rental_history_list.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/rental_history_page.dart';
import 'package:hrs/pages/wishlist_list_page.dart';
import 'package:hrs/provider/refresh_provider.dart';
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
  late Future<UserProfile> _userDetails;
  String? _role;

  @override
  void initState() {
    super.initState();
    _role = context.read<AuthService>().userRole;
    _userDetails = _userService.getUserDetails(
        FirebaseAuth.instance.currentUser!.uid, _role!);
  }

  @override
  Widget build(BuildContext context) {
    bool profileRefresh = context.watch<RefreshProvider>().profileRefresh;

    if (profileRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshProfile();
        if (context.mounted) {
          context.read<RefreshProvider>().profileRefresh = false;
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
          child: FutureBuilder<UserProfile>(
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
                        duration: const Duration(seconds: 3),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  });
                } else if (snapshot.hasData) {
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

  Column _buildProfile(BuildContext context, UserProfile userProfile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Profile Picture
        CustomCircleAvatar(
          imageURL: userProfile.profilePictureURL,
          name: userProfile.name!,
          radius: 50.0,
        ),

        // Add space between elements
        const SizedBox(height: 14),

        // Profile Name
        Text(
          userProfile.name!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),

        // Add space between elements
        const SizedBox(height: 3.0),

        // Rating Icon
        if (userProfile.ratingCount != 0) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomRatingBar(
                  rating: userProfile.overallRating!,
                  itemSize: 21.0,
                ),

                // Expand More Button
                InkWell(
                  onTap: () {
                    // Handle tap
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    child: const Icon(Icons.expand_more),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3.0)
        ],

        // Number of Reviews
        Text(
          userProfile.ratingCount != 0
              ? "(${userProfile.ratingCount} reviews)"
              : "No reviews yet",
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

        ProfileMenu(
            text: "Account",
            icon: Icons.person,
            onPressed: () {
              // Navigate to Edit Profile Page
              NavigationUtils.pushPage(
                context,
                AccountPage(
                  userProfile: userProfile,
                ),
                SlideDirection.left,
              ).then((message) {
                if (message != null) {
                  // Show snackbar message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              });
            }),

        // Add space between elements
        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

        ProfileMenu(
            text: "Wishlist",
            icon: Icons.favorite_rounded,
            onPressed: () {
              // Navigate to Wishlist Page
              NavigationUtils.pushPage(
                context,
                const WishlistListPage(),
                SlideDirection.left,
              );
            }),

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
              } else if (_role == "Landlord") {
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
                context.read<AuthService>().signOut().then((_) {
                  context.read<RefreshProvider>().setRefresh(true);
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  Future<void> refreshProfile() async {
    await _userService
        .getUserDetails(FirebaseAuth.instance.currentUser!.uid, _role!)
        .then((newData) {
      setState(() {
        _userDetails = Future.value(newData);
      });
    });
  }
}

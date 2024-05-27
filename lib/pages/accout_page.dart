import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/my_profilemenu.dart';
import 'package:hrs/model/user/user.dart';
import 'package:hrs/pages/edit_profile_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Account"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Navigate to Edit Profile Page
            ProfileMenu(
                text: "Edit Profile",
                icon: Icons.person,
                onPressed: (() => NavigationUtils.pushPage(
                    context,
                    EditProfilePage(userProfile: userProfile),
                    SlideDirection.left).then((message) => {
                      if (message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 3),
                          ),
                        )
                      }
                    }))),

            // Add space between elements
            const SizedBox(height: 16),

            const ProfileMenu(text: "Change Phone Number", icon: Icons.numbers),
          ],
        ),
      ),
    );
  }
}
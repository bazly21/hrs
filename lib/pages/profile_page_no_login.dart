import 'package:flutter/material.dart';
import 'package:hrs/components/my_profilemenu.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class ProfilePageNoAccount extends StatelessWidget {
  const ProfilePageNoAccount({super.key});

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
                  backgroundImage: AssetImage("images/blank_profile_picture.png"),
                ),

                // Add space between elements
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                const Divider(),

                // Add space between elements
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                const ProfileMenu(text: "Settings", icon: Icons.settings),

                // Add space between elements
                SizedBox(height: MediaQuery.of(context).size.height * 0.017),

                ProfileMenu(
                  text: "Login",
                  icon: Icons.login,
                  onPressed: () => NavigationUtils.pushPage(
                      context, const LoginPage(role: "Tenant"), SlideDirection.left),
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
                      context, const LoginPage(role: "Landlord"), SlideDirection.left)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

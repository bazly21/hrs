import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/pages/chat_page.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/view_profile_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class UserDetailsSection extends StatelessWidget {
  const UserDetailsSection({
    super.key,
    required this.userName,
    required this.rating,
    required this.ratingCount,
    required this.userID,
    this.position = "Property Owner",
    this.textButton = "Contact Owner",
    this.role = "Landlord",
    this.imageUrl,
  });

  final String userName;
  final String role;
  final String userID;
  final String position;
  final String textButton;
  final String? imageUrl;
  final int ratingCount;
  final double rating;

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    bool isLoggedin = FirebaseAuth.instance.currentUser != null;

    return Row(
      children: [
        // Profile picture **Database Required**
        InkWell(
          onTap: () {
            NavigationUtils.pushPage(
              context,
              ProfileViewPage(
                userID: userID,
                role: role,
              ),
              SlideDirection.left,
            );
          },
          child: CustomCircleAvatar(
            imageURL: imageUrl,
            name: userName,
            radius: 21.0,
            fontSize: 15,
          ),
        ),

        // Add space between elements
        const SizedBox(width: 10),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Landlord's Name **Database Required**
            Text(
              userName,
              style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 16.0),
            ),

            // Add space between elements
            const SizedBox(height: 1),

            // Title
            Text(
              position,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF7D7F88),
                fontSize: 14.0,
              ),
            ),

            // Add space between elements
            const SizedBox(height: 1),

            // Landlord's Overall Rating
            _buildLandlordRating(),
          ],
        ),

        // Add space between elements
        const Spacer(),

        ElevatedButton(
          onPressed: () {
            // If user is logged in, navigate to chat page
            // Else, show a snackbar to prompt user to log in
            if (isLoggedin) {
              NavigationUtils.pushPage(
                context,
                ChatPage(
                  receiverID: userID,
                  receiverName: userName,
                  receiverProfilePicUrl: imageUrl,
                ),
                SlideDirection.left,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Please log in to chat with the owner"),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: "Log In",
                    onPressed: () {
                      NavigationUtils.pushPage(
                        context,
                        const LoginPage(role: "Tenant"),
                        SlideDirection.left,
                      );
                    },
                  ),
                ),
              );
            }
          },
          style: ButtonStyle(
            fixedSize: const MaterialStatePropertyAll(Size.fromHeight(42)),
            elevation: const MaterialStatePropertyAll(0),
            backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.96), // Set corner radius
                  side: const BorderSide(color: Color(0xFFA59B9B))),
            ),
          ),
          child: Text(
            textButton,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildLandlordRating() {
    // If there is no rating
    if (ratingCount == 0 && rating == 0.0) {
      return const Text(
        "No reviews yet",
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(0xFF7D7F88),
            fontSize: 14.0),
      );
    }
    // If there is a rating
    else {
      return Row(
        children: [
          // Star icon
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 18.0,
          ),

          // Add space between elements
          const SizedBox(width: 3),

          // Rating value
          RichText(
            text: TextSpan(
              // Default text style
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(text: "$rating"),
                TextSpan(
                  text: ratingCount > 1
                      ? " ($ratingCount Reviews)"
                      : " ($ratingCount Review)",
                  style: const TextStyle(
                    color: Color(0xFF7D7F88),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}

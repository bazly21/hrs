import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/pages/chat_page.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class UserDetails extends StatelessWidget {
  final String landlordName, landlordID, position, textButton;
  final String? image;
  final int numReview;
  final double rating;
  final VoidCallback? onPressed;

  final User? user = FirebaseAuth.instance.currentUser;

  UserDetails(
      {super.key,
      required this.landlordName,
      this.position = "Property Owner",
      required this.rating,
      required this.numReview,
      this.image,
      this.textButton = "Chat with owner",
      this.onPressed,
      required this.landlordID});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile picture **Database Required**
        InkWell(
          onTap: onPressed ?? () {}, // Go to landlord profile page
          child: ClipOval(
            child: Image.network(
              image ??
                  'https://via.placeholder.com/150', // Replace with your profile picture URL
              width: 42, // Width for the profile picture
              height: 42, // Height for the profile picture
              fit: BoxFit
                  .cover, // Cover the bounds of the parent widget (ClipOval)
            ),
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
              landlordName,
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
                  fontSize: 14.0),
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
            if (user != null) {
              NavigationUtils.pushPage(
                  context,
                  ChatPage(receiverID: landlordID, receiverName: landlordName),
                  SlideDirection.left);
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please log in to chat with the owner")),
              );

              NavigationUtils.pushPage(
                context,
                LoginPage(),
                SlideDirection.left,
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
    if (numReview == 0 && rating == 0.0) {
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
            color: Color(0xFFFFBF75),
            size: 21.0,
          ),

          // Add space between elements
          const SizedBox(width: 5),

          // Rating value
          RichText(
              text: TextSpan(
                  // Default text style
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                TextSpan(text: "$rating"),
                TextSpan(
                    text: numReview > 1
                        ? " ($numReview Reviews)"
                        : " ($numReview Review)",
                    style: const TextStyle(color: Color(0xFF7D7F88)))
              ])),
        ],
      );
    }
  }
}

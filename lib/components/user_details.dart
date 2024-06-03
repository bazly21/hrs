import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/pages/chat_page.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/view_profile_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:provider/provider.dart';

class UserDetailsSection extends StatelessWidget {
  const UserDetailsSection({
    super.key,
    required String userName,
    required double rating,
    required int ratingCount,
    required String userID,
    String position = "Property Owner",
    String textButton = "Chat with owner",
    String role = "Landlord",
    String? imageUrl,
  })  : _userName = userName,
        _role = role,
        _position = position,
        _rating = rating,
        _ratingCount = ratingCount,
        _imageUrl = imageUrl,
        _textButton = textButton,
        _userID = userID;

  final String _userName;
  final String _role;
  final String _userID;
  final String _position;
  final String _textButton;
  final String? _imageUrl;
  final int _ratingCount;
  final double _rating;

  @override
  Widget build(BuildContext context) {
    String? role = context.watch<AuthService>().userRole;

    return Row(
      children: [
        // Profile picture **Database Required**
        InkWell(
          onTap: () {
            NavigationUtils.pushPage(
                context,
                ProfileViewPage(userID: _userID, role: _role),
                SlideDirection.left);
          },
          child: CustomCircleAvatar(
              imageURL: _imageUrl, name: _userName, radius: 21.0, fontSize: 15),
        ),

        // Add space between elements
        const SizedBox(width: 10),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Landlord's Name **Database Required**
            Text(
              _userName,
              style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 16.0),
            ),

            // Add space between elements
            const SizedBox(height: 1),

            // Title
            Text(
              _position,
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
            if (role != null) {
              NavigationUtils.pushPage(
                  context,
                  ChatPage(receiverID: _userID, receiverName: _userName),
                  SlideDirection.left);
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
            _textButton,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildLandlordRating() {
    // If there is no rating
    if (_ratingCount == 0 && _rating == 0.0) {
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
                TextSpan(text: "$_rating"),
                TextSpan(
                    text: _ratingCount > 1
                        ? " ($_ratingCount Reviews)"
                        : " ($_ratingCount Review)",
                    style: const TextStyle(color: Color(0xFF7D7F88)))
              ])),
        ],
      );
    }
  }
}

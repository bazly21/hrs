import 'package:flutter/material.dart';
import 'package:hrs/components/custom_rating.dart';
import 'package:hrs/components/my_appbar.dart';

class ProfileViewPage extends StatelessWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(text: "Abdul Hakim's Profile"),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              const Center(
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Example URL
                  backgroundColor: Colors
                      .transparent, // Make background transparent if using image
                ),
              ),

              // Add space between elements
              SizedBox(height: screenSize.height * 0.015),

              // Profile Name
              const Center(
                child: Text(
                  "Abdul Hakim",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                ),
              ),

              // Add space between elements
              SizedBox(height: screenSize.height * 0.015),

              const Divider(),

              // Add space between elements
              SizedBox(height: screenSize.height * 0.02),

              const CustomRating(
                numReview: 1,
                rating1: 5.0,
                rating2: 5.0,
                rating3: 5.0,
                hasTitle: true,
              ),

              // Add space between elements
              SizedBox(height: screenSize.height * 0.02),

              const Divider(),

              // Add space between elements
              SizedBox(height: screenSize.height * 0.02),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Example URL
                    backgroundColor: Colors
                        .transparent, // Make background transparent if using image
                  ),

                  // Add space between elements
                  SizedBox(width: screenSize.width * 0.04),

                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Amelia Shah",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 17),
                            ),
                          ],
                        ),

                        // Add space between elements
                        SizedBox(height: screenSize.height * 0.003),

                        const CustomRating(
                          numReview: 1,
                          rating1: 5.0,
                          rating2: 5.0,
                          rating3: 5.0,
                          spacing: 0.002,
                          fontSize: 16.0,
                          iconSize: 19.0,
                        ),

                        // Add space between elements
                        SizedBox(height: screenSize.height * 0.008),

                        const Text(
                          "The owner is exceptional! He’s very responsive, maintains the property well, and is always fair and respectful. Highly recommended.",
                          style: TextStyle(fontSize: 16.0),
                        ),

                        // Add space between elements
                        SizedBox(height: screenSize.height * 0.002),

                        const Row(
                          children: [
                            Text(
                              "01-01-2023  07:22",
                              style: TextStyle(
                                  fontSize: 14.0, color: Color(0xFF7D7F88)),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

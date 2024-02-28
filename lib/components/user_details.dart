import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final String name, position, textButton;
  final String? image;
  final int numReview;
  final double rating;
  final VoidCallback? onPressed;

  const UserDetails({
    super.key, 
    required this.name, 
    this.position = "Property Owner", 
    required this.rating, 
    required this.numReview, 
    this.image, 
    this.textButton = "Chat with owner", 
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile picture **Database Required**
        InkWell(
          onTap: onPressed ?? () {}, // Go to landlord profile page
          child: ClipOval(
            child: Image.network(
              image ?? 'https://via.placeholder.com/150', // Replace with your profile picture URL
              width:
                  42, // Width for the profile picture
              height:
                  42, // Height for the profile picture
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
              name,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16.0
              ),
            ),

            // Add space between elements
            const SizedBox(height: 1), 

            // Title
            Text(
              position,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF7D7F88),
                fontSize: 14.0
              ),
            ),

            // Add space between elements
            const SizedBox(height: 1), 

            // Landlord's Overall Rating **Database Required**
            Row(
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
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14
                    ),
                                        
                    // Text **Database Required**
                    children: [
                      rating > 0 ? TextSpan(text: "$rating") : const TextSpan(text: "No Rating"),

                      if(rating > 0)
                        TextSpan(
                          text: numReview > 1 ? " ($numReview Reviews)" : " ($numReview Review)",
                          style: const TextStyle(color: Color(0xFF7D7F88))
                        )
                    ]
                  )
                ),
              ],
            ),
          ],
        ),

        // Add space between elements
        const Spacer(),

        ElevatedButton (
          onPressed: () {}, // Go to chat page
          style: ButtonStyle(
            fixedSize: const MaterialStatePropertyAll(Size.fromHeight(42)),
            elevation: const MaterialStatePropertyAll(0),
            backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.96), // Set corner radius
                side: const BorderSide(color: Color(0xFFA59B9B))
              ),
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
}
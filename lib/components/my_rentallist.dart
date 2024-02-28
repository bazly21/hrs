import 'package:flutter/material.dart';
import 'package:hrs/property_details_page.dart';

class MyRentalList extends StatelessWidget {
  const MyRentalList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const PropertyDetailsPage()),
              );
            }, // Go to property details page
            child: Container(
              constraints: const BoxConstraints(minHeight: 189),
              // height: 189,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 189),
                    width: 108,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        image: DecorationImage(
                            image:
                                AssetImage("lib/images/city${index + 1}.jpg"),
                            fit: BoxFit.cover)),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 189), // Set minimum height 189 pixel
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left
                              children: [
                                //////// Property Name Section (Start) //////
                                const Text(
                                  "Modern Wood Cabin in Bangi",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                //////// Property Name Section (End) //////

                                // Add space between elements
                                const SizedBox(height: 4.0),

                                //////// Property Location Section (Start) //////
                                const Text(
                                  "Seksyen 9, Bangi",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF7D7F88)),
                                ),
                                //////// Property Location Section (End) //////

                                // Add space between elements
                                const SizedBox(height: 8.0),

                                //////// Profile and Rating Sections (Start) //////
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Profile picture
                                    InkWell(
                                      onTap: () {},
                                      child: ClipOval(
                                        child: Image.network(
                                          'https://via.placeholder.com/150', // Replace with your profile picture URL
                                          width:
                                              20, // Width for the profile picture
                                          height:
                                              20, // Height for the profile picture
                                          fit: BoxFit
                                              .cover, // Cover the bounds of the parent widget (ClipOval)
                                        ),
                                      ),
                                    ),

                                    // Add space between elements
                                    const SizedBox(width: 5),

                                    // Star icon
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFBF75),
                                      size: 21.0,
                                    ),

                                    // Rating value
                                    RichText(
                                        text: const TextSpan(

                                            // Default text style
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),

                                            // Text
                                            children: [
                                          TextSpan(text: "5.0"),
                                          TextSpan(
                                              text: " (1)",
                                              style: TextStyle(
                                                  color: Color(0xFF7D7F88)))
                                        ]))
                                  ],
                                ),
                                //////// Profile and Rating Sections (End) //////

                                // Add space between elements
                                const SizedBox(height: 12.0),

                                //////// Property Brief Information Section (Start) //////
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ////// Bed Information (Start) //////
                                    Icon(
                                      Icons.bed,
                                      size: 21.0,
                                      color: Color(0xFF7D7F88),
                                    ),

                                    // Add space between elements
                                    SizedBox(width: 5),

                                    Text(
                                      "2 Rooms",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7D7F88)),
                                    ),
                                    ////// Bed Information (End) //////

                                    // Add space between elements
                                    SizedBox(width: 10),

                                    ////// Property Size Information (Start) //////
                                    Icon(
                                      Icons.house_rounded,
                                      size: 21.0,
                                      color: Color(0xFF7D7F88),
                                    ),

                                    // Add space between elements
                                    SizedBox(width: 5),

                                    Text(
                                      "673 m\u00B2",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7D7F88)),
                                    )
                                    ////// Property Size Information (End) //////
                                  ],
                                ),
                              ],
                            ),
                            //////// Property Brief Information Section (End) //////

                            //////// Rental Property's Price and Wishlist Section (Start) //////
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Rental price
                                RichText(
                                    text: const TextSpan(
                                        // Default text style
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),

                                        // Text
                                        children: [
                                      TextSpan(
                                        text: "RM300",
                                      ),
                                      TextSpan(
                                          text: " / month",
                                          style: TextStyle(
                                              color: Color(0xFF7D7F88),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0))
                                    ])),

                                // Wishlist Icon
                                const Icon(
                                  Icons.favorite_border_rounded,
                                  size: 20.0,
                                  color: Color(0xFF7D7F88),
                                ),
                              ],
                            ),
                            //////// Rental Property's Price and Wishlist Section (End) //////
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

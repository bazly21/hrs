import 'package:flutter/material.dart';
import 'package:hrs/components/my_circulariconbutton.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/user_details.dart';
import 'package:hrs/view_profile_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  bool isWishlist = false; // Initial state of the wishlist icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [             
              // ********* App Bar and Image Container (Start)  *********
              Container(
                height: 303,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "lib/images/city1.jpg"),
                    fit: BoxFit.cover,
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      CircularIconButton(
                        iconData: Icons.arrow_back, 
                        onPressed: () => Navigator.of(context).pop()
                      ),
                                       
                      // Share Button (Dummy)
                      CircularIconButton(
                        iconData: Icons.share, 
                        onPressed: () {}
                      ), 
                    ],
                  ),
                ),
              ),
              // ********* App Bar and Image Container (End)  *********
           
              // ********* Property Main Details (Start)  *********
              // Add space between elements
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),

                    PropertyDetails(
                      propertyName: "Modern Wood Cabin in Bangi",
                      propertyLocation: "Seksyen 9, Bangi",
                      isFavorite: isWishlist, // or false, based on your state
                      showIcon: true, // Set this to false to hide the icon button
                      onIconPressed: () {
                        setState(() {
                          isWishlist = !isWishlist;
                        });
                      },
                    ),
          
                    // Add space between elements
                    const SizedBox(height: 25.0),
          
                    const Row(
                      children: [
          
                        // ********* Bed Information (Start) *********
                        // House's Size Icon
                        Icon(
                          Icons.bed,
                          size: 18.0,
                          color: Color(0xFF7D7F88),
                        ),
                                                  
                        // Add space between elements
                        SizedBox(width: 5),
          
                        // Propery's Size Text **Database Required**                   
                        Text(
                          "2 Rooms",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF7D7F88)
                          ),
                        ),
                        // ********* Bed Information (End) *********
                        
                        // Add space between elements
                        SizedBox(width: 16),
                                             
                        // ********* Property Size Information (Start) *********
                        // Property Size Icon
                        Icon(
                          Icons.house_rounded,
                          size: 18.0,
                          color: Color(0xFF7D7F88),
                        ),
                                                  
                        // Add space between elements
                        SizedBox(width: 5),
          
                        // Property Size Text **Database Required**
                        Text(
                          "673 m\u00B2",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7D7F88)
                          ),
                        ),
                        // ********* Property Size Information (End) *********
          
                        // Add space between elements
                        SizedBox(width: 16),
          
                        // ********* Number of Bathroom Information (Start) *********
                        // Bathroom Icon
                        Icon(
                          Icons.bathroom_rounded,
                          size: 18.0,
                          color: Color(0xFF7D7F88),
                        ),
          
                        // Add space between elements
                        SizedBox(width: 5),
          
                        // Number of Bathroom Text **Database Required**
                        Text(
                          "4 Bathrooms",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7D7F88)
                          ),
                        ),
                        // ********* Number of Bed Information (End) *********                                   
                      ],  
                    ),
                    // ********* Property Main Details (End)  *********
          
                    // Add space between elements
                    const SizedBox(height: 16),        
          
                    const Divider(),
          
                    // Add space between elements
                    const SizedBox(height: 16), 
          
                    // ********* Landlord Profile Section (Start) *********
                    UserDetails(
                      name: "Abdul Hakim", 
                      rating: 5.0, 
                      numReview: 1,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ProfileViewPage())
                        );
                      },
                    ),        
                    // ********* Landlord Profile Section (End) *********

                    // Add space between elements
                    const SizedBox(height: 30),

                    // ********* Property Description Section (Start) *********
                    // Property Description Label
                    const PropertyDescription(
                      title: "Description",
                      content: "1 Bedroom And 1 Bathroom Unit In OUG Parklane, Old Klang Road Accessibility : 3 Min Drive To Muhibbah LRT Station 3 Min Drive To Checkers Seri Sentosa",
                    ),

                    // Furnishing Description Label
                    const PropertyDescription(
                      title: "Furnishing",
                      content: "1 Bedroom And 1 Bathroom Unit In OUG Parklane, Old Klang Road Accessibility : 3 Min Drive To Muhibbah LRT Station 3 Min Drive To Checkers Seri Sentosa",
                    ),

                    // Facilities Description Label
                    const PropertyDescription(
                      title: "Facilities",
                      content: "1 Bedroom And 1 Bathroom Unit In OUG Parklane, Old Klang Road Accessibility : 3 Min Drive To Muhibbah LRT Station 3 Min Drive To Checkers Seri Sentosa",
                    ),

                    // Accessibility Description Label
                    const PropertyDescription(
                      title: "Accessibility",
                      content: "1 Bedroom And 1 Bathroom Unit In OUG Parklane, Old Klang Road Accessibility : 3 Min Drive To Muhibbah LRT Station 3 Min Drive To Checkers Seri Sentosa",
                    ),

                    // Location Label
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18.0
                      ),
                    ),
                    // ********* Property Description Section (End) *********
                  ],
                ),
              ),
          
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color.
              spreadRadius: 2,
              blurRadius: 3, // Shadow blur radius.
              offset: const Offset(0, 2), // Vertical offset for the shadow.
            ),
          ],
          color: Colors.white
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // Rental Payment Information
                  RichText(
                    text: const TextSpan(
                      // Default text style
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                      ),
                                          
                      // Text **Database Required**
                      children: [
                        TextSpan(text: "RM300"),
                        TextSpan(
                          text: " / month",
                          style: TextStyle(
                            color: Color(0xFF7D7F88),
                            fontWeight: FontWeight.normal,
                            fontSize: 16
                          ),
                        )
                      ]
                    )
                  ),
          
                  const Text(
                    "Payment Estimation",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 14 
                    ),
                  ),
                ],
              ),

              // Apply Button
              ElevatedButton (
                onPressed: () {}, // Go to chat page
                style: ButtonStyle(
                  fixedSize: const MaterialStatePropertyAll(Size.fromHeight(42)),
                  elevation: const MaterialStatePropertyAll(0),
                  backgroundColor: const MaterialStatePropertyAll(Color(0xFF765CF8)),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(72), // Set corner radius
                    ),
                  ),
                ),
                child: const Text(
                  'Apply',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  ),                         
              ),
            ],
          ),
        ),
      ),
    );
  }
}

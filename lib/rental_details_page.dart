import 'package:flutter/material.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/rental_details.dart';
import 'package:hrs/components/user_details.dart';

class RentalDetailsPage extends StatelessWidget {
  const RentalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          // MediaQuery.of(context).size.height will take the screen size within SafeArea
          height: MediaQuery.of(context).size.height,
          child: Stack(
            clipBehavior: Clip.none, // Allows the second container to draw outside of the stack's bounds
            alignment: Alignment.topCenter, // Aligns the children of the stack at the top center
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width, // Makes the container fill the width of the screen
                height: 337, // The height of the image container
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/images/city1.jpg"), // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 290, // Adjust this value to control the amount of overlay
                width: MediaQuery.of(context).size.width, // Width of the phone screen

                // MediaQuery.of(context).size.height = Height of the screen
                // MediaQuery.of(context).padding.top = Height of the notification bar
                // 290 = Position at which the Container positioned
                // 75 = Height of the bottom navigation bar
                height: MediaQuery.of(context).size.height - 290 - 75 - MediaQuery.of(context).padding.top,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, -2), // Lifts the container up by 2 pixels to enhance the overlay effect
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25.0, 22.0, 25.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property name and location labels
                        const PropertyDetails(
                          propertyName: "Modern Wood Cabin in Bangi",
                          propertyLocation: "Seksyen 9, Bangi",
                        ),
          
                        // Add space between elements
                        const SizedBox(height: 20),

                        // Landlord's details
                        const UserDetails(
                          name: "Abdul Hakim", 
                          rating: 5.0, 
                          numReview: 1,
                          textButton: "Contact owner",
                        ),
                        
                        // Add space between elements
                        const SizedBox(height: 20),
          
                        const Divider(),

                        // Add space between elements
                        const SizedBox(height: 20),

                        // Rental information
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26, // Shadow color.
                                spreadRadius: 1,
                                blurRadius: 3, // Shadow blur radius.
                                offset: Offset(0, 2), // Vertical offset for the shadow.
                              ),
                            ],
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [                        
                                RentalDetails(title: "Tenancy Duration", text: "4 months"),

                                Divider(),

                                RentalDetails(title: "Start Date", text: "01/05/2023"),

                                Divider(),

                                RentalDetails(title: "End Date", text: "01/09/2023"),                               
                              ],
                            ),
                          ),
                        ),
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
  }
}

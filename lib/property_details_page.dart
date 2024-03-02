import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<Map<String, dynamic>?>?
      rentalDetailsFuture; // To store rental's data that has been fetched from the Firestore

  // Initialize state
  // Execute fetchRentalDetails function and store it
  // in the rentalDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    rentalDetailsFuture = fetchRentalDetails();
  }

  // Function to fetch rental details along with the landlord's name from Firebase collection
  Future<Map<String, dynamic>?> fetchRentalDetails() async {
    try {
      // Fetch the property document first
      DocumentSnapshot propertySnapshot = await FirebaseFirestore.instance
          .collection("properties")
          .doc("ee1lkVxQjSOQbM7ZbpR") // Use the actual property ID
          .get();

      if (propertySnapshot.exists) {
        Map<String, dynamic> propertyData =
            propertySnapshot.data() as Map<String, dynamic>;

        // Check if the property document has a landlordID
        if (propertyData.containsKey('landlordID')) {

          // Use DocumentReference because propertyData['landlordID']'s
          // value is reference type.
          DocumentReference landlordRef = propertyData['landlordID'];

          // Fetch the landlord's data based on reference in landlordRef
          DocumentSnapshot landlordSnapshot = await landlordRef.get();

          // Check if the landlord document exists and has data
          if (landlordSnapshot.exists) {
            Map<String, dynamic> landlordData =
                landlordSnapshot.data() as Map<String, dynamic>;

            // Add the landlord's name to the propertyData map
            propertyData['landlordName'] = landlordData['name'];

            // Return the updated propertyData map including landlord's name
            return propertyData;
          }
        }
      }
      return null;
    } catch (e) {
      print(e); // For debugging purpose
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: rentalDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If snapshot contains data
                  if (snapshot.hasData && snapshot.data != null) {
                    final Map<String, dynamic> propertyData = snapshot.data!;

                    return buildContent(propertyData, context);
                  }
                  // If snapshot does not contain data
                  else {
                    // Document does not exist or no data, navigate back
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context);
                    });
                    // Return an empty Container, SizedBox, or any widget to
                    // fulfill the builder function requirement while the navigation
                    // command is being prepared to execute.
                    return const SizedBox();
                  }
                }
                // If something happen during fetch process
                else if (snapshot.hasError) {
                  return SizedBox(
                      child: Center(child: Text("Error: ${snapshot.error}")));
                }
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()));
              }),
        ),
      ),
      bottomNavigationBar: FutureBuilder(
          future: rentalDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If snapshot contains data
              if (snapshot.hasData && snapshot.data != null) {
                final Map<String, dynamic> propertyData = snapshot.data!;
                return buildBottomNavigationBar(propertyData);
              }
            } else if (snapshot.hasError) {
              return SizedBox(
                  child: Center(child: Text("Error: ${snapshot.error}")));
            }
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(child: CircularProgressIndicator()));
          }),
    );
  }

  Container buildBottomNavigationBar(Map<String, dynamic> propertyData) {
    return Container(
      height: 80,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Shadow color.
          spreadRadius: 2,
          blurRadius: 3, // Shadow blur radius.
          offset: const Offset(0, 2), // Vertical offset for the shadow.
        ),
      ], color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Rental Payment Information
                RichText(
                    text: TextSpan(
                        // Default text style
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),

                        // Text **Database Required**
                        children: [
                      TextSpan(text: "RM${propertyData["rent"]}"),
                      const TextSpan(
                        text: " / month",
                        style: TextStyle(
                            color: Color(0xFF7D7F88),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                      )
                    ])),

                const Text(
                  "Payment Estimation",
                  style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: 14),
                ),
              ],
            ),

            // Apply Button
            ElevatedButton(
              onPressed: () {}, // Go to chat page
              style: ButtonStyle(
                fixedSize: const MaterialStatePropertyAll(Size.fromHeight(42)),
                elevation: const MaterialStatePropertyAll(0),
                backgroundColor:
                    const MaterialStatePropertyAll(Color(0xFF765CF8)),
                shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(72), // Set corner radius
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
    );
  }

  Column buildContent(Map<String, dynamic> propertyData, BuildContext context) {
    return Column(
      children: [
        // ********* App Bar and Image Container (Start)  *********
        Container(
          height: 303,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: NetworkImage(propertyData["image"][0]),
            fit: BoxFit.cover,
          )),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between items
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                CircularIconButton(
                    iconData: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop()),

                // Share Button (Dummy)
                CircularIconButton(iconData: Icons.share, onPressed: () {}),
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
                propertyName: propertyData["name"],
                propertyLocation: propertyData["address"],
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

              Row(
                children: [
                  // ********* Bed Information (Start) *********
                  // House's Size Icon
                  const Icon(
                    Icons.bed,
                    size: 18.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Propery's Size Text **Database Required**
                  Text(
                    "${propertyData["bedrooms"]} Rooms",
                    style: const TextStyle(
                        fontSize: 16.0, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Bed Information (End) *********

                  // Add space between elements
                  const SizedBox(width: 16),

                  // ********* Property Size Information (Start) *********
                  // Property Size Icon
                  const Icon(
                    Icons.house_rounded,
                    size: 18.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Property Size Text **Database Required**
                  Text(
                    "${propertyData["size"]} m\u00B2",
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Property Size Information (End) *********

                  // Add space between elements
                  const SizedBox(width: 16),

                  // ********* Number of Bathroom Information (Start) *********
                  // Bathroom Icon
                  const Icon(
                    Icons.bathroom_rounded,
                    size: 18.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Number of Bathroom Text **Database Required**
                  Text(
                    "${propertyData["bathrooms"]} Bathrooms",
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF7D7F88)),
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfileViewPage()));
                },
              ),
              // ********* Landlord Profile Section (End) *********

              // Add space between elements
              const SizedBox(height: 30),

              // ********* Property Description Section (Start) *********
              // Property Description Label
              PropertyDescription(
                  title: "Description", content: propertyData["description"]),

              // Furnishing Description Label
              PropertyDescription(
                  title: "Furnishing", content: propertyData["furnishing"]),

              // Facilities Description Label
              PropertyDescription(
                  title: "Facilities", content: propertyData["facilities"]),

              // Accessibility Description Label
              PropertyDescription(
                  title: "Accessibility",
                  content: propertyData["accessibilities"]),

              // Location Label
              const Text(
                "Location",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 18.0),
              ),
              // ********* Property Description Section (End) *********
            ],
          ),
        ),
      ],
    );
  }
}

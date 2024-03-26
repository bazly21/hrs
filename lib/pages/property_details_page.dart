import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_circulariconbutton.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/user_details.dart';
import 'package:hrs/pages/apply_rental_page.dart';
import 'package:hrs/pages/view_profile_page.dart';
import 'package:hrs/services/chat/property_service.dart';
import 'package:hrs/services/user_service.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const PropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final PropertyService propertyService = PropertyService();
  final UserService userService = UserService();
  bool rentalExists = false; // Initial state of the rental existence
  bool isWishlist = false; // Initial state of the wishlist icon
  bool isApplicationExists = false;

  Future<Map<String, dynamic>>?
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
  Future<Map<String, dynamic>> fetchRentalDetails() async {
    // Create propertyData map to store the fetched data
    Map<String, dynamic> propertyData = {};

    // Fetch the property document first
    try {
      DocumentSnapshot propertySnapshot =
          await propertyService.getPropertyDetails(widget.propertyID);

      if (propertySnapshot.exists) {
        propertyData = propertyService.propertyDataToMap(propertySnapshot);

        // Check if the property document has a landlordID
        if (propertyData.containsKey('landlordID')) {
          String landlordID = propertyData['landlordID'];

          // Fetch the landlord document using the landlordID
          DocumentSnapshot landlordSnapshot =
              await userService.getUserDetails(landlordID);

          // Check if the landlord document exists and has data
          if (landlordSnapshot.exists) {
            // Add the landlord's name to the propertyData map
            propertyData['landlordName'] = landlordSnapshot['name'];
          }
        }
      }

      return propertyData;
    } catch (e) {
      rethrow;
    }
  }

  Stream<bool> checkUserApplicationStream(String propertyID) {
    return FirebaseFirestore.instance
        .collection('applications')
        .where('propertyID', isEqualTo: propertyID)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> handleRefresh() async {
    await fetchRentalDetails().then((newData) {
      setState(() {
        rentalDetailsFuture =
            Future.value(newData); // Use the new data for the future
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          child: LayoutBuilder (
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FutureBuilder(
                    future: rentalDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: const Center(child: CircularProgressIndicator())
                        );                
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pop(
                              context, 'Something went wrong. Please try again.');
                        });
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return buildContent(snapshot.data!, context);                    
                      }

                      // Act as a placeholder
                      return const SizedBox();
                    }),
              );
            }
          ),
        ),
      ),
      bottomNavigationBar: rentalDetailsFuture == null ? null : buildBottomNavigationBar(),
    );
  }

  FutureBuilder<Map<String, dynamic>> buildBottomNavigationBar() {
    return FutureBuilder(
      future: rentalDetailsFuture,
      builder: (context, snapshot) {   
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return bottomNavigationBarContent(snapshot.data!);
        }
        
        return const SizedBox();
      });
  }

  Container bottomNavigationBarContent(Map<String, dynamic> propertyData) {
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
            StreamBuilder<bool>(
                stream: checkUserApplicationStream(widget.propertyID),
                builder: (context, snapshot) {
                  // Disable button if stream emits true (application exists) or data is not yet available
                  bool isButtonDisabled = snapshot.hasData && snapshot.data!;

                  return ElevatedButton(
                    onPressed: () {
                      // If false, button is enabled,
                      // This button will bring tenant
                      // to the Apply Rental Page
                      if (!isButtonDisabled) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ApplyRentalPage(rentalID: widget.propertyID)));
                      }
                    },
                    style: ButtonStyle(
                      fixedSize:
                          const MaterialStatePropertyAll(Size.fromHeight(42)),
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor: MaterialStatePropertyAll(isButtonDisabled
                          ? Colors.grey
                          : const Color(0xFF765CF8)),
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
                  );
                }),
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
                landlordName: propertyData["landlordName"],
                rating: 5.0,
                numReview: 1,
                landlordID: propertyData["landlordID"],
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

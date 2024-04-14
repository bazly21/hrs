import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/rental_details.dart';
import 'package:hrs/components/user_details.dart';
import 'package:hrs/services/rental/rental_service.dart';
import 'package:intl/intl.dart';

class RentalDetailsPage extends StatefulWidget {
  const RentalDetailsPage({super.key});

  @override
  State<RentalDetailsPage> createState() => _RentalDetailsPageState();
}

class _RentalDetailsPageState extends State<RentalDetailsPage> {
  final RentalService _rentalService = RentalService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>?> tenancyDetailsFuture;

  @override
  void initState() {
    super.initState();
    tenancyDetailsFuture =
        _rentalService.fetchTenancyInfo(_auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
            future: _rentalService.fetchTenancyInfo(_auth.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Display error message through snackbar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(snapshot.error.toString()),
                    ),
                  );
                });
              } else if (snapshot.hasData && snapshot.data != null) {
                return _buildTenancyInfo(context, snapshot.data!);
              }
              return const Center(child: Text('No tenancy found'));
            }),
      ),
    );
  }

  SizedBox _buildTenancyInfo(BuildContext context, Map<String, dynamic> tenancyData) {
    return SizedBox(
      // MediaQuery.of(context).size.height will take the screen size within SafeArea
      height: MediaQuery.of(context).size.height,
      child: Stack(
        clipBehavior: Clip
            .none, // Allows the second container to draw outside of the stack's bounds
        alignment: Alignment
            .topCenter, // Aligns the children of the stack at the top center
        children: <Widget>[
          Container(
            width: MediaQuery.of(context)
                .size
                .width, // Makes the container fill the width of the screen
            height: 337, // The height of the image container
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    tenancyData['propertyImageURL']), // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 290, // Adjust this value to control the amount of overlay
            width:
                MediaQuery.of(context).size.width, // Width of the phone screen
            height: MediaQuery.of(context).size.height -
                290 -
                75 -
                MediaQuery.of(context).padding.top,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0,
                        -2), // Lifts the container up by 2 pixels to enhance the overlay effect
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 22.0, 25.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property name and location labels
                    PropertyDetails(
                      propertyName: tenancyData['propertyName'],
                      propertyLocation: tenancyData['propertyAddress'],
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Landlord's details
                    UserDetails(
                      landlordName: tenancyData['landlordName'],
                      rating: tenancyData['landlordRatingAverage'],
                      numReview: tenancyData['landlordRatingCount'],
                      landlordID: tenancyData['landlordID'], 
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
                              offset: Offset(
                                  0, 2), // Vertical offset for the shadow.
                            ),
                          ],
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            RentalDetails(
                                title: "Tenancy Duration", text: "${tenancyData['tenancyDuration']} months"),
                            const Divider(),
                            RentalDetails(
                                title: "Start Date", text: formatDate(tenancyData['tenancyStartDate'])),
                            const Divider(),
                            RentalDetails(
                                title: "End Date", text: formatDate(tenancyData['tenancyEndDate'])),
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
    );
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();  // Convert Timestamp to DateTime
    return DateFormat('dd/MM/yyyy').format(date);  // Format the date
  }
}

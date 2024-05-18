import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/pages/landord_pages/landlord_edit_property_details_page.dart';
import 'package:hrs/services/property/property_service.dart';

class PropertyDetailsSection extends StatefulWidget {
  final String propertyID;

  const PropertyDetailsSection({super.key, required this.propertyID});

  @override
  State<PropertyDetailsSection> createState() => _PropertyDetailsSectionState();
}

class _PropertyDetailsSectionState extends State<PropertyDetailsSection> {
  final PropertyService _propertyService = PropertyService();
  late Future<DocumentSnapshot> propertyApplicationsFuture;

  @override
  void initState() {
    super.initState();
    propertyApplicationsFuture =
        _propertyService.getPropertyDetails(widget.propertyID);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () => refreshData(),
      child: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot?>(
              future: propertyApplicationsFuture,
              builder: (context, snapshot) {
                // If snapshot return other than null
                // including empty Map
                if (snapshot.connectionState == ConnectionState.done) {
                  // Check if the snapshot
                  final DocumentSnapshot propertyData = snapshot.data!;

                  return Column(
                    children: [
                      // Image container
                      Container(
                        height: 220, // The height of the image container
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(propertyData["image"]
                                [0]), // Replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // ********* Property Details Section (Start) *********
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ********* Property Name, Property Location & Edit Button (Start) *********
                            PropertyDetails(
                              propertyName: propertyData["name"],
                              propertyLocation: propertyData["address"],
                              icon: const Icon(Icons.edit, size: 21),
                              showIcon:
                                  true, // Set this to false to hide the icon button
                              onIconPressed: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditPropertyDetailsPage(
                                                    propertyID:
                                                        widget.propertyID)))
                                    .then((statusMessageFromPreviousPage) {
                                  if (statusMessageFromPreviousPage !=
                                      null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              statusMessageFromPreviousPage)),
                                    );
                                  }
                                });
                              },
                            ),
                            // ********* Property Name, Property Location & Edit Button (End) *********

                            // Add space between elements
                            SizedBox(height: height * 0.025),

                            // ********* Property Main Details (Start)  *********
                            Row(
                              children: [
                                // ********* Property Size Information (Start) *********
                                // Property Size Icon
                                const Icon(
                                  Icons.house_rounded,
                                  size: 16.0,
                                  color: Color(0xFF7D7F88),
                                ),

                                // Add space between elements
                                SizedBox(width: width * 0.015),

                                // Property Size Text **Database Required**
                                Text(
                                  "${propertyData["size"]} m\u00B2",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7D7F88)),
                                ),
                                // ********* Property Size Information (End) *********

                                // Add space between elements
                                SizedBox(width: width * 0.04),

                                // ********* Bed Information (Start) *********
                                // House's Size Icon
                                const Icon(
                                  Icons.bed,
                                  size: 16.0,
                                  color: Color(0xFF7D7F88),
                                ),

                                // Add space between elements
                                SizedBox(width: width * 0.015),

                                // Propery's Size Text **Database Required**
                                Text(
                                  "${propertyData["bedrooms"]} Rooms",
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF7D7F88)),
                                ),
                                // ********* Bed Information (End) *********

                                // Add space between elements
                                SizedBox(width: width * 0.04),

                                // ********* Number of Bathroom Information (Start) *********
                                // Bathroom Icon
                                const Icon(
                                  Icons.bathroom_rounded,
                                  size: 16.0,
                                  color: Color(0xFF7D7F88),
                                ),

                                // Add space between elements
                                SizedBox(width: width * 0.015),

                                // Number of Bathroom Text **Database Required**
                                Text(
                                  "${propertyData["bathrooms"]} Bathrooms",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7D7F88)),
                                ),
                                // ********* Number of Bed Information (End) *********
                              ],
                            ),
                            // ********* Property Main Details (End)  *********

                            // Add space between elements
                            SizedBox(height: height * 0.01),

                            const Divider(),

                            // Add space between elements
                            SizedBox(height: height * 0.01),

                            // ********* Property Description Section (Start) *********
                            // Property Description Label
                            PropertyDescription(
                                title: "Description",
                                content: propertyData["description"]),

                            // Furnishing Description Label
                            PropertyDescription(
                                title: "Furnishing",
                                content: propertyData["furnishing"]),

                            // Facilities Description Label
                            PropertyDescription(
                                title: "Facilities",
                                content: propertyData["facilities"]),

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
                                  fontSize: 16.0),
                            ),
                            // ********* Property Description Section (End) *********
                          ],
                        ),
                      )
                      // ********* Property Details Section (End) *********
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
    );
  }

  Future<void> refreshData() async {
    await _propertyService
        .getPropertyDetails(widget.propertyID)
        .then((newData) {
      setState(() {
        propertyApplicationsFuture = Future.value(newData);
      });
    });
  }
}

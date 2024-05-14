import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/pages/property_details_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';

class RentalListPage extends StatefulWidget {
  const RentalListPage({super.key});

  @override
  State<RentalListPage> createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  late Future<QuerySnapshot> rentalListFuture;

  // Initialize state
  // Execute fetchRentalDetails function and store it
  // in the rentalDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    rentalListFuture = PropertyService.fetchAvailableProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: "Enter location or property type",
        appBarType: "Search",
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: FutureBuilder<QuerySnapshot?>(
            future: rentalListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()));
              }
              // If there's an error fetching the data
              else if (snapshot.hasError) {
                // Show an error message if there's an error fetching the data
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${snapshot.error}')),
                  );
                });
              }
              // If there is data and the data is empty
              else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                int propertyCount = snapshot.data!.docs.length;

                return LayoutBuilder(builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: propertyCount,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot propertyData =
                            snapshot.data!.docs[index];

                        // Return the rental list
                        return rentalList(context, propertyData);
                      },
                    ),
                  );
                });
              }

              // When there is no data
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No rental properties found'),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }

  Widget rentalList(BuildContext context, DocumentSnapshot propertyData) {
    // Format the rental price to 2 decimal places
    double rentalPrice = propertyData['rent'];
    String formattedRentalPrice = rentalPrice != rentalPrice.toInt()
        ? rentalPrice.toStringAsFixed(2)
        : rentalPrice.toStringAsFixed(0);
    String propertyID = propertyData.id;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: InkWell(
        onTap: () {
          NavigationUtils.pushPage(
            context,
            PropertyDetailsPage(propertyID: propertyID),
            SlideDirection.left)
          .then((errorMessage) {
            // Show an error message if there's an error
            if (errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            }
          });
        }, // Go to property details page
        child: Container(
          constraints: const BoxConstraints(minHeight: 189),
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
                        image: NetworkImage(propertyData["image"][0]),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: [
                            //////// Property Name Section (Start) //////
                            Text(
                              propertyData["name"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            //////// Property Name Section (End) //////

                            // Add space between elements
                            const SizedBox(height: 4.0),

                            //////// Property Location Section (Start) //////
                            Text(
                              propertyData["address"],
                              style: const TextStyle(
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
                                            color: Colors.black, fontSize: 14),

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ////// Bed Information (Start) //////
                                const Icon(
                                  Icons.bed,
                                  size: 21.0,
                                  color: Color(0xFF7D7F88),
                                ),

                                // Add space between elements
                                const SizedBox(width: 5),

                                Text(
                                  "${propertyData["bedrooms"]} Rooms",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF7D7F88)),
                                ),
                                ////// Bed Information (End) //////

                                // Add space between elements
                                const SizedBox(width: 10),

                                ////// Property Size Information (Start) //////
                                const Icon(
                                  Icons.house_rounded,
                                  size: 21.0,
                                  color: Color(0xFF7D7F88),
                                ),

                                // Add space between elements
                                const SizedBox(width: 5),

                                Text(
                                  "${propertyData["size"]} m\u00B2",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF7D7F88)),
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
                                text: TextSpan(
                                    // Default text style
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),

                                    // Text
                                    children: [
                                  TextSpan(
                                    text: "RM$formattedRentalPrice",
                                  ),
                                  const TextSpan(
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
  }

  Future<void> handleRefresh() async {
    await PropertyService.fetchAvailableProperties().then((newData) {
      setState(() {
        rentalListFuture =
            Future.value(newData); // Use the new data for the future
      });
    });
  }
}

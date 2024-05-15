import 'package:flutter/material.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/property_details_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';

class RentalListPage extends StatefulWidget {
  const RentalListPage({super.key});

  @override
  State<RentalListPage> createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  late Future<List<PropertyFullDetails>?> rentalListFuture;

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
        child: FutureBuilder<List<PropertyFullDetails>?>(
            future: rentalListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return const Center(child: CircularProgressIndicator());
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
              else if (snapshot.hasData && snapshot.data != null) {
                int propertyCount = snapshot.data!.length;

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: propertyCount,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {

                    // Return the rental list
                    return rentalList(context, snapshot.data![index], index, propertyCount);
                  },
                );
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

  Widget rentalList(BuildContext context, PropertyFullDetails propertyData,
      int index, int totalCount) {
    // Format the rental price to 2 decimal places
    num rentalPrice = propertyData.rentalPrice!;
    String formattedRentalPrice = rentalPrice != rentalPrice.toInt()
        ? rentalPrice.toStringAsFixed(2)
        : rentalPrice.toStringAsFixed(0);
    String propertyID = propertyData.propertyID!;

    return Container(
      margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: index == totalCount - 1 ? 16 : 0),
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
      child: InkWell(
        onTap: () {
          // Go to property details page
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
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    image: DecorationImage(
                        image: NetworkImage(propertyData.image![0]),
                        fit: BoxFit.cover)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to the left
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //////// Property Name Section (Start) //////
                          Text(
                            propertyData.propertyName!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //////// Property Name Section (End) //////

                          //////// Property Location Section (Start) //////
                          Text(
                            propertyData.address!,
                            style: const TextStyle(fontSize: 15),
                          ),
                          //////// Property Location Section (End) //////

                          // Add space between elements
                          const SizedBox(height: 4.0),

                          //////// Profile and Rating Sections (Start) //////
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile picture
                              InkWell(
                                onTap: () {},
                                child: const CircleAvatar(
                                  radius: 9,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150'),
                                ),
                              ),

                              // Add space between elements
                              const SizedBox(width: 2),

                              // Star icon
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),

                              // Add space between elements
                              const SizedBox(width: 2),

                              // Rating value
                               CustomRichText(
                                  mainText: propertyData.landlordOverallRating!.toString(),
                                  subText: " (${propertyData.landlordRatingCount})",
                                  mainFontSize: 14,
                                  mainFontWeight: FontWeight.normal)
                            ],
                          ),
                          //////// Profile and Rating Sections (End) //////

                          // Add space between elements
                          const SizedBox(height: 4.0),

                          //////// Property Brief Information Section (Start) //////
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ////// Bed Information (Start) //////
                              const Icon(
                                Icons.bed,
                                size: 18,
                                color: Colors.grey,
                              ),

                              // Add space between elements
                              const SizedBox(width: 4),

                              Text(
                                "${propertyData.bathrooms!} Rooms",
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF7D7F88)),
                              ),
                              ////// Bed Information (End) //////

                              // Add space between elements
                              const SizedBox(width: 10),

                              ////// Property Size Information (Start) //////
                              const Icon(
                                Icons.house_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),

                              // Add space between elements
                              const SizedBox(width: 4),

                              Text(
                                "${propertyData.size!} m\u00B2",
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF7D7F88)),
                              )
                              ////// Property Size Information (End) //////
                            ],
                          ),
                        ],
                      ),
                      //////// Property Brief Information Section (End) //////

                      // Add space between elements
                      const SizedBox(height: 15),

                      //////// Rental Property's Price and Wishlist Section (Start) //////
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rental price
                          CustomRichText(
                              mainText: "RM$formattedRentalPrice",
                              subText: " /month"),

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

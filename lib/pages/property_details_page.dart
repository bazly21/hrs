import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_circulariconbutton.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/user_details.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/apply_rental_page.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';
import 'package:hrs/style/app_style.dart';
import 'package:provider/provider.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const PropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final PropertyService _propertyService = PropertyService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? role;
  bool isWishlist = false; // Initial state of the wishlist icon
  bool hasApplied = false;
  int _currentIndex = 0;

  late Future<PropertyFullDetails> rentalDetailsFuture;

  // Initialize state
  // Execute fetchRentalDetails function and store it
  // in the rentalDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    rentalDetailsFuture = _propertyService.getPropertyFullDetails(
        widget.propertyID, _auth.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    role = context.watch<AuthService>().userRole;

    return FutureBuilder(
        future: rentalDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, 'Something went wrong. Please try again.');
            });
          } else if (snapshot.hasData && snapshot.data != null) {
            return Scaffold(
              body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildContent(snapshot.data!, context),
                    )),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(snapshot.data!),
            );
          }
          return const SizedBox();
        });
  }

  Container _buildBottomNavigationBar(PropertyFullDetails propertyData) {
    // Format the rental price to 2 decimal places
    num rentalPrice = propertyData.rentalPrice!;
    String formattedRentalPrice = rentalPrice != rentalPrice.toInt()
        ? rentalPrice.toStringAsFixed(2)
        : rentalPrice.toStringAsFixed(0);

    hasApplied = propertyData.hasApplied!;

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
                      TextSpan(text: "RM$formattedRentalPrice"),
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
              onPressed:
                  propertyData.hasApplied! ? null : () => _goToPage(context),
              style: AppStyles.elevatedButtonStyle,
              child: Text(propertyData.hasApplied! ? "Applied" : "Apply"),
            )
          ],
        ),
      ),
    );
  }

  Column _buildContent(PropertyFullDetails propertyData, BuildContext context) {
    return Column(
      children: [
        // ********* App Bar and Image Container (Start)  *********
        Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 303,
                viewportFraction: 1.0,
                enableInfiniteScroll:
                    propertyData.image!.length > 1 ? true : false,
                autoPlay: false,
                onPageChanged: (index, _) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: propertyData.image!
                  .map((item) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Positioned(
              top: 12.0,
              left: 16.0,
              child: CircularIconButton(
                iconData: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 12.0,
              right: 16.0,
              child: CircularIconButton(
                iconData: Icons.share,
                onPressed: () {},
              ),
            ),
            if (propertyData.image!.length > 1)
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(
                  child: CarouselIndicator(
                    count: propertyData.image!.length,
                    index: _currentIndex,
                    color: Colors.white,
                    activeColor: const Color(0xFF8568F3),
                    space: 6.0,
                    width: 11.0,
                    height: 11.0,
                    cornerRadius: 6.0,
                  ),
                ),
              ),
          ],
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
                propertyName: propertyData.propertyName!,
                propertyLocation: propertyData.address!,
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
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Propery's Size Text **Database Required**
                  Text(
                    "${propertyData.bedrooms} Rooms",
                    style: const TextStyle(
                        fontSize: 14.0, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Bed Information (End) *********

                  // Add space between elements
                  const SizedBox(width: 16),

                  // ********* Property Size Information (Start) *********
                  // Property Size Icon
                  const Icon(
                    Icons.house_rounded,
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Property Size Text **Database Required**
                  Text(
                    "${propertyData.size} m\u00B2",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Property Size Information (End) *********

                  // Add space between elements
                  const SizedBox(width: 16),

                  // ********* Number of Bathroom Information (Start) *********
                  // Bathroom Icon
                  const Icon(
                    Icons.bathroom_rounded,
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  const SizedBox(width: 5),

                  // Number of Bathroom Text **Database Required**
                  Text(
                    "${propertyData.bathrooms} Bathrooms",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Number of Bed Information (End) *********
                ],
              ),
              // ********* Property Main Details (End)  *********

              // Add space between elements
              const SizedBox(height: 14),

              const Divider(),

              // Add space between elements
              const SizedBox(height: 14),

              // ********* Landlord Profile Section (Start) *********
              UserDetails(
                landlordName: propertyData.landlordName!,
                rating: propertyData.landlordOverallRating!,
                numReview: propertyData.landlordRatingCount!,
                landlordID: propertyData.landlordID!,
              ),
              // ********* Landlord Profile Section (End) *********

              // Add space between elements
              const SizedBox(height: 20),

              // ********* Property Description Section (Start) *********
              // Property Description Label
              PropertyDescription(
                  title: "Description", content: propertyData.description!),

              // Furnishing Description Label
              PropertyDescription(
                  title: "Furnishing", content: propertyData.furnishing!),

              // Facilities Description Label
              PropertyDescription(
                  title: "Facilities", content: propertyData.facilities!),

              // Accessibility Description Label
              PropertyDescription(
                  title: "Accessibility",
                  content: propertyData.accessibilities!),

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
        ),
      ],
    );
  }

  void _goToPage(BuildContext context) {
    if (role != null) {
      NavigationUtils.pushPage(
        context,
        ApplyRentalPage(
          propertyID: widget.propertyID,
        ),
        SlideDirection.left,
      ).then((message) {
        if (message != null) {
          refreshData();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      });
    } else {
      // User is not logged in, navigate to LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in first before applying."),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Login",
            onPressed: () {
              NavigationUtils.pushPage(
                context,
                const LoginPage(role: "Tenant"),
                SlideDirection.left,
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> refreshData() async {
    await _propertyService
        .getPropertyFullDetails(widget.propertyID, _auth.currentUser!.uid)
        .then((newData) {
      setState(() {
        rentalDetailsFuture = Future.value(newData);
      });
    });
  }
}

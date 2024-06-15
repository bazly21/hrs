import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_rating.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/services/rating/rating_service.dart';

class ProfileViewPage extends StatefulWidget {
  final String userID;
  final String role;

  const ProfileViewPage({super.key, required this.userID, required this.role});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  late Future _loadProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileFuture =
        RatingService.getUserRatings(widget.userID, widget.role);
  }

  Future<void> _loadProfile() async {
    // Simulating an asynchronous operation
    await Future.delayed(const Duration(seconds: 2));
    // Perform the actual profile loading here
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _loadProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Show snackbar with error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, "Unable to load profile. Please try again.");
          });
        } else if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
            appBar: MyAppBar(text: "${snapshot.data!.name}'s Profile"),
            body: _buildProfile(screenSize, snapshot.data!),
          );
        }

        return const Scaffold(
          body: SizedBox(),
        );
      },
    );
  }

  Widget _buildProfile(Size screenSize, dynamic userRating) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 37.0, 16.0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Center(
                    child: CustomCircleAvatar(
                      radius: 50.0,
                      name: userRating.name,
                      imageURL: null,
                    ),
                  ),

                  // Add space between elements
                  SizedBox(height: screenSize.height * 0.015),

                  // Profile Name
                  Center(
                    child: Text(
                      userRating.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 24),
                    ),
                  ),

                  // Add space between elements
                  SizedBox(height: screenSize.height * 0.015),

                  const Divider(),

                  // Add space between elements
                  SizedBox(height: screenSize.height * 0.02),

                  if (widget.role == "Landlord") ...[
                    CustomRating(
                      numReview: userRating.ratingCount,
                      rating1: userRating.overallSupportRating,
                      rating2: userRating.overallMaintenanceRating,
                      rating3: userRating.overallCommunicationRating,
                      hasTitle: true,
                      iconSize: 21.0,
                    ),
                  ] else ...[
                    CustomRating(
                      numReview: userRating.ratingCount,
                      rating1: userRating.overallPaymentRating,
                      rating2: userRating.overallMaintenanceRating,
                      rating3: userRating.overallCommunicationRating,
                      criteria1: "Payment History",
                      hasTitle: true,
                      iconSize: 21.0,
                    ),
                  ],

                  SizedBox(height: screenSize.height * 0.02),

                  const Divider(),

                  // Add space between elements
                  SizedBox(height: screenSize.height * 0.02),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userRating.ratings.length,
                    itemBuilder: (context, index) {
                      final rating = userRating.ratings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150'), // Example URL
                              backgroundColor: Colors
                                  .transparent, // Make background transparent if using image
                            ),

                            // Add space between elements
                            SizedBox(width: screenSize.width * 0.04),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rating?['reviewerName'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),

                                  // Add space between elements
                                  SizedBox(height: screenSize.height * 0.003),

                                  if (widget.role == "Landlord")
                                    CustomRating(
                                      numReview: 1,
                                      rating1: rating?['supportRating']
                                              ?.toDouble() ??
                                          0.0,
                                      rating2: rating?['maintenanceRating']
                                              ?.toDouble() ??
                                          0.0,
                                      rating3: rating?['communicationRating']
                                              ?.toDouble() ??
                                          0.0,
                                      spacing: 0.002,
                                      fontSize: 16.0,
                                      iconSize: 19.0,
                                    ),

                                  if (widget.role == "Tenant")
                                    CustomRating(
                                      numReview: 1,
                                      rating1: rating?['paymentRating']
                                              ?.toDouble() ??
                                          0.0,
                                      rating2: rating?['maintenanceRating']
                                              ?.toDouble() ??
                                          0.0,
                                      rating3: rating?['communicationRating']
                                              ?.toDouble() ??
                                          0.0,
                                      criteria1: "Payment History",
                                      spacing: 0.002,
                                      fontSize: 16.0,
                                      iconSize: 19.0,
                                    ),

                                  // Add space between elements
                                  SizedBox(height: screenSize.height * 0.008),

                                  Text(
                                    rating?['comments'] != "" &&
                                            rating?['comments'] != null
                                        ? rating!['comments']
                                        : 'No comment provided.',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),

                                  // Add space between elements
                                  SizedBox(height: screenSize.height * 0.002),

                                  Row(
                                    children: [
                                      Text(
                                        rating?['date'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xFF7D7F88),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

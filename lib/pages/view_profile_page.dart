import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_rating.dart';
import 'package:hrs/components/custom_rating_bar.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/model/rating/rating_details.dart';
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

  @override
  Widget build(BuildContext context) {
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
          return _buildMainBody(snapshot.data!);
        }

        return const Scaffold(
          body: SizedBox(),
        );
      },
    );
  }

  Widget _buildMainBody(dynamic userProfile) {
    return Scaffold(
      // appBar: _buildAppBar(userProfile),
      body: _buildProfile(userProfile),
    );
  }

  Widget _buildProfile(dynamic userProfile) {
    bool hasRating = userProfile.ratingCount > 0;
    bool hasRatingMoreThanOne = userProfile.ratingCount > 1;
    String name = userProfile.name!;
    String? imageUrl = userProfile.profilePictureUrl;
    int ratingCount = userProfile.ratingCount!;
    double overallCommunicationRating = userProfile.overallCommunicationRating!;
    double overallMaintenanceRating = userProfile.overallMaintenanceRating!;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: DefaultTabController(
          length: 1,
          child: NestedScrollView(
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return <Widget>[
                // Profile Info
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    expandedHeight: hasRating ? 230 : 200,
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white,
                    title: Text(
                      "$name's Profile",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomCircleAvatar(
                              imageURL: imageUrl,
                              name: name,
                              radius: 40.0,
                              fontSize: 30.0,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomRichText(
                                    mainText: name,
                                    subText: hasRating
                                        ? " ($ratingCount review${hasRatingMoreThanOne ? 's' : ''})"
                                        : "",
                                    mainFontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(height: 5.0),
                      
                                  // If there are no ratings
                                  if (!hasRating) ...[
                                    const Text(
                                      "No reviews yet",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.role == "Landlord"
                                              ? "Support and assistance"
                                              : "Payment history",
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        CustomRatingBar(
                                          rating: widget.role == "Landlord"
                                              ? userProfile.overallSupportRating!
                                              : userProfile.overallPaymentRating!,
                                          itemSize: 16.0,
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 3.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Maintenace",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        CustomRatingBar(
                                          rating: overallMaintenanceRating,
                                          itemSize: 16.0,
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 3.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Communication",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        CustomRatingBar(
                                          rating: overallCommunicationRating,
                                          itemSize: 16.0,
                                        )
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: const TabBar(
                      tabs: [
                        Tab(text: "RATINGS"),
                      ],
                    ),
                    // floating: false,
                    pinned: true,
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                hasRating
                    ? SafeArea(
                        top: false,
                        bottom: false,
                        child: Builder(
                          builder: (BuildContext context) {
                            return CustomScrollView(
                              slivers: [
                                SliverOverlapInjector(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(context),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return _buildRatingDetails(
                                        index,
                                        userProfile.ratings[index],
                                        MediaQuery.of(context).size,
                                      );
                                    },
                                    childCount: userProfile.ratings.length,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                        // child: ListView.builder(
                        //     itemCount: userProfile.ratings.length,
                        //     itemBuilder: (context, index) {
                        //       return _buildRatingDetails(
                        //         index,
                        //         userProfile.ratings[index],
                        //         MediaQuery.of(context).size,
                        //       );
                        //     },
                        //   ),
                        )
                    : const Center(
                        child: Text("No ratings yet"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingDetails(
    int index,
    RatingDetails rating,
    Size screenSize,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CustomCircleAvatar(
            radius: 25.0,
            name: rating.reviewerName!,
            imageURL: rating.profilePictureUrl,
          ),

          // Add space between elements
          SizedBox(width: screenSize.width * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.reviewerName!,
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
                    rating1: rating.supportRating!,
                    rating2: rating.maintenanceRating!,
                    rating3: rating.communicationRating!,
                    spacing: 0.002,
                    fontSize: 14.0,
                    iconSize: 16.0,
                  ),

                if (widget.role == "Tenant")
                  CustomRating(
                    numReview: 1,
                    rating1: rating.paymentRating!,
                    rating2: rating.maintenanceRating!,
                    rating3: rating.communicationRating!,
                    criteria1: "Payment History",
                    spacing: 0.002,
                    fontSize: 14.0,
                    iconSize: 16.0,
                  ),

                // Add space between elements
                SizedBox(height: screenSize.height * 0.008),

                // If there is comment, display the comment
                if (rating.comments != null && rating.comments != "")
                  Text(
                    rating.comments!,
                    style: const TextStyle(fontSize: 14.0),
                  ),

                // Add space between elements
                SizedBox(height: screenSize.height * 0.002),

                // Review Date
                // Only show the review date if it is available
                if (rating.reviewDate != null)
                  Row(
                    children: [
                      Text(
                        rating.reviewDate!.toString(),
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
  }
}

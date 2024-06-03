import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/model/application/application_model.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/services/property/application_service.dart';
import 'package:hrs/services/utils/error_message_utils.dart';

class ApplicationHistoryList extends StatefulWidget {
  const ApplicationHistoryList({super.key});

  @override
  State<ApplicationHistoryList> createState() => _ApplicationHistoryListState();
}

class _ApplicationHistoryListState extends State<ApplicationHistoryList> {
  final ApplicationService _applicationService = ApplicationService();
  late Future<List<Application>> _appHistoryListFuture;

  @override
  void initState() {
    super.initState();
    _appHistoryListFuture = _applicationService.getApplicationListByTenantID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainBody(),
    );
  }

  SafeArea _buildMainBody() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshData,
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: FutureBuilder(
                  future: _appHistoryListFuture,
                  builder: (context, snapshot) {
                    // If the connection is active, show a loading indicator
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      _buildErrorMessage(snapshot, context);
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      int applicationCount = snapshot.data!.length;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applicationCount,
                        itemBuilder: (context, index) {
                          var propertyData = snapshot.data![index];

                          return _buildApplicationList(
                            propertyData,
                            isLastIndex: index == applicationCount - 1,);
                        },
                      );
                    }

                    return const Center(
                      child: Text('There are no applications found.'),
                    );
                  }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildApplicationList(Application application, {bool isLastIndex = false}) {
    PropertyDetails propertyData = application.propertyDetails!;

    num rentalPrice = propertyData.rentalPrice!;
    String formattedRentalPrice = rentalPrice != rentalPrice.toInt()
        ? rentalPrice.toStringAsFixed(2)
        : rentalPrice.toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.only(
          left: 16, right: 16, top: 16, bottom: isLastIndex ? 16 : 0),
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
                            SizedBox(
                                width: propertyData.landlordOverallRating! >
                                            0 &&
                                        propertyData.landlordRatingCount! > 0
                                    ? 2
                                    : 5),

                            // If the landlord has a rating
                            if (propertyData.landlordOverallRating! > 0 &&
                                propertyData.landlordRatingCount! > 0) ...[
                              // Star icon
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),

                              // Add space between elements
                              const SizedBox(width: 2),

                              CustomRichText(
                                  mainText: propertyData
                                      .landlordOverallRating!
                                      .toString(),
                                  subText:
                                      " (${propertyData.landlordRatingCount})",
                                  mainFontSize: 14,
                                  mainFontWeight: FontWeight.normal)
                            ],

                            // If the landlord has no rating
                            if (propertyData.landlordOverallRating! == 0 &&
                                propertyData.landlordRatingCount! == 0)
                              const Text("No rating",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                        //////// Profile and Rating Sections (End) //////
                      ],
                    ),
                    //////// Property Brief Information Section (End) //////

                    // Add space between elements
                    const SizedBox(height: 25),

                    //////// Rental Property's Price and Wishlist Section (Start) //////
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rental price
                        CustomRichText(
                            mainText: "RM$formattedRentalPrice",
                            subText: " /month"),

                        // Text to show the status of the application
                        Text(
                          application.status,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _getStatusTextColor(application.status),
                          )
                        )
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
    );
  }

  void _buildErrorMessage(
      AsyncSnapshot<List<Application>> snapshot, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String errorMessage;
      if (snapshot.error is FirebaseException) {
        FirebaseException e = snapshot.error as FirebaseException;
        switch (e.code) {
          case 'auth/network-request-failed':
            errorMessage = networkRequestFailedErrorMessage;
            break;
          case 'invalid-access':
            errorMessage = invalidAccessErrorMessage;
            break;
          default:
            errorMessage = genericFutureErrorMessage;
        }
      } else {
        errorMessage = genericFutureErrorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    });
  }

  Future<void> refreshData() async {
    await _applicationService.getApplicationListByTenantID().then((wishlist) {
      setState(() {
        _appHistoryListFuture = Future.value(wishlist);
      });
    });
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Declined":
        return Colors.red;
      case "Accepted":
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/rental_details.dart';
import 'package:hrs/components/user_details.dart';
import 'package:hrs/services/rental/rental_service.dart';
import 'package:intl/intl.dart';

class LandlordTenancyDetailsSection extends StatefulWidget {
  final String propertyID;

  const LandlordTenancyDetailsSection({super.key, required this.propertyID});

  @override
  State<LandlordTenancyDetailsSection> createState() =>
      _LandlordTenancyDetailsSectionState();
}

class _LandlordTenancyDetailsSectionState
    extends State<LandlordTenancyDetailsSection> {
  late Future<Map<String, dynamic>?> tenancyDetailsFuture;

  @override
  void initState() {
    super.initState();
    tenancyDetailsFuture =
        RentalService.landlordFetchTenancyInfo(widget.propertyID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
            future: tenancyDetailsFuture,
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

  Widget _buildTenancyInfo(
      BuildContext context, Map<String, dynamic> tenancyData) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: _refreshTenancyDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(tenancyData['propertyImageURL']),
                fit: BoxFit.fill,
                opacity: 0.8,
              ),
            ),
            child: Center(
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // // Property name and location labels
                      // PropertyDetails(
                      //   propertyName: tenancyData['propertyName'],
                      //   propertyLocation: tenancyData['propertyAddress'],
                      // ),

                      // // Add space between elements
                      // const SizedBox(height: 20),

                      // Landlord's details
                      UserDetails(
                        landlordName: tenancyData['tenantName'],
                        rating: tenancyData['tenantRatingAverage'],
                        numReview: tenancyData['tenantRatingCount'],
                        landlordID: tenancyData['tenantID'],
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
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              RentalDetails(
                                title: "Tenancy Duration",
                                text:
                                    "${tenancyData['tenancyDuration']} months",
                              ),
                              const Divider(),
                              RentalDetails(
                                title: "Start Date",
                                text:
                                    formatDate(tenancyData['tenancyStartDate']),
                              ),
                              const Divider(),
                              RentalDetails(
                                title: "End Date",
                                text: formatDate(tenancyData['tenancyEndDate']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate(); // Convert Timestamp to DateTime
    return DateFormat('dd/MM/yyyy').format(date); // Format the date
  }

  // Refresh the tenancy details
  Future<void> _refreshTenancyDetails() async {
    await RentalService.landlordFetchTenancyInfo(widget.propertyID)
        .then((value) {
      setState(() {
        tenancyDetailsFuture = Future.value(value);
      });
    });
  }
}

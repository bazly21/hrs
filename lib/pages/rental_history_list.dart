import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/model/tenancy/tenant_ended_tenancy.dart';
import 'package:hrs/pages/rating_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/tenancy_service.dart';

class RentalHistoryList extends StatefulWidget {
  const RentalHistoryList({super.key});

  @override
  State<RentalHistoryList> createState() => _RentalHistoryListState();
}

class _RentalHistoryListState extends State<RentalHistoryList> {
  late Future<List<TenantEndedTenancy>> _endedTenancies;

  @override
  void initState() {
    super.initState();
    _endedTenancies = TenancyService.fetchTenantEndedTenancies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshEndedTenancies,
        child: FutureBuilder<List<TenantEndedTenancy>>(
            future: _endedTenancies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(snapshot.error.toString()),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                });
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final List<TenantEndedTenancy> tenancies = snapshot.data!;
                return ListView.builder(
                  itemCount: tenancies.length,
                  itemBuilder: (context, index) {
                    return _buildRentalItem(
                        tenancies[index], index == tenancies.length - 1);
                  },
                );
              }
              return const Center(
                child: Text('No tenancies found'),
              );
            }),
      ),
    ));
  }

  Container _buildRentalItem(
    TenantEndedTenancy tenancyData,
    bool isLastIndex,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, isLastIndex ? 16 : 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  image: DecorationImage(
                      image: NetworkImage(tenancyData.propertyImageURL),
                      fit: BoxFit.cover)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenancyData.propertyName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tenancyData.propertyAddress,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            // Landlord's profile picture
                            CustomCircleAvatar(
                              imageURL: tenancyData.landlordImageURL,
                              name: tenancyData.landlordName,
                              radius: 9.0,
                              fontSize: 7.0,
                            ),

                            // Add space between elements
                            // If the landlord has a rating
                            // Set the width to 2, else set it to 5
                            SizedBox(
                              width: tenancyData.landlordRatingAverage > 0 &&
                                      tenancyData.landlordRatingCount > 0
                                  ? 2
                                  : 5,
                            ),

                            // If the landlord has a rating
                            // show the star icon and the rating
                            if (tenancyData.landlordRatingAverage > 0 &&
                                tenancyData.landlordRatingCount > 0) ...[
                              // Star icon
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),

                              // Add space between elements
                              const SizedBox(width: 2),

                              CustomRichText(
                                mainText: tenancyData.landlordRatingAverage
                                    .toString(),
                                subText:
                                    " (${tenancyData.landlordRatingCount})",
                                mainFontSize: 14,
                                mainFontWeight: FontWeight.normal,
                              )
                            ] 
                            // Else show no rating
                            else ...[
                              const Text(
                                "No rating",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: tenancyData.rentalPrice ==
                                        tenancyData.rentalPrice.toInt()
                                    ? 'RM${tenancyData.rentalPrice.toStringAsFixed(0)}'
                                    : 'RM${tenancyData.rentalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: const [
                                  TextSpan(
                                    text: ' /month',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              tenancyData.tenancyStatus,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFB5A4F8),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: tenancyData.isRated
                            ? null
                            : () {
                                // Create a Map to pass to the RatingPage
                                final ratingInfo = {
                                  'propertyID': tenancyData.propertyID,
                                  'propertyImageURL':
                                      tenancyData.propertyImageURL,
                                  'propertyName': tenancyData.propertyName,
                                  'propertyAddress':
                                      tenancyData.propertyAddress,
                                  'landlordID': tenancyData.landlordID,
                                  'landlordImageURL':
                                      tenancyData.landlordImageURL,
                                  'landlordName': tenancyData.landlordName,
                                  'tenancyDocID': tenancyData.tenancyDocID,
                                };

                                NavigationUtils.pushPage(
                                  context,
                                  RatingPage(
                                    ratingInfo: ratingInfo,
                                  ),
                                  SlideDirection.left,
                                ).then((value) {
                                  // If a succes message is returned
                                  // from the RatingPage,
                                  if (value != null && value['success']) {
                                    // Refresh the list of tenancies
                                    setState(() {
                                      _endedTenancies = Future.value(
                                          value['updatedEndedTenancies']);
                                    });

                                    // Show success message
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(value['message']),
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: Colors.green[700],
                                        ));
                                      },
                                    );

                                    // Refresh the list of tenancies
                                    // _refreshEndedTenancies();
                                  }
                                });
                              },
                        child: Text(tenancyData.isRated ? 'Rated' : 'Rate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshEndedTenancies() async {
    await TenancyService.fetchTenantEndedTenancies().then((newData) {
      setState(() {
        _endedTenancies =
            Future.value(newData); // Use the new data for the future
      });
    });
  }
}

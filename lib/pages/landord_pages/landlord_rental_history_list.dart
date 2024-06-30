import 'package:flutter/material.dart';
import 'package:hrs/components/appbar_shadow.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/model/tenancy/landlord_ended_tenancy.dart';
import 'package:hrs/pages/landord_pages/landlord_rating_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/tenancy_service.dart';

class LandlordRentalHistoryList extends StatefulWidget {
  const LandlordRentalHistoryList({super.key});

  @override
  State<LandlordRentalHistoryList> createState() =>
      _LandlordRentalHistoryListState();
}

class _LandlordRentalHistoryListState extends State<LandlordRentalHistoryList> {
  late Future<List<LandlordEndedTenancy>> _endedTenancies;

  @override
  void initState() {
    super.initState();
    _endedTenancies = TenancyService.fetchLandlordEndedTenancies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rental History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              )),
          centerTitle: true,
          toolbarHeight: 70.0,
          flexibleSpace: const AppBarShadow(),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshEndedTenancies,
            child: FutureBuilder<List<LandlordEndedTenancy>>(
                future: _endedTenancies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${snapshot.error}"),
                        ),
                      );
                    });
                  } else if (snapshot.hasData &&
                      (snapshot.data!.isNotEmpty || snapshot.data != null)) {
                    final List<LandlordEndedTenancy> tenancies = snapshot.data!;
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
    LandlordEndedTenancy tenancyData,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CustomCircleAvatar(
                              imageURL: tenancyData.tenantImageURL,
                              name: tenancyData.tenantName,
                              radius: 9.0,
                              fontSize: 7.0,
                            ),
                            const SizedBox(width: 5),
                            if (tenancyData.tenantRatingAverage > 0 &&
                                tenancyData.tenantRatingCount > 0)
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            RichText(
                              text: TextSpan(
                                text: tenancyData.tenantRatingAverage == 0.0
                                    ? 'No rating yet'
                                    : '${tenancyData.tenantRatingAverage}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                children: [
                                  if (tenancyData.tenantRatingCount > 0)
                                    TextSpan(
                                      text:
                                          ' (${tenancyData.tenantRatingCount})',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
                                  'tenantID': tenancyData.tenantID,
                                  'tenantImageURL': tenancyData.tenantImageURL,
                                  'tenantName': tenancyData.tenantName,
                                  'tenancyDocID': tenancyData.tenancyDocID,
                                };

                                NavigationUtils.pushPage(
                                  context,
                                  LandlordRatingPage(
                                    ratingInfo: ratingInfo,
                                  ),
                                  SlideDirection.left,
                                ).then((value) {
                                  if (value != null && value['success']) {
                                    // Refresh the list of ended tenancies
                                    setState(() {
                                      _endedTenancies = Future.value(
                                          value['updatedEndedTenancies']);
                                    });

                                    // Show success message
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(value['message']),
                                            duration:
                                                const Duration(seconds: 3),
                                            backgroundColor: Colors.green[700],
                                          ),
                                        );
                                      },
                                    );
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
    await TenancyService.fetchLandlordEndedTenancies().then((newData) {
      setState(() {
        _endedTenancies =
            Future.value(newData); // Use the new data for the future
      });
    });
  }
}

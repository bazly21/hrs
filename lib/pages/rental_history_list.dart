import 'package:flutter/material.dart';
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(snapshot.error.toString())));
                });
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final List<TenantEndedTenancy> tenancies = snapshot.data!;
                return ListView.builder(
                  itemCount: tenancies.length,
                  itemBuilder: (context, index) {
                    return _buildRentalItem(tenancies[index]);
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

  Container _buildRentalItem(TenantEndedTenancy tenancyData) {
    return Container(
      margin: const EdgeInsets.all(16),
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
                            CircleAvatar(
                              radius: 9,
                              backgroundImage:
                                  NetworkImage(tenancyData.landlordImageURL),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            RichText(
                              text: TextSpan(
                                text: tenancyData.landlordRatingAverage == 0.0
                                    ? 'No rating yet'
                                    : '${tenancyData.landlordRatingAverage}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                children: [
                                  if (tenancyData.landlordRatingCount > 0)
                                    TextSpan(
                                      text:
                                          ' (${tenancyData.landlordRatingCount})',
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
                                text: tenancyData.rentalPrice == 0.0
                                    ? 'N/A'
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white,
                          disabledForegroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: tenancyData.isRated
                                      ? Colors.grey
                                      : Colors.black)),
                        ),
                        onPressed: tenancyData.isRated
                            ? null
                            : () => NavigationUtils.pushPage(
                                        context,
                                        RatingPage(
                                          landlordID: tenancyData.landlordID,
                                          tenancyDocID:
                                              tenancyData.tenancyDocID,
                                          propertyID: tenancyData.propertyID,
                                        ),
                                        SlideDirection.left)
                                    .then((message) {
                                  if (message != null) {
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(message)));

                                    // Refresh the list of tenancies
                                    _refreshEndedTenancies();
                                  }
                                }),
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

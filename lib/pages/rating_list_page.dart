import 'package:flutter/material.dart';
import 'package:hrs/pages/rating_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/rental/rental_service.dart';

class RatingList extends StatefulWidget {
  const RatingList({super.key});

  @override
  State<RatingList> createState() => _RatingListState();
}

class _RatingListState extends State<RatingList> {
  final RentalService _rentalService = RentalService();
  Future<List<Map<String, dynamic>>?>? _endedTenancies;

  @override
  void initState() {
    super.initState();
    _endedTenancies = _rentalService.fetchEndedTenancies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshEndedTenancies,
        child: FutureBuilder<List<Map<String, dynamic>>?>(
            future: _endedTenancies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData &&
                  (snapshot.data!.isNotEmpty || snapshot.data != null)) {
                final List<Map<String, dynamic>> tenancies = snapshot.data!;
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

  Container _buildRentalItem(Map<String, dynamic> tenancyData) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tenancyData['propertyName'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            tenancyData['propertyAddress'],
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            tenancyData['landlordRatingAverage'] == 0.0
                ? 'No rating yet'
                : '${tenancyData['landlordRatingAverage']}',
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tenancyData['rentalPrice'] == 0.0
                    ? 'N/A'
                    : 'RM ${tenancyData['rentalPrice'].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${tenancyData['tenancyStatus']}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: tenancyData['isRated']
                ? null
                : () => NavigationUtils.pushPage(
                        context,
                        RatingPage(
                          landlordID: tenancyData['landlordID'],
                          tenancyDocID: tenancyData['tenancyDocID'],
                        ),
                        SlideDirection.left).then((message) {
                      if (message != null) {
                        // Show success message
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));

                        // Refresh the list of tenancies
                        _refreshEndedTenancies();
                      }
                    }),
            child: Text(tenancyData['isRated'] ? 'Rated' : 'Rate'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshEndedTenancies() async {
    await _rentalService.fetchEndedTenancies().then((newData) {
      setState(() {
        _endedTenancies =
            Future.value(newData); // Use the new data for the future
      });
    });
  }

}

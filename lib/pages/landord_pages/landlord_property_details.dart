import 'package:flutter/material.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details_section.dart';
import 'package:hrs/pages/landord_pages/landlord_property_applications_section.dart';

enum RefreshType { propertyDetails, propertyApplications }

class LandlordPropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const LandlordPropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<LandlordPropertyDetailsPage> createState() =>
      _LandlordPropertyDetailsPageState();
}

class _LandlordPropertyDetailsPageState
    extends State<LandlordPropertyDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Rental Property Details",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                  child: Text("DETAILS",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
              Tab(
                  child: Text("APPLICATIONS",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: PropertyDetailsSection(propertyID: widget.propertyID)),
            PropertyApplicationsSection(propertyID: widget.propertyID),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details_section.dart';
import 'package:hrs/pages/landord_pages/landlord_property_applications_section.dart';
import 'package:hrs/pages/landord_pages/landlord_tenant_criteria_setting_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';

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
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              position: PopupMenuPosition.under,
              onSelected: (String result) async {
                if (result == 'Set tenant criteria') {
                  // Navigate to the tenant criteria setting page
                  NavigationUtils.pushPage(
                      context,
                      TenantCriteriaSettingPage(propertyID: widget.propertyID),
                      SlideDirection.left);
                } else if (result == 'Delete property') {
                  // Add confirmation dialog
                  await _deleteConfirmationDialog(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Set tenant criteria',
                  child: Text('Set tenant criteria'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'Delete property',
                  child: Text('Delete property',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
        ),
        body: TabBarView(
          children: [
            Center(
                child: PropertyDetailsSection(propertyID: widget.propertyID)),
            PropertyApplicationsSection(propertyID: widget.propertyID),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteConfirmationDialog(BuildContext context) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Property'),
          content: const Text(
              "Are you sure you want to delete this property?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    
    if (isConfirmed ?? false) {
      await PropertyService.deleteProperty(widget.propertyID)
          .then((_) {
        Navigator.pop(context, 'success');
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting property: $error'),
          ),
        );
      });
    }
  }
}

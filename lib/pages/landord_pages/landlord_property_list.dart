import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details.dart';
import 'package:hrs/provider/refresh_provider.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:provider/provider.dart';

class LandlordPropertyListPage extends StatefulWidget {
  const LandlordPropertyListPage({super.key});

  @override
  State<LandlordPropertyListPage> createState() =>
      _LandlordPropertyListPageState();
}

class _LandlordPropertyListPageState extends State<LandlordPropertyListPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<PropertyDetails>?> propertyListFuture;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    propertyListFuture = fetchRentalPropertiesList();
  }

  @override
  Widget build(BuildContext context) {
    _isRefreshing = context.watch<RefreshProvider>().propertyRefresh;

    if (_isRefreshing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshRentalList().then((_) {
          context.read<RefreshProvider>().propertyRefresh = false;
        });
      });
    }
    
    return Scaffold(
      appBar: SearchAppBar(
        hintText: 'Search property',
        controller: _searchController,
        onChanged: _handleSearch,
      ),
      body: RefreshIndicator(
        onRefresh: refreshRentalList,
        child: FutureBuilder(
          future: propertyListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Failed to fetch properties"));
            } else if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return propertyCard(context, snapshot.data![index]);
                },
              );
            }

            // If no properties are found
            return const Center(child: Text("No rental properties found"));
          },
        ),
      ),
    );
  }

  Future<List<PropertyDetails>?> fetchRentalPropertiesList(
      {String? searchQuery}) async {
    final landlordID = user.uid;
    QuerySnapshot propertiesSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('landlordID', isEqualTo: landlordID)
        .get();

    // Return null if no properties found
    if (propertiesSnapshot.docs.isEmpty) return null;

    List<PropertyDetails> propertyList =
        await Future.wait(propertiesSnapshot.docs.map((propertyDoc) async {
      Map<String, dynamic>? propertyData =
          propertyDoc.data() as Map<String, dynamic>?;

      if (propertyData == null) return null;

      return PropertyDetails(
        propertyID: propertyDoc.id,
        propertyName: propertyData['name'],
        address: propertyData['address'],
        image: List<String>.from(propertyData['image']),
      );
    })).then((list) => list.whereType<PropertyDetails>().toList());

    // Filter properties based on searchQuery if it is not null and not empty
    if (searchQuery != null && searchQuery.isNotEmpty) {
      propertyList = propertyList.where((property) {
        return property.propertyName!
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

    return propertyList;
  }

  Future<void> refreshRentalList() async {
    await fetchRentalPropertiesList().then((newData) {
      setState(() {
        propertyListFuture = Future.value(newData);
      });
    });
  }

  Padding propertyCard(BuildContext context, PropertyDetails propertyData) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: InkWell(
        onTap: () {
          // Navigate to RentalPropertyDetailsPage and pass the snapshotId
          NavigationUtils.pushPage(
            context,
            LandlordPropertyDetailsPage(propertyID: propertyData.propertyID!),
            SlideDirection.left,
          ).then((result) {
            if (result != null && result == 'success') {
              refreshRentalList();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          height: 131,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7D7F88).withOpacity(0.5),
                spreadRadius: 0.1,
                blurRadius: 5,
                offset: const Offset(1, 2),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(propertyData.image![0]),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                propertyData.propertyName!,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
              Text(
                propertyData.address!,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearch(String searchQuery) {
    setState(() {
      propertyListFuture = fetchRentalPropertiesList(searchQuery: searchQuery);
    });
  }
}

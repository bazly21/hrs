import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class LandlordPropertyListPage extends StatefulWidget {
  
  const LandlordPropertyListPage({super.key});

  @override
  State<LandlordPropertyListPage> createState() => _LandlordPropertyListPageState();
}

class _LandlordPropertyListPageState extends State<LandlordPropertyListPage> {
  final user = FirebaseAuth.instance.currentUser!;
  Future<List<DocumentSnapshot>>? propertyListFuture;

  @override
  void initState() {
    super.initState();
    propertyListFuture = fetchRentalPropertiesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Search property", appBarType: "Search"),
      body: RefreshIndicator(
        onRefresh: refreshRentalList,
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: propertyListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Failed to fetch properties"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot propertyData = snapshot.data![index];
        
                  return propertyCard(context, propertyData);
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

  Future<List<DocumentSnapshot>> fetchRentalPropertiesList() async {
    final landlordID = user.uid;

    QuerySnapshot propertiesQuerySnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('landlordID', isEqualTo: landlordID)
        .get();

    return propertiesQuerySnapshot.docs;
  }

  Future<void> refreshRentalList() async {
    await fetchRentalPropertiesList().then((newData) {
      setState(() {
        propertyListFuture = Future.value(newData);
      });
    });
  }

  Padding propertyCard(BuildContext context, DocumentSnapshot propertyData) {
    final String propertyID = propertyData.id;
    final String propertyName = propertyData['name'];
    final String propertyLocation = propertyData['address'];
    final List propertyImageUrl = propertyData['image'];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: InkWell(
      onTap: () {
        // Navigate to RentalPropertyDetailsPage and pass the snapshotId
        NavigationUtils.pushPage(
          context,
          LandlordPropertyDetailsPage(propertyID: propertyID),
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
            image: NetworkImage(propertyImageUrl[0]),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              propertyName,
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
            Text(
              propertyLocation,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ),
        ),
    );
  }
}


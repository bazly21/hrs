import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/pages/landord_pages/landlord_property_details.dart';

class LandlordPropertyListPage extends StatelessWidget {
  
  final user = FirebaseAuth.instance.currentUser!;

  LandlordPropertyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Search property", appBarType: "Search"),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getPropertiesByLandlordId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to fetch properties"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final property = snapshot.data![index];
                final snapshotId = property.id; // Get snapshot ID

                return RentalPropertyTile(
                    name: property['name'],
                    address: property['address'],
                    imageUrl: property['image'][0],
                    snapshotId: snapshotId);
              },
            );
          } else {
            return const Center(child: Text("No rental properties found"));
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> getPropertiesByLandlordId() async {
    final landlorID = user.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('landlordID', isEqualTo: landlorID)
        .get();

    return querySnapshot.docs;
  }
}

class RentalPropertyTile extends StatelessWidget {
  final String name;
  final String address;
  final String imageUrl;
  final String snapshotId;

  const RentalPropertyTile({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.snapshotId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to RentalPropertyDetailsPage and pass the snapshotId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LandlordPropertyDetailsPage(snapshotId: snapshotId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

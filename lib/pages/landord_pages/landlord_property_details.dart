import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/components/my_starrating.dart';

class LandlordPropertyDetailsPage extends StatefulWidget {
  final String snapshotId;

  const LandlordPropertyDetailsPage({super.key, required this.snapshotId});

  @override
  State<LandlordPropertyDetailsPage> createState() => _LandlordPropertyDetailsPageState();
}

class _LandlordPropertyDetailsPageState extends State<LandlordPropertyDetailsPage> {
  bool isWishlist = false; // Initial state of the wishlist icon
  bool isApplicationExists = false;
  final String rentalID = "ee1lkVxQjSOQbM7ZbpR4";
  Future<Map<String, dynamic>?>?
      propertyDetailsFuture; // To store rental's data that has been fetched from the Firestore

  // Initialize state
  // Execute fetchPropertyDetails function and store it
  // in the propertyDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    propertyDetailsFuture = fetchPropertyDetails();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Rental Property Details",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text("Details",
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 17
                  )
                )
              ),
              Tab(
                child: Text("Applications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 17
                  )
                )
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: rentalPropertyDetailsSection(context, screenSize)),
            rentalPropertyApplicationsSection(context, screenSize),
            // const Text(
            //   "Rental Property Details",
            //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            // )
          ],
        ),
      ),
    );
  }

  RefreshIndicator rentalPropertyDetailsSection(BuildContext context, Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;

    return RefreshIndicator(
      onRefresh: handleRefresh,
      child: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>?>(
            future: propertyDetailsFuture,
            builder: (context, snapshot) {
              // If snapshot return other than null
              // including empty Map
              if (snapshot.connectionState == ConnectionState.done) {
                // Check if the snapshot
                final Map<String, dynamic> propertyData = snapshot.data!;
      
                return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        // Image container
                        Container(
                          height: 259, // The height of the image container
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  propertyData["image"][0]), // Replace with your image URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
      
                        // ********* Property Details Section (Start) *********
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ********* Property Name, Property Location & Edit Button (Start) *********
                              PropertyDetails(
                                propertyName: propertyData["name"],
                                propertyLocation: propertyData["address"],
                                icon: const Icon(Icons.edit, size: 22),
                                showIcon: true, // Set this to false to hide the icon button
                                onIconPressed: () {},
                              ),
                              // ********* Property Name, Property Location & Edit Button (End) *********
      
                              // Add space between elements
                              SizedBox(height: height * 0.03),
      
                              // ********* Property Main Details (Start)  *********
                              Row(
                                children: [
                                  // ********* Property Size Information (Start) *********
                                  // Property Size Icon
                                  const Icon(
                                    Icons.house_rounded,
                                    size: 18.0,
                                    color: Color(0xFF7D7F88),
                                  ),
      
                                  // Add space between elements
                                  SizedBox(width: width * 0.015),
      
                                  // Property Size Text **Database Required**
                                  Text(
                                    "${propertyData["size"]} m\u00B2",
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF7D7F88)),
                                  ),
                                  // ********* Property Size Information (End) *********
      
                                  // Add space between elements
                                  SizedBox(width: width * 0.04),
      
                                  // ********* Bed Information (Start) *********
                                  // House's Size Icon
                                  const Icon(
                                    Icons.bed,
                                    size: 18.0,
                                    color: Color(0xFF7D7F88),
                                  ),
      
                                  // Add space between elements
                                  SizedBox(width: width * 0.015),
      
                                  // Propery's Size Text **Database Required**
                                  Text(
                                    "${propertyData["bedrooms"]} Rooms",
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFF7D7F88)),
                                  ),
                                  // ********* Bed Information (End) *********
      
                                  // Add space between elements
                                  SizedBox(width: width * 0.04),
      
                                  // ********* Number of Bathroom Information (Start) *********
                                  // Bathroom Icon
                                  const Icon(
                                    Icons.bathroom_rounded,
                                    size: 18.0,
                                    color: Color(0xFF7D7F88),
                                  ),
      
                                  // Add space between elements
                                  SizedBox(width: width * 0.015),
      
                                  // Number of Bathroom Text **Database Required**
                                  Text(
                                    "${propertyData["bathrooms"]} Bathrooms",
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF7D7F88)),
                                  ),
                                  // ********* Number of Bed Information (End) *********
                                ],
                              ),
                              // ********* Property Main Details (End)  *********
      
                              // Add space between elements
                              SizedBox(height: height * 0.015),
      
                              const Divider(),
      
                              // Add space between elements
                              SizedBox(height: height * 0.015),
      
                              // ********* Property Description Section (Start) *********
                              // Property Description Label
                              PropertyDescription(
                                title: "Description",
                                content: propertyData["description"]
                              ),
      
                              // Furnishing Description Label
                              PropertyDescription(
                                title: "Furnishing",
                                content: propertyData["furnishing"]
                              ),
      
                              // Facilities Description Label
                              PropertyDescription(
                                title: "Facilities",
                                content: propertyData["facilities"]
                              ),
      
                              // Accessibility Description Label
                              PropertyDescription(
                                title: "Accessibility",
                                content: propertyData["accessibilities"]
                              ),
      
                              // Location Label
                              const Text(
                                "Location",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 18.0),
                              ),
                              // ********* Property Description Section (End) *********
                            ],
                          ),
                        )
                        // ********* Property Details Section (End) *********
                      ],
                    ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })),
    );
  }


  Column rentalPropertyApplicationsSection(BuildContext context, Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7D7F88)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // ********* Applicant Details (Start)  ********* 
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Row(
                      children: [
                        // ********* Profile Picture and Rating Section (Start)  ********* 
                        Column(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                              radius: 40,
                            ),
                            SizedBox(height: height * 0.007),
                            const StarRating(rating: 5.0, iconSize: 18),
                            SizedBox(height: height * 0.007),
                            const CustomRichText(text1: "5.0", text2: " (3 Reviews)")
                          ],
                        ),
                        // ********* Profile Picture and Rating Section (End)  *********
                             
                        SizedBox(width: width * 0.05),
                        
                        // ********* Applicant Details Section (Start)  *********
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Applicant's Name
                              const Text("Lucy Bond", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                          
                              SizedBox(height: height * 0.005),
                          
                              // Applicant's Details
                              Row(
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Occupation
                                      Text("Occupation:", style: TextStyle(fontSize: 13)),
                                      Text("Student", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                  
                                      // Profile Type
                                      Text("Profile type:", style: TextStyle(fontSize: 13)),
                                      Text("Student", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                  
                                      // Number of Pax
                                      Text("No. of pax:", style: TextStyle(fontSize: 13)),
                                      Text("3 pax", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                    ],
                                  ),
                              
                                  SizedBox(width: width * 0.03),
                              
                                  Container(width: 1, color: const Color(0xFF8568F3), height: 110),
                                  
                                  SizedBox(width: width * 0.03),
                              
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Occupation
                                      Text("Occupation:", style: TextStyle(fontSize: 13)),
                                      Text("Student", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                  
                                      // Profile Type
                                      Text("Profile type:", style: TextStyle(fontSize: 13)),
                                      Text("Student", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                  
                                      // Number of Pax
                                      Text("No. of pax:", style: TextStyle(fontSize: 13)),
                                      Text("3 pax", style: TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                    ],
                                  ),
                                  
                                ],
                              ),
                            ],
                          ),
                        )
                        // ********* Applicant Details Section (End)  *********
                        
                      ],
                     ),
                   ),
                   // ********* Applicant Details (End)  ********* 

                   // ********* Accept and Decline Buttons (Start)  ********* 
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decline Button
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5858),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))
                          ),
                          child: const Text(
                            "Decline", 
                            style: TextStyle(
                              fontSize: 13, 
                              color: Colors.white
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5BBA53),
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                          ),
                          child: const Text(
                            "Accept", 
                            style: TextStyle(
                              fontSize: 13, 
                              color: Colors.white
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                   ],)
                   // ********* Accept and Decline Buttons (End)  *********  
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Function to fetch rental details along with the landlord's name from Firebase collection
  Future<Map<String, dynamic>?> fetchPropertyDetails() async {
    try {
      // Fetch the property document first
      DocumentSnapshot propertySnapshot = await FirebaseFirestore.instance
          .collection("properties")
          .doc(widget.snapshotId) // Use the actual property ID
          .get();

      if (propertySnapshot.exists) {
        // Convert the propertySnapshot data to a Map
        Map<String, dynamic> propertyData =
            propertySnapshot.data() as Map<String, dynamic>;

        // Check if the property document has a landlordID
        if (propertyData.containsKey('landlordID')) {
          // Use DocumentReference because propertyData['landlordID']'s
          // value is a reference type.
          DocumentReference landlordRef = propertyData['landlordID'];

          // Fetch the landlord's data based on the reference in landlordRef
          DocumentSnapshot landlordSnapshot = await landlordRef.get();

          // Check if the landlord document exists and has data
          if (landlordSnapshot.exists) {
            // Get the landlord's name from the landlordSnapshot
            String landlordName = landlordSnapshot.get('name');

            // Add the landlord's name to the propertyData map
            propertyData['landlordName'] = landlordName;

            // Return the modified propertyData map;
            return propertyData;
          }
        }
      }
      return null;
    } catch (e) {
      print(e); // For debugging purpose
      return null;
    }
  }
  
  Future<void> handleRefresh() async {
    await fetchPropertyDetails().then((newData) {
      setState(() {
        propertyDetailsFuture = Future.value(newData); // Use the new data for the future
      });
    });
  }
}

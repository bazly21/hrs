import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/ink_button.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/components/my_starrating.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

enum RefreshType { propertyDetails, propertyApplications }

class LandlordPropertyDetailsPage extends StatefulWidget {
  final String snapshotId;

  const LandlordPropertyDetailsPage({super.key, required this.snapshotId});

  @override
  State<LandlordPropertyDetailsPage> createState() =>
      _LandlordPropertyDetailsPageState();
}

class _LandlordPropertyDetailsPageState extends State<LandlordPropertyDetailsPage> {
  bool isWishlist = false; // Initial state of the wishlist icon
  bool isApplicationExists = false;
  Future<Map<String, dynamic>?>? propertyDetailsFuture; // To store rental's data that has been fetched from the Firestore
  Future<List<Map<String, dynamic>>>? propertyApplicationsFuture; // To store propertys's application data that has been fetched from the Firestore
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Initialize state
  // Execute fetchPropertyDetails function and store it
  // in the propertyDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    propertyDetailsFuture = fetchPropertyDetails();
    propertyApplicationsFuture = fetchPropertyApplication();
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
                          fontWeight: FontWeight.w600, fontSize: 17))),
              Tab(
                  child: Text("Applications",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 17))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: rentalPropertyDetailsSection(context, screenSize)),
            rentalPropertyApplicationsSection(context, screenSize),
          ],
        ),
      ),
    );
  }

  RefreshIndicator rentalPropertyDetailsSection(
      BuildContext context, Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;

    return RefreshIndicator(
      onRefresh: () => refreshData(RefreshType.propertyDetails),
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
                                image: NetworkImage(propertyData["image"]
                                    [0]), // Replace with your image URL
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
                                  showIcon:
                                      true, // Set this to false to hide the icon button
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
                                          fontSize: 16,
                                          color: Color(0xFF7D7F88)),
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
                                          fontSize: 16,
                                          color: Color(0xFF7D7F88)),
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
                                    content: propertyData["description"]),

                                // Furnishing Description Label
                                PropertyDescription(
                                    title: "Furnishing",
                                    content: propertyData["furnishing"]),

                                // Facilities Description Label
                                PropertyDescription(
                                    title: "Facilities",
                                    content: propertyData["facilities"]),

                                // Accessibility Description Label
                                PropertyDescription(
                                    title: "Accessibility",
                                    content: propertyData["accessibilities"]),

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

  RefreshIndicator rentalPropertyApplicationsSection(BuildContext context, Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;
    const appBarHeight = 56.0; // Default AppBar height
    const tabBarHeight = 48.0; // Default TabBar height
    final statusBarHeight = MediaQuery.of(context).padding.top; // Status bar height

    return RefreshIndicator(
      onRefresh: () => refreshData(RefreshType.propertyApplications),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: propertyApplicationsFuture,
        builder: (context, snapshot) {
          // If snapshot contains data
          // Note that empty list also makes
          // snapshot.hasData equal to true
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          // If there is data and the data is not empty
          else if(snapshot.hasData && snapshot.data!.isNotEmpty){
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> applicationData = snapshot.data![index];
                final bool isAccepted = applicationData['status'] == "Accepted";  // To check if the status of the application wether it is accepted or not
                final String applicationID = applicationData["applicationID"];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: isAccepted ? 0 : 1.0,
                    child: Column(
                      children: [
                        // ********* Profile Picture and Rating Section (Start)  *********
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: const BorderSide(width: 0.3, color: Color(0xFF7D7F88)),
                              left: const BorderSide(width: 0.3, color: Color(0xFF7D7F88)),
                              right: const BorderSide(width: 0.3, color: Color(0xFF7D7F88)),
                              bottom: isAccepted ? const BorderSide(width: 0.3, color: Color(0xFF7D7F88)) : BorderSide.none,
                            ),
                            borderRadius:BorderRadius.circular(10.0).copyWith(
                              bottomLeft: isAccepted ? null : Radius.zero,
                              bottomRight: isAccepted ? null : Radius.zero,
                            )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 8.0, 0, 8.0),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(applicationData["applicantName"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),

                                        // If the application status is accepted,
                                        // then show the 'Kebab' (three vertical dot) menu
                                        if(isAccepted)
                                          PopupMenuButton<String>(
                                            position: PopupMenuPosition.under,
                                            color: Colors.white,
                                            onSelected: (String result) async  {
                                              // Handle the menu item selected here
                                              if(result == "Undo Application"){
                                                showConfirmationAndUpdateStatus(
                                                  context: context, 
                                                  confirmationTitle: "Confirm Undo", 
                                                  confirmationContent: "Are you sure you want to undo this application?",
                                                  status: "Pending", 
                                                  applicationID: applicationID
                                                );
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              // First PopupMenuItem
                                              const PopupMenuItem<String>(
                                                value: 'Contact Tenant',
                                                child: Text('Contact Tenant'),
                                              ),

                                              // Add divider between PopupMenuItem
                                              const PopupMenuDivider(),

                                              // Second PopupMenuItem
                                              const PopupMenuItem<String>(
                                                value: 'Undo Application',
                                                child: Text(
                                                  'Undo Application',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            icon: const Icon(Icons.more_vert), // Icon for kebab menu (three vertical dots)
                                          ),
                                      ],
                                    ),
                          
                                    SizedBox(height: height * 0.005),
                          
                                    // Applicant's Details
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Occupation
                                            const Text("Occupation:", style: TextStyle(fontSize: 13)),
                                            Text(applicationData["occupation"], style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                          
                                            // Profile Type
                                            const Text("Profile type:", style: TextStyle(fontSize: 13)),
                                            Text(applicationData["profileType"], style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                          
                                            // Number of Pax
                                            const Text("No. of pax:", style: TextStyle(fontSize: 13)),
                                            Text("${applicationData["numberOfPax"]} pax", style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                                          ],
                                        ),
                          
                                        SizedBox(width: width * 0.03),
                          
                                        Container(width: 1, color: const Color(0xFF8568F3), height: 110),
                          
                                        SizedBox(width: width * 0.03),
                          
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Occupation
                                            const Text("Nationality:", style: TextStyle(fontSize: 13)),
                                            Text(applicationData["nationality"], style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                          
                                            // Profile Type
                                            const Text("Move-in date:", style: TextStyle(fontSize: 13)),
                                            Text("${applicationData["moveInDate"]}", style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
                          
                                            // Number of Pax
                                            const Text("Tenancy duration:", style: TextStyle(fontSize: 13)),
                                            Text("${applicationData["tenancyDuration"]} months", style: const TextStyle(fontSize: 13, color: Color(0xFF7D7F88))),
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
                        ),
                        // ********* Profile Picture and Rating Section (End)  *********
                              
                        // ********* Accept and Decline Buttons (Start)  *********
                        if (!isAccepted)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Decline Button
                              Expanded(
                                child: InkButton(
                                  backgroundColor: Colors.red[400]!, 
                                  onTap: () => showConfirmationAndUpdateStatus(
                                    context: context, 
                                    confirmationTitle: "Confirm Decline", 
                                    confirmationContent: "Are you sure you want to decline this application?",
                                    status: "Declined", 
                                    applicationID: applicationID
                                  ),
                                  textButton: "Decline", 
                                  splashColor: Colors.red[700]!.withOpacity(0.5), 
                                  highlightColor: Colors.red[900]!.withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
                                )
                              ),
                                
                              // Accept Button
                              Expanded(
                                child: InkButton(
                                  backgroundColor: Colors.green[400]!, 
                                  onTap: () => showConfirmationAndUpdateStatus(
                                    context: context, 
                                    confirmationTitle: "Confirm Accept", 
                                    confirmationContent: "Are you sure you want to accept this application?",
                                    status: "Accepted", 
                                    applicationID: applicationID
                                  ), 
                                  textButton: "Accept", 
                                  splashColor: Colors.green[700]!.withOpacity(0.5), 
                                  highlightColor: Colors.green[900]!.withOpacity(0.5)
                                ),
                              ),
                            ]
                          )
                        // ********* Accept and Decline Buttons (End)  *********
                      ],
                    ),
                  ),
                );
              }
            );     
          }
          else {
            // When there is no data
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures it's always scrollable to trigger refresh
              child: 
              SizedBox(
                height: screenSize.height - statusBarHeight - appBarHeight - tabBarHeight,
                child: const Center(
                  child: Text('No application found'),
                ),
              ),
            );
          }
        }
      ),
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

  Future<List<Map<String, dynamic>>> fetchPropertyApplication() async {
    List<Map<String, dynamic>> applicationDataList = [];

    // Fetch the rental property's applications
    QuerySnapshot applicationSnapshots = await db
        .collection("applications")
        .where("propertyID", isEqualTo: widget.snapshotId)
        .where("status", isNotEqualTo: "Declined")
        .get();
        

    if (applicationSnapshots.docs.isNotEmpty) {
      // Fetch all applicant user documents in parallel
      List<DocumentSnapshot> userSnapshots = await Future.wait(
        applicationSnapshots.docs
            .map((appDoc) => appDoc.get("applicantID") as String?)
            .whereNotNull()
            .map((applicantID) => db.collection("users").doc(applicantID).get())
            .toList()
      );

      // Map applicationData with corresponding user data
      for (int i = 0; i < applicationSnapshots.docs.length; i++) {
        Map<String, dynamic> applicationData = applicationSnapshots.docs[i].data() as Map<String, dynamic>;
        DocumentSnapshot userSnapshot = userSnapshots[i];

        if (userSnapshot.exists) {
          String? applicantName = userSnapshot.get("name");
          if (applicantName != null && applicantName.isNotEmpty) {
            // Get the document ID
            applicationData["applicationID"] = applicationSnapshots.docs[i].id;

            // Create new property inside applicationData called applicantName
            applicationData["applicantName"] = applicantName;

            // Since applicationData['moveInDate'] is timestamp
            // type (Firestore only support timestamp type),
            // Then we need to convert it to DateTime format
            // to use the DateFormat object
            Timestamp timestamp = applicationData['moveInDate'];
            DateTime moveInDate = timestamp.toDate();
            String formattedDate = DateFormat('dd/MM/yyyy').format(moveInDate);
            applicationData['moveInDate'] = formattedDate;

            // Once all the processes are done, add the document
            // into applicationDataList
            applicationDataList.add(applicationData);
          }
        }
      }
    }

    return applicationDataList;
  }

  Future<void> refreshData(RefreshType type) async {
    switch (type) {
      case RefreshType.propertyDetails:
        await fetchPropertyDetails().then((newData) {
          setState(() {
            propertyDetailsFuture = Future.value(newData);
          });
        });
        break;
      case RefreshType.propertyApplications:
        await fetchPropertyApplication().then((newData) {
          setState(() {
            propertyApplicationsFuture = Future.value(newData);
          });
        });
        break;
    }
  }

  Future<void> showConfirmationAndUpdateStatus({
    required BuildContext context,
    required String confirmationTitle,
    required String confirmationContent,
    required String status,
    required String applicationID
  }) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(confirmationTitle),
          content: Text(confirmationContent),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (isConfirmed ?? false) {
      await db.collection("applications").doc(applicationID).update({
        "status": status,
      }).then((_) {
        refreshData(RefreshType.propertyApplications);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something wrong happened. Please try again')),
        );
      });
    }
  }

}

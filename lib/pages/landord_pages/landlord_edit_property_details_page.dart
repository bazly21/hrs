import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/property_details_price_texfield.dart';
import 'package:hrs/components/property_details_textfield.dart';
import 'package:hrs/components/size_bath_bed_textfield.dart';

class EditPropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const EditPropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<EditPropertyDetailsPage> createState() => _EditPropertyDetailsPageState();
}

class _EditPropertyDetailsPageState extends State<EditPropertyDetailsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Future<DocumentSnapshot?>? propertyDetailsFuture;

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
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: appBar(context),
      body: bodyContent(context),
    );
  }

  FutureBuilder bodyContent(BuildContext context) {
    return FutureBuilder(
      future: propertyDetailsFuture, 
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return propertyDetailsForm(snapshot.data);      
          }
          // When snapshot has error or the data is null
          else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, 'Error occured. Please try again');
            });
          }
        }
        else if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        else{
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, 'Unexpected state. Please try again');
          });
        }

        // Return empty SizedBox
        return const SizedBox();
      })
    );
  }

  SingleChildScrollView propertyDetailsForm(DocumentSnapshot propertyData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Shadow color.
                spreadRadius: 1,
                blurRadius: 2, // Shadow blur radius.
                offset: const Offset(0, 2), // Vertical offset for the shadow.
              ),
            ]
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Property Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                    TextButton(
                      onPressed: () {
                        // Handle add image process
                      },
                      child: const Text('Add'), // Adjust color as needed
                    )
                  ],
                ),
              ),
      
              SizedBox( // Use a Container with a fixed height
                height: 180, // Example fixed height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadiusDirectional.circular(10),
                        child: Image.asset(
                          'lib/images/city${index + 1}.jpg',
                          fit: BoxFit.cover
                        ),
                      ),
                    );
                  },
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Property Name Textfield
                    PropertyDetailsTextField(
                      title: 'Property Name', 
                      initialValue: propertyData['name']
                    ),
      
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Property Location Textfield
                    PropertyDetailsTextField(
                      title: 'Location', 
                      initialValue: propertyData['address']
                    ),
      
                    // Add space between elements
                    const SizedBox(height: 20),
  
                    // Rental Price TextField
                    PropertyDetailsPriceTextField(rentalPrice: '${propertyData['rent']}'),
  
                    // Add space between elements
                    const SizedBox(height: 20),
  
                    SizeBathBedTextField(
                      propertySize: '${propertyData['size']}', 
                      numBathroom: '${propertyData['bathrooms']}', 
                      numBedroom: '${propertyData['bedrooms']}'
                    ),
  
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Description Textfield
                    PropertyDetailsTextField(
                      title: 'Description', 
                      initialValue: propertyData['description'],
                      textInputType: TextInputType.multiline,
                    ),
                    
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Furnishing Textfield
                    PropertyDetailsTextField(
                      title: 'Furnishing', 
                      initialValue: propertyData['furnishing'],
                      textInputType: TextInputType.multiline,
                    ),
  
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Facilities Textfield
                    PropertyDetailsTextField(
                      title: 'Facilities', 
                      initialValue: propertyData['facilities'],
                      textInputType: TextInputType.multiline,
                    ),
  
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Accesibilities Textfield
                    PropertyDetailsTextField(
                      title: 'Accessibilities', 
                      initialValue: propertyData['accessibilities'],
                      textInputType: TextInputType.multiline,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      leadingWidth: 70,
      centerTitle: true,
      // Cancel Button
      leading: TextButton(
        onPressed: () => Navigator.pop(context), 
        child: const Text('Cancel'),
      ),
      // App Bar title
      title: const Text(
        'Edit Property Details', 
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Handle 'Save' action
            print('Save pressed');
          },
          child: const Text('Save'), // Adjust color as needed
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color.
              spreadRadius: 2,
              blurRadius: 3, // Shadow blur radius.
              offset: const Offset(0, 2), // Vertical offset for the shadow.
            ),
          ],
          color: Colors.white
        ),
      )
    );
  }

  // Function to fetch property details
  Future<DocumentSnapshot?> fetchPropertyDetails() async {
    // Fetch the property document first
    DocumentSnapshot propertySnapshot = await db
        .collection('properties')
        .doc(widget.propertyID) // Use the actual property ID
        .get();

    // If there is snapshot related with the propertyID
    if (propertySnapshot.exists) {
      return propertySnapshot;
    }
    
    // If there is no snapshot related with the propertyID
    return null;
  }
}
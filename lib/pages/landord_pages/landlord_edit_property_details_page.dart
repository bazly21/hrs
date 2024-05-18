import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrs/components/property_details_price_texfield.dart';
import 'package:hrs/components/property_details_textfield.dart';
import 'package:image_picker/image_picker.dart';

class EditPropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const EditPropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<EditPropertyDetailsPage> createState() => _EditPropertyDetailsPageState();
}

class _EditPropertyDetailsPageState extends State<EditPropertyDetailsPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker(); // Object to choose image from the gallery
  Future<DocumentSnapshot?>? propertyDetailsFuture;
  List<String> _tempImagePaths = []; // Holds local paths of selected images
  List<String> _savedImageUrls = []; // Holds URLs of images already saved in Firestore
  bool _isSaving = false;

  // Variable to store property information
  String propertyName = '';
  String propertyLocation = '';
  String propertyDescription = '';
  String propertyFurnishing = '';
  String propertyFacilities = '';
  String propertyAccessibilities = '';

  dynamic propertySize = '';
  dynamic propertyBathrooms = '';
  dynamic propertyBedrooms = '';
  dynamic rentalPrice = '';

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
      body: _isSaving ? const Center(child: CircularProgressIndicator()) : bodyContent(context),
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
    final List<dynamic>? images = propertyData['image'];

    if (images != null) {
      _savedImageUrls = images.cast<String>();
    }

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
                      onPressed: _pickImages,
                      child: const Text('Add'),
                    )
                  ],
                ),
              ),

              // Property Images
              SizedBox(
                height: 180, // Example fixed height
                child: _buildImageList(),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Property Name Textfield
                    PropertyDetailsTextField(
                      title: 'Property Name',
                      initialValue: propertyData['name'],
                      hintText: 'Enter property name',
                      getText: (String text) {
                        propertyName = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Property Location Textfield
                    PropertyDetailsTextField(
                      title: 'Location',
                      initialValue: propertyData['address'],
                      hintText: 'Enter property location',
                      getText: (String text) {
                        propertyLocation = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Rental Price TextField
                    PropertyDetailsPriceTextField(
                      rentalPrice: '${propertyData['rent']}',
                      getText: (String text) {
                        // Convert text from String to int
                        // If tryParse returns null then return 0
                        rentalPrice = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: PropertyDetailsTextField(
                              title: 'Property Size (sqft)',
                              initialValue: '${propertyData['size']}',
                              hintText: '0',
                              textInputType: TextInputType.number,
                              getText: (String text) {
                                // Convert text from String to int
                                // If tryParse returns null then return 0
                                propertySize = text;
                              },
                            ),
                          ),

                          // Add space between elements
                          const SizedBox(width: 20.0),

                          Expanded(
                            child: PropertyDetailsTextField(
                              title: 'Bathroom',
                              initialValue: '${propertyData['bathrooms']}',
                              hintText: '0',
                              textInputType: TextInputType.number,
                              getText: (String text) {
                                // Convert text from String to int
                                // If tryParse returns null then return 0
                                propertyBathrooms = text;
                              },
                            ),
                          ),

                          // Add space between elements
                          const SizedBox(width: 20.0),

                          Expanded(
                            child: PropertyDetailsTextField(
                              title: 'Bedroom',
                              initialValue: '${propertyData['bedrooms']}',
                              hintText: '0',
                              textInputType: TextInputType.number,
                              getText: (String text) {
                                // Convert text from String to int
                                // If tryParse returns null then return 0
                                propertyBedrooms = text;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Description Textfield
                    PropertyDetailsTextField(
                      title: 'Description',
                      initialValue: propertyData['description'],
                      hintText: 'Enter description',
                      textInputType: TextInputType.multiline,
                      getText: (String text) {
                        propertyDescription = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Furnishing Textfield
                    PropertyDetailsTextField(
                      title: 'Furnishing',
                      initialValue: propertyData['furnishing'],
                      hintText: 'List down furniture available in the property',
                      textInputType: TextInputType.multiline,
                      getText: (String text) {
                        propertyFurnishing = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Facilities Textfield
                    PropertyDetailsTextField(
                      title: 'Facilities',
                      initialValue: propertyData['facilities'],
                      hintText: 'List down available facilities with the property',
                      textInputType: TextInputType.multiline,
                      getText: (String text) {
                        propertyFacilities = text;
                      },
                    ),

                    // Add space between elements
                    const SizedBox(height: 20),

                    // Accesibilities Textfield
                    PropertyDetailsTextField(
                      title: 'Accessibilities',
                      initialValue: propertyData['accessibilities'],
                      hintText: 'List down available accessibility near the property',
                      textInputType: TextInputType.multiline,
                      getText: (String text) {
                        propertyAccessibilities = text;
                      },
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

  // ************* Upload Image Functions (Start) *************
  ListView _buildImageList() {
    final totalImages = _savedImageUrls.length + _tempImagePaths.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: totalImages,
      itemBuilder: (context, index) {
        // Display images from database
        if (index < _savedImageUrls.length) {
          return _showImage(_savedImageUrls[index], "Network");
        }
         // Display added images temporarily
        else {
          return _showImage(_tempImagePaths[index - _savedImageUrls.length], "File");
        }
      },
    );
  }

  Container _showImage(String imageUrl, String imageType) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.circular(10),
        child: imageType == "Network"
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
            ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        // Add all selected images to _tempImagePaths
        for (XFile image in pickedFiles) {
          _tempImagePaths.add(image.path);
        }
      });
    }
  }
  // ************* Upload Image Functions (End) *************

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
        // Save button
        TextButton(
          onPressed: () {
            // Handle 'Save' action
            saveUpdatedPropertyDetails(context);
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

  // Function to fetch property details
  Future<void> saveUpdatedPropertyDetails(BuildContext context) async {
    // Check to ensure all fields are filled in
    if (propertyName != '' &&
        propertyLocation != '' &&
        propertyDescription != '' &&
        propertyFurnishing != '' &&
        propertyFacilities != '' &&
        propertyAccessibilities != '' &&
        propertySize != '' &&
        propertyBathrooms != '' &&
        propertyBedrooms != '' &&
        rentalPrice != '')
    {
      setState(() {
        _isSaving = true; // Start saving
      });

      // Converts all numeric text fields to number data type (int / double)
      propertySize = num.tryParse(propertySize);
      propertyBathrooms = int.tryParse(propertyBathrooms);
      propertyBedrooms = int.tryParse(propertyBedrooms);
      rentalPrice = double.tryParse(rentalPrice);

      List<String>? newImageUrls;
      bool newImageUrlsHasError = false;

      // Upload images and get download URLs
      if (_tempImagePaths.isNotEmpty){
        newImageUrls = await _uploadImages();

        if (newImageUrls == null) {
          newImageUrlsHasError = true;
        }
      }

      // If one of these variables contains null value
      if (propertySize == null || propertyBathrooms == null || propertyBedrooms == null || rentalPrice == null || newImageUrlsHasError) {
        setState(() {
          _isSaving = false; // Stop saving
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something error happen. Please try again'))
          );
        }
        return;
      }

      // Stores the information in the database
      try{
        await db.collection('properties').doc(widget.propertyID).update({
          'name': propertyName,
          'address': propertyLocation,
          'rent': rentalPrice,
          'size': propertySize,
          'bathrooms': propertyBathrooms,
          'bedrooms': propertyBedrooms,
          'description': propertyDescription,
          'furnishing': propertyFurnishing,
          'facilities': propertyFacilities,
          'accessibilities': propertyAccessibilities,
          // 'image': FieldValue.arrayUnion(newImageUrls),
        }).then((_) {
          if (mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All informations have been updated successfully'))
            );

            _handleRefresh();
          }
        });
      }
      catch(e) {
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e. Please try again'))
          );
        }
      }
      finally {
        setState(() {
          _isSaving = false; // Stop saving
        });
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please make sure all fields are filled in'))
      );
    }
  }

  Future<void> _handleRefresh() async {
    _tempImagePaths.clear();

    await fetchPropertyDetails().then((newData) {
      setState(() {
        propertyDetailsFuture =
            Future.value(newData); // Use the new data for the future
      });
    });
  }

  Future<List<String>?> _uploadImages() async {
    List<String> downloadUrls = [];

    for (String imagePath in _tempImagePaths) {
      File file = File(imagePath);
      String fileName = "images/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);

        // Upload image
        UploadTask uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;

        // Get download URL
        final url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      }
      catch (_) {
        return null;
      }
    }

    return downloadUrls;
  }
}
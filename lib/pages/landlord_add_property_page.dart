import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/property_details_price_texfield.dart';
import 'package:hrs/components/property_details_textfield.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyPage extends StatefulWidget {
  
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker(); // Object to choose image from the gallery
  final List<String> _tempImagePaths = []; // Holds local paths of selected images 
  Future<DocumentSnapshot?>? propertyDetailsFuture;
  bool _isSaving = false;

  // Variable to store property information
  late String propertyName;
  late String propertyLocation;
  late String propertyDescription;
  late String propertyFurnishing;
  late String propertyFacilities;
  late String propertyAccessibilities;
  late String propertySize; 
  late String propertyBathrooms;
  late String propertyBedrooms ;
  late String rentalPrice;

  // Initialize state
  // Execute fetchPropertyDetails function and store it
  // in the propertyDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: appBar(context),
      body: _isSaving ? const Center(child: CircularProgressIndicator()) : propertyDetailsForm(context),
    );
  }

  SingleChildScrollView propertyDetailsForm(BuildContext context) {
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
                height: _tempImagePaths.isEmpty? null : 180, // Example fixed height
                child: _tempImagePaths.isEmpty
                  ? Text(
                      'No images selected', 
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    )
                  : _buildImageList(),
              ),
      
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Property Name Textfield
                    PropertyDetailsTextField(
                      title: 'Property Name',
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
                      hintText: 'Enter property location',
                      getText: (String text) {
                        propertyLocation = text;
                      },
                    ),
      
                    // Add space between elements
                    const SizedBox(height: 20),
  
                    // Rental Price TextField
                    PropertyDetailsPriceTextField(                     
                      getText: (String text) {
                        // Convert text from String to int
                        // If tryParse returns null then return 0
                        rentalPrice = text;
                      },
                    ),
  
                    // Add space between elements
                    const SizedBox(height: 20),
  
                    Row(
                      children: [
                        Expanded(
                          child: PropertyDetailsTextField(
                            title: 'Property Size', 
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
  
                    // Add space between elements
                    const SizedBox(height: 20),
                    
                    // Description Textfield
                    PropertyDetailsTextField(
                      title: 'Description', 
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

  // ************* Add Image Functions (Start) *************
  Widget _buildImageList() {
    final totalImages = _tempImagePaths.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: totalImages,
      itemBuilder: (context, index) {
        return _showImage(_tempImagePaths[index], index);
      },
    );
  }

  Widget _showImage(String imageUrl, int index) {
    return Stack(
      children: [
        Container(
          width: 160,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadiusDirectional.circular(10),
            child: Image.file(
                    File(imageUrl),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        // Remove Button
        Positioned(
          right: 5,
          top: 0,
          child: InkWell(
            onTap: () => _removeImage(index),           
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove,
                size: 21,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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
  // ************* Add Image Functions (End) *************

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
        // Add button
        TextButton(
          onPressed: () {
            addPropertyDetails(context);
          },
          child: const Text('Add'), // Adjust color as needed
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

  // Function to remove image from _tempImagePaths
  void _removeImage(int index) {
    setState(() {
      _tempImagePaths.removeAt(index);
    });
  }
  
  Future<void> addPropertyDetails(BuildContext context) async {
    // Check to ensure all fields are filled in
    if (propertyName.isNotEmpty &&
        propertyLocation.isNotEmpty&&
        propertyDescription.isNotEmpty &&
        propertyFurnishing.isNotEmpty &&
        propertyFacilities.isNotEmpty &&
        propertyAccessibilities.isNotEmpty &&
        propertySize.isNotEmpty &&
        propertyBathrooms.isNotEmpty &&
        propertyBedrooms .isNotEmpty &&
        rentalPrice.isNotEmpty) 
    {
      setState(() {
        _isSaving = true; // Start saving
      });

      // Get landlordID from the current user
      final User user = FirebaseAuth.instance.currentUser!;
      final String landlordID = user.uid;
      
      // Converts all numeric text fields to number data type (int / double)
      num? formattedPropertySize = num.tryParse(propertySize);
      int? formattedPropertyBathrooms = int.tryParse(propertyBathrooms);
      int? formattedPropertyBedrooms = int.tryParse(propertyBedrooms);
      double? formattedRentalPrice = double.tryParse(rentalPrice);

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
      if (formattedPropertySize == null || 
          formattedPropertyBathrooms == null || 
          formattedPropertyBedrooms == null || 
          formattedRentalPrice == null || 
          newImageUrlsHasError) 
      {
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

      // Add the new property information in the database
      try{
        await db.collection('properties').add({
        'name': propertyName,
        'address': propertyLocation,
        'rent': formattedRentalPrice,
        'size': formattedPropertySize,
        'bathrooms': formattedPropertyBathrooms,
        'bedrooms': formattedPropertyBedrooms,
        'description': propertyDescription,
        'furnishing': propertyFurnishing,
        'facilities': propertyFacilities,
        'accessibilities': propertyAccessibilities,
        'landlordID': landlordID,
        'image': FieldValue.arrayUnion(newImageUrls!),
      }).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All informations have been added successfully'))
          );
          
          // Navigate to the previous page
          Navigator.pop(context);
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
}
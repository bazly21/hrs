import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/components/property_details_price_texfield.dart';
import 'package:hrs/provider/image_provider.dart';
import 'package:hrs/services/utils/error_message_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditPropertyDetailsPage extends StatefulWidget {
  final String propertyID;

  const EditPropertyDetailsPage({super.key, required this.propertyID});

  @override
  State<EditPropertyDetailsPage> createState() =>
      _EditPropertyDetailsPageState();
}

class _EditPropertyDetailsPageState extends State<EditPropertyDetailsPage> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _furnishingController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _accessibilitiesController =
      TextEditingController();

  late ImageService _imageService;
  late List<String> _images;
  late List<String> _copyImages;

  Future<DocumentSnapshot?>? propertyDetailsFuture;
  bool _isSaving = false;

  // Initialize state
  // Execute fetchPropertyDetails function and store it
  // in the propertyDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    propertyDetailsFuture = fetchPropertyDetails();
    _imageService = context.read<ImageService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: appBar(context),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : bodyContent(context),
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
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, 'Unexpected state. Please try again');
            });
          }

          // Return empty SizedBox
          return const SizedBox();
        }));
  }

  SingleChildScrollView propertyDetailsForm(DocumentSnapshot propertyData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial images from the database
      _imageService.images = propertyData['image'].cast<String>();

      // Copy the images
      _copyImages = List.from(_imageService.images);

      _nameController.text = propertyData['name'];
      _locationController.text = propertyData['address'];
      _rentPriceController.text = propertyData['rent'].toString();
      _sizeController.text = propertyData['size'].toString();
      _bathroomController.text = propertyData['bathrooms'].toString();
      _bedroomController.text = propertyData['bedrooms'].toString();
      _descriptionController.text = propertyData['description'];
      _furnishingController.text = propertyData['furnishing'];
      _accessibilitiesController.text = propertyData['accessibilities'];
      _facilitiesController.text = propertyData['facilities'];
    });

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
              ]),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Property Image',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16.0)),
                      TextButton(
                        onPressed: _showPickImagesDialog,
                        child: const Text('Add'),
                      )
                    ],
                  ),
                ),

                // Property Images
                _buildImageSection(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Property Name Textfield
                      CustomTextFormField(
                        label: 'Property Name',
                        hintText: 'Enter property name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property name';
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Property Location Textfield
                      CustomTextFormField(
                        label: 'Location',
                        hintText: 'Enter property location',
                        controller: _locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property location';
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Rental Price TextField
                      CustomTextFormField(
                        label: 'Rent Price / Month',
                        hintText: '0.00',
                        controller: _rentPriceController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'RM',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rental price';
                          }

                          if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            return "Rental price must contain numbers and a dot only";
                          }
                          return null;
                        },
                        inputFormatters: [CurrencyInputFormatter()],
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      CustomTextFormField(
                        label: 'Property Size (sqft)',
                        hintText: '0',
                        controller: _sizeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property size';
                          }

                          if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            return "Property size cannot contain letter";
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      CustomTextFormField(
                        label: 'Bathroom',
                        hintText: '0',
                        controller: _bathroomController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property size';
                          }

                          if (RegExp(r'\D').hasMatch(value)) {
                            return "Number of bathrooms cannot contain letter";
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      CustomTextFormField(
                        label: 'Bedroom',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        controller: _bedroomController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property size';
                          }

                          if (RegExp(r'\D').hasMatch(value)) {
                            return "Number of bedrooms cannot contain letter";
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Description Textfield
                      CustomTextFormField(
                        label: 'Description',
                        hintText: 'Enter description',
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Furnishing Textfield
                      CustomTextFormField(
                        label: 'Furnishing',
                        hintText: 'Enter furnishing',
                        keyboardType: TextInputType.multiline,
                        controller: _furnishingController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter furnishing';
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Facilities Textfield
                      CustomTextFormField(
                        label: 'Facilities',
                        hintText: 'Enter facilities',
                        keyboardType: TextInputType.multiline,
                        controller: _facilitiesController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter facilities';
                          }
                          return null;
                        },
                      ),

                      // Add space between elements
                      const SizedBox(height: 15),

                      // Accesibilities Textfield
                      CustomTextFormField(
                        label: 'Property Name',
                        hintText: 'Enter property name',
                        keyboardType: TextInputType.multiline,
                        controller: _accessibilitiesController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Consumer _buildImageSection() {
    return Consumer<ImageService>(builder: (context, imageProvider, _) {
      _images = imageProvider.images;

      return SizedBox(
        height: _images.isEmpty ? null : 180,
        child: _images.isEmpty
            ? Text(
                'No images selected',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              )
            : _buildListImages(),
      );
    });
  }

  ListView _buildListImages() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _images.length,
      itemBuilder: (context, index) {
        String imagePath = _images[index];
        bool isNetworkImage =
            imagePath.startsWith('http') || imagePath.startsWith('https');

        return _showImage(imagePath, isNetworkImage, index);
      },
    );
  }

  // ************* Upload Image Functions (Start) *************

  Widget _showImage(String imageUrl, bool isNetworkImage, int index) {
    return Stack(
      children: [
        Container(
          width: 160,
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadiusDirectional.circular(10),
            child: isNetworkImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                : Image.file(
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
            onTap: () => _imageService.removeImage(index),
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

  Future<void> _showPickImagesDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photos'),
                onTap: () {
                  _pickMultipleImagesFromCamera(context);
                  Navigator.pop(innerContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickImagesFromGallery(context);
                  Navigator.pop(innerContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImagesFromGallery(BuildContext context) async {
    try {
      final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        for (XFile file in pickedFiles) {
          _imageService.addImage(file.path);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to pick images. Please try again."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImagesFromCamera(BuildContext context) async {
    try {
      while (true) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          _imageService.addImage(pickedFile.path);
        } else {
          break; // User cancelled the camera, stop the loop
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to pick image. Please try again."),
            duration: Duration(seconds: 3),
          ),
        );
      }
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Save button
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updatePropertyDetails(context);
              }
            },
            child: const Text('Save'), // Adjust color as needed
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color.
              spreadRadius: 2,
              blurRadius: 3, // Shadow blur radius.
              offset: const Offset(0, 2), // Vertical offset for the shadow.
            ),
          ], color: Colors.white),
        ));
  }

  // Function to fetch property details
  Future<DocumentSnapshot?> fetchPropertyDetails() async {
    // Fetch the property document first
    DocumentSnapshot propertySnapshot = await _fireStore
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
  Future<void> _updatePropertyDetails(BuildContext context) async {
    try {
      // Show loading indicator
      setState(() {
        _isSaving = true;
      });

      final List<String> newImageUrls = await _uploadImages();
      final List<String> invalidImageUrls = _getInvalidImageUrls();

      if (context.mounted) {
        await _deleteInvalidImages(invalidImageUrls);
      }

      final List<String> updatedImages = _getUpdatedImageUrls(newImageUrls);

      final propertyDetailsMap = {
        'name': _nameController.text,
        'address': _locationController.text,
        'rent': double.parse(_rentPriceController.text),
        'size': num.parse(_sizeController.text),
        'bathrooms': int.parse(_bathroomController.text),
        'bedrooms': int.parse(_bedroomController.text),
        'description': _descriptionController.text,
        'furnishing': _furnishingController.text,
        'facilities': _facilitiesController.text,
        'accessibilities': _accessibilitiesController.text,
        'image': updatedImages,
      };

      // Update the property details
      await _fireStore
          .collection('properties')
          .doc(widget.propertyID)
          .update(propertyDetailsMap);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property details updated successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = getErrorMessage(e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final List<String> downloadUrls = [];
    final uploadImagesPath = _images
        .where(
            (image) => !image.startsWith('http') && !image.startsWith('https'))
        .toList();

    if (uploadImagesPath.isNotEmpty) {
      for (String imagePath in uploadImagesPath) {
        File file = File(imagePath);
        String fileName =
            "images/properties/${widget.propertyID}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
        try {
          final ref = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          final url = await snapshot.ref.getDownloadURL();
          downloadUrls.add(url);
        } catch (_) {
          rethrow;
        }
      }
    }

    return downloadUrls;
  }

  List<String> _getUpdatedImageUrls(List<String> newImageUrls) {
    final List<String> updatedUrls = [];

    // Add existing image URLs
    updatedUrls.addAll(_images.where(
        (image) => image.startsWith('http') || image.startsWith('https')));

    // Add new image URLs
    updatedUrls.addAll(newImageUrls);

    return updatedUrls;
  }

  List<String> _getInvalidImageUrls() {
    return _copyImages.where((image) => !_images.contains(image)).toList();
  }

  Future<void> _deleteInvalidImages(List<String> invalidImageUrls) async {
    if (invalidImageUrls.isNotEmpty) {
      for (String invalidImageUrl in invalidImageUrls) {
        try {
          await FirebaseStorage.instance.refFromURL(invalidImageUrl).delete();
        } catch (_) {
          rethrow;
        }
      }
    }
  }
}

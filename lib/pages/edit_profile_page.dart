import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/model/user/user.dart';
import 'package:hrs/provider/refresh_provider.dart';
import 'package:hrs/services/utils/error_message_utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Text editing controller
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final User user = FirebaseAuth.instance.currentUser!;
  ImageProvider? _initialProfilePicture;
  File? _imageFile;
  bool _showInitialProfilePicture = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile.profilePictureURL != null) {
      _initialProfilePicture =
          NetworkImage(widget.userProfile.profilePictureURL!);
      _showInitialProfilePicture = true;
    }

    // Set initial value of name textfield
    _nameController.text = widget.userProfile.name ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Edit Profile"),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context),
    );
  }

  Padding _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePicture(context),

            // Add space between elements
            const SizedBox(height: 20),

            // Name textfield
            _buildTextFormField(context),

            // Add space between elements
            const SizedBox(height: 20),

            _buildButton()
          ],
        ),
      ),
    );
  }

  Center _buildProfilePicture(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a photo'),
                      onTap: () {
                        _pickImage(ImageSource.camera, context);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from gallery'),
                      onTap: () {
                        _pickImage(ImageSource.gallery, context);
                        Navigator.pop(context);
                      },
                    ),
                    // Remove profile picture option if there is an image
                    if (_imageFile != null || _showInitialProfilePicture)
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove profile picture',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          setState(() {
                            _imageFile = null;
                            _showInitialProfilePicture = false;
                          });
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              image: DecorationImage(
                image: _imageFile != null
                    ? FileImage(_imageFile!)
                    : _showInitialProfilePicture &&
                            _initialProfilePicture != null
                        ? _initialProfilePicture!
                        : MemoryImage(kTransparentImage), // Transparent image
                fit: BoxFit.cover,
                opacity: 0.7,
              )),
          alignment: Alignment.center,
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
            label: "Name",
            hintText: "Enter your name",
            nameController: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name cannot be empty";
              }

              // Check if the value contains any special characters
              if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%$]').hasMatch(value)) {
                return "Name cannot contain special characters";
              }
              return null;
            },
            onChanged: (value) {
              List<String> words = value.split(' ');
              String capitalized = words.map((word) {
                if (word.isEmpty) return word;
                if (word.length == 1) return word.toUpperCase();
                return word[0].toUpperCase() + word.substring(1).toLowerCase();
              }).join(' ');
              if (value != capitalized) {
                final cursorPosition = _nameController.selection.base.offset;
                _nameController.value = _nameController.value.copyWith(
                  text: capitalized,
                  selection: TextSelection.collapsed(offset: cursorPosition),
                );
              }
            }),
      ],
    );
  }

  Row _buildButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.96),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Hide keyboard
                FocusScope.of(context).unfocus();

                setState(() {
                  _isLoading = true;
                });

                // Update the user profile
                _updateProfile();
              }
            },
            child: const Text("Confirm"),
          ),
        ),
      ],
    );
  }

  void _updateProfile() async {
    String? newProfilePictureURL;
    final userRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    try {
      // If user has selected a new profile picture, upload it to Firebase Storage
      // and get the download URL
      if (_imageFile != null) {
        final fileName =
            "images/users/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.uri.pathSegments.last}";
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final uploadTask = ref.putFile(_imageFile!);

        final snapshot = await uploadTask;
        newProfilePictureURL = await snapshot.ref.getDownloadURL();
      }

      // Create a map of data to update
      final Map<String, dynamic> updateData = {
        "name": _nameController.text,
      };

      // If user has selected a new profile picture, add it to the map
      if (newProfilePictureURL != null) {
        updateData["profilePictureURL"] = newProfilePictureURL;
      }
      // If user has removed the profile picture, set the profile picture URL to null
      else if (!_showInitialProfilePicture) {
        updateData["profilePictureURL"] = null;
      }

      await userRef.update(updateData);

      // If user's profile picture has been updated,
      // delete the old profile picture from Firebase Storage
      if (widget.userProfile.profilePictureURL != null) {
        final oldRef = FirebaseStorage.instance
            .refFromURL(widget.userProfile.profilePictureURL!);
        print("Old ref: $oldRef");
        await oldRef.delete();
      }

      if (context.mounted) {
        context.read<RefreshProvider>().profileRefresh = true;

        // Go back to the previous page
        Navigator.pop(context);
        Navigator.pop(context, "Profile updated successfully");
      }
    } catch (e) {
      String errorMessage;

      if (e is FirebaseException) {
        switch (e.code) {
          case 'storage/canceled':
            errorMessage = canceledErrorMessage;
            break;
          case 'storage/unauthorized':
            errorMessage = unauthorizedErrorMessage;
            break;
          case 'storage/unknown':
            errorMessage = unknownErrorMessage;
            break;
          default:
            errorMessage = genericUpdateErrorMessage;
        }
      } else {
        errorMessage = genericUpdateErrorMessage;
      }

      if (context.mounted) {
        Navigator.pop(context, errorMessage);
      }
    }
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarColor: const Color(0xFF8568F3),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
          ],
        );
        if (croppedFile != null) {
          setState(() {
            _imageFile = File(croppedFile.path);
          });
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
}

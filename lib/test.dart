import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String _phoneNumber = "1234567890";
  final String role = "Tenant";
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: "Account Details"),
        body: _buildForm(context));
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

  Row _buildButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8568F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.96),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print("Name: ${_nameController.text}");
              }
            },
            child: const Text("Create Account"),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    return CustomTextFormField(
        label: "Name",
        hintText: "Enter your name",
        controller: _nameController,
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
          print("Text field value changed to: $value");
          String capitalized = value.split(' ').map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');
          if (value != capitalized) {
            _nameController.value = _nameController.value.copyWith(
              text: capitalized,
              selection: TextSelection.collapsed(offset: capitalized.length),
            );
          }
        });
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
                    if (_imageFile != null)
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove profile picture',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          setState(() {
                            _imageFile = null;
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
                image: FileImage(_imageFile ?? File('')),
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

          print("Image path: ${_imageFile!.uri}");
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

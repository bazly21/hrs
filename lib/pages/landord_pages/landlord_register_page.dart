///////// L A N D L O R D  R E G I S T E R  P A G E /////////
// For register, it contains 3 pages
// 1. Enter phone number page
// 2. Enter OTP (One-Time Password) page
// 3. Create password page

// The flow of register are as follows:
// 1. First, the user enter their phone number
// 2. Then, the system will check if the phone number already exist in the database or not
// 2. Then, they will receive one SMS that contains the OTP
// 3. Next, the user must enter their OTP
// 4. If the entered OTP is correct, then they can proceed to create the password

// Import
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/pages/landord_pages/landlord_navigation_page.dart';
import 'package:hrs/services/auth/auth_service.dart';

class LandlordRegisterPage extends StatefulWidget {
  final String? statusMessage;

  const LandlordRegisterPage({super.key, this.statusMessage});

  @override
  State<LandlordRegisterPage> createState() => _LandlordRegisterPageState();
}

class _LandlordRegisterPageState extends State<LandlordRegisterPage> {
  // Text editing controller
  final TextEditingController _phoneNumberController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    if (widget.statusMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.statusMessage!)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Register as Landlord"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Add space between elements
              const SizedBox(height: 20),

              // Phone number label
              const MyLabel(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Phone number",
                  fontSize: 16.0),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone Number textfield
              MyTextField(
                controller: _phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                text: "Next",
                onPressed: () => _authService.authentication(
                  context: context,
                  phoneNumber: _phoneNumberController.text,
                  role: "Landlord",
                  method: "Register",
                ),
              ),

              // Add space between elements
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class LandlordEnterDetailsPage extends StatelessWidget {
  LandlordEnterDetailsPage({super.key, required this.phoneNumber});

  // Text editing controller
  final nameController = TextEditingController();
  final String phoneNumber;

  // Function to register profile name to the FireStore
  void registerProfileName(BuildContext context) async {
    // Get value of the name textfield in String / text format
    String profileName = nameController.text.trim();

    if (profileName.isNotEmpty) {
      // Get current user's information
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore db = FirebaseFirestore.instance;

      if (user != null) {
        //Get UID (User ID)
        String uid = user.uid;

        try {
          // Store profileName to the FireStore database
          await db.collection('users').doc(uid).set({
            'name': profileName,
            "role": ["Landlord"],
            "phoneNumber": phoneNumber
          }, SetOptions(merge: true));

          // Check if the widget is still mounted before navigating
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LandlordNavigationPage()),
              (Route<dynamic> route) =>
                  false, // This predicate will never be true, so it removes all the routes below the new one.
            );
          }
        } catch (e) {
          if (context.mounted) {
            // Display error message if the storing operation is failed
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Something happened while storing profile name. Please try again")));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Account Details"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Add space between elements
              const SizedBox(height: 20),

              // Name textfield label
              const MyLabel(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Name",
                  fontSize: 16.0),

              // Add space between elements
              const SizedBox(height: 10),

              // Name textfield
              MyTextField(
                controller: nameController,
                hintText: "Enter your full name",
                obscureText: false,
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                  text: "Create Account",
                  onPressed: () => registerProfileName(context)),
            ],
          ),
        ),
      ),
    );
  }
}

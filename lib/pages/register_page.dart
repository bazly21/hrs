///////// R E G I S T E R  P A G E /////////
// For register, it contains 3 pages
// 1. Enter phone number page
// 2. Enter OTP (One-Time Password) page
// 3. Create password page

// The flow of register are as follows:
// 1. First, the user enter their phone number
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
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/otp_confirmation_page.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controller
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Function to send OTP code
  Future<void> sendOTP(BuildContext context) async {
    // Only support Malaysia phone number format "+60"
    final phoneNumber = "+6${_phoneNumberController.text.trim()}";
    print(phoneNumber);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification completed.
      },
      verificationFailed: (FirebaseAuthException e) {
        // Show error message if the verification failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An error occurred")),
        );
        print("Error: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to ConfirmationPage and pass verificationId.
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTPConfirmationPage(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                  buttonText: 'Register')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Register"),
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
                onPressed: () => sendOTP(context),
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

class PasswordPage extends StatelessWidget {
  PasswordPage({super.key, required this.phoneNumber});

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
            "role": ["Tenant"],
            "phoneNumber": phoneNumber
          }, SetOptions(merge: true));

          // Check if the widget is still mounted before navigating
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const NavigationPage()),
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

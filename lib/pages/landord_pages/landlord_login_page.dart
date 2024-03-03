// Components import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Packages import
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/pages/landord_pages/landlord_otp_confirmation_page.dart';
import 'package:hrs/pages/landord_pages/landlord_register_page.dart';
import 'package:hrs/pages/register_page.dart';

class LandlordLoginPage extends StatelessWidget {
  LandlordLoginPage({super.key});

  // Text editing controller
  final phoneNumberController = TextEditingController();
  final db = FirebaseFirestore.instance;

  // Function to send OTP code
  Future<void> sendOTP(BuildContext context) async {
    // Only support Malaysia phone number format "+60"
    final phoneNumber = "+6${phoneNumberController.text.trim()}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification completed.
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error.
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to ConfirmationPage and pass verificationId.
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LandlordOTPConfirmationPage(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                  buttonText: 'Login', 
                  hasRegister: true,)),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> checkPhoneNumber(BuildContext context) async {
    // Only support Malaysia phone number format "+60"
    final phoneNumber = "+6${phoneNumberController.text.trim()}";

    // Check if the phone number is registered
    final querySnapshot = await db
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .where("role", arrayContains: "Landlord")
        .get();

    if (querySnapshot.docs.isEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LandlordRegisterPage(
                  statusMessage:
                      "You are not registered as landlord yet. Please complete your registration.")),
        );
      }
    } else {
      if (context.mounted) {
        sendOTP(context);
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Login as Landlord"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Add space between elements
              const SizedBox(height: 30),

              // Phone Number label
              const MyLabel(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Phone number",
                  fontSize: 16.0),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone number textfield
              MyTextField(
                controller: phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Log in button
              MyButton(
                  text: "Login", onPressed: () => checkPhoneNumber(context)),

              // Add space between elements
              const SizedBox(height: 14),

              // Link to the Register page
              RichTextLink(
                  text1: "Do not have an account? ",
                  text2: "Register",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

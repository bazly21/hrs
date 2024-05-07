import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/register_page.dart';

class OTPConfirmationPage extends StatelessWidget {
  OTPConfirmationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.buttonText
  });

  final String phoneNumber, verificationId, buttonText;
  final otpController = TextEditingController();

  // Function to verify OTP code
  void verifyOTP(BuildContext context) async {
    final otp = otpController.text.trim();

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    // Sign in the user with the credential
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Checking if the user is new or existing
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? true;

      // If the user is a new user
      if (isNewUser) {
        // Check if the widget is still mounted before navigating
        if (context.mounted) {
          // Navigate to the PasswordPage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => PasswordPage(phoneNumber: phoneNumber)),
            (Route<dynamic> route) =>
                false, // This predicate will never be true, so it removes all the routes below the new one.
          );
        }
      }
      // If the user is existing user
      else {
        // Check if the widget is still mounted before navigating
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NavigationPage()),
            (Route<dynamic> route) =>
                false, // This predicate will never be true, so it removes all the routes below the new one.
          );
        }
      }
    } on FirebaseAuthException {
      if (context.mounted) {
        // Display error message if the storing operation is failed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something error happened. Please try again")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Confirmation Code"),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Add space between elements
              const SizedBox(height: 20),

              // Phone number label
              const MyLabel(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Confirmation code",
                  fontSize: 16.0),

              // Phone number label
              MyLabel(
                mainAxisAlignment: MainAxisAlignment.start,
                text: "An SMS was sent to $phoneNumber",
                fontSize: 13.0,
                color: const Color(0xFFA6A6A6),
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone Number textfield
              MyTextField(
                controller: otpController,
                hintText: "Enter your confirmation code",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(text: buttonText, onPressed: () => verifyOTP(context)),
            ],
          ),
        ),
      ),
    );
  }
}

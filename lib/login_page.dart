// Components import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hrs/register_page.dart';

import 'components/my_textfield.dart';
import 'components/my_label.dart';
import 'components/my_button.dart';
import 'components/my_richtext.dart';
import 'components/my_appbar.dart';

// Packages import
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Pages import
import 'otp_confirmation_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Text editing controller
  final phoneNumberController = TextEditingController();

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
              builder: (context) => OTPConfirmationPage(
                  verificationId: verificationId, phoneNumber: phoneNumber, buttonText: 'Login')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Login"),
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
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone number textfield
              MyTextField(
                controller: phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [FilteringTextInputFormatter.digitsOnly],
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Log in button
              MyButton(
                text: "Login",
                onPressed: () => sendOTP(context)
              ),

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
                }
              ),                  
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';

class TestPage extends StatefulWidget {
  const TestPage({
    super.key,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String userID = FirebaseAuth.instance.currentUser!.uid;
  final String oldPhoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;

  int _counter = 20;
  bool _disabledResend = true;
  String? _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();

    // Start the timer once the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "OTP Verification",
      ),
      body: _buildForm(context),
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
            // New phone number textfield
            _buildTextFormField(),

            // Add space between elements
            if (_counter != 0) ...[
              const SizedBox(height: 16),
              _buildTimerText(),
            ],

            // Add space between elements
            const SizedBox(height: 25),

            _buildButton(),

            // Add space between elements
            const SizedBox(height: 15),

            _buildResendOTPButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField() {
    return CustomTextFormField(
      label: "OTP code",
      hintText: "Enter OTP code",
      controller: _otpController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "OTP code cannot be empty";
        }

        // Check if the value contains any non-numeric characters
        if (RegExp(r'\D').hasMatch(value)) {
          return "OTP code must contain numbers only";
        }

        return null;
      },
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _signInWithOTP(_otpController.text.trim());
              }
            },
            child: const Text("Next"),
          ),
        ),
      ],
    );
  }

  Row _buildResendOTPButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF462AB5),
                surfaceTintColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey, width: 0.7))),
            onPressed: _disabledResend
                ? null
                : () {
                    setState(() {
                      // Reset the counter to 20 seconds
                      _counter = 20;
                      // Disable the button
                      _disabledResend = true;
                    });

                    // Start the timer
                    startTimer();
                  },
            child: const Text("Resend OTP"),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerText() {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: "Resend OTP in ",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: "$_counter",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: " seconds"),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer.periodic(onsec, (timer) {
      if (_counter == 0) {
        setState(() {
          timer.cancel();
          _disabledResend = false;
        });
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  Future<void> _signInWithOTP(String otp) async {
    try {
      // Create a PhoneAuthCredential with the verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Update the user's phone number with the new phone number
      await user?.updatePhoneNumber(credential);

      // Sign in the user with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigation or showing a success message
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context, "Phone number updated successfully!");
      }
    } catch (e) {
      // Handle any errors that occurred during the sign-in process
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("An error occurred during sign-in. Please try again."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    // Resend the OTP
    // Create dummy phone number
    const phoneNumber = "+60123456789";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Navigation or showing a success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Phone number verified successfully!"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("An error occurred while verifying the phone number."),
            duration: Duration(seconds: 3),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        // OTP has been sent to the new phone number
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _counter = 20; // Reset the counter to 20 seconds
          _disabledResend = true; // Disable the button
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
        
      },
    );

    // Start the timer
    startTimer();
  }
}

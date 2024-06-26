import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/provider/refresh_provider.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/utils/error_message_utils.dart';
import 'package:provider/provider.dart';

class ChangePhoneNumberPage extends StatefulWidget {
  const ChangePhoneNumberPage({super.key, required this.oldPhoneNumber});

  final String oldPhoneNumber;

  @override
  State<ChangePhoneNumberPage> createState() => _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends State<ChangePhoneNumberPage> {
  // Text editing controller
  final TextEditingController _phoneNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final User user = FirebaseAuth.instance.currentUser!;
  late String cleanedOldPhoneNumber;

  @override
  void initState() {
    super.initState();
    cleanedOldPhoneNumber = widget.oldPhoneNumber.substring(2);
  }

  @override
  void dispose() {
    _phoneNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Change Phone Number"),
      backgroundColor: Colors.white,
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
            _buildTextFormField(context),

            // Add space between elements
            const SizedBox(height: 20),

            _buildButton()
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          label: "New phone number",
          hintText: "Enter new phone number",
          controller: _phoneNumController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Phone number cannot be empty";
            }

            // Check if the value contains any non-numeric characters
            if (RegExp(r'\D').hasMatch(value)) {
              return "Phone number must contain numbers only";
            }

            // Check if the phone number starts with 0
            if (!value.startsWith('0')) {
              return "Phone number must start with 0";
            }

            if (value == cleanedOldPhoneNumber) {
              return "New phone number cannot be the same as the old phone number";
            }

            return null;
          },
        ),
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Hide keyboard
                FocusScope.of(context).unfocus();

                // Store new phone number
                String newPhoneNumber = "+6${_phoneNumController.text.trim()}";

                // Send OTP to the new phone number
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: newPhoneNumber,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {},
                  verificationFailed: (FirebaseAuthException e) {
                    // Handle verification failure
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            "An error occurred while verifying the phone number."),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  codeSent: (String verificationId, int? resendToken) {
                    // OTP has been sent to the new phone number
                    NavigationUtils.pushPage(
                        context,
                        OTPVerificationPage(
                            phoneNumber: newPhoneNumber,
                            verificationId: verificationId),
                        SlideDirection.left);
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {},
                );
              }
            },
            child: const Text("Next"),
          ),
        ),
      ],
    );
  }
}

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Timer _timer;

  int _counter = 20;
  bool _disabledResend = true;
  String? _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();

    // Initialize verification ID
    _verificationId = widget.verificationId;

    // Start the timer once the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer.cancel();
    super.dispose();
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

            _buildConfirmButton(),

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

  Row _buildConfirmButton() {
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Hide keyboard
                FocusScope.of(context).unfocus();

                _signInWithOTP(_otpController.text.trim());
              }
            },
            child: const Text("Confirm"),
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
                    // Hide keyboard
                    FocusScope.of(context).unfocus();

                    _resendOTP();
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
    _timer = Timer.periodic(onsec, (timer) {
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

  void _signInWithOTP(String otp) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Throw an error if user is null
      if (user == null) {
        throw FirebaseAuthException(
          code: 'invalid-access',
          message: 'User is not signed in.',
        );
      }

      // Create a PhoneAuthCredential with the verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);

      // Update the user's phone number with the new phone number
      await user.updatePhoneNumber(credential);

      // Force refresh user data to get the latest information
      await user.reload();

      // Store the updated user information
      user = FirebaseAuth.instance.currentUser;

      // Throw an error if user is null
      if (user == null) {
        throw FirebaseAuthException(
          code: 'invalid-access',
          message: 'User is not signed in.',
        );
      }

      // Change the phone number in the database
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"phoneNumber": user.phoneNumber});

      // Navigation or showing a success message
      if (context.mounted) {
        context.read<RefreshProvider>().profileRefresh = true;
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context, "Phone number updated successfully!");
      }
    } catch (e) {
      // Handle any errors that occurred during the update process
      String errorMessage;

      if (e is FirebaseException) {
        switch (e.code) {
          case 'auth/invalid-phone-number':
            errorMessage = invalidPhoneNumberErrorMessage;
            break;
          case 'auth/too-many-requests':
            errorMessage = tooManyRequestsErrorMessage;
            break;
          case 'auth/network-request-failed':
            errorMessage = networkRequestFailedErrorMessage;
            break;
          case 'phone-number-already-exists':
            errorMessage = phoneNumberExistsErrorMessage;
            break;
          case 'auth/quota-exceeded':
            errorMessage = quotaExceededErrorMessage;
            break;
          case 'invalid-access':
            errorMessage = invalidAccessErrorMessage;
            break;
          default:
            errorMessage = unknownErrorMessage;
        }
      } else {
        errorMessage = unknownErrorMessage;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _resendOTP() async {
    // Resend the OTP
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        String errorMessage = getErrorMessage(e);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // OTP has been sent to the new phone number
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _counter = 20; // Reset the counter to 20 seconds
          _disabledResend = true; // Disable the button
        });

        // Start the timer
        startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP has been resent"),
            duration: Duration(seconds: 3),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}

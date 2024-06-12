import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/utils/error_message_utils.dart';
import 'package:provider/provider.dart';

class OTPConfirmationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String buttonText;
  final String role;

  const OTPConfirmationPage(
      {super.key,
      required this.phoneNumber,
      required this.verificationId,
      required this.buttonText,
      required this.role});

  @override
  State<OTPConfirmationPage> createState() => _OTPConfirmationPageState();
}

class _OTPConfirmationPageState extends State<OTPConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

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
      appBar: const CustomAppBar(title: "OTP Confirmation"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      ),
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

                context.read<AuthService>().verifyOTP(
                  context: context,
                  verificationId: _verificationId!,
                  otpCode: _otpController.text,
                  role: widget.role,
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ),
      ],
    );
  }

  CustomTextFormField _buildTextFormField() {
    return CustomTextFormField(
      label: "Confirmation Code",
      subText: "An SMS was sent to ${widget.phoneNumber}",
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

  Row _buildResendOTPButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

  void _resendOTP() async {
    // Resend the OTP
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        String errorMessage;

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
          default:
            errorMessage = unknownErrorMessage;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
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

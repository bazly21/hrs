import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/services/auth/auth_service.dart';

class OTPConfirmationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String buttonText;
  final String role;

  const OTPConfirmationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.buttonText,
    required this.role
  });


  @override
  State<OTPConfirmationPage> createState() => _OTPConfirmationPageState();
}

class _OTPConfirmationPageState extends State<OTPConfirmationPage> {
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();

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
                text: "An SMS was sent to ${widget.phoneNumber}",
                fontSize: 13.0,
                color: const Color(0xFFA6A6A6),
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone Number textfield
              MyTextField(
                controller: _otpController,
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
              MyButton(text: widget.buttonText, onPressed: () => _authService.verifyOTP(
                context: context,
                verificationId: widget.verificationId,
                otpCode: _otpController.text,
                role: widget.role
              )),
            ],
          ),
        ),
      ),
    );
  }
}

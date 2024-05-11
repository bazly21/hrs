///////// R E G I S T E R  P A G E /////////
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controller
  final _phoneNumberController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
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
                onPressed: () => _authService.authentication(
                    context: context,
                    phoneNumber: _phoneNumberController.text,
                    role: "Tenant",
                    method: "Register"),
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

class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({
    super.key,
    required this.phoneNumber
  });

  final String phoneNumber;

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  // Text editing controller
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                controller: _nameController,
                hintText: "Enter your full name",
                obscureText: false,
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                  text: "Create Account",
                  onPressed: () => _authService.registerProfile(
                      context: context,
                      phoneNumber: widget.phoneNumber,
                      profileName: _nameController.text,
                      role: "Tenant"
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

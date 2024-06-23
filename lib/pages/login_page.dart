// Components import
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/pages/register_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controller
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.role == "Tenant" ? "Login" : "Login as Landlord",
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Phone number textfield
              CustomTextFormField(
                controller: _phoneNumberController,
                label: "Phone number",
                hintText: "Enter your phone number",
                keyboardType: TextInputType.number,
                validator: (value) {
                  // Check if the phone number is empty
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }

                  // Check if the phone number is not a number
                  if (RegExp(r'\D').hasMatch(value)) {
                    return "Phone number cannot contain letters or special characters";
                  }

                  // Check if the phone number start with other than 0
                  if (!value.startsWith("0")) {
                    return "Phone number must start with 0";
                  }

                  // Check if the phone number is less than 10 digits
                  if (value.length < 10) {
                    return "Phone number must be at least 10 digits long";
                  }

                  return null;
                },
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Log in button
              CustomButton(
                text: "Login",
                onPressed: validate,
              ),

              // Add space between elements
              const SizedBox(height: 14),

              // Link to the Register page
              RichTextLink(
                  text1: "Do not have an account? ",
                  text2: "Register",
                  onTap: () {
                    NavigationUtils.pushPage(context,
                        RegisterPage(role: widget.role), SlideDirection.left);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  // Validate function
  void validate() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthService>().authentication(
            context: context,
            phoneNumber: _phoneNumberController.text,
            role: widget.role,
            method: "Login",
          );
    }
  }
}

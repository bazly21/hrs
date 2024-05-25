// Components import
import 'package:flutter/material.dart';
// Packages import
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/components/my_textfield.dart';
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

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(text: widget.role == "Tenant" ? "Login" : "Login as Landlord"),
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

              // Log in button
              MyButton(
                text: "Login",
                onPressed: () => context.read<AuthService>().authentication(
                    context: context,
                    phoneNumber: _phoneNumberController.text,
                    role: widget.role,
                    method: "Login"),
              ),

              // Add space between elements
              const SizedBox(height: 14),

              // Link to the Register page
              RichTextLink(
                  text1: "Do not have an account? ",
                  text2: "Register",
                  onTap: () {
                    NavigationUtils.pushPage(
                        context, RegisterPage(role: widget.role), SlideDirection.left);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

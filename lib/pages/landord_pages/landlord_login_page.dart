// Components import
import 'package:flutter/material.dart';
// Packages import
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_richtext.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/pages/landord_pages/landlord_register_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class LandlordLoginPage extends StatefulWidget {
  const LandlordLoginPage({super.key});

  @override
  State<LandlordLoginPage> createState() => _LandlordLoginPageState();
}

class _LandlordLoginPageState extends State<LandlordLoginPage> {
  // Text editing controller
  final TextEditingController _phoneNumberController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
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
                  onPressed: () => _authService.authentication(
                      context: context,
                      phoneNumber: _phoneNumberController.text,
                      role: "Landlord",
                      method: "Login")),

              // Add space between elements
              const SizedBox(height: 14),

              // Link to the Register page
              RichTextLink(
                  text1: "Do not have an account? ",
                  text2: "Register",
                  onTap: () {
                    NavigationUtils.pushPage(
                      context,
                      const LandlordRegisterPage(),
                      SlideDirection.left,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

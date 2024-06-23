// Components import
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_phone_number_form.dart';
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
          child: CustomPhoneNumberForm(
            formKey: _formKey,
            controller: _phoneNumberController,
            buttonOnPressed: validate,
            linkOnTap: () {
              NavigationUtils.pushPage(
                context,
                RegisterPage(role: widget.role),
                SlideDirection.left,
              );
            },
          )),
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



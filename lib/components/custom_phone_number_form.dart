import 'package:flutter/material.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/components/my_button.dart';

class CustomPhoneNumberForm extends StatelessWidget {
  const CustomPhoneNumberForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController controller,
    required void Function() buttonOnPressed,
    required void Function()? linkOnTap,
    bool hasRegisterLink = true,
  })  : _formKey = formKey,
        _controller = controller,
        _buttonOnPressed = buttonOnPressed,
        _linkOnTap = linkOnTap,
        _hasRegisterLink = hasRegisterLink,
        assert(
          !hasRegisterLink || linkOnTap != null,
          'linkOnTap is required when hasRegisterLink is true',
        );

  final GlobalKey<FormState> _formKey;
  final TextEditingController _controller;
  final void Function() _buttonOnPressed;
  final void Function()? _linkOnTap;
  final bool _hasRegisterLink;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Phone number textfield
          CustomTextFormField(
            controller: _controller,
            label: "Phone number",
            hintText: "Enter your phone number",
            keyboardType: TextInputType.phone,
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
            onPressed: _buttonOnPressed,
          ),

          // Only show the Register link if hasRegisterLink is true
          if (_hasRegisterLink) ...[
            // Add space between elements
            const SizedBox(height: 14),

            // Link to the Register page
            RichTextLink(
              text1: "Do not have an account? ",
              text2: "Register",
              onTap: _linkOnTap!,
            ),
          ]
        ],
      ),
    );
  }
}
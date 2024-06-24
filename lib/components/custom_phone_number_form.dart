import 'package:flutter/material.dart';
import 'package:hrs/components/custom_richtext.dart';
import 'package:hrs/components/custom_textformfield.dart';
import 'package:hrs/components/my_button.dart';

class CustomPhoneNumberForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final void Function() buttonOnPressed;
  final void Function()? linkOnTap;
  final bool hasRegisterLink;

  const CustomPhoneNumberForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.buttonOnPressed,
    required this.linkOnTap,
    this.hasRegisterLink = true,
  }) : assert(
          !hasRegisterLink || linkOnTap != null,
          'linkOnTap is required when hasRegisterLink is true',
        );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Phone number textfield
          CustomTextFormField(
            controller: controller,
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
            onPressed: buttonOnPressed,
          ),

          // Only show the Register link if hasRegisterLink is true
          if (hasRegisterLink) ...[
            // Add space between elements
            const SizedBox(height: 14),

            // Link to the Register page
            RichTextLink(
              text1: "Do not have an account? ",
              text2: "Register",
              onTap: linkOnTap!,
            ),
          ]
        ],
      ),
    );
  }
}

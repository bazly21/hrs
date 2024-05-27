import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_textformfield.dart';

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

            if(value == cleanedOldPhoneNumber) {
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Hide keyboard
                FocusScope.of(context).unfocus();

                // Update the user profile
                // _updateProfile();
              }
            },
            child: const Text("Confirm"),
          ),
        ),
      ],
    );
  }
}

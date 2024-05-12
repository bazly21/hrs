///////// L A N D L O R D  R E G I S T E R  P A G E /////////
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_button.dart';
import 'package:hrs/components/my_label.dart';
import 'package:hrs/components/my_textfield.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LandlordRegisterPage extends StatefulWidget {

  const LandlordRegisterPage({super.key});

  @override
  State<LandlordRegisterPage> createState() => _LandlordRegisterPageState();
}

class _LandlordRegisterPageState extends State<LandlordRegisterPage> {
  // Text editing controller
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "Register as Landlord"),
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
                onPressed: () => context.read<AuthService>().authentication(
                  context: context,
                  phoneNumber: _phoneNumberController.text,
                  role: "Landlord",
                  method: "Register",
                ),
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
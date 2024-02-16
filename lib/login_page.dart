// Components import
import 'components/my_textfield.dart';
import 'components/my_label.dart';
import 'components/my_button.dart';
import 'components/my_richtext.dart';
import 'components/my_appbar.dart';

// Packages import
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Pages import
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Text editing controller
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        text: "Login",
        appBarContent: "Title"
      ),
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
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone number textfield
              MyTextField(
                controller: phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [FilteringTextInputFormatter.digitsOnly],
              ),

              // Add space between elements
              const SizedBox(height: 20),

              // Password label
              const MyLabel(
                mainAxisAlignment: MainAxisAlignment.start, 
                text: "Password", 
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Password textfield
              MyTextField(
                controller: passwordController,
                hintText: "Enter your password",
                obscureText: true,
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Forgot password
              const MyLabel(
                mainAxisAlignment: MainAxisAlignment.end, 
                text: "Forgot password?", 
                fontSize: 12.0,
                color: Color(0xFF8568F3)
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Log in button
              MyButton(
                text: "Login",
                onPressed: () {
                  // Navigator.push(
                  //   context, 
                  //   MaterialPageRoute(builder: (context) => RegisterPage())
                  // );
                },
              ),

              // Add space between elements
              const SizedBox(height: 14),

              // Link to the Register page
              MyRichText(
                text1: "Do not have an account? ", 
                text2: "Register", 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                }
              ),                  
            ],
          ),
        ),
      ),
    );
  }
}

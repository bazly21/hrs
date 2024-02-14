///////// R E G I S T E R  P A G E /////////
// For register, it contains 3 pages
// 1. Enter phone number page
// 2. Enter OTP (One-Time Password) page
// 3. Create password page

// The flow of register are as follows:
// 1. First, the user enter their phone number
// 2. Then, they will receive one SMS that contains the OTP
// 3. Next, the user must enter their OTP
// 4. If the entered OTP is correct, then they can proceed to create the password


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
import 'login_page.dart';

class RegisterPage extends StatelessWidget {

  RegisterPage({
    super.key,
  });

  // Text editing controller
  final phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Register",
        iconButton: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone Number textfield
              MyTextField(
                controller: phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [FilteringTextInputFormatter.digitsOnly],
              ),
              
              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                text: "Next",
                onPressed: () {
                  String phoneNumberStr = phoneNumberController.text; // Get data from the phone number textfield

                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ConfirmationPage(phoneNumber: phoneNumberStr))
                  );
                  // print("Go to register page");
                },
              ),

              // Add space between elements
              const SizedBox(height: 14),

              MyRichText(
                text1: "Already have an account? ", 
                text2: "Login", 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
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

class ConfirmationPage extends StatelessWidget {

  ConfirmationPage({
    super.key,
    required this.phoneNumber
  });

  // Text editing controller
  final String phoneNumber;
  final confirmationCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Confirmation Code",
        iconButton: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                text: "Confirmation code", 
                fontSize: 16.0
              ),

              // Phone number label
              MyLabel(
                mainAxisAlignment: MainAxisAlignment.start, 
                text: "An SMS was sent to $phoneNumber", 
                fontSize: 13.0,
                color: const Color(0xFFA6A6A6),
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Phone Number textfield
              MyTextField(
                controller: confirmationCode,
                hintText: "Enter your confirmation code",
                obscureText: false,
                textInputType: TextInputType.number,
                filteringTextInputFormatter: [FilteringTextInputFormatter.digitsOnly],
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                text: "Next",
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => PasswordPage())
                  );
                  // print("Go to register page");
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordPage extends StatelessWidget {

  PasswordPage({super.key});

  // Text editing controller
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Create Account",
        iconButton: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Name textfield
              MyTextField(
                controller: nameController,
                hintText: "Enter your full name",
                obscureText: true,
              ),

              // Add space between elements
              const SizedBox(height: 20),

              // Password textfield label
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
              const SizedBox(height: 20),

              // Confirm password textfield label
              const MyLabel(
                mainAxisAlignment: MainAxisAlignment.start, 
                text: "Confirm Password", 
                fontSize: 16.0
              ),

              // Add space between elements
              const SizedBox(height: 10),

              // Confirm password textfield
              MyTextField(
                controller: confirmPasswordController,
                hintText: "Confirm your password",
                obscureText: true,
              ),

              // Add space between elements
              const SizedBox(height: 28),

              // Next button
              MyButton(
                text: "Create Account",
                onPressed: () {
                  // Navigator.push(
                  //   context, 
                  //   MaterialPageRoute(builder: (context) => ConfirmationPage(phoneNumber: phoneNumberStr))
                  // );
                  // print("Go to register page");
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

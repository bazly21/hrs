import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/model/user/user.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/otp_confirmation_page.dart';
import 'package:hrs/pages/register_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';

class AuthService with ChangeNotifier {
  String? _userRole;

  String? get userRole => _userRole;

  Future<void> authentication(
      {required BuildContext context,
      required String phoneNumber,
      required String role,
      required String method}) async {
    // Get the cleaned phone number
    phoneNumber = formatPhoneNum(phoneNumber);
    phoneNumber = formatInput(phoneNumber);

    // Check phone number
    if (method == "Login") {
      final bool isPhoneNumberRegistered = await checkPhoneNumber(
          context: context, phoneNumber: phoneNumber, role: role);

      // If the phone number is not registered, show error snackbar
      if (!isPhoneNumberRegistered) {
        if (context.mounted) {
          showErrorSnackBar(
            context: context,
            errorMessage:
                "You are not registered yet. Please complete your registration.",
            showAction: true,
            role: role,
          );
        }
        return;
      }
    }

    // Send OTP to the phone number
    if (context.mounted) {
      await sendOTP(
        context: context,
        phoneNumber: phoneNumber,
        role: role,
      );
    }
  }

  Future<void> registerProfile(
      {required BuildContext context,
      required String profileName,
      required String phoneNumber,
      required String role}) async {
    if (profileName.isNotEmpty) {
      // Get current user's information
      User? user = FirebaseAuth.instance.currentUser;

      // If user is logged in
      if (user != null) {
        //Get UID (User ID)
        String uid = user.uid;

        UserProfile userProfile = UserProfile(
            name: profileName, phoneNumber: phoneNumber, role: [role]);

        try {
          // Store profileName to the FireStore database
          await FirebaseFirestore.instance.collection('users').doc(uid).set(
                userProfile.toMap(),
                SetOptions(merge: true),
              );

          // Check if the widget is still mounted before navigating
          if (context.mounted) {
            _userRole = role;
            notifyListeners();

            goToNavigationPage(context);
          }
        } catch (e) {
          if (context.mounted) {
            // Display error message if the storing operation is failed
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Something happened while storing profile name. Please try again")));
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name."),
        ),
      );
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _userRole = null;
    notifyListeners();
  }

  Future<void> registerRole(String role, String userID) async {
    await FirebaseFirestore.instance.collection('users').doc(userID).update(
      {
        "role": FieldValue.arrayUnion([role]),
      },
    );
  }

  void goToNavigationPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const NavigationPage()),
      (Route<dynamic> route) =>
          false, // This predicate will never be true, so it removes all the routes below the new one.
    );
  }

  Future<void> sendOTP({
    required BuildContext context,
    required String phoneNumber,
    required String role,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification completed.
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("An error occurred while verifying the phone number."),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to ConfirmationPage and pass verificationId.
        NavigationUtils.pushPage(
            context,
            OTPConfirmationPage(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                buttonText: 'Confirm',
                role: role),
            SlideDirection.left);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTP(
      {required BuildContext context,
      required String otpCode,
      required String verificationId,
      required String role}) async {
    otpCode = formatInput(otpCode);

    // Create a PhoneAuthCredential with the code
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    try {
      // Sign in the user with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Checking if the user is new or existing
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? true;

      // If the user is a new user
      if (isNewUser) {
        // Navigate to the PasswordPage
        if (context.mounted) {
          NavigationUtils.pushPage(
              context,
              RegisterProfilePage(
                  phoneNumber: userCredential.user!.phoneNumber!, role: role),
              SlideDirection.left);
        }
      }
      // If the user is existing user
      else {
        // Check if the user has the role
        final bool hasRole =
            await checkUserRole(userCredential.user!.uid, role);

        if (!hasRole) {
          await registerRole(role, userCredential.user!.uid);
        }

        if (context.mounted) {
          _userRole = role;
          notifyListeners();

          goToNavigationPage(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
            context: context,
            errorMessage:
                "An error occurred while verifying the OTP code. Please try again.",
            showAction: false,
            role: role);
      }
    }
  }

  Future<bool> checkPhoneNumber(
      {required BuildContext context,
      required String phoneNumber,
      required String role}) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .where("role", arrayContains: role)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return false;
    }

    return true;
  }

  Future<bool> checkUserRole(String userID, String role) async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();

    if (userSnapshot.exists) {
      List roles = userSnapshot.get("role");
      if (roles.contains(role)) {
        return true;
      }
    }

    return false;
  }

  void showErrorSnackBar({
    required BuildContext context,
    required String errorMessage,
    required bool showAction,
    required String role,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        action: showAction
            ? SnackBarAction(
                label: 'Register',
                onPressed: () {
                  NavigationUtils.pushPage(
                      context, RegisterPage(role: role), SlideDirection.left);
                },
              )
            : null));
  }

  String formatPhoneNum(String phoneNumber) {
    if (!phoneNumber.contains("+6")) {
      phoneNumber = "+6$phoneNumber";
    }
    return phoneNumber;
  }

  String formatInput(String input) {
    return input.trim();
  }
}

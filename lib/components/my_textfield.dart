import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? filteringTextInputFormatter;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.textInputType,
    this.filteringTextInputFormatter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: textInputType, //To make the OS shows numeric keyboard only
        inputFormatters: filteringTextInputFormatter, // Prevent the insertion non-numeric characters
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8568F3)),
            borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA6A6A6),
            fontSize: 14),
          contentPadding: const EdgeInsets.all(10.0),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    ); 
  }
}
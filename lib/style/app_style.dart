import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static TextStyle hintText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color:  Color(0xFFA6A6A6),
  );

  static TextStyle textFieldText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static ButtonStyle elevatedButtonStyle = ButtonStyle(
    fixedSize: const MaterialStatePropertyAll(Size.fromHeight(42)),
    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return const Color(0xFFDDDCDC); // Text color when disabled
      }
      return const Color(0xFF765CF8); // Regular color
    }),
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey; // Text color when disabled
      }
      return Colors.white; // Regular text color
    }),
    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
      ),
    ),
  );

  static const Color primaryColor = Colors.blue;
}

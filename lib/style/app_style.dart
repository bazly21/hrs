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
    color: Color(0xFFA6A6A6),
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

  static ButtonStyle acceptButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF8568F3),
    foregroundColor: Colors.white,
    disabledBackgroundColor: const Color(0xFFAFA0F5),
    disabledForegroundColor: Colors.white70,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static ButtonStyle declineButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[300],
    foregroundColor: Colors.grey[600],
    disabledBackgroundColor: Colors.grey[200],
    disabledForegroundColor: Colors.grey[500],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static const Color primaryColor = Colors.blue;
}

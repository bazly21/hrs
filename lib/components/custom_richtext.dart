import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';

class RichTextLink extends StatelessWidget {
  final String text1, text2;
  final VoidCallback onTap;

  const RichTextLink(
      {super.key,
      required this.text1,
      required this.text2,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            color: Colors.black, fontSize: 12), // Default text style
        children: [
          TextSpan(text: text1),
          TextSpan(
              text: text2,
              style: const TextStyle(
                  color: Color(0xFF8568F3)), // Register link style
              recognizer: TapGestureRecognizer()..onTap = onTap),
        ],
      ),
    );
  }
}

class CustomRichText extends StatelessWidget {
  final String mainText;
  final String subText;
  final double mainFontSize;
  final double subFontSize;
  final FontWeight mainFontWeight;
  final FontWeight subFontWeight;

  const CustomRichText({
    super.key,
    required this.mainText,
    required this.subText,
    this.mainFontSize = 18,
    this.subFontSize = 14,
    this.mainFontWeight = FontWeight.bold,
    this.subFontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        // Default text style
        style: TextStyle(
            color: Colors.black,
            fontSize: mainFontSize,
            fontWeight: mainFontWeight),
        children: [
          TextSpan(text: mainText),
          TextSpan(
            text: subText,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: subFontWeight),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyLabel extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final String text;
  final double fontSize;
  final Color? color;

  const MyLabel({
    super.key,
    required this.mainAxisAlignment,
    required this.text,
    required this.fontSize,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w500
            )
          )
        ]
      ),   
    );
  }
}
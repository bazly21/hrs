import 'package:flutter/material.dart';

class RentalDetails extends StatelessWidget {
  final String title, text;

  const RentalDetails({
    super.key, 
    required this.title, 
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
              fontSize: 17.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF7D7F88), fontSize: 16.0),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }
}

import 'package:flutter/material.dart';

// This is for description of the rental property
// such as Description, Furnishing, Facilities and
// Accessibility
class PropertyDescription extends StatelessWidget {
  final String title;
  final String content;

  const PropertyDescription({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // Get total screen height
    double height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
        SizedBox(height: height * 0.003),
        Text(
          content,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(0xFF7D7F88),
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: height * 0.015),
      ],
    );
  }
}

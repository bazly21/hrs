import 'package:flutter/material.dart';

class PropertyDescription extends StatelessWidget {
  final String title;
  final String content;

  const PropertyDescription({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 3.0),
        Text(
          content,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(0xFF7D7F88),
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class PropertyDetailsTextField extends StatelessWidget {
  final String title, initialValue;
  final TextInputType textInputType;
  
  const PropertyDetailsTextField({
    super.key, 
    required this.title, 
    required this.initialValue, 
    this.textInputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
    
        // Add space between elements
        const SizedBox(height: 8),
    
        TextFormField(
          maxLines: null,
          keyboardType: textInputType,
          style: const TextStyle(fontSize: 14),
          initialValue: initialValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFA6A6A6),
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}
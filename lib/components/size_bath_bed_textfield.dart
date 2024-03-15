import 'package:flutter/material.dart';

class SizeBathBedTextField extends StatelessWidget {
  final String propertySize, numBathroom, numBedroom;
  
  const SizeBathBedTextField({
    super.key, 
    required this.propertySize, 
    required this.numBathroom, 
    required this.numBedroom,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        customSizeTextfield('Property Size', propertySize),
    
        // Add space between elements
        const SizedBox(width: 20.0),
    
        Expanded(
          child: customSizeTextfield('Bathroom', numBathroom),
        ),
    
        // Add space between elements
        const SizedBox(width: 20.0),
    
        Expanded(
          child: customSizeTextfield('Bedroom', numBedroom),
        )
      ],
    );
  }

  Column customSizeTextfield(String title, String value) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
  
          // Add space between elements
          const SizedBox(height: 8.0),
  
          SizedBox(
            width: 100,
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFA6A6A6),
                  ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(10.0),
              ),
              keyboardType: TextInputType.number,
              initialValue: value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
          )
        ],
      );
  }
}
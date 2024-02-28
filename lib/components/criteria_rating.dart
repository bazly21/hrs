import 'package:flutter/material.dart';
import 'package:hrs/components/my_starrating.dart';

class CriteriaRating extends StatelessWidget {
  final String criteria;
  final double rating;
  final double iconSize;
  final double fontSize;

  const CriteriaRating({
    super.key, 
    required this.criteria,
    required this.rating, 
    required this.fontSize,
    required this.iconSize
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          criteria,
          style: TextStyle(
            color: const Color(0xFF7D7F88),
            fontSize: fontSize
          ),
        ),

        StarRating(rating: rating, iconSize: iconSize)
      ],
    );
  }
}
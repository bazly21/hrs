import 'package:flutter/material.dart';
import 'package:hrs/components/custom_rating_bar.dart';

class CustomCriteriaRating extends StatelessWidget {
  final String criteria;
  final double rating;
  final double iconSize;
  final double fontSize;

  const CustomCriteriaRating({
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

        CustomRatingBar(
          rating: rating,
          itemSize: iconSize,
        ),
      ],
    );
  }
}
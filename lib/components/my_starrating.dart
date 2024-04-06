import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating; // Ensure rating is a double to allow fractional values
  final double? iconSize;

  const StarRating({
    super.key,
    this.rating = 0.0,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = List.generate(5, (index) {
      // Full star condition
      if (index < rating) {
        // Check for half star
        bool isHalfStar = rating - index < 1;
        return Icon(
          isHalfStar ? Icons.star_half : Icons.star,
          color: const Color(0xFFFFBF75),
          size: iconSize ?? 24.0,
        );
      }
      // Empty star
      return Icon(
        Icons.star_border,
        color: Colors.grey,
        size: iconSize ?? 24.0,
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}

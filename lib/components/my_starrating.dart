import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double? iconSize;

  const StarRating({
    super.key,
    this.rating = 0.0,
    this.iconSize
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: index < rating ? const Color(0xFFFFBF75) : Colors.grey,
        size: iconSize ?? 24.0
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
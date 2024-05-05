import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar({
    super.key,
    this.rating = 0.0,
    this.color = Colors.amber,
    this.itemSize = 18.0,
  });

  final double rating;
  final Color color;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: color,
      ),
      itemCount: 5,
      itemSize: itemSize,
      direction: Axis.horizontal,
    );
  }
}

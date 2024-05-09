import 'package:flutter/material.dart';

class AppBarShadow extends StatelessWidget {
  final Color color;
  final double spreadRadius;
  final double blurRadius;
  final Offset offset;

  const AppBarShadow({
    super.key,
    this.color = Colors.grey,
    this.spreadRadius = 2,
    this.blurRadius = 3,
    this.offset = const Offset(0, 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
        color: Colors.white,
      ),
    );
  }
}
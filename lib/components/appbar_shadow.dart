import 'package:flutter/material.dart';

class AppBarShadow extends StatelessWidget {
  const AppBarShadow({
    super.key,
    Color color = Colors.grey,
    double spreadRadius = 1,
    double blurRadius = 3,
    Offset offset = const Offset(0, 2),
  })  : _offset = offset,
        _blurRadius = blurRadius,
        _spreadRadius = spreadRadius,
        _color = color;

  final Color _color;
  final double _spreadRadius;
  final double _blurRadius;
  final Offset _offset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.15),
            spreadRadius: _spreadRadius,
            blurRadius: _blurRadius,
            offset: _offset,
          ),
        ],
        color: Colors.white,
      ),
    );
  }
}

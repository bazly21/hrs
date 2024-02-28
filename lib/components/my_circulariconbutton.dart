import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData iconData;
  final double size;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color backgroundColor;

  const CircularIconButton({
    Key? key,
    required this.iconData,
    this.size = 20.0,
    required this.onPressed,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor, // Background color of the circle
        shape: BoxShape.circle, // Ensures the container is circular
      ),
      child: IconButton(
        icon: Icon(iconData, size: size),
        padding: const EdgeInsets.all(0),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

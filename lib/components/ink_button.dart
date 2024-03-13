import 'package:flutter/material.dart';

class InkButton extends StatelessWidget {
  final Color backgroundColor, splashColor, highlightColor;
  final VoidCallback onTap;
  final String textButton;
  final BorderRadius? borderRadius;

  const InkButton({
    super.key, 
    required this.backgroundColor, 
    required this.onTap, 
    required this.textButton, 
    required this.splashColor, 
    required this.highlightColor, 
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: backgroundColor, // Background color
        borderRadius: borderRadius ?? const BorderRadius.only(bottomRight: Radius.circular(10)),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor, // Splash color for a darker effect on tap
        highlightColor: highlightColor, // Highlight color for a darker effect
        borderRadius: borderRadius ?? const BorderRadius.only(bottomRight: Radius.circular(10)), // Ensuring rounded corners for splash and highlight effects
        child: Container(
          padding: const EdgeInsets.all(3),
          height: 26,
          alignment: Alignment.center, // Centers the text within the container
          child: Text(
            textButton,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class PropertyDetails extends StatelessWidget {
  final String propertyName, propertyLocation;
  final bool isFavorite; // For favourite/wishlist icon
  final bool showIcon;
  final Icon? icon;
  final VoidCallback? onIconPressed;

  const PropertyDetails({
    super.key,
    required this.propertyName,
    required this.propertyLocation,
    this.isFavorite = false,
    this.showIcon = false,
    this.onIconPressed, 
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              propertyName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              ),
            ),
            if (showIcon) // This will only build the IconButton if showIcon is true
              IconButton(
                icon: icon ?? Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                  size: 22.0,
                  color: isFavorite ? Colors.red : const Color(0xFF7D7F88),
                ),
                onPressed: onIconPressed ?? (){},
              ),
          ],
        ),

        if (!showIcon)
          const SizedBox(height: 8.0),

        Row(
          children: [
            // Location Icon
            const Icon(
              Icons.location_on_rounded,
              size: 18.0,
              color: Color(0xFF7D7F88),
            ),

            // Add space between elements
            const SizedBox(width: 5.0),

            // Property's Location Text **Database Required**
            Text(
              propertyLocation, // Dummy data
              style: const TextStyle(
                color: Color(0xFF7D7F88),
                fontSize: 16.0
              ),
            )
          ],
        ),
      ],
    );
  }
}

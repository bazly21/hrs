import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;

  const ProfileMenu({
    super.key,
    required this.text,
    this.onPressed,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon),
          ),

          // Add space between elements
          const SizedBox(width: 15.0),

          // Menu Label
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16
            ),
          ),

          const Spacer(),

          // Arrow Icon
          IconButton(
            onPressed: onPressed ?? (){}, 
            icon: const Icon(Icons.arrow_forward)
          )
        ],
      ),
    );
  }
}
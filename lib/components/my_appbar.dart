import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconButton? iconButton;

  const MyAppBar({
    super.key,
    required this.title,
    this.iconButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // AppBar background color.
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color.
            spreadRadius: 2,
            blurRadius: 3, // Shadow blur radius.
            offset: const Offset(0, 2), // Vertical offset for the shadow.
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white, // Make AppBar's background transparent.
        leading: iconButton,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Title color.
          ),
        ),
        centerTitle: false, // Title alignment.
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65); // Specify the AppBar height.
}

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      flexibleSpace: Container(
        // Create shadow for the AppBar
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!, // Shadow color.
            spreadRadius: 1,
            blurRadius: 3, // Shadow blur radius.
            offset: const Offset(0, 2), // Vertical offset for the shadow.
          )
        ], color: Colors.white),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
              color: Colors.black)),
      centerTitle: true,
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
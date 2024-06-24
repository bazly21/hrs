import 'package:flutter/material.dart';
import 'package:hrs/components/appbar_shadow.dart';
import 'package:hrs/components/custom_circleavatar.dart';

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

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required String hintText,
    required TextEditingController controller,
    required void Function(String) onChanged,
  })  : _hintText = hintText,
        _controller = controller,
        _onChanged = onChanged;

  final String _hintText;
  final TextEditingController _controller;
  final void Function(String) _onChanged;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      flexibleSpace: const AppBarShadow(),
      title: Container(
        height: 41,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF858585)),
            border: InputBorder.none,
            hintText: _hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF858585),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.all(10.0),
          ),
          style: const TextStyle(fontSize: 14),
          cursorColor: Colors.black54,
          onChanged: _onChanged,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? imageUrl;

  const ChatAppBar({
    super.key,
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      flexibleSpace: const AppBarShadow(),
      title: Row(
        children: [
          // User profile picture
          CustomCircleAvatar(
            name: name,
            imageURL: imageUrl,
            radius: 23.0,
            fontSize: 18.0,
          ),
      
          // Space between elements
          const SizedBox(width: 10),
      
          // User name
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

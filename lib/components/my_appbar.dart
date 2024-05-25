import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final String appBarType;
  final bool hasImage;

  const MyAppBar({
    super.key,
    required this.text,
    this.appBarType = "Title",
    this.hasImage = false
  });

  Widget _appBar (BuildContext context) {
    return AppBar(
      toolbarHeight: 70.0,
      flexibleSpace: Container( // Create shadow for the AppBar
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color.
              spreadRadius: 2,
              blurRadius: 3, // Shadow blur radius.
              offset: const Offset(0, 2), // Vertical offset for the shadow.
            ),
          ],
          color: Colors.white
        ),
      ),
      title: appBarType == "Title" ? _titleAppBar(context) : _searchAppBar(context),
      backgroundColor: Colors.white,
    );
  }

  Widget _titleAppBar(BuildContext context) {
    return Row(
      children: [
        if(hasImage) ...[
          const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 10),
        ],

        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.black)),
      ],
    );
  }

  Widget _searchAppBar(BuildContext context) {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(10.69),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.search, color: Color(0xFF858585)),
          ),
          border: InputBorder.none,
          hintText: text,
          hintStyle: const TextStyle(
            color: Color(0xFF858585),
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
        style: const TextStyle(fontSize: 14),
        cursorColor: Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _appBar(context);
  }

  @override
  Size get preferredSize => const Size.fromHeight(70); // Adjusted for potential search bar height.
}

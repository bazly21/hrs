// import 'package:flutter/material.dart';

// class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String text, appBarContent;
//   final IconButton? iconButton;

//   const MyAppBar({
//     super.key,
//     required this.text,
//     required this.appBarContent,
//     this.iconButton,
//   });

//   dynamic getAppBarContent (String content, BuildContext context) {
//     if(content == "Title") {
//       return AppBar(
//         backgroundColor: Colors.white, // Make AppBar's background transparent.
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black, // Title color.
//           ),
//         ),
//         centerTitle: false, // Title alignment.
//       );
//     } else if(content == "Search") {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.end, // Align search bar to bottom
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Add gap at the bottom
//             child: Container(
//               height: 41,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F3F3),
//                 borderRadius: BorderRadius.circular(10.69),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 3,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(left: 18.0, right: 14.0),
//                     child: Icon(Icons.search, color: Color(0xFF858585)),
//                   ),
//                   border: InputBorder.none,
//                   hintText: text, //'Enter location or property type',
//                   hintStyle: const TextStyle(
//                     color: Color(0xFF858585),
//                     fontWeight: FontWeight.normal,
//                     fontSize: 14),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//                 cursorColor: Colors.black54,
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white, // AppBar background color.
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2), // Shadow color.
//             spreadRadius: 2,
//             blurRadius: 3, // Shadow blur radius.
//             offset: const Offset(0, 2), // Vertical offset for the shadow.
//           ),
//         ],
//       ),
//       child: getAppBarContent(appBarContent, context),
//     );
//   }



//   @override
//   Size get preferredSize => const Size.fromHeight(65); // Specify the AppBar height.
// }

import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text, appBarContent;
  final Widget? leadingWidget;

  const MyAppBar({
    super.key,
    required this.text,
    required this.appBarContent,
    this.leadingWidget,
  });

  Widget _titleAppBar(BuildContext context) {
    // Wrap AppBar with Container for shadow effect
    return Container(
      decoration: BoxDecoration(
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
        backgroundColor: Colors.white, // Make AppBar's background transparent to show Container color.
        elevation: 0, // Remove AppBar elevation to prevent double shadow.
        centerTitle: false,
        titleSpacing: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 19), // Apply padding at the bottom
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                leadingWidget ?? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchAppBar(BuildContext context) {
    // Similar wrapping for search AppBar
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
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
                      padding: EdgeInsets.only(left: 18.0, right: 14.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBarContent == "Title" ? _titleAppBar(context) : _searchAppBar(context);
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // Adjusted for potential search bar height.
}

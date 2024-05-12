import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final String? role;
  final Function(int) onTap;

  const MyBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> items = role == 'Landlord'
        ? const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Property'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          ]
        : const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Rental'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          ];

    return SizedBox(
      height: 75,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // This is needed for 4 or more items
        elevation: 16.0,
        backgroundColor: Colors.white,
        items: items,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF8568F3),
        unselectedItemColor: const Color(0xFF7D7F88),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24.0,
        onTap: onTap,
      ),
    );
  }
}
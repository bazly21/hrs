import 'package:flutter/material.dart';
import 'package:hrs/chat_list_page.dart';
import 'package:hrs/notification_page.dart';
import 'package:hrs/profile_page_login.dart';
import 'package:hrs/profile_page_no_login.dart';
import 'package:hrs/rental_details_page.dart';
import 'package:hrs/rental_list_page.dart';
import 'components/my_bottomnavigationbar.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}

class _NavigationPage extends State<NavigationPage> {
  int _selectedIndex = 0; // Assuming Home is the central item
  final List<Widget> _pages = [const RentalListPage(), ChatListPage(), const RentalDetailsPage(), const NotificationPage(), const ProfilePageNoAccount() ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

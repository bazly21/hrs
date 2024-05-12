import 'package:flutter/material.dart';
import 'package:hrs/components/my_bottomnavigationbar.dart';
import 'package:hrs/pages/chat_list_page.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/notification_page.dart';
import 'package:hrs/pages/profile_page_login.dart';
import 'package:hrs/pages/profile_page_no_login.dart';
import 'package:hrs/pages/rental_details_page.dart';
import 'package:hrs/pages/rental_list_page.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:provider/provider.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}

class _NavigationPage extends State<NavigationPage> {
  int _selectedIndex = 0; // Assuming Home is the central item

  @override
  Widget build(BuildContext context) {
    String? role = context.watch<AuthService>().userRole;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const RentalListPage(),
          role == 'Tenant' ? const ChatListPage() : Container(),
          role == 'Tenant' ? const RentalDetailsPage() : Container(),
          const NotificationPage(),
          role != null ? const ProfilePage() : const ProfilePageNoAccount(),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _handleNavigationTap(index, role),
      ),
    );
  }

  // Handle navigation tap
  void _handleNavigationTap(int index, String? role) {
    if ((index == 1 || index == 2) && role == null) {
      NavigationUtils.pushPage(context, const LoginPage(), SlideDirection.up);
    } else {
      setState(() => _selectedIndex = index);
    }
  }
}
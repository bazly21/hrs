import 'package:flutter/material.dart';
import 'package:hrs/components/my_bottomnavigationbar.dart';
import 'package:hrs/pages/chat_list_page.dart';
import 'package:hrs/pages/landord_pages/landlord_add_property_page.dart';
import 'package:hrs/pages/landord_pages/landlord_property_list.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/pages/notification_page.dart';
import 'package:hrs/pages/profile_page_login.dart';
import 'package:hrs/pages/profile_page_no_login.dart';
import 'package:hrs/pages/tenancy_details_page.dart';
import 'package:hrs/pages/rental_property_list_page.dart';
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

    final List<Widget> pages = role == 'Landlord'
        ? [
            const LandlordPropertyListPage(),
            const ChatListPage(),
            // Placeholder for AddPropertyPage
            Container(),
            const NotificationPage(),
            const ProfilePage(),
          ]
        : [
            const RentalListPage(),
            role == 'Tenant' ? const ChatListPage() : Container(),
            role == 'Tenant' ? const TenancyDetailsPage() : Container(),
            const NotificationPage(),
            role != null ? const ProfilePage() : const ProfilePageNoAccount(),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        role: role,
        onTap: (index) => _handleNavigationTap(index, role, context),
      ),
    );
  }

  // Handle navigation tap
  void _handleNavigationTap(int index, String? role, BuildContext context) {
    if ((index == 1 || index == 2) && role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to access this feature'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              NavigationUtils.pushPage(context, const LoginPage(role: "Tenant"),
                  SlideDirection.left);
            },
          ),
        ),
      );
    } else if (index == 2 && role == 'Landlord') {
      NavigationUtils.pushPage(
          context, const AddPropertyPage(), SlideDirection.up);
    } else {
      setState(() => _selectedIndex = index);
    }
  }
}

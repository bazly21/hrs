import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return const Scaffold(
      body: SafeArea(
        child:  ListTile(
        title: Text(
          'Tenancy Duration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17
          ),
        ),
        subtitle: Text(
          '4 months',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7D7F88)
          ),
        ),
      ),
      ),
    );
  }
}
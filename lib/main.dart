import 'package:flutter/material.dart';
import 'login_page.dart';
import 'rental_list_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "SFProDisplay",
      ),
      home: LoginPage(),
      // home: const RentalListPage()
    );
  }
}
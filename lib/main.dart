import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/pages/rating_list_page.dart';
import 'package:hrs/pages/rating_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        scaffoldBackgroundColor: const Color(0xFFFCFCFC),
      ),
      // home: LoginPage(),
      home: const NavigationPage()
      // home: const RatingList()
    );
  }
}
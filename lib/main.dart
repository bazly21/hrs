import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hrs/pages/navigation_page.dart';
import 'package:hrs/provider/image_provider.dart';
import 'package:hrs/provider/refresh_provider.dart';
import 'package:hrs/provider/wishlist_provider.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => RefreshProvider()),
        ChangeNotifierProvider(create: (context) => ImageService()),
      ],
      child: const MyApp(),
    ),
  );
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
        primaryColor: const Color(0xFF8568F3),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Theme.of(context).primaryColor,
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          // Set corner radius
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: const NavigationPage()
    );
  }
}

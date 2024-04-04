import 'package:flutter/material.dart';

class NavigationUtils {
  static void pushPageWithSlideUpAnimation(BuildContext context, Widget page) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin = const Offset(0.0, 1.0);
            Offset end = Offset.zero;
            Cubic curve = Curves.ease;

            Animatable<Offset> tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            Animation<Offset> offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
  }

  static void pushPageWithSlideLeftAnimation(BuildContext context, Widget page) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin = const Offset(1.0, 0.0);
            Offset end = Offset.zero;
            Cubic curve = Curves.ease;

            Animatable<Offset> tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            Animation<Offset> offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
  }
}

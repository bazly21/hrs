import 'package:flutter/material.dart';

enum SlideDirection {
  left,
  up,
}

class NavigationUtils {
  static Future pushPage(BuildContext context, Widget page, SlideDirection direction) {
    Offset begin;
    switch (direction) {
      case SlideDirection.left:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset end = Offset.zero;
          Cubic curve = Curves.ease;
          Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          Animation<Offset> offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
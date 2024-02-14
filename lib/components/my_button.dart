import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed

  });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8568F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.96),
                ),
              ), 
              onPressed: onPressed,
              child: Text(text),
            ),
          ),
        ),
      ],
    );
    
    // return Container(
    //   padding: const EdgeInsets.all(15),
    //   margin: const EdgeInsets.symmetric(horizontal: 25),
    //   decoration: BoxDecoration(
    //     color: const Color(0xFF6246EA),
    //     borderRadius: BorderRadius.circular(10.69)
    //     ),
    //   child: const Center(
    //     child: Text(
    //       "Login",
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   ),
    // );
  }
}
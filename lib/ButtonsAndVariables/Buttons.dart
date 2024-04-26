import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Fixed background color
          onPrimary: Colors.white, // Fixed text color
          minimumSize: Size(250, 50),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white), // Fixed text color
        ),
      ),
    );
  }
}
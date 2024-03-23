import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
 final String hintText;
  final IconData icon;
  final bool obscureText;

  RoundedTextField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.blue, width: 2), // Change border color when focused
        ),
      ),
    );
  }
}

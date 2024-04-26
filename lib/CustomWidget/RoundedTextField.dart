import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller; // New attribute for text controller

  RoundedTextField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.controller, // Initialize text controller
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Bind the controller to TextFormField
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

class RoundedTextField2 extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final String value;

  RoundedTextField2({
    required this.hintText,
    required this.icon,
    required this.onTap,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: Icon(Icons.arrow_drop_down),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.blue, width: 2), // Change border color when focused
        ),
        labelText: value.isNotEmpty ? hintText : null,
      ),
      controller: TextEditingController(text: value),
    );
  }
} 
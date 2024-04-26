import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiHandler {
  static const baseUrl = 'http://192.168.0.108:8000/user';

static Future<bool> checkConnection() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/check_connection'));
    if (response.statusCode == 200) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  } catch (e) {
      return false;
  }
}

  static Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login
        return true;
      } else {
        // Login failed
        return false;
      }
    } catch (e) {
      // Exception occurred
      return false;
    }
  }
}
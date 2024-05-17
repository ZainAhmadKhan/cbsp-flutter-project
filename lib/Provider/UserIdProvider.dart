import 'package:flutter/material.dart';

class UserIdProvider extends ChangeNotifier {
  int _userId = 0; // Initialize with a default value

  int get userId => _userId;

  void setUserId(int userId) {
    _userId = userId;
    notifyListeners();
  }
}
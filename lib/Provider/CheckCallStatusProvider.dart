import 'package:flutter/material.dart';

class checkCallAccepted with ChangeNotifier {
  bool _callStatus = false;

  bool get callStatus => _callStatus;

  void setCallStatus(bool status) {
    _callStatus = status;
    notifyListeners();
  }
}
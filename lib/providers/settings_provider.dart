import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _useSystemMotion = true;

  bool get useSystemMotion => _useSystemMotion;

  void toggleMotion(bool enabled) {
    _useSystemMotion = enabled;
    notifyListeners();
  }
}

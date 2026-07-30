import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsProvider extends ChangeNotifier {
  File? _customIconFile;
  bool _useSystemMotion = true;

  File? get customIconFile => _customIconFile;
  bool get useSystemMotion => _useSystemMotion;

  Future<void> pickCustomIcon() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (result != null) {
      _customIconFile = File(result.path);
      notifyListeners();
    }
  }

  void toggleMotion(bool enabled) {
    _useSystemMotion = enabled;
    notifyListeners();
  }
}

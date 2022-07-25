import 'package:flutter/material.dart';

class WordHider extends ChangeNotifier {
  bool _isHide = false;

  bool getHide() {
    return _isHide;
  }

  void setHide(bool hide) {
    _isHide = hide;
    notifyListeners();
  }
}

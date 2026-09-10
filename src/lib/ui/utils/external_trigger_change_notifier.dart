import "package:flutter/material.dart";

class ExternalTriggerChangeNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
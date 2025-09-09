import 'package:flutter/material.dart';

class ExternalTriggerChangedNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
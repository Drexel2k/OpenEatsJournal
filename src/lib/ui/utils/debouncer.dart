import "dart:async";
import "package:flutter/material.dart";

class Debouncer {
  final int _milliseconds;
  Timer? _timer;

  Debouncer({int milliseconds = 500}) : _milliseconds = milliseconds;

  void run({required VoidCallback callback}) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: _milliseconds), callback);
  }

  void cancel() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}

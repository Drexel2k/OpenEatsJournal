import 'package:flutter/material.dart';

class OverlayInfo {
  OverlayInfo({required String displayText, required Color backgroundColor, required Color shadowColorBase, required TextStyle textStyle})
    : _displayText = displayText,
      _backgroundColor = backgroundColor,
      _shadowColorBase = shadowColorBase,
      _textStyle = textStyle;

  final String _displayText;
  final Color _backgroundColor;
  final Color _shadowColorBase;
  final TextStyle _textStyle;

  String get displayText => _displayText;
  Color get backgroundColor => _backgroundColor;
  Color get shadowColorBase => _shadowColorBase;
  TextStyle get textStyle => _textStyle;
}

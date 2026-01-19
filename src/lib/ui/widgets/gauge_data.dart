import "package:flutter/material.dart";

class GaugeData {
  GaugeData({required num currentValue, required num maxValue, required ColorScheme colorScheme})
    : _currentValue = currentValue,
      _maxValue = maxValue,
      _percentageFilled = _getPercentageFilled(currentValue: currentValue, maxValue: maxValue),
      _colors = _getColors(currentValue: currentValue, maxValue: maxValue, colorScheme: colorScheme);

  final num _currentValue;
  final num _maxValue;
  final int _percentageFilled;
  final List<Color> _colors;

  num get currentValue => _currentValue;
  num get maxValue => _maxValue;
  int get percentageFilled => _percentageFilled;
  List<Color> get colors => _colors;

  static int _getPercentageFilled({required num currentValue, required num maxValue}) {
    int percentageFilled = (currentValue / maxValue * 100).round();
    if (currentValue > maxValue && currentValue <= 2 * maxValue) {
      percentageFilled = ((currentValue - maxValue) / maxValue * 100).round();
    }

    if (currentValue > 2 * maxValue) {
      percentageFilled = 100;
    }

    return percentageFilled;
  }

  static List<Color> _getColors({required num currentValue, required num maxValue, required ColorScheme colorScheme}) {
    List<Color> colors = [];
    if (currentValue <= maxValue) {
      colors.add(colorScheme.inversePrimary);
      colors.add(colorScheme.primary);
    } else {
      colors.add(colorScheme.primary);
      colors.add(colorScheme.error);
    }

    return colors;
  }
}

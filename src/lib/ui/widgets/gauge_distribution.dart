import "package:flutter/material.dart";
import "package:graphic/graphic.dart";

class GaugeDistribution extends StatelessWidget {
  GaugeDistribution({super.key, required double startValue, required endValue})
    : _startValue = _getStartValue(startValue: startValue),
      _endValue = _getEndValue(startValue: startValue, endValue: endValue);

  final double _startValue;
  final double _endValue;

  static double _getStartValue({required double startValue}) {
    if (startValue < 0) {
      startValue = 0;
    }

    if (startValue > 100) {
      startValue = 100;
    }

    return startValue;
  }

  static double _getEndValue({required double startValue, required double endValue}) {
    if (startValue < 0) {
      startValue = 0;
    }

    if (startValue > 100) {
      startValue = 100;
    }

    if (endValue < startValue) {
      endValue = startValue;
    }

    if (endValue > 100) {
      endValue = 100;
    }
    return endValue;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Color> colors = [colorScheme.inversePrimary, colorScheme.primary, colorScheme.inversePrimary];

    double dimension = 75;
    double radius = 0.85;

    return SizedBox(
      height: dimension,
      width: dimension,
      child: Chart(
        data: [
          {"type": "100Percent", "min": 0, "max": 100},
          {"type": "currentRange", "min": _startValue, "max": _endValue},
        ],
        variables: {
          "type": Variable(accessor: (Map map) => map["type"] as String),
          "min": Variable(accessor: (Map map) => map["min"] as num, scale: LinearScale(min: 0, max: 100)),
          "max": Variable(accessor: (Map map) => map["max"] as num, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [
          IntervalMark(
            position: Varset("type") * (Varset("min") + Varset("max")),
            size: SizeEncode(value: 8),
            shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(4)))),
            color: ColorEncode(variable: "type", values: colors),
          ),
        ],
        coord: PolarCoord(transposed: true, startAngle: 2.5, endAngle: 6.93, startRadius: radius, endRadius: radius),
      ),
    );
  }
}

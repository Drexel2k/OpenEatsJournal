import "package:flutter/material.dart";
import "package:graphic/graphic.dart";

class GaugeDistribution extends StatelessWidget {
  GaugeDistribution({super.key, required double value, required double startValue})
    : _startValue = startValue,
      _value = value {
    if (_value < 0 || _value > 100) {
      throw ArgumentError("Value must be greater 0 and max 100.");
    }

    if (_value + _startValue > 100) {
      throw ArgumentError("Value + startValue must not be greater than 100.");
    }
  }

  final double _value;
  final double _startValue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorTheme = Theme.of(context).colorScheme;

    List<Color> colors = [colorTheme.inversePrimary, colorTheme.primary, colorTheme.inversePrimary];

    double dimension = 75;
    double radius = 0.85;

    return SizedBox(
      height: dimension,
      width: dimension,
      child: Chart(
        data: [
          {"type": "100Percent", "min": 0, "max": 100},
          {"type": "currentRange", "min": _startValue, "max": _startValue + _value},
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

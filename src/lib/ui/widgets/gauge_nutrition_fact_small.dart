import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";

class GaugeNutritionFactSmall extends StatelessWidget {
  const GaugeNutritionFactSmall({super.key, required String factName, required int value, required int maxValue})
    : _maxValue = maxValue,
      _value = value,
      _factName = factName;

  final String _factName;
  final int _value;
  final int _maxValue;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat formatter = NumberFormat(null, Localizations.localeOf(context).languageCode);

    List<Color> colors = [];
    int percentageFilled;

    if (_value <= _maxValue) {
      colors.add(Theme.of(context).colorScheme.inversePrimary);
      colors.add(Theme.of(context).colorScheme.primary);

      percentageFilled = (_value / _maxValue * 100).round();
    } else {
      colors.add(Theme.of(context).colorScheme.primary);
      colors.add(Theme.of(context).colorScheme.error);

      if (_value <= 2 * _maxValue) {
        percentageFilled = ((_value - _maxValue) / _maxValue * 100).round();
      } else {
        percentageFilled = 100;
      }
    }

    double dimension = 75;
    double radius = 0.85;

    return Stack(
      children: [
        SizedBox(
          height: dimension,
          width: dimension,
          child: Chart(
            data: [
              {'type': '100Percent', 'percent': 100},
              {'type': 'actualPercent', 'percent': percentageFilled},
            ],
            variables: {
              'type': Variable(accessor: (Map map) => map['type'] as String),
              'percent': Variable(accessor: (Map map) => map['percent'] as num, scale: LinearScale(min: 0, max: 100)),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: 8),
                shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(4)))),
                color: ColorEncode(variable: 'type', values: colors),
              ),
            ],
            coord: PolarCoord(
              transposed: true,
              startAngle: 2.5,
              endAngle: 6.93,
              startRadius: radius,
              endRadius: radius,
            ),
          ),
        ),
        SizedBox(
          height: dimension,
          width: dimension,
          child: Column(
            children: [
              Spacer(),
              Text(_factName, style: textTheme.labelMedium, textAlign: TextAlign.center),
              Text(
                "${formatter.format(_value)}/\n${formatter.format(_maxValue)}",
                style: textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

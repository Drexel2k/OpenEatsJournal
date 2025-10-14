import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";

class GaugeNutritionFactSmall extends StatelessWidget {
  const GaugeNutritionFactSmall({super.key, required String factName, required GaugeData gaugeData})
    : _gaugeData = gaugeData,
      _factName = factName;

  final String _factName;
  final GaugeData _gaugeData;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat formatter = NumberFormat("0.0", Localizations.localeOf(context).languageCode);

    double dimension = 75;
    double radius = 0.85;

    return Stack(
      children: [
        SizedBox(
          height: dimension,
          width: dimension,
          child: Chart(
            data: [
              {"type": "100Percent", "percent": 100},
              {"type": "currentPercent", "percent": _gaugeData.percentageFilled},
            ],
            variables: {
              "type": Variable(accessor: (Map map) => map["type"] as String),
              "percent": Variable(accessor: (Map map) => map["percent"] as num, scale: LinearScale(min: 0, max: 100)),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: 8),
                shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(4)))),
                color: ColorEncode(variable: "type", values: _gaugeData.colors),
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
                "${formatter.format(_gaugeData.currentValue)}/\n${formatter.format(_gaugeData.maxValue)}",
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

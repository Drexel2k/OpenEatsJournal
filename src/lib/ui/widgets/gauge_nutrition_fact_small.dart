import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";

class GaugeNutritionFactSmall extends StatelessWidget {
  const GaugeNutritionFactSmall({super.key, required String factName, required GaugeData gaugeData}) : _gaugeData = gaugeData, _factName = factName;

  final String _factName;
  final GaugeData _gaugeData;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    double height = 80;
    double width = 85;
    double radius = 0.85;

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 3),
            SizedBox(
              height: height,
              width: width,
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
                coord: PolarCoord(transposed: true, startAngle: 2.5, endAngle: 6.93, startRadius: radius, endRadius: radius),
              ),
            ),
          ],
        ),
        SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              Text(_factName, style: textTheme.labelMedium, textAlign: TextAlign.center),
              SizedBox(height: 13),
              Text(
                "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _gaugeData.currentValue as double)}/\n${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _gaugeData.maxValue as double)}",
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

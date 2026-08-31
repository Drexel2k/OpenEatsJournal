import "package:flutter/material.dart";
import "package:gauge_indicator/gauge_indicator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:provider/provider.dart";

class GaugeNutritionFactSmall extends StatelessWidget {
  const GaugeNutritionFactSmall({super.key, required String factName, required GaugeData gaugeData}) : _gaugeData = gaugeData, _factName = factName;

  final String _factName;
  final GaugeData _gaugeData;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(_factName, style: textTheme.labelMedium, textAlign: TextAlign.center),
        Stack(
          alignment: AlignmentGeometry.center,
          children: [
            SizedBox(
              height: 45,
              child: Column(
                children: [
                  SizedBox(height: 13),
                  Text(
                    "${convert.getCleanDoubleString1DecimalDigit(doubleValue: _gaugeData.currentValue as double)}/\n${convert.getCleanDoubleString1DecimalDigit(doubleValue: _gaugeData.maxValue as double)}",
                    style: textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 47,
              child: RadialGauge(
                radius: 150.0,
                value: _gaugeData.percentageFilled.toDouble(),
                axis: GaugeAxis(
                  pointer: null,
                  min: 0,
                  max: 100,
                  sweepDegrees: 260.0,
                  progressBar: GaugeProgressBar.rounded(
                    color: _gaugeData.currentValue < _gaugeData.maxValue ? colorScheme.primary : colorScheme.error,
                    placement: GaugeProgressPlacement.inside,
                  ),
                  style: GaugeAxisStyle(
                    thickness: 8,
                    background: _gaugeData.currentValue < _gaugeData.maxValue ? colorScheme.inversePrimary : colorScheme.primary,
                    cornerRadius: Radius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

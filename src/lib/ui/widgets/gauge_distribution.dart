import "package:flutter/material.dart";
import "package:gauge_indicator/gauge_indicator.dart";

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
    startValue = _getStartValue(startValue: startValue);

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

    return Stack(
      children: [
        SizedBox(
          height: 43,
          child: RadialGauge(
            radius: 150.0,
            value: _getEndValue(startValue: _startValue, endValue: _endValue),
            axis: GaugeAxis(
              pointer: null,
              min: 0,
              max: 100,
              sweepDegrees: 260.0,
              progressBar: GaugeProgressBar.rounded(color: colorScheme.primary, placement: GaugeProgressPlacement.inside),
              style: GaugeAxisStyle(thickness: 8, background: colorScheme.inversePrimary, cornerRadius: Radius.circular(8.0)),
            ),
          ),
        ),
        SizedBox(
          height: 43,
          child: RadialGauge(
            radius: 150.0,
            value: _getStartValue(startValue: _startValue),
            axis: GaugeAxis(
              pointer: null,
              min: 0,
              max: 100,
              sweepDegrees: 260.0,
              progressBar: GaugeProgressBar.rounded(color: colorScheme.inversePrimary, placement: GaugeProgressPlacement.inside),
              style: GaugeAxisStyle(thickness: 8, background: Colors.transparent, cornerRadius: Radius.circular(8.0)),
            ),
          ),
        ),
      ],
    );
  }
}

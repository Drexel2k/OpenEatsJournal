import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";
import "package:provider/provider.dart";

class Linechart extends StatelessWidget {
  const Linechart({
    super.key,
    required List<Tuple> data,
    required DateTime scaleMinValue,
    required DateTime scaleMaxValue,
    required Map<DateTime, String> xAxisInfo,
    required StatisticInterval statisticInterval,
    required double width,
  }) : _data = data,
       _scaleMinValue = scaleMinValue,
       _scaleMaxValue = scaleMaxValue,
       _xAxisInfo = xAxisInfo,
       _statisticInterval = statisticInterval,
       _width = width;

  final List<Tuple> _data;
  //with adjusted scaleMin/MaxValues a margin can be created
  final DateTime _scaleMinValue;
  final DateTime _scaleMaxValue;
  final Map<DateTime, String> _xAxisInfo;
  final StatisticInterval _statisticInterval;
  final double _width;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double? minValue = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartDataIs] < nextEntry[OpenEatsJournalStrings.chartDataIs]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartDataIs];

    double? maxValue = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartDataIs] > nextEntry[OpenEatsJournalStrings.chartDataIs]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartDataIs];

    minValue ??= 0;
    maxValue ??= 0;

    int yAxisScaleMinValue = 0;
    int yAxisScaleMaxValue = 0;

    yAxisScaleMinValue = minValue.toInt() - 5;
    yAxisScaleMaxValue = maxValue.toInt() + 5;

    double xAxisLabelXOffset = 12;
    double xAxisLabelYOffset = 15;
    if (_statisticInterval == StatisticInterval.weekly) {
      xAxisLabelXOffset = 14;
      xAxisLabelYOffset = 18;
    } else if (_statisticInterval == StatisticInterval.monthly) {
      xAxisLabelXOffset = 12;
      xAxisLabelYOffset = 18;
    }

    String timeInfo = AppLocalizations.of(context)!.days;
    if (_statisticInterval == StatisticInterval.weekly) {
      timeInfo = AppLocalizations.of(context)!.weeks;
    } else if (_statisticInterval == StatisticInterval.monthly) {
      timeInfo = AppLocalizations.of(context)!.months;
    }

    final String header = AppLocalizations.of(context)!.last_amount_timeinfo(_xAxisInfo.length - 1, timeInfo);

    final double fontSize = 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: textTheme.titleMedium),
        SizedBox(height: 5),
        SizedBox(
          width: _width,
          height: 150,
          child: Chart(
            data: _data,
            variables: {
              OpenEatsJournalStrings.chartDateVar: Variable(
                accessor: (Map<dynamic, dynamic> map) => map[OpenEatsJournalStrings.chartDateInformation] as DateTime,
                scale: TimeScale(
                  min: _scaleMinValue,
                  max: _scaleMaxValue,
                  ticks: _xAxisInfo.keys.toList(),
                  formatter: (DateTime date) {
                    return _xAxisInfo[date];
                  },
                ),
              ),
              OpenEatsJournalStrings.chartDataIsVar: Variable(
                accessor: (Map<dynamic, dynamic> map) => map[OpenEatsJournalStrings.chartDataIs] != null ? map[OpenEatsJournalStrings.chartDataIs] as num : 0,
                scale: LinearScale(min: yAxisScaleMinValue, max: yAxisScaleMaxValue),
              ),
            },
            marks: [
              LineMark(
                position: Varset(OpenEatsJournalStrings.chartDateVar) * Varset(OpenEatsJournalStrings.chartDataIsVar),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(value: colorScheme.tertiary),
                shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                label: LabelEncode(
                  encoder: (Map<dynamic, dynamic> map) {
                    return Label(
                      convert.getCleanDoubleString1DecimalDigit(doubleValue: map[OpenEatsJournalStrings.chartDataIsVar]),
                      LabelStyle(
                        textStyle: TextStyle(fontSize: fontSize, color: const Color(0xff808080)),
                        offset: Offset(6, -15),
                        rotation: 4.72,
                      ),
                    );
                  },
                ),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(strokeColor: Color(0xffe8e8e8), strokeWidth: 1),
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: fontSize, color: colorScheme.secondary),
                  offset: Offset(xAxisLabelXOffset, xAxisLabelYOffset),
                  rotation: 1,
                ),
              ),
              AxisGuide(
                dim: Dim.y,
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: fontSize, color: colorScheme.secondary),
                  offset: const Offset(-7.5, 0),
                ),
                grid: PaintStyle(strokeColor: colorScheme.surfaceDim, strokeWidth: 1),
              ),
            ],
            padding: (_) => const EdgeInsets.fromLTRB(40, 5, 20, 20),
          ),
        ),
      ],
    );
  }
}

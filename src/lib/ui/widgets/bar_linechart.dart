import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";
import "package:provider/provider.dart";

class BarLinechart extends StatelessWidget {
  const BarLinechart({
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

    final double barSize = _statisticInterval == StatisticInterval.daily ? 4 : 18;

    num? maxNutritionIntake = _data.reduce((currentEntry, nextEntry) {
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

    num? maxNutritionTarget = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartDataIs] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartDataTarget] > nextEntry[OpenEatsJournalStrings.chartDataTarget]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartDataTarget];

    num maxValue = 0;
    if (maxNutritionIntake != null) {
      maxValue = maxNutritionIntake;
    }

    if (maxNutritionTarget != null) {
      if (maxNutritionTarget > maxValue) {
        maxValue = maxNutritionTarget;
      }
    }

    //offset for point values
    double markOffset = -20;
    int yAxisScaleMaxValue = (maxValue * 1.4).toInt();
    if (maxValue >= 100000) {
      markOffset = -23;
      yAxisScaleMaxValue = (maxValue * 1.55).toInt();
    } else if (maxValue >= 50000) {
      markOffset = -20;
      yAxisScaleMaxValue = (maxValue * 1.45).toInt();
    } else if (maxValue >= 10000) {
      markOffset = -20;
      yAxisScaleMaxValue = (maxValue * 1.45).toInt();
    } else if (maxValue >= 5000) {
      markOffset = -18;
      yAxisScaleMaxValue = (maxValue * 1.5).toInt();
    }

    double xAxisLabelXOffset = 12;
    double xAxisLabelYOffset = 15;
    if (_statisticInterval == StatisticInterval.weekly) {
      xAxisLabelXOffset = 14;
      xAxisLabelYOffset = 18;
    } else if (_statisticInterval == StatisticInterval.monthly) {
      xAxisLabelXOffset = 12;
      xAxisLabelYOffset = 18;
    }

    final List entriesWithValues = _data.where((item) {
      return item[OpenEatsJournalStrings.chartDataIs] != null;
    }).toList();
    final num totalNutritionIntake = entriesWithValues.fold(0, (sum, item) => sum + item[OpenEatsJournalStrings.chartDataIs]);
    final num totalEntryCount = entriesWithValues.fold(0, (sum, item) => sum + item[OpenEatsJournalStrings.chartEntryCount]);
    int average = 0;
    if (entriesWithValues.isNotEmpty) {
      average = (totalNutritionIntake / totalEntryCount).toInt();
    }

    String timeInfo = AppLocalizations.of(context)!.days;
    if (_statisticInterval == StatisticInterval.weekly) {
      timeInfo = AppLocalizations.of(context)!.weeks;
    } else if (_statisticInterval == StatisticInterval.monthly) {
      timeInfo = AppLocalizations.of(context)!.months;
    }

    final String header = AppLocalizations.of(context)!.last_amount_timeinfo(_data.length - 1, timeInfo);

    final double fontSize = 12;

    return Column(
      children: [
        Row(
          children: [
            Text(header, style: textTheme.titleMedium),
            Spacer(),
            Text(AppLocalizations.of(context)!.average_per_day_number(convert.numberFomatterInt.format(average)), style: textTheme.titleSmall),
          ],
        ),
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
                scale: LinearScale(
                  min: 0,
                  max: yAxisScaleMaxValue,
                  //value is num/double, this removes the decimal separator on y axis label.
                  formatter: (value) => convert.numberFomatterInt.format(value.toInt()),
                  //ticks: [0, 500, 1000, 1500, 2000, 2500, 3000, 3500],
                ),
              ),
              OpenEatsJournalStrings.chartDataTargetVar: Variable(
                accessor: (Map<dynamic, dynamic> map) =>
                    map[OpenEatsJournalStrings.chartDataTarget] != null ? map[OpenEatsJournalStrings.chartDataTarget] as num : 0,
                scale: LinearScale(min: 0, max: yAxisScaleMaxValue),
              ),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: barSize),
                label: LabelEncode(
                  encoder: (Map<dynamic, dynamic> map) => Label(
                    map[OpenEatsJournalStrings.chartDataIsVar] > 0
                        ? (map[OpenEatsJournalStrings.chartDataIsVar] is int
                              ? convert.numberFomatterInt.format(map[OpenEatsJournalStrings.chartDataIsVar])
                              : convert.getCleanDoubleString1DecimalDigit(doubleValue: map[OpenEatsJournalStrings.chartDataIsVar]))
                        : OpenEatsJournalStrings.emptyString,
                    LabelStyle(
                      textStyle: TextStyle(fontSize: fontSize, color: const Color(0xff808080)),
                      offset: Offset(6, markOffset),
                      rotation: 4.72,
                    ),
                  ),
                ),
                color: ColorEncode(value: colorScheme.primary),
              ),
              LineMark(
                position: Varset(OpenEatsJournalStrings.chartDateVar) * Varset(OpenEatsJournalStrings.chartDataTargetVar),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(value: colorScheme.tertiary),
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

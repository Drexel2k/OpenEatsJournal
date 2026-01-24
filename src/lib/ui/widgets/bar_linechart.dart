import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";

//Values and bars on the corner cases are cut off, due to limitation on setting marginMin and marginMax on a TimeScale when min and max values are set.
//We could work with a linear scale here, but the placement of xAxis values is different than on the line charts, that looks also strange, especially
//on switching charts.
//See issue https://github.com/entronad/graphic/issues/358
class BarLinechart extends StatelessWidget {
  const BarLinechart({super.key, required List<Tuple> data, required Map<DateTime, String> xAxisInfo, required StatisticInterval statisticsType})
    : _data = data,
      _xAxisInfo = xAxisInfo,
      _statisticsType = statisticsType;

  final List<Tuple> _data;
  final Map<DateTime, String> _xAxisInfo;
  final StatisticInterval _statisticsType;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double barSize = _statisticsType == StatisticInterval.daily ? 4 : 18;

    int? maxkCalIntake = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartKCalIntake] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartKCalIntake] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartKCalIntake] > nextEntry[OpenEatsJournalStrings.chartKCalIntake]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartKCalIntake];

    int? maxkCalTarget = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartKCalIntake] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartKCalIntake] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartKCalTarget] > nextEntry[OpenEatsJournalStrings.chartKCalTarget]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartKCalTarget];

    int maxValue = 0;
    if (maxkCalIntake != null) {
      maxValue = maxkCalIntake;
    }

    if (maxkCalTarget != null) {
      if (maxkCalTarget > maxValue) {
        maxValue = maxkCalTarget;
      }
    }

    //offset for point values
    double markOffset = -15;
    int yAxisScaleMaxValue = (maxValue * 1.3).toInt();
    if (maxValue >= 100000) {
      markOffset = -20;
      yAxisScaleMaxValue = (maxValue * 1.5).toInt();
    } else if (maxValue >= 50000) {
      markOffset = -18;
      yAxisScaleMaxValue = (maxValue * 1.4).toInt();
    } else if (maxValue >= 10000) {
      markOffset = -18;
      yAxisScaleMaxValue = (maxValue * 1.35).toInt();
    } else if (maxValue >= 5000) {
      markOffset = -15;
      yAxisScaleMaxValue = (maxValue * 1.5).toInt();
    }

    double xAxisLabelXOffset = 12;
    double xAxisLabelYOffset = 15;
    if (_statisticsType == StatisticInterval.weekly) {
      xAxisLabelXOffset = 14;
      xAxisLabelYOffset = 18;
    } else if (_statisticsType == StatisticInterval.monthly) {
      xAxisLabelXOffset = 12;
      xAxisLabelYOffset = 18;
    }

    List entriesWithValues = _data.where((item) {
      return item[OpenEatsJournalStrings.chartKCalIntake] != null;
    }).toList();
    num totalkCalIntake = entriesWithValues.fold(0, (sum, item) => sum + item[OpenEatsJournalStrings.chartKCalIntake]);
    num totalEntryCount = entriesWithValues.fold(0, (sum, item) => sum + item[OpenEatsJournalStrings.chartEntryCount]);
    int average = 0;
    if (entriesWithValues.isNotEmpty) {
      average = (totalkCalIntake / totalEntryCount).toInt();
    }

    DateTime displayFrom =
        _data.reduce((currentEntry, nextEntry) {
              if ((currentEntry[OpenEatsJournalStrings.chartDateInformation] as DateTime).compareTo(
                    nextEntry[OpenEatsJournalStrings.chartDateInformation] as DateTime,
                  ) <
                  1) {
                return currentEntry;
              } else {
                return nextEntry;
              }
            })[OpenEatsJournalStrings.chartDateInformation]!
            as DateTime;

    DateTime displayUntil =
        _data.reduce((currentEntry, nextEntry) {
              if ((currentEntry[OpenEatsJournalStrings.chartDateInformation] as DateTime).compareTo(
                    nextEntry[OpenEatsJournalStrings.chartDateInformation] as DateTime,
                  ) >
                  1) {
                return currentEntry;
              } else {
                return nextEntry;
              }
            })[OpenEatsJournalStrings.chartDateInformation]!
            as DateTime;

    String timeInfo = AppLocalizations.of(context)!.days;
    if (_statisticsType == StatisticInterval.weekly) {
      timeInfo = AppLocalizations.of(context)!.weeks;
    } else if (_statisticsType == StatisticInterval.monthly) {
      timeInfo = AppLocalizations.of(context)!.months;
    }

    String header = AppLocalizations.of(context)!.last_amount_timeinfo(_data.length - 1, timeInfo);

    return Column(
      children: [
        Row(
          children: [
            Text(header, style: textTheme.titleMedium),
            Spacer(),
            Text(AppLocalizations.of(context)!.average_per_day_number(ConvertValidate.numberFomatterInt.format(average)), style: textTheme.titleSmall),
          ],
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 400,
          height: 150,
          child: Chart(
            data: _data,
            variables: {
              OpenEatsJournalStrings.chartDateVar: Variable(
                accessor: (Map<dynamic, dynamic> map) => map[OpenEatsJournalStrings.chartDateInformation] as DateTime,
                scale: TimeScale(
                  min: displayFrom,
                  max: displayUntil,
                  ticks: _xAxisInfo.keys.toList(),
                  formatter: (DateTime date) {
                    return _xAxisInfo[date];
                  },
                ),
              ),
              OpenEatsJournalStrings.chartKCalIntakeVar: Variable(
                accessor: (Map<dynamic, dynamic> map) =>
                    map[OpenEatsJournalStrings.chartKCalIntake] != null ? map[OpenEatsJournalStrings.chartKCalIntake] as num : 0,
                scale: LinearScale(
                  min: 0,
                  max: yAxisScaleMaxValue,
                  //value is num/double, this removes the decimal separator on y axis label.
                  formatter: (value) => ConvertValidate.numberFomatterInt.format(value.toInt()),
                  //ticks: [0, 500, 1000, 1500, 2000, 2500, 3000, 3500],
                ),
              ),
              OpenEatsJournalStrings.chartKCalTargetVar: Variable(
                accessor: (Map<dynamic, dynamic> map) =>
                    map[OpenEatsJournalStrings.chartKCalTarget] != null ? map[OpenEatsJournalStrings.chartKCalTarget] as num : 0,
                scale: LinearScale(min: 0, max: yAxisScaleMaxValue),
              ),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: barSize),
                label: LabelEncode(
                  encoder: (Map<dynamic, dynamic> map) => Label(
                    map[OpenEatsJournalStrings.chartKCalIntakeVar] > 0
                        ? ConvertValidate.numberFomatterInt.format(map[OpenEatsJournalStrings.chartKCalIntakeVar])
                        : OpenEatsJournalStrings.emptyString,
                    LabelStyle(
                      textStyle: TextStyle(fontSize: 10, color: const Color(0xff808080)),
                      offset: Offset(6, markOffset),
                      rotation: 4.72,
                    ),
                  ),
                ),
                color: ColorEncode(value: colorScheme.primary),
              ),
              LineMark(
                position: Varset(OpenEatsJournalStrings.chartDateVar) * Varset(OpenEatsJournalStrings.chartKCalTargetVar),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(value: colorScheme.tertiary),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(strokeColor: Color(0xffe8e8e8), strokeWidth: 1),
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: 10, color: colorScheme.secondary),
                  offset: Offset(xAxisLabelXOffset, xAxisLabelYOffset),
                  rotation: 1,
                ),
              ),
              AxisGuide(
                dim: Dim.y,
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: 10, color: colorScheme.secondary),
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

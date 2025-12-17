import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";

//Values and bars on the corner cases are cut off, due to limitation on setting marginMin and marginMax on a TimeScale when min and max values are set.
//See issue https://github.com/entronad/graphic/issues/358
class Linechart extends StatelessWidget {
  const Linechart({
    super.key,
    required List<Tuple> data,
    required DateTime displayFrom,
    required DateTime displayUntil,
    required Map<DateTime, String> xAxisInfo,
    required StatisticType statisticsType,
  }) : _data = data,
       _displayFrom = displayFrom,
       _displayUntil = displayUntil,
       _xAxisInfo = xAxisInfo,
       _statisticsType = statisticsType;

  final List<Tuple> _data;
  final DateTime _displayFrom;
  final DateTime _displayUntil;
  final Map<DateTime, String> _xAxisInfo;
  final StatisticType _statisticsType;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double? maxWeight = _data.reduce((currentEntry, nextEntry) {
      if (currentEntry[OpenEatsJournalStrings.chartWeight] == null) {
        return nextEntry;
      }

      if (nextEntry[OpenEatsJournalStrings.chartWeight] == null) {
        return currentEntry;
      }

      if (currentEntry[OpenEatsJournalStrings.chartWeight] > nextEntry[OpenEatsJournalStrings.chartWeight]) {
        return currentEntry;
      } else {
        return nextEntry;
      }
    })[OpenEatsJournalStrings.chartWeight];

    double maxValue = 0;
    if (maxWeight != null) {
      maxValue = maxWeight;
    }
		
    int yAxisScaleMaxValue = (maxValue * 1.3).toInt();
    if (maxValue >= 100000) {	   
      yAxisScaleMaxValue = (maxValue * 1.5).toInt();
    } else if (maxValue >= 50000) { 
      yAxisScaleMaxValue = (maxValue * 1.4).toInt();
    } else if (maxValue >= 10000) {  
      yAxisScaleMaxValue = (maxValue * 1.35).toInt();
    } else if (maxValue >= 5000) {
      yAxisScaleMaxValue = (maxValue * 1.5).toInt();
    }

    double xAxisLabelXOffset = 12;
    double xAxisLabelYOffset = 15;
    if (_statisticsType == StatisticType.weekly) {
      xAxisLabelXOffset = 14;
      xAxisLabelYOffset = 18;
    } else if (_statisticsType == StatisticType.monthly) {
      xAxisLabelXOffset = 12;
      xAxisLabelYOffset = 18;
    }

    String timeInfo = AppLocalizations.of(context)!.days;
    if (_statisticsType == StatisticType.weekly) {
      timeInfo = AppLocalizations.of(context)!.weeks;
    } else if (_statisticsType == StatisticType.monthly) {
      timeInfo = AppLocalizations.of(context)!.months;
    }

    String header = AppLocalizations.of(context)!.last_amount_timeinfo(_xAxisInfo.length - 1, timeInfo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: textTheme.titleMedium),
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
                  min: _displayFrom,
                  max: _displayUntil,
                  ticks: _xAxisInfo.keys.toList(),
                  formatter: (DateTime date) {
                    return _xAxisInfo[date];
                  },
                ),
              ),
              OpenEatsJournalStrings.chartWeightVar: Variable(
                accessor: (Map<dynamic, dynamic> map) => map[OpenEatsJournalStrings.chartWeight] != null ? map[OpenEatsJournalStrings.chartWeight] as num : 0,
                scale: LinearScale(min: 0, max: yAxisScaleMaxValue),
              ),
            },
            marks: [
              LineMark(
                position: Varset(OpenEatsJournalStrings.chartDateVar) * Varset(OpenEatsJournalStrings.chartWeightVar),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(value: colorScheme.tertiary),
                shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                label: LabelEncode(
                  encoder: (Map<dynamic, dynamic> map) {
                    if (map[OpenEatsJournalStrings.chartDateVar] != _displayUntil) {
                      return Label(
                        ConvertValidate.numberFomatterDouble.format(map[OpenEatsJournalStrings.chartWeightVar]),
                        LabelStyle(
                          textStyle: TextStyle(fontSize: 10, color: const Color(0xff808080)),
                          offset: Offset(6, -15),
                          rotation: 4.72,
                        ),
                      );
                    }

                    return Label(OpenEatsJournalStrings.emptyString);
                  },
                ),
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

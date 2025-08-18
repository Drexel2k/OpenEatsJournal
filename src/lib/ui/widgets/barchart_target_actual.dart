import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/statistic_type.dart";

class BarchartTargetActual extends StatelessWidget {
  const BarchartTargetActual({super.key, required data, required statisticsType})
    : _data = data,
      _statisticsType = statisticsType;

  final List<Tuple> _data;
  final StatisticsType _statisticsType;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat formatter = NumberFormat(null, Localizations.localeOf(context).languageCode);

    double barSize = _statisticsType == StatisticsType.daily ? 4 : 18;

    int maxkCalIntakeEntry = _data.reduce(
      (currentEntry, nextEntry) => currentEntry["kCalIntake"] > nextEntry["kCalIntake"] ? currentEntry : nextEntry,
    )["kCalIntake"];

    int maxkCalTargetEntry = _data.reduce(
      (currentEntry, nextEntry) => currentEntry["kCalTarget"] > nextEntry["kCalTarget"] ? currentEntry : nextEntry,
    )["kCalTarget"];

    int maxValue = maxkCalIntakeEntry > maxkCalTargetEntry ? maxkCalIntakeEntry : maxkCalTargetEntry;

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
    if (_statisticsType == StatisticsType.weekly) {
      xAxisLabelXOffset = 6;
      xAxisLabelYOffset = 10;
    } else if (_statisticsType == StatisticsType.monthly) {
      xAxisLabelXOffset = 8;
      xAxisLabelYOffset = 11;
    }

    num totalkCalIntake = _data.fold(0, (sum, item) => sum + item["kCalIntake"]);
    int average = (totalkCalIntake / _data.length).toInt();

    String timeInfo = AppLocalizations.of(context)!.days;
    if (_statisticsType == StatisticsType.weekly) {
      timeInfo = AppLocalizations.of(context)!.weeks;
    } else if (_statisticsType == StatisticsType.monthly) {
      timeInfo = AppLocalizations.of(context)!.months;
    }

    String header = AppLocalizations.of(context)!.last_amount_timeinfo(_data.length, timeInfo);

    return Column(
      children: [
        Center(child: Text(header, style: textTheme.titleMedium)),
        Center(
          child: Text(
            AppLocalizations.of(context)!.average_number(formatter.format(average)),
            style: textTheme.titleSmall,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 400,
          height: 150,
          child: Chart(
            data: _data,
            variables: {
              "date_information": Variable(accessor: (Map map) => map["dateInformation"] as String),
              "kCalIntake": Variable(
                accessor: (Map map) => map["kCalIntake"] as num,
                scale: LinearScale(
                  max: yAxisScaleMaxValue,
                  min: 0,
                  //value is num/double, this removes the decimal separator on y axis label.
                  formatter: (value) => formatter.format(value.toInt()),
                  //ticks: [0, 500, 1000, 1500, 2000, 2500, 3000, 3500],
                ),
              ),
              "kCalTarget": Variable(
                accessor: (Map map) => map["kCalTarget"] as num,
                scale: LinearScale(max: yAxisScaleMaxValue, min: 0),
              ),
            },
            marks: [
              IntervalMark(
                size: SizeEncode(value: barSize),
                label: LabelEncode(
                  encoder: (tuple) => Label(
                    formatter.format(tuple["kCalIntake"]),
                    LabelStyle(
                      textStyle: TextStyle(fontSize: 10, color: const Color(0xff808080)),
                      offset: Offset(6, markOffset),
                      rotation: 4.72,
                    ),
                  ),
                ),
                color: ColorEncode(value: Theme.of(context).colorScheme.primary),
              ),
              LineMark(
                position: Varset("date_information") * Varset("kCalTarget"),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(value: Theme.of(context).colorScheme.tertiary),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(strokeColor: Color(0xffe8e8e8), strokeWidth: 1),
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.secondary),
                  offset: Offset(xAxisLabelXOffset, xAxisLabelYOffset),
                  rotation: 1,
                ),
              ),
              AxisGuide(
                dim: Dim.y,
                label: LabelStyle(
                  textStyle: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.secondary),
                  offset: const Offset(-7.5, 0),
                ),
                grid: PaintStyle(strokeColor: Theme.of(context).colorScheme.surfaceDim, strokeWidth: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

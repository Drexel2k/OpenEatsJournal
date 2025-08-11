import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";

class BarchartTargetActual extends StatelessWidget {
  const BarchartTargetActual({
    super.key,
    required data,
    required dateInformation,
  }) : _data = data,
       _dateInformation = dateInformation;

  final List<Tuple> _data;
  final String _dateInformation;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat formatter = NumberFormat(
      null,
      Localizations.localeOf(context).languageCode,
    );

    double barSize = _dateInformation == "day" ? 4 : 18;

    int maxkCalIntakeEntry = _data.reduce(
      (currentEntry, nextEntry) =>
          currentEntry["kCalIntake"] > nextEntry["kCalIntake"]
          ? currentEntry
          : nextEntry,
    )["kCalIntake"];

    int maxkCalTargetEntry = _data.reduce(
      (currentEntry, nextEntry) =>
          currentEntry["kCalTarget"] > nextEntry["kCalTarget"]
          ? currentEntry
          : nextEntry,
    )["kCalTarget"];

    int maxValue = maxkCalIntakeEntry > maxkCalTargetEntry
        ? maxkCalIntakeEntry
        : maxkCalTargetEntry;

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

    double xAxisOffset = 20;
    if (_dateInformation == "week") {
      xAxisOffset = 13;
    } else if (_dateInformation == "month") {
      xAxisOffset = 15;
    }

    num totalkCalIntake = _data.fold(
      0,
      (sum, item) => sum + item["kCalIntake"],
    );
    int average = (totalkCalIntake / _data.length).toInt();

    String header = "Last ${_data.length} ${_dateInformation}s";

    return Column(
      children: [
        Center(child: Text(header, style: textTheme.titleMedium)),
        Center(
          child: Text(
            "Average: ${formatter.format(average)}",
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
              "date_information": Variable(
                accessor: (Map map) => map["dateInformation"] as String,
              ),
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
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: const Color(0xff808080),
                      ),
                      offset: Offset(6, markOffset),
                      rotation: 4.72,
                    ),
                  ),
                ),
                color: ColorEncode(
                  value: Theme.of(context).colorScheme.primary,
                ),
              ),
              LineMark(
                position: Varset("date_information") * Varset("kCalTarget"),
                size: SizeEncode(value: 1.5),
                color: ColorEncode(
                  value: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(
                  strokeColor: Color(0xffe8e8e8),
                  strokeWidth: 1,
                ),
                label: LabelStyle(
                  textStyle: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  offset: Offset(0, xAxisOffset),
                  rotation: 1.55,
                ),
              ),
              AxisGuide(
                dim: Dim.y,
                label: LabelStyle(
                  textStyle: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  offset: const Offset(-7.5, 0),
                ),
                grid: PaintStyle(
                  strokeColor: Theme.of(context).colorScheme.surfaceDim,
                  strokeWidth: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

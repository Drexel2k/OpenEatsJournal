import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";
import "package:openeatsjournal/ui/widgets/bar_linechart.dart";
import "package:provider/provider.dart";

class StatisticsScreenPageNutritions extends StatelessWidget {
  const StatisticsScreenPageNutritions({super.key, required StatisticType statistic, required StatisticsScreenViewModel statisticsScreenViewModel})
    : _statisticsScreenViewModel = statisticsScreenViewModel,
      _statistic = statistic;

  final StatisticsScreenViewModel _statisticsScreenViewModel;
  final StatisticType _statistic;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final double chartsWidth = MediaQuery.sizeOf(context).width * 0.96;

    return Column(
      children: [
        FutureBuilder<JournalRepositoryGetNutritionSumsResult>(
          future: _statisticsScreenViewModel.last31daysNutritionData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else if (snapshot.hasData) {
              DateFormat dateFormatter = DateFormat("dd.MMM");
              List<Tuple> dayData = [];
              DateTime currentDate;
              Map<DateTime, String> xAxisInfo = {};

              for (int dayIndex = 0; dayIndex <= 31; dayIndex++) {
                currentDate = snapshot.data!.from.add(Duration(days: dayIndex));
                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentDate)) {
                  dayData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentDate,
                    OpenEatsJournalStrings.chartDataIs: _getNutritionIntake(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartDataTarget: _getNutritionTarget(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentDate]!.entryCount,
                  });
                } else {
                  dayData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentDate,
                    OpenEatsJournalStrings.chartDataIs: null,
                    OpenEatsJournalStrings.chartDataTarget: null,
                  });
                }

                xAxisInfo[currentDate] = dateFormatter.format(currentDate);
              }

              return BarLinechart(
                data: dayData,
                scaleMinValue: snapshot.data!.from.subtract(Duration(hours: 8)),
                scaleMaxValue: snapshot.data!.until.add(Duration(hours: 8)),
                xAxisInfo: xAxisInfo,
                statisticInterval: StatisticInterval.daily,
                width: chartsWidth,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
        SizedBox(height: 20),
        FutureBuilder<JournalRepositoryGetNutritionSumsResult>(
          future: _statisticsScreenViewModel.last15weeksNutritionData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else if (snapshot.hasData) {
              List<Tuple> weekData = [];
              DateTime currentWeekStartDate;
              Map<DateTime, String> xAxisInfo = {};

              for (int weekIndex = 0; weekIndex <= 14; weekIndex++) {
                currentWeekStartDate = snapshot.data!.from.add(Duration(days: weekIndex * 7));
                WeekOfYear currentWeekOfYear = ConvertValidate.getweekOfYear(currentWeekStartDate);

                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentWeekStartDate)) {
                  weekData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                    OpenEatsJournalStrings.chartDataIs: _getNutritionIntake(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentWeekStartDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartDataTarget: _getNutritionTarget(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentWeekStartDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentWeekStartDate]!.entryCount,
                  });
                } else {
                  weekData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                    OpenEatsJournalStrings.chartDataIs: null,
                    OpenEatsJournalStrings.chartDataTarget: null,
                  });
                }

                xAxisInfo[currentWeekStartDate] = ("${currentWeekOfYear.week}/${currentWeekOfYear.year}");
              }

              return BarLinechart(
                data: weekData,
                scaleMinValue: snapshot.data!.from.subtract(Duration(hours: 80)),
                scaleMaxValue: snapshot.data!.until.add(Duration(hours: 80)),
                xAxisInfo: xAxisInfo,
                statisticInterval: StatisticInterval.daily,
                width: chartsWidth,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
        SizedBox(height: 26),
        FutureBuilder<JournalRepositoryGetNutritionSumsResult>(
          future: _statisticsScreenViewModel.last13monthsNutritionData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else if (snapshot.hasData) {
              List<Tuple> monthData = [];
              DateTime currentDate = _statisticsScreenViewModel.today;
              int currentMonth = currentDate.month;
              int currentYear = currentDate.year - 1;
              DateTime currentMonthStartDate;
              Map<DateTime, String> xAxisInfo = {};

              for (int monthIndex = 0; monthIndex <= 12; monthIndex++) {
                currentMonthStartDate = DateTime.utc(currentYear, currentMonth, 1);

                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentMonthStartDate)) {
                  monthData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                    OpenEatsJournalStrings.chartDataIs: _getNutritionIntake(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentMonthStartDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartDataTarget: _getNutritionTarget(
                      statistic: _statistic,
                      snapshot: snapshot,
                      currentDate: currentMonthStartDate,
                      convert: convert,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentMonthStartDate]!.entryCount,
                  });
                } else {
                  monthData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                    OpenEatsJournalStrings.chartDataIs: null,
                    OpenEatsJournalStrings.chartDataTarget: null,
                  });
                }

                xAxisInfo[currentMonthStartDate] = ("$currentMonth/$currentYear");

                currentMonth = currentMonth + 1;
                if (currentMonth > 12) {
                  currentMonth = 1;
                  currentYear = currentYear + 1;
                }
              }

              return BarLinechart(
                data: monthData,
                scaleMinValue: snapshot.data!.from.subtract(Duration(hours: 300)),
                scaleMaxValue: snapshot.data!.until.add(Duration(hours: 300)),
                xAxisInfo: xAxisInfo,
                statisticInterval: StatisticInterval.daily,
                width: chartsWidth,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
        //rotated axis label hangs over the widget, this prevents the label from being cut off if charts need more place than screen size...
        SizedBox(height: 20),
      ],
    );
  }

  double? _getNutritionIntake({
    required StatisticType statistic,
    required DateTime currentDate,
    required AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot,
    required ConvertValidate convert,
  }) {
    if (statistic == StatisticType.fat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.fat != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.fat!)
          : 0;
    }

    if (statistic == StatisticType.stauratedFat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.saturatedFat != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.saturatedFat!)
          : 0;
    }

    if (statistic == StatisticType.carbohydrates) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.carbohydrates != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.carbohydrates!)
          : 0;
    }

    if (statistic == StatisticType.sugar) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.sugar != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.sugar!)
          : 0;
    }

    if (statistic == StatisticType.protein) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.protein != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.protein!)
          : 0;
    }

    if (statistic == StatisticType.salt) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.salt != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.salt!)
          : 0;
    }

    throw StateError("Unknown statistic type.");
  }

  double? _getNutritionTarget({
    required StatisticType statistic,
    required DateTime currentDate,
    required AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot,
    required ConvertValidate convert,
  }) {
    if (statistic == StatisticType.fat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.fat != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.fat!)
          : 0;
    }

    if (statistic == StatisticType.stauratedFat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.saturatedFat != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.saturatedFat!)
          : 0;
    }

    if (statistic == StatisticType.carbohydrates) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.carbohydrates != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.carbohydrates!)
          : 0;
    }

    if (statistic == StatisticType.sugar) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.sugar != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.sugar!)
          : 0;
    }

    if (statistic == StatisticType.protein) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.protein != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.protein!)
          : 0;
    }

    if (statistic == StatisticType.salt) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.salt != null
          ? convert.getDisplayWeightG(weightG: snapshot.data!.groupNutritionTargets![currentDate]!.salt!)
          : 0;
    }

    throw StateError("Unknown statistic type.");
  }
}

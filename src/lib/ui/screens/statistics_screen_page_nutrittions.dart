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
import "package:openeatsjournal/ui/widgets/linechart.dart";

class StatisticsScreenPageNutritions extends StatelessWidget {
  const StatisticsScreenPageNutritions({super.key, required StatisticType statistic, required StatisticsScreenViewModel statisticsScreenViewModel})
    : _statisticsScreenViewModel = statisticsScreenViewModel,
      _statistic = statistic;

  final StatisticsScreenViewModel _statisticsScreenViewModel;
  final StatisticType _statistic;

  @override
  Widget build(BuildContext context) {
    String statisticVar = _getStatisticVar(statistic: _statistic);
    double chartsWidth = MediaQuery.sizeOf(context).width * 0.96;

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

              if (snapshot.data!.groupNutritionSums != null) {
                for (int dayIndex = 0; dayIndex <= 31; dayIndex++) {
                  currentDate = snapshot.data!.from!.add(Duration(days: dayIndex));
                  if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentDate)) {
                    //don't put in empty days, as the line in the chart will drop to 0 then
                    dayData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentDate,
                      statisticVar: _getStatisticData(statistic: _statistic, snapshot: snapshot, currentDate: currentDate),
                    });
                  }

                  xAxisInfo[currentDate] = dateFormatter.format(currentDate);
                }
              }

              return Linechart(
                dataVar: statisticVar,
                data: dayData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                yAxisStartAtZero: true,
                statisticsType: StatisticInterval.daily,
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

              if (snapshot.data!.groupNutritionSums != null) {
                for (int weekIndex = 0; weekIndex <= 14; weekIndex++) {
                  currentWeekStartDate = snapshot.data!.from!.add(Duration(days: weekIndex * 7));
                  WeekOfYear currentWeekOfYear = ConvertValidate.getweekOfYear(currentWeekStartDate);

                  //don't put in empty weeks, as the line in the chart will drop to 0 then
                  if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentWeekStartDate)) {
                    weekData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                      statisticVar: _getStatisticData(statistic: _statistic, snapshot: snapshot, currentDate: currentWeekStartDate),
                    });
                  }

                  xAxisInfo[currentWeekStartDate] = ("${currentWeekOfYear.week}/${currentWeekOfYear.year}");
                }
              }

              return Linechart(
                dataVar: statisticVar,
                data: weekData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                yAxisStartAtZero: true,
                statisticsType: StatisticInterval.weekly,
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
              DateTime currentDate = DateTime.now();
              int currentMonth = currentDate.month;
              int currentYear = currentDate.year - 1;
              DateTime currentMonthStartDate;
              Map<DateTime, String> xAxisInfo = {};

              if (snapshot.data!.groupNutritionSums != null) {
                for (int monthIndex = 0; monthIndex <= 12; monthIndex++) {
                  currentMonthStartDate = DateTime(currentYear, currentMonth, 1);

                  //don't put in empty months, as the line in the chart will drop to 0 then
                  if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentMonthStartDate)) {
                    monthData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                      statisticVar: _getStatisticData(statistic: _statistic, snapshot: snapshot, currentDate: currentMonthStartDate),
                    });
                  }

                  xAxisInfo[currentMonthStartDate] = ("$currentMonth/$currentYear");

                  currentMonth = currentMonth + 1;
                  if (currentMonth > 12) {
                    currentMonth = 1;
                    currentYear = currentYear + 1;
                  }
                }
              }

              return Linechart(
                dataVar: statisticVar,
                data: monthData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                yAxisStartAtZero: true,
                statisticsType: StatisticInterval.monthly,
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

  double? _getStatisticData({
    required StatisticType statistic,
    required DateTime currentDate,
    required AsyncSnapshot<JournalRepositoryGetNutritionSumsResult> snapshot,
  }) {
    if (statistic == StatisticType.fat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.fat != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.fat!)
          : 0;
    }

    if (statistic == StatisticType.stauratedFat) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.saturatedFat != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.saturatedFat!)
          : 0;
    }

    if (statistic == StatisticType.carbohydrates) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.carbohydrates != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.carbohydrates!)
          : 0;
    }

    if (statistic == StatisticType.sugar) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.sugar != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.sugar!)
          : 0;
    }

    if (statistic == StatisticType.protein) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.protein != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.protein!)
          : 0;
    }

    if (statistic == StatisticType.salt) {
      return snapshot.data!.groupNutritionSums![currentDate]!.nutritions.salt != null
          ? ConvertValidate.getDisplayWeightG(weightG: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.salt!)
          : 0;
    }

    throw StateError("Unknown statistic type.");
  }

  String _getStatisticVar({required StatisticType statistic}) {
    if (statistic == StatisticType.fat) {
      return OpenEatsJournalStrings.chartfat;
    }

    if (statistic == StatisticType.stauratedFat) {
      return OpenEatsJournalStrings.chartSaturatedFat;
    }

    if (statistic == StatisticType.carbohydrates) {
      return OpenEatsJournalStrings.chartCarbohydrates;
    }

    if (statistic == StatisticType.sugar) {
      return OpenEatsJournalStrings.chartSugar;
    }

    if (statistic == StatisticType.protein) {
      return OpenEatsJournalStrings.chartProtein;
    }

    if (statistic == StatisticType.salt) {
      return OpenEatsJournalStrings.chartSalt;
    }

    throw StateError("Unknown statistic type.");
  }
}

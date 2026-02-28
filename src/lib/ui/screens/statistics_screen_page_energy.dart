import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";
import "package:openeatsjournal/ui/widgets/bar_linechart.dart";

class StatisticsScreenPageEnergy extends StatelessWidget {
  const StatisticsScreenPageEnergy({super.key, required StatisticsScreenViewModel statisticsScreenViewModel})
    : _statisticsScreenViewModel = statisticsScreenViewModel;

  final StatisticsScreenViewModel _statisticsScreenViewModel;

  @override
  Widget build(BuildContext context) {
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

              for (int dayIndex = 0; dayIndex <= 31; dayIndex++) {
                currentDate = snapshot.data!.from!.add(Duration(days: dayIndex));
                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentDate)) {
                  dayData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentDate,
                    OpenEatsJournalStrings.chartKCalIntake: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionSums![currentDate]!.nutritions.kJoule,
                    ),
                    OpenEatsJournalStrings.chartKCalTarget: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionTargets![currentDate]!.kJoule,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentDate]!.entryCount,
                  });
                } else {
                  dayData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentDate,
                    OpenEatsJournalStrings.chartKCalIntake: null,
                    OpenEatsJournalStrings.chartKCalTarget: null,
                  });
                }

                xAxisInfo[currentDate] = dateFormatter.format(currentDate);
              }

              return BarLinechart(data: dayData, xAxisInfo: xAxisInfo, statisticsType: StatisticInterval.daily, width: chartsWidth);
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
                currentWeekStartDate = snapshot.data!.from!.add(Duration(days: weekIndex * 7));
                WeekOfYear currentWeekOfYear = ConvertValidate.getweekOfYear(currentWeekStartDate);

                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentWeekStartDate)) {
                  weekData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                    OpenEatsJournalStrings.chartKCalIntake: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionSums![currentWeekStartDate]!.nutritions.kJoule,
                    ),
                    OpenEatsJournalStrings.chartKCalTarget: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionTargets![currentWeekStartDate]!.kJoule,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentWeekStartDate]!.entryCount,
                  });
                } else {
                  weekData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                    OpenEatsJournalStrings.chartKCalIntake: null,
                    OpenEatsJournalStrings.chartKCalTarget: null,
                  });
                }

                xAxisInfo[currentWeekStartDate] = ("${currentWeekOfYear.week}/${currentWeekOfYear.year}");
              }

              return BarLinechart(data: weekData, xAxisInfo: xAxisInfo, statisticsType: StatisticInterval.weekly, width: chartsWidth);
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

              DateTime currentDate = DateUtils.dateOnly(_statisticsScreenViewModel.today);
              int currentMonth = currentDate.month;
              int currentYear = currentDate.year - 1;
              DateTime currentMonthStartDate;
              Map<DateTime, String> xAxisInfo = {};

              for (int monthIndex = 0; monthIndex <= 12; monthIndex++) {
                currentMonthStartDate = DateTime(currentYear, currentMonth, 1);

                if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(currentMonthStartDate)) {
                  monthData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                    OpenEatsJournalStrings.chartKCalIntake: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionSums![currentMonthStartDate]!.nutritions.kJoule,
                    ),
                    OpenEatsJournalStrings.chartKCalTarget: ConvertValidate.getDisplayEnergy(
                      energyKJ: snapshot.data!.groupNutritionTargets![currentMonthStartDate]!.kJoule,
                    ),
                    OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![currentMonthStartDate]!.entryCount,
                  });
                } else {
                  monthData.add({
                    OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                    OpenEatsJournalStrings.chartKCalIntake: null,
                    OpenEatsJournalStrings.chartKCalTarget: null,
                  });
                }

                xAxisInfo[currentMonthStartDate] = ("$currentMonth/$currentYear");

                currentMonth = currentMonth + 1;
                if (currentMonth > 12) {
                  currentMonth = 1;
                  currentYear = currentYear + 1;
                }
              }

              return BarLinechart(data: monthData, xAxisInfo: xAxisInfo, statisticsType: StatisticInterval.monthly, width: chartsWidth);
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
}

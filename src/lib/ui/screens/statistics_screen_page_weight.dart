import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/repository/journal_repository_get_weight_max_result.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/statistic_interval.dart";
import "package:openeatsjournal/ui/widgets/linechart.dart";

class StatisticsScreenPageWeight extends StatelessWidget {
  const StatisticsScreenPageWeight({super.key, required StatisticsScreenViewModel statisticsScreenViewModel})
    : _statisticsScreenViewModel = statisticsScreenViewModel;

  final StatisticsScreenViewModel _statisticsScreenViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<JournalRepositoryGetWeightMaxResult>(
          future: _statisticsScreenViewModel.last31daysWeightData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetWeightMaxResult> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else if (snapshot.hasData) {
              DateFormat dateFormatter = DateFormat("dd.MMM");
              List<Tuple> dayData = [];
              DateTime currentDate;
              Map<DateTime, String> xAxisInfo = {};

              if (snapshot.data!.groupMaxWeights != null) {
                for (int dayIndex = 0; dayIndex <= 31; dayIndex++) {
                  currentDate = snapshot.data!.from!.add(Duration(days: dayIndex));

                  //check if an entry exists before the current stastics range, as a weight entry is also valid for the following days until a newer entry is
                  //available, so the the drawn line enters the chart at the correct height
                  if (dayIndex == 0) {
                    DateTime dateBeforeEntry = snapshot.data!.groupMaxWeights!.keys.min;
                    if (dateBeforeEntry.compareTo(currentDate) < 0) {
                      dayData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateBeforeEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.min],
                      });
                    }
                  }

                  //don't put in empty days, as the line in the chart will drop to 0 then
                  if (snapshot.data!.groupMaxWeights!.containsKey(currentDate)) {
                    dayData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentDate,
                      OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![currentDate]!,
                    });
                  }

                  xAxisInfo[currentDate] = dateFormatter.format(currentDate);

                  //check if an entry exists after the current stastics range, as a weight entry is also valid for the following days until a newer entry is
                  //available, so the the drawn line exits the chart at the correct height
                  if (dayIndex == 31) {
                    DateTime dateAfterEntry = snapshot.data!.groupMaxWeights!.keys.max;
                    if (dateAfterEntry.compareTo(currentDate) > 0) {
                      dayData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateAfterEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.max],
                      });
                    }
                  }
                }
              }

              return Linechart(
                dataVar: OpenEatsJournalStrings.chartWeight,
                data: dayData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                statisticsType: StatisticInterval.daily,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
        SizedBox(height: 20),
        FutureBuilder<JournalRepositoryGetWeightMaxResult>(
          future: _statisticsScreenViewModel.last15weeksWeightData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetWeightMaxResult> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else if (snapshot.hasData) {
              List<Tuple> weekData = [];
              DateTime currentWeekStartDate;
              Map<DateTime, String> xAxisInfo = {};

              if (snapshot.data!.groupMaxWeights != null) {
                for (int weekIndex = 0; weekIndex <= 14; weekIndex++) {
                  currentWeekStartDate = snapshot.data!.from!.add(Duration(days: weekIndex * 7));
                  WeekOfYear currentWeekOfYear = ConvertValidate.getweekOfYear(currentWeekStartDate);

                  if (weekIndex == 0) {
                    DateTime dateBeforeEntry = snapshot.data!.groupMaxWeights!.keys.min;
                    if (dateBeforeEntry.compareTo(currentWeekStartDate) < 0) {
                      weekData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateBeforeEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.min],
                      });
                    }
                  }

                  //don't put in empty weeks, as the line in the chart will drop to 0 then
                  if (snapshot.data!.groupMaxWeights!.containsKey(currentWeekStartDate)) {
                    weekData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentWeekStartDate,
                      OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![currentWeekStartDate]!,
                    });
                  }

                  xAxisInfo[currentWeekStartDate] = ("${currentWeekOfYear.week}/${currentWeekOfYear.year}");

                  if (weekIndex == 14) {
                    DateTime dateAfterEntry = snapshot.data!.groupMaxWeights!.keys.max;
                    if (dateAfterEntry.compareTo(currentWeekStartDate) > 0) {
                      weekData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateAfterEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.max],
                      });
                    }
                  }
                }
              }

              return Linechart(
                dataVar: OpenEatsJournalStrings.chartWeight,
                data: weekData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                statisticsType: StatisticInterval.weekly,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
        SizedBox(height: 26),
        FutureBuilder<JournalRepositoryGetWeightMaxResult>(
          future: _statisticsScreenViewModel.last13monthsWeightData,
          builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetWeightMaxResult> snapshot) {
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

              if (snapshot.data!.groupMaxWeights != null) {
                for (int monthIndex = 0; monthIndex <= 12; monthIndex++) {
                  currentMonthStartDate = DateTime(currentYear, currentMonth, 1);

                  if (monthIndex == 0) {
                    DateTime dateBeforeEntry = snapshot.data!.groupMaxWeights!.keys.min;
                    if (dateBeforeEntry.compareTo(currentMonthStartDate) < 0) {
                      monthData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateBeforeEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.min],
                      });
                    }
                  }

                  //don't put in empty months, as the line in the chart will drop to 0 then
                  if (snapshot.data!.groupMaxWeights!.containsKey(currentMonthStartDate)) {
                    monthData.add({
                      OpenEatsJournalStrings.chartDateInformation: currentMonthStartDate,
                      OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![currentMonthStartDate]!,
                    });
                  }

                  xAxisInfo[currentMonthStartDate] = ("$currentMonth/$currentYear");

                  if (monthIndex == 12) {
                    DateTime dateAfterEntry = snapshot.data!.groupMaxWeights!.keys.max;
                    if (dateAfterEntry.compareTo(currentMonthStartDate) > 0) {
                      monthData.add({
                        OpenEatsJournalStrings.chartDateInformation: dateAfterEntry,
                        OpenEatsJournalStrings.chartWeight: snapshot.data!.groupMaxWeights![snapshot.data!.groupMaxWeights!.keys.max],
                      });
                    }
                  }

                  currentMonth = currentMonth + 1;
                  if (currentMonth > 12) {
                    currentMonth = 1;
                    currentYear = currentYear + 1;
                  }
                }
              }

              return Linechart(
                dataVar: OpenEatsJournalStrings.chartWeight,
                data: monthData,
                displayFrom: snapshot.data!.from!,
                displayUntil: snapshot.data!.until!,
                xAxisInfo: xAxisInfo,
                statisticsType: StatisticInterval.monthly,
              );
            } else {
              return Text("No Data Available");
            }
          },
        ),
      ],
    );
  }
}

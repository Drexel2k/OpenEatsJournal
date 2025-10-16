import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/journal_repository_get_sums_result.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/ui/widgets/barchart_target_actual.dart";

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required StatisticsScreenViewModel statisticsScreenViewModel}) : _statisticsScreenViewModel = statisticsScreenViewModel;

  final StatisticsScreenViewModel _statisticsScreenViewModel;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteStatistics,
      body: Column(
        children: [
          FutureBuilder<JournalRepositoryGetSumsResult>(
            future: _statisticsScreenViewModel.last31daysData,
            builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetSumsResult> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                throw StateError("Something went wrong: ${snapshot.error}");
              } else if (snapshot.hasData) {
                List<Tuple> dayData = [];

                DateFormat dateFormatter = DateFormat("dd.MMM");
                DateTime currentDate;
                for (int dayIndex = 0; dayIndex <= 31; dayIndex++) {
                  currentDate = snapshot.data!.from!.add(Duration(days: dayIndex));
                  if (snapshot.data!.groupNutritionSums != null &&
                      snapshot.data!.groupNutritionSums!.containsKey(ConvertValidate.dateformatterDateOnly.format(currentDate))) {
                    dayData.add({
                      OpenEatsJournalStrings.chartDateInformation: dateFormatter.format(currentDate),
                      OpenEatsJournalStrings.chartKCalIntake: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionSums![ConvertValidate.dateformatterDateOnly.format(currentDate)]!.nutritions.kJoule,
                      ),
                      OpenEatsJournalStrings.chartKCalTarget: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionTargets![ConvertValidate.dateformatterDateOnly.format(currentDate)]!.kJoule,
                      ),
                      OpenEatsJournalStrings.chartEntryCount:
                          snapshot.data!.groupNutritionSums![ConvertValidate.dateformatterDateOnly.format(currentDate)]!.entryCount,
                    });
                  } else {
                    dayData.add({
                      OpenEatsJournalStrings.chartDateInformation: dateFormatter.format(currentDate),
                      OpenEatsJournalStrings.chartKCalIntake: null,
                      OpenEatsJournalStrings.chartKCalTarget: null,
                    });
                  }
                }

                return BarchartTargetActual(data: dayData, statisticsType: StatisticType.daily);
              } else {
                return Text("No Data Available");
              }
            },
          ),
          SizedBox(height: 30),
          FutureBuilder<JournalRepositoryGetSumsResult>(
            future: _statisticsScreenViewModel.last15weeksData,
            builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetSumsResult> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                throw StateError("Something went wrong: ${snapshot.error}");
              } else if (snapshot.hasData) {
                List<Tuple> weekData = [];

                DateTime currentDate;

                for (int weekIndex = 0; weekIndex <= 14; weekIndex++) {
                  currentDate = snapshot.data!.from!.add(Duration(days: weekIndex * 7));
                  WeekOfYear weekOfYear = ConvertValidate.getweekNumber(currentDate);
                  String dbResultKey = "${weekOfYear.year}-${weekOfYear.week.toString().padLeft(2, "0")}";

                  if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(dbResultKey)) {
                    weekData.add({
                      OpenEatsJournalStrings.chartDateInformation: "${weekOfYear.week}/${weekOfYear.year}",
                      OpenEatsJournalStrings.chartKCalIntake: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionSums![dbResultKey]!.nutritions.kJoule,
                      ),
                      OpenEatsJournalStrings.chartKCalTarget: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionTargets![dbResultKey]!.kJoule,
                      ),
                      OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![dbResultKey]!.entryCount,
                    });
                  } else {
                    weekData.add({
                      OpenEatsJournalStrings.chartDateInformation: "${weekOfYear.week}/${weekOfYear.year}",
                      OpenEatsJournalStrings.chartKCalIntake: null,
                      OpenEatsJournalStrings.chartKCalTarget: null,
                    });
                  }
                }

                return BarchartTargetActual(data: weekData, statisticsType: StatisticType.weekly);
              } else {
                return Text("No Data Available");
              }
            },
          ),
          SizedBox(height: 35),
          FutureBuilder<JournalRepositoryGetSumsResult>(
            future: _statisticsScreenViewModel.last13monthsData,
            builder: (BuildContext context, AsyncSnapshot<JournalRepositoryGetSumsResult> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                throw StateError("Something went wrong: ${snapshot.error}");
              } else if (snapshot.hasData) {
                List<Tuple> monthData = [];

                DateTime currentDate = DateTime.now();
                int currentMonth = currentDate.month;
                int currentYear = currentDate.year - 1;
                for (int monthIndex = 0; monthIndex <= 12; monthIndex++) {
                  String dbResultKey = "$currentYear-${currentMonth.toString().padLeft(2, "0")}";

                  if (snapshot.data!.groupNutritionSums != null && snapshot.data!.groupNutritionSums!.containsKey(dbResultKey)) {
                    monthData.add({
                      OpenEatsJournalStrings.chartDateInformation: "$currentMonth/$currentYear",
                      OpenEatsJournalStrings.chartKCalIntake: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionSums![dbResultKey]!.nutritions.kJoule,
                      ),
                      OpenEatsJournalStrings.chartKCalTarget: NutritionCalculator.getKCalsFromKJoules(
                        snapshot.data!.groupNutritionTargets![dbResultKey]!.kJoule,
                      ),
                      OpenEatsJournalStrings.chartEntryCount: snapshot.data!.groupNutritionSums![dbResultKey]!.entryCount,
                    });
                  } else {
                    monthData.add({
                      OpenEatsJournalStrings.chartDateInformation: "$currentMonth/$currentYear",
                      OpenEatsJournalStrings.chartKCalIntake: null,
                      OpenEatsJournalStrings.chartKCalTarget: null,
                    });
                  }

                  currentMonth = currentMonth + 1;
                  if (currentMonth > 12) {
                    currentMonth = 1;
                    currentYear = currentYear + 1;
                  }
                }

                return BarchartTargetActual(data: monthData, statisticsType: StatisticType.monthly);
              } else {
                return Text("No Data Available");
              }
            },
          ),
        ],
      ),
      title: AppLocalizations.of(context)!.statistics,
    );
  }
}

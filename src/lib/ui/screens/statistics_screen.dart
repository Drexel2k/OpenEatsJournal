import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/ui/widgets/barchart_target_actual.dart";

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Tuple> dayData = [
      {'dateInformation': '10.Aug', 'kCalIntake': 2300, 'kCalTarget': 2400},
      {'dateInformation': '9.Aug', 'kCalIntake': 2700, 'kCalTarget': 2400},
      {'dateInformation': '8.Aug', 'kCalIntake': 2600, 'kCalTarget': 2400},
      {'dateInformation': '7.Aug', 'kCalIntake': 2000, 'kCalTarget': 2400},
      {'dateInformation': '6.Aug', 'kCalIntake': 1000, 'kCalTarget': 2400},
      {'dateInformation': '5.Aug', 'kCalIntake': 2300, 'kCalTarget': 2400},
      {'dateInformation': '4.Aug', 'kCalIntake': 2700, 'kCalTarget': 2400},
      {'dateInformation': '3.Aug', 'kCalIntake': 2600, 'kCalTarget': 2400},
      {'dateInformation': '2.Aug', 'kCalIntake': 2000, 'kCalTarget': 2400},
      {'dateInformation': '1.Aug', 'kCalIntake': 1000, 'kCalTarget': 2400},
      {'dateInformation': '31.Jul', 'kCalIntake': 2300, 'kCalTarget': 2500},
      {'dateInformation': '30.Jul', 'kCalIntake': 2700, 'kCalTarget': 2500},
      {'dateInformation': '29.Jul', 'kCalIntake': 2600, 'kCalTarget': 2500},
      {'dateInformation': '28.Jul', 'kCalIntake': 2000, 'kCalTarget': 2500},
      {'dateInformation': '27.Jul', 'kCalIntake': 1000, 'kCalTarget': 2500},
      {'dateInformation': '26.Jul', 'kCalIntake': 2300, 'kCalTarget': 2500},
      {'dateInformation': '25.Jul', 'kCalIntake': 2700, 'kCalTarget': 2500},
      {'dateInformation': '24.Jul', 'kCalIntake': 2600, 'kCalTarget': 2500},
      {'dateInformation': '23.Jul', 'kCalIntake': 2000, 'kCalTarget': 2500},
      {'dateInformation': '22.Jul', 'kCalIntake': 1000, 'kCalTarget': 2500},
      {'dateInformation': '21.Jul', 'kCalIntake': 2300, 'kCalTarget': 2500},
      {'dateInformation': '20.Jul', 'kCalIntake': 2700, 'kCalTarget': 2500},
      {'dateInformation': '19.Jul', 'kCalIntake': 2600, 'kCalTarget': 2500},
      {'dateInformation': '18.Jul', 'kCalIntake': 2000, 'kCalTarget': 2500},
      {'dateInformation': '17.Jul', 'kCalIntake': 1000, 'kCalTarget': 2500},
      {'dateInformation': '16.Jul', 'kCalIntake': 2300, 'kCalTarget': 2500},
      {'dateInformation': '15.Jul', 'kCalIntake': 2700, 'kCalTarget': 2500},
      {'dateInformation': '14.Jul', 'kCalIntake': 2600, 'kCalTarget': 2500},
      {'dateInformation': '13.Jul', 'kCalIntake': 2000, 'kCalTarget': 2500},
      {'dateInformation': '12.Jul', 'kCalIntake': 1000, 'kCalTarget': 2500},
    ];

    List<Tuple> weekData = [
      {'dateInformation': '32', 'kCalIntake': 17000, 'kCalTarget': 16800},
      {'dateInformation': '31', 'kCalIntake': 16500, 'kCalTarget': 16800},
      {'dateInformation': '30', 'kCalIntake': 18000, 'kCalTarget': 17500},
      {'dateInformation': '29', 'kCalIntake': 18200, 'kCalTarget': 17500},
      {'dateInformation': '28', 'kCalIntake': 17100, 'kCalTarget': 17500},
      {'dateInformation': '27', 'kCalIntake': 17000, 'kCalTarget': 17500},
      {'dateInformation': '26', 'kCalIntake': 17500, 'kCalTarget': 17500},
      {'dateInformation': '25', 'kCalIntake': 16500, 'kCalTarget': 17500},
      {'dateInformation': '24', 'kCalIntake': 18500, 'kCalTarget': 17500},
      {'dateInformation': '23', 'kCalIntake': 17700, 'kCalTarget': 17500},
      {'dateInformation': '22', 'kCalIntake': 17700, 'kCalTarget': 17500},
      {'dateInformation': '21', 'kCalIntake': 17400, 'kCalTarget': 17500},
      {'dateInformation': '20', 'kCalIntake': 17500, 'kCalTarget': 17500},
    ];

    List<Tuple> monthData = [
      {'dateInformation': 'Jul', 'kCalIntake': 80000, 'kCalTarget': 77500},
      {'dateInformation': 'Jun', 'kCalIntake': 74000, 'kCalTarget': 75000},
      {'dateInformation': 'May', 'kCalIntake': 73000, 'kCalTarget': 77500},
      {'dateInformation': 'Apr', 'kCalIntake': 76000, 'kCalTarget': 75000},
      {'dateInformation': 'Mar', 'kCalIntake': 75000, 'kCalTarget': 77500},
      {'dateInformation': 'Feb', 'kCalIntake': 64000, 'kCalTarget': 62500},
      {'dateInformation': 'Jan', 'kCalIntake': 80000, 'kCalTarget': 77500},
      {'dateInformation': 'Dec', 'kCalIntake': 85000, 'kCalTarget': 77500},
      {'dateInformation': 'Nov', 'kCalIntake': 76000, 'kCalTarget': 75000},
      {'dateInformation': 'Oct', 'kCalIntake': 76000, 'kCalTarget': 77500},
      {'dateInformation': 'Sep', 'kCalIntake': 78000, 'kCalTarget': 75000},
      {'dateInformation': 'Aug', 'kCalIntake': 73000, 'kCalTarget': 77500},
    ];

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteStatistics,
      body: Column(
        children: [
          BarchartTargetActual(data: dayData, statisticsType: StatisticType.daily),
          SizedBox(height: 30),
          BarchartTargetActual(data: weekData, statisticsType: StatisticType.weekly),
          SizedBox(height: 20),
          BarchartTargetActual(data: monthData, statisticsType: StatisticType.monthly),
        ],
      ),
      title: AppLocalizations.of(context)!.statistics,
    );
  }
}

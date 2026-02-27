import "package:flutter/material.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_page_energy.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_page_nutrittions.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_page_weight.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:provider/provider.dart";

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsScreenViewModel>(
      builder: (context, statisticsScreenViewModel, _) => MainLayout(
        route: OpenEatsJournalStrings.navigatorRouteStatistics,
        body: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: statisticsScreenViewModel.currentStatistic,
              builder: (_, _, _) {
                return OpenEatsJournalDropdownMenu<int>(
                  onSelected: (int? statisticValue) {
                    statisticsScreenViewModel.currentStatistic.value = StatisticType.getByValue(statisticValue!);
                  },
                  dropdownMenuEntries: LocalizedDropDownEntries.getStatisticDropDownMenuEntries(context: context),
                  initialSelection: statisticsScreenViewModel.currentStatistic.value.value,
                );
              },
            ),
            SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: statisticsScreenViewModel.currentStatistic,
              builder: (_, _, _) {
                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.weight) {
                  return StatisticsScreenPageWeight(statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.fat) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.fat, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.stauratedFat) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.stauratedFat, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.carbohydrates) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.carbohydrates, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.sugar) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.sugar, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.protein) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.protein, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                if (statisticsScreenViewModel.currentStatistic.value == StatisticType.salt) {
                  return StatisticsScreenPageNutritions(statistic: StatisticType.salt, statisticsScreenViewModel: statisticsScreenViewModel);
                }

                return StatisticsScreenPageEnergy(statisticsScreenViewModel: statisticsScreenViewModel);
              },
            ),
          ],
        ),
        title: AppLocalizations.of(context)!.statistics,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

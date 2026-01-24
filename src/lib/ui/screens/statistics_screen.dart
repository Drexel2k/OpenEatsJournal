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

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required StatisticsScreenViewModel statisticsScreenViewModel}) : _statisticsScreenViewModel = statisticsScreenViewModel;

  final StatisticsScreenViewModel _statisticsScreenViewModel;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late StatisticsScreenViewModel _statisticsScreenViewModel;

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _statisticsScreenViewModel = widget._statisticsScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteStatistics,
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _statisticsScreenViewModel.currentStatistic,
            builder: (_, _, _) {
              return OpenEatsJournalDropdownMenu<int>(
                onSelected: (int? statisticValue) {
                  _statisticsScreenViewModel.currentStatistic.value = StatisticType.getByValue(statisticValue!);
                },
                dropdownMenuEntries: LocalizedDropDownEntries.getStatisticDropDownMenuEntries(context: context),
                initialSelection: _statisticsScreenViewModel.currentStatistic.value.value,
              );
            },
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: _statisticsScreenViewModel.currentStatistic,
            builder: (_, _, _) {
              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.weight) {
                return StatisticsScreenPageWeight(statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.fat) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.fat, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.stauratedFat) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.stauratedFat, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.carbohydrates) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.carbohydrates, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.sugar) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.sugar, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.protein) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.protein, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              if (_statisticsScreenViewModel.currentStatistic.value == StatisticType.salt) {
                return StatisticsScreenPageNutritions(statistic: StatisticType.salt, statisticsScreenViewModel: _statisticsScreenViewModel);
              }

              return StatisticsScreenPageEnergy(statisticsScreenViewModel: _statisticsScreenViewModel);
            },
          ),
        ],
      ),
      title: AppLocalizations.of(context)!.statistics,
    );
  }

  @override
  void dispose() {
    widget._statisticsScreenViewModel.dispose();
    if (widget._statisticsScreenViewModel != _statisticsScreenViewModel) {
      _statisticsScreenViewModel.dispose();
    }

    super.dispose();
  }
}

import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/daily_overview_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";

class DailyOverviewScreen extends StatelessWidget {
  const DailyOverviewScreen({
    super.key,
    required DailyOverviewViewModel homeViewModel,
    required SettingsRepository settingsRepository,
  }) : _homeViewModel = homeViewModel,
       _settingsRepository = settingsRepository;

  final DailyOverviewViewModel _homeViewModel;
  final SettingsRepository _settingsRepository;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    final NumberFormat formatter = NumberFormat(null, Localizations.localeOf(context).languageCode);

    int value = 1250;
    int maxValue = 2500;

    List<Color> colors = [];
    int percentageFilled;

    if (value <= maxValue) {
      colors.add(colorTheme.inversePrimary);
      colors.add(colorTheme.primary);

      percentageFilled = (value / maxValue * 100).round();
    } else {
      colors.add(colorTheme.primary);
      colors.add(colorTheme.error);

      if (value <= 2 * maxValue) {
        percentageFilled = ((value - maxValue) / maxValue * 100).round();
      } else {
        percentageFilled = 100;
      }
    }

    double dimension = 200;
    double radius = 0.9;

    return MainLayout(
      route: NavigatorRoutes.home,
      title: AppLocalizations.of(context)!.daily_overview,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 4,
                child: TextButton(
                  onPressed: () async {
                    try {} on Exception catch (exc, stack) {
                      await ErrorHandlers.showException(
                        context: navigatorKey.currentContext!,
                        exception: exc,
                        stackTrace: stack,
                      );
                    } on Error catch (error, stack) {
                      await ErrorHandlers.showException(
                        context: navigatorKey.currentContext!,
                        error: error,
                        stackTrace: stack,
                      );
                    }
                  },
                  child: Text(
                    DateFormat.yMMMMd(_homeViewModel.languageCode).format(DateTime.now()),
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    iconSize: 36,
                    onPressed: () async {
                      try {
                        await showDialog<void>(
                          useSafeArea: true,
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext contextBuilder) {
                            double horizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.05;
                            double verticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.03;

                            return Dialog(
                              insetPadding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                verticalPadding,
                                horizontalPadding,
                                verticalPadding,
                              ),
                              child: SettingsScreen(
                                settingsViewModel: SettingsViewModel(settingsRepository: _settingsRepository),
                              ),
                            );
                          },
                        );
                      } on Exception catch (exc, stack) {
                        await ErrorHandlers.showException(
                          context: navigatorKey.currentContext!,
                          exception: exc,
                          stackTrace: stack,
                        );
                      } on Error catch (error, stack) {
                        await ErrorHandlers.showException(
                          context: navigatorKey.currentContext!,
                          error: error,
                          stackTrace: stack,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(AppLocalizations.of(context)!.kcal, style: textTheme.titleLarge, textAlign: TextAlign.center),
                    Text(
                      "${formatter.format(value)}/\n${formatter.format(maxValue)}",
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: dimension,
                      width: dimension,
                      child: Chart(
                        data: [
                          {'type': '100Percent', 'percent': 100},
                          {'type': 'actualPercent', 'percent': percentageFilled},
                        ],
                        variables: {
                          'type': Variable(accessor: (Map map) => map['type'] as String),
                          'percent': Variable(
                            accessor: (Map map) => map['percent'] as num,
                            scale: LinearScale(min: 0, max: 100),
                          ),
                        },
                        marks: [
                          IntervalMark(
                            shape: ShapeEncode(
                              value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(8))),
                            ),
                            color: ColorEncode(variable: "type", values: colors),
                          ),
                        ],
                        coord: PolarCoord(
                          transposed: true,
                          startAngle: 2.5,
                          endAngle: 6.93,
                          startRadius: radius,
                          endRadius: radius,
                        ),
                      ),
                    ),
                  ),
                  Flexible(flex: 1, child: SizedBox()),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 150),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: AppLocalizations.of(context)!.fat,
                            value: 256,
                            maxValue: 596,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: AppLocalizations.of(context)!.carb,
                            value: 33,
                            maxValue: 88,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: AppLocalizations.of(context)!.prot,
                            value: 33,
                            maxValue: 88,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

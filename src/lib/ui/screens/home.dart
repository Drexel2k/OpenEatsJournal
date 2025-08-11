import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/home_viewmodel.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required HomeViewModel homeViewModel})
    : _homeViewModel = homeViewModel;

  final HomeViewModel _homeViewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat formatter = NumberFormat(null, Localizations.localeOf(context).languageCode);

    int value = 1250;
    int maxValue = 2500;

    List<Color> colors = [];
    int percentageFilled;

    if (value <= maxValue) {
      colors.add(Theme.of(context).colorScheme.inversePrimary);
      colors.add(Theme.of(context).colorScheme.primary);

      percentageFilled = (value / maxValue * 100).round();
    } else {
      colors.add(Theme.of(context).colorScheme.primary);
      colors.add(Theme.of(context).colorScheme.error);

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
              Expanded(child: SizedBox()),
              Expanded(
                flex: 4,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    DateFormat.yMMMMd(
                      _homeViewModel.languageCode,
                    ).format(DateTime.now()),
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.settings, size: 36),
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
                    Text(
                      "kCal",
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
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
                  Expanded(child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: dimension,
                      width: dimension,
                      child: Chart(
                        data: [
                          {'type': '100_percent', 'percent': 100},
                          {
                            'type': 'current_prcent',
                            'percent': percentageFilled,
                          },
                        ],
                        variables: {
                          'type': Variable(
                            accessor: (Map map) => map['type'] as String,
                          ),
                          'percent': Variable(
                            accessor: (Map map) => map['percent'] as num,
                            scale: LinearScale(min: 0, max: 100),
                          ),
                        },
                        marks: [
                          IntervalMark(
                            shape: ShapeEncode(
                              value: RectShape(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            color: ColorEncode(
                              variable: 'type',
                              values: colors,
                            ),
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
                  Expanded(child: SizedBox()),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 150),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: "Fat",
                            value: 256,
                            maxValue: 596
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: "Carb",
                            value: 33,
                            maxValue: 88
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GaugeNutritionFactSmall(
                            factName: "Prot",
                            value: 33,
                            maxValue: 88
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

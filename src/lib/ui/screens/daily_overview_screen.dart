import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/daily_overview_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/localized_meal_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/widgets/gauge_distribution.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/round_transparent_choice_chip.dart";

class DailyOverviewScreen extends StatelessWidget {
  const DailyOverviewScreen({
    super.key,
    required DailyOverviewScreenViewModel dailyOverviewScreenViewModel,
    required SettingsRepository settingsRepository,
  }) : _dailyOverviewScreenViewModel = dailyOverviewScreenViewModel,
       _settingsRepository = settingsRepository;

  final DailyOverviewScreenViewModel _dailyOverviewScreenViewModel;
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

    double breakfastPercent = 13.7;
    double lunchPercent = 36.4;
    double dinnerPercent = 45.1;
    double snacksPercent = 4.8;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteHome,
      title: AppLocalizations.of(context)!.daily_overview,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: ValueListenableBuilder(
                  valueListenable: _dailyOverviewScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        try {
                          _selectDate(initialDate: _dailyOverviewScreenViewModel.currentJournalDate.value, context: context);
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
                      child: Text(
                        DateFormat.yMMMMd(
                          _dailyOverviewScreenViewModel.languageCode,
                        ).format(_dailyOverviewScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: ValueListenableBuilder(
                  valueListenable: _dailyOverviewScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _dailyOverviewScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedMealDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: _dailyOverviewScreenViewModel.currentMeal.value.value,
                    );
                  },
                ),
              ),
            ],
          ),
          //Hack for renderring graphic pie chart. The pie chart takes always the space of the full circle,
          //even if through start and end angle not the full space is needed.
          //Through the stack widgets can be placed closer together by overlapping the free space of the
          //pie chart.
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
              Center(
                child: SizedBox(
                  height: dimension,
                  width: dimension,
                  child: Chart(
                    data: [
                      {'type': '100Percent', 'percent': 100},
                      {'type': 'currentPercent', 'percent': percentageFilled},
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
                        shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(8)))),
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
                            value: 80,
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
                  SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: _dailyOverviewScreenViewModel.currentJournalDate,
                    builder: (_, _, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _getLast8DaysIncludingToday().map((DateTime date) {
                          return RoundTransparentChoiceChip(
                            selected: _dailyOverviewScreenViewModel.currentJournalDate.value == date,
                            onSelected: (bool selected) => {_dailyOverviewScreenViewModel.currentJournalDate.value = date},
                            label: Text(DateFormat("EEEE").format(date).substring(0, 1)),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 6),
                  //Hack for renderring graphic pie chart. The pie chart takes always the space of the full circle,
                  //even if through start and end angle not the full space is needed.
                  //Through the stack widgets can be placed closer together by overlapping the free space of the
                  //pie chart.
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GaugeDistribution(value: breakfastPercent, startValue: 0),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              margin: const EdgeInsets.only(top: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text(AppLocalizations.of(context)!.breakfast), Text("$breakfastPercent%")],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 50),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GaugeDistribution(value: lunchPercent, startValue: breakfastPercent),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 11),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [Text(AppLocalizations.of(context)!.lunch), Text("$lunchPercent%")],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 100),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GaugeDistribution(
                                    value: dinnerPercent,
                                    startValue: breakfastPercent + lunchPercent,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 11),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [Text(AppLocalizations.of(context)!.dinner), Text("$dinnerPercent%")],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 150),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GaugeDistribution(
                                        value: snacksPercent,
                                        startValue: breakfastPercent + lunchPercent + dinnerPercent,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 11),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [Text(AppLocalizations.of(context)!.snacks), Text("$snacksPercent%")],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 7),
                          Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(height: 48, child: OutlinedButton(onPressed: () {}, child: null)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.breakfast;
                                    },
                                    icon: Icon(Icons.check),
                                  ),

                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.breakfast;
                                      Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 57),
                          Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(height: 48, child: OutlinedButton(onPressed: () {}, child: null)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.lunch;
                                    },
                                    icon: Icon(Icons.check),
                                  ),

                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.lunch;
                                      Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 107),
                          Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(height: 48, child: OutlinedButton(onPressed: () {}, child: null)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.dinner;
                                    },
                                    icon: Icon(Icons.check),
                                  ),

                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.dinner;
                                      Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 157),
                          Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(height: 48, child: OutlinedButton(onPressed: () {}, child: null)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.snacks;
                                    },
                                    icon: Icon(Icons.check),
                                  ),

                                  IconButton.outlined(
                                    onPressed: () {
                                      _dailyOverviewScreenViewModel.currentMeal.value = Meal.snacks;
                                      Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 220,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.0)),
                            ),
                            onPressed: () {},
                            child: null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
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
                                        settingsScreenViewModel: SettingsScreenViewModel(settingsRepository: _settingsRepository),
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
                            icon: Icon(Icons.settings),
                            iconSize: 36,
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

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(9999),
    );

    if (date != null) {
      _dailyOverviewScreenViewModel.currentJournalDate.value = date;
    }
  }

  List<DateTime> _getLast8DaysIncludingToday() {
    DateTime date = DateUtils.dateOnly(DateTime.now());
    date = date.subtract(Duration(days: 7));

    List<DateTime> days = [];
    for (var i = 0; i <= 7; i++) {
      days.add(date);
      date = date.add(Duration(days: 1));
    }

    return days;
  }
}

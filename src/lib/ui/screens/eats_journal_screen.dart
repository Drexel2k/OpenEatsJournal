import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/localized_meal_drop_down_entries.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:openeatsjournal/ui/widgets/gauge_distribution.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/round_transparent_choice_chip.dart";

class EatsJournalScreen extends StatelessWidget {
  const EatsJournalScreen({super.key, required EatsJournalScreenViewModel eatsJournalScreenViewModel})
    : _eatsJournalScreenViewModel = eatsJournalScreenViewModel;

  final EatsJournalScreenViewModel _eatsJournalScreenViewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fabMenuWidth = 150;

    double dimension = 200;
    double radius = 0.9;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteEatsJournal,
      title: AppLocalizations.of(context)!.eats_journal,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        try {
                          _selectDate(initialDate: _eatsJournalScreenViewModel.currentJournalDate.value, context: context);
                        } on Exception catch (exc, stack) {
                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                        } on Error catch (error, stack) {
                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                        }
                      },
                      child: Text(
                        DateFormat.yMMMMd(_eatsJournalScreenViewModel.languageCode).format(_eatsJournalScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedMealDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: _eatsJournalScreenViewModel.currentMeal.value.value,
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
          ListenableBuilder(
            listenable: _eatsJournalScreenViewModel.eatsJournalDataChanged,
            builder: (_, _) {
              return FutureBuilder<FoodRepositoryGetDayMealSumsResult>(
                future: _eatsJournalScreenViewModel.dayData,
                builder: (BuildContext context, AsyncSnapshot<FoodRepositoryGetDayMealSumsResult> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    throw StateError("Something went wrong: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    final ColorScheme colorScheme = Theme.of(context).colorScheme;

                    GaugeData kJouleGaugeData = _getKJouleGaugeData(foodRepositoryGetDayDataResult: snapshot.data!, colorScheme: colorScheme);
                    GaugeData carbohydratesGaugeData = _getCarbohydratesGaugeData(foodRepositoryGetDayDataResult: snapshot.data!, colorScheme: colorScheme);
                    GaugeData proteinGaugeData = _getProteinGaugeData(foodRepositoryGetDayDataResult: snapshot.data!, colorScheme: colorScheme);
                    GaugeData fatGaugeData = _getFatGaugeData(foodRepositoryGetDayDataResult: snapshot.data!, colorScheme: colorScheme);

                    double breakfastPercent = _getBreakfastKJoulePercent(
                      foodRepositoryGetDayDataResult: snapshot.data!,
                      dayKJoule: kJouleGaugeData.currentValue,
                    );
                    double lunchPercent = _getLunchKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                    double dinnerPercent = _getDinnerKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                    double snacksPercent = _getSnacksKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);

                    return Stack(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(height: 50),
                              Text(AppLocalizations.of(context)!.kcal, style: textTheme.titleLarge, textAlign: TextAlign.center),
                              Text(
                                "${ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: kJouleGaugeData.currentValue))}/\n${ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: kJouleGaugeData.maxValue))}",
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
                                {"type": "100Percent", "percent": 100},
                                {"type": "currentPercent", "percent": kJouleGaugeData.percentageFilled},
                              ],
                              variables: {
                                "type": Variable(accessor: (Map map) => map["type"] as String),
                                "percent": Variable(accessor: (Map map) => map["percent"] as num, scale: LinearScale(min: 0, max: 100)),
                              },
                              marks: [
                                IntervalMark(
                                  shape: ShapeEncode(value: RectShape(borderRadius: const BorderRadius.all(Radius.circular(8)))),
                                  color: ColorEncode(variable: "type", values: kJouleGaugeData.colors),
                                ),
                              ],
                              coord: PolarCoord(transposed: true, startAngle: 2.5, endAngle: 6.93, startRadius: radius, endRadius: radius),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 150),
                            Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.fat, gaugeData: fatGaugeData),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.carb, gaugeData: carbohydratesGaugeData),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.prot, gaugeData: proteinGaugeData),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ValueListenableBuilder(
                              valueListenable: _eatsJournalScreenViewModel.currentJournalDate,
                              builder: (_, _, _) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: _getLast8DaysIncludingToday().map((DateTime date) {
                                    return RoundTransparentChoiceChip(
                                      selected: _eatsJournalScreenViewModel.currentJournalDate.value == date,
                                      onSelected: (bool selected) => {_eatsJournalScreenViewModel.currentJournalDate.value = date},
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
                                    SizedBox(
                                      width: 80,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GaugeDistribution(value: breakfastPercent, startValue: 0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 11),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)!.breakfast),
                                            Text("${ConvertValidate.numberFomatterDouble.format(breakfastPercent)}%"),
                                          ],
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
                                        SizedBox(
                                          width: 80,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: GaugeDistribution(value: lunchPercent, startValue: breakfastPercent),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.lunch),
                                                Text("${ConvertValidate.numberFomatterDouble.format(lunchPercent)}%"),
                                              ],
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
                                        SizedBox(
                                          width: 80,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: GaugeDistribution(value: dinnerPercent, startValue: breakfastPercent + lunchPercent),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.dinner),
                                                Text("${ConvertValidate.numberFomatterDouble.format(dinnerPercent)}%"),
                                              ],
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
                                            SizedBox(
                                              width: 80,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: GaugeDistribution(value: snacksPercent, startValue: breakfastPercent + lunchPercent + dinnerPercent),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(top: 11),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(AppLocalizations.of(context)!.snacks),
                                                    Text("${ConvertValidate.numberFomatterDouble.format(snacksPercent)}%"),
                                                  ],
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
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.breakfast;
                                              },
                                              icon: Icon(Icons.check),
                                            ),

                                            IconButton.outlined(
                                              onPressed: () {
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.breakfast;
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
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.lunch;
                                              },
                                              icon: Icon(Icons.check),
                                            ),

                                            IconButton.outlined(
                                              onPressed: () {
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.lunch;
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
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.dinner;
                                              },
                                              icon: Icon(Icons.check),
                                            ),

                                            IconButton.outlined(
                                              onPressed: () {
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.dinner;
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
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.snacks;
                                              },
                                              icon: Icon(Icons.check),
                                            ),

                                            IconButton.outlined(
                                              onPressed: () {
                                                _eatsJournalScreenViewModel.currentMeal.value = Meal.snacks;
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
                                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.0))),
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
                                                insetPadding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
                                                child: SettingsScreen(
                                                  settingsScreenViewModel: SettingsScreenViewModel(
                                                    settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                  ),
                                                ),
                                              );
                                            },
                                          );

                                          _eatsJournalScreenViewModel.refreshData();
                                        } on Exception catch (exc, stack) {
                                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                                        } on Error catch (error, stack) {
                                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
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
                    );
                  } else {
                    return Text("No Data Available");
                  }
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: fabMenuWidth,
        height: 310,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder(
              valueListenable: _eatsJournalScreenViewModel.floatingActionMenuElapsed,
              builder: (_, _, _) {
                if (_eatsJournalScreenViewModel.floatingActionMenuElapsed.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "5",
                          onPressed: () {
                            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                          },
                          label: Text(AppLocalizations.of(context)!.eats_journal_entry),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(heroTag: "4", onPressed: () {}, label: Text(AppLocalizations.of(context)!.weight_journal_entry)),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "3",
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              OpenEatsJournalStrings.navigatorRouteFoodEdit,
                              arguments: Food(
                                name: OpenEatsJournalStrings.emptyString,
                                foodSource: FoodSource.user,
                                kJoule: NutritionCalculator.kJouleForOncekCal,
                                nutritionPerGramAmount: 100,
                              ),
                            );
                          },
                          label: Text(AppLocalizations.of(context)!.food),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(heroTag: "2", onPressed: () {}, label: Text(AppLocalizations.of(context)!.quick_entry)),
                      ),
                    ],
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
            const SizedBox(height: 10, width: 0),
            FloatingActionButton(
              heroTag: "1",
              onPressed: () {
                _eatsJournalScreenViewModel.toggleFloatingActionButtons();
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      _eatsJournalScreenViewModel.currentJournalDate.value = date;
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

  GaugeData _getKJouleGaugeData({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required ColorScheme colorScheme}) {
    int dayTargetKJoule = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.kJoule
        : _eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule();
    int daySumKJoule = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.kJoule)
              .reduce((kJouleEntry1, kJouleEntry2) => kJouleEntry1 + kJouleEntry2)
        : 0;

    return GaugeData(currentValue: daySumKJoule, maxValue: dayTargetKJoule, colorScheme: colorScheme);
  }

  GaugeData _getCarbohydratesGaugeData({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required ColorScheme colorScheme}) {
    double dayTargetCarbohydrates = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.carbohydrates!
        : NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: _eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
    double daySumCarbohydrates = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.carbohydrates!)
              .reduce((carbohydratesEntry1, carbohydratesEntry2) => carbohydratesEntry1 + carbohydratesEntry2)
        : 0;

    return GaugeData(currentValue: daySumCarbohydrates, maxValue: dayTargetCarbohydrates, colorScheme: colorScheme);
  }

  GaugeData _getProteinGaugeData({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required ColorScheme colorScheme}) {
    double dayTargetProtein = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.protein!
        : NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: _eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
    double daySumProtein = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.protein!)
              .reduce((proteinEntry1, proteinEntry2) => proteinEntry1 + proteinEntry2)
        : 0;

    return GaugeData(currentValue: daySumProtein, maxValue: dayTargetProtein, colorScheme: colorScheme);
  }

  GaugeData _getFatGaugeData({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required ColorScheme colorScheme}) {
    double dayTargetFat = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.fat!
        : NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: _eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
    double daySumFat = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.fat!)
              .reduce((fatEntry1, fatEntry2) => fatEntry1 + fatEntry2)
        : 0;

    return GaugeData(currentValue: daySumFat, maxValue: dayTargetFat, colorScheme: colorScheme);
  }

  double _getBreakfastKJoulePercent({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required num dayKJoule}) {
    double percent = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.breakfast)) {
      percent = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.breakfast]!.kJoule / dayKJoule * 100;
    }

    return percent;
  }

  double _getLunchKJoulePercent({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required num dayKJoule}) {
    double percent = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.lunch)) {
      percent = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.lunch]!.kJoule / dayKJoule * 100;
    }

    return percent;
  }

  double _getDinnerKJoulePercent({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required num dayKJoule}) {
    double percent = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.dinner)) {
      percent = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.dinner]!.kJoule / dayKJoule * 100;
    }

    return percent;
  }

  double _getSnacksKJoulePercent({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult, required num dayKJoule}) {
    double percent = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.snacks)) {
      percent = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.snacks]!.kJoule / dayKJoule * 100;
    }

    return percent;
  }
}

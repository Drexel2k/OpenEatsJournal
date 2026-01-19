import "package:flutter/material.dart";
import "package:graphic/graphic.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:openeatsjournal/ui/widgets/gauge_distribution.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/round_transparent_choice_chip.dart";

class EatsJournalScreen extends StatefulWidget {
  const EatsJournalScreen({super.key, required EatsJournalScreenViewModel eatsJournalScreenViewModel})
    : _eatsJournalScreenViewModel = eatsJournalScreenViewModel;

  final EatsJournalScreenViewModel _eatsJournalScreenViewModel;

  @override
  State<EatsJournalScreen> createState() => _EatsJournalScreenState();
}

class _EatsJournalScreenState extends State<EatsJournalScreen> {
  late EatsJournalScreenViewModel _eatsJournalScreenViewModel;

  @override
  void initState() {
    _eatsJournalScreenViewModel = widget._eatsJournalScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fabMenuWidth = 150;

    double dimension = 200;
    double radius = 0.9;

    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteEatsJournal,
      title: AppLocalizations.of(context)!.eats_journal,
      mainNavigationCallback: () {
        _eatsJournalScreenViewModel.refreshNutritionData();
      },
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
                        DateTime? date = await _selectDate(initialDate: _eatsJournalScreenViewModel.currentJournalDate.value, context: context);
                        if (date != null) {
                          _changeDate(date: date);
                        }
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalScreenViewModel.currentJournalDate.value),
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
                        _changeMeal(meal: Meal.getByValue(mealValue!));
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
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
                future: _eatsJournalScreenViewModel.dayNutritionDataPerMeal,
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

                    double breakfastStartPoint = 0;
                    double breakfastEndpoint = breakfastPercent;

                    double lunchPercent = _getLunchKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                    double lunchStartPoint = breakfastPercent;
                    double lunchEndpoint = breakfastPercent + lunchPercent;

                    double dinnerPercent = _getDinnerKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                    double dinnerStartPoint = breakfastPercent + lunchPercent;
                    double dinnerEndpoint = breakfastPercent + lunchPercent + dinnerPercent;

                    double snacksPercent = _getSnacksKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                    double snacksStartPoint = breakfastPercent + lunchPercent + dinnerPercent;
                    double snacksEndpoint = breakfastPercent + lunchPercent + dinnerPercent + snacksPercent;

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
                            FutureBuilder<Map<int, bool>>(
                              future: _eatsJournalScreenViewModel.eatsJournalEntriesAvailableForLast8Days,
                              builder: (BuildContext context, AsyncSnapshot<Map<int, bool>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                                } else if (snapshot.hasError) {
                                  throw StateError("Something went wrong: ${snapshot.error}");
                                } else if (snapshot.hasData) {
                                  DateTime currentDate = DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: 8));
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [-7, -6, -5, -4, -3, -2, -1, 0].map((int dayIndex) {
                                      currentDate = currentDate.add(Duration(days: 1));
                                      DateTime chipDate = currentDate;
                                      TextStyle? style = snapshot.data![dayIndex]!
                                          ? TextStyle(color: colorScheme.inversePrimary, fontWeight: FontWeight.w900)
                                          : null;

                                      return RoundTransparentChoiceChip(
                                        selected: _eatsJournalScreenViewModel.currentJournalDate.value == chipDate,
                                        onSelected: (bool selected) {
                                          _changeDate(date: chipDate);
                                        },
                                        label: Text(DateFormat("EEEE").format(chipDate).substring(0, 1), style: style),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return Text("No Data Available");
                                }
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
                                        child: GaugeDistribution(startValue: breakfastStartPoint, endValue: breakfastEndpoint),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 11),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)!.breakfast),
                                            Text("${ConvertValidate.getCleanDoubleString(doubleValue: breakfastPercent)}%"),
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
                                            child: GaugeDistribution(startValue: lunchStartPoint, endValue: lunchEndpoint),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.lunch),
                                                Text("${ConvertValidate.getCleanDoubleString(doubleValue: lunchPercent)}%"),
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
                                            child: GaugeDistribution(startValue: dinnerStartPoint, endValue: dinnerEndpoint),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.dinner),
                                                Text("${ConvertValidate.getCleanDoubleString(doubleValue: dinnerPercent)}%"),
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
                                    SizedBox(height: 150),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: GaugeDistribution(startValue: snacksStartPoint, endValue: snacksEndpoint),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.snacks),
                                                Text("${ConvertValidate.getCleanDoubleString(doubleValue: snacksPercent)}%"),
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
                                    SizedBox(height: 200),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 20),
                                        SizedBox(
                                          width: 60,
                                          height: 54,
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Icon(Icons.scale, size: 45, color: colorScheme.primary),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 11),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(AppLocalizations.of(context)!.weight),
                                                ListenableBuilder(
                                                  listenable: _eatsJournalScreenViewModel.currentWeightChanged,
                                                  builder: (_, _) {
                                                    return FutureBuilder<WeightJournalEntry?>(
                                                      future: _eatsJournalScreenViewModel.currentWeight,
                                                      builder: (BuildContext context, AsyncSnapshot<WeightJournalEntry?> snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                                                        } else if (snapshot.hasError) {
                                                          throw StateError("Something went wrong: ${snapshot.error}");
                                                        } else if (snapshot.hasData) {
                                                          return Text(
                                                            snapshot.data != null
                                                                ? "${ConvertValidate.getCleanDoubleString(doubleValue: snapshot.data!.weight)}${AppLocalizations.of(context)!.kg}"
                                                                : AppLocalizations.of(context)!.na,
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
                                          ),
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
                                              //breakfast nutrition button
                                              child: SizedBox(
                                                height: 48,
                                                child: OutlinedButton(
                                                  onPressed: () async {
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
                                                          child: EatsJournalEditScreen(
                                                            eatsJournalEditScreenViewModel: EatsJournalEditScreenViewModel(
                                                              journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                              settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                              meal: Meal.breakfast,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    _eatsJournalScreenViewModel.refreshNutritionData();
                                                  },
                                                  child: null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.outlined(
                                              onPressed: () {
                                                _changeMeal(meal: Meal.breakfast);
                                              },
                                              icon: Icon(Icons.check),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.breakfast);
                                                await UiHelpers.pushQuickEntryRoute(
                                                  context: (context),
                                                  initialEntryDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                                                  initialMeal: _eatsJournalScreenViewModel.currentMeal.value,
                                                );
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
                                              },
                                              icon: Icon(Icons.speed),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.breakfast);
                                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
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
                                              //lunch nutrition button
                                              child: SizedBox(
                                                height: 48,
                                                child: OutlinedButton(
                                                  onPressed: () async {
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
                                                          child: EatsJournalEditScreen(
                                                            eatsJournalEditScreenViewModel: EatsJournalEditScreenViewModel(
                                                              journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                              settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                              meal: Meal.lunch,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    _eatsJournalScreenViewModel.refreshNutritionData();
                                                  },
                                                  child: null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.outlined(
                                              onPressed: () {
                                                _changeMeal(meal: Meal.lunch);
                                              },
                                              icon: Icon(Icons.check),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.lunch);
                                                await UiHelpers.pushQuickEntryRoute(
                                                  context: (context),
                                                  initialEntryDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                                                  initialMeal: _eatsJournalScreenViewModel.currentMeal.value,
                                                );
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
                                              },
                                              icon: Icon(Icons.speed),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.lunch);
                                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
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
                                              //dinner nutrition button
                                              child: SizedBox(
                                                height: 48,
                                                child: OutlinedButton(
                                                  onPressed: () async {
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
                                                          child: EatsJournalEditScreen(
                                                            eatsJournalEditScreenViewModel: EatsJournalEditScreenViewModel(
                                                              journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                              settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                              meal: Meal.dinner,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    _eatsJournalScreenViewModel.refreshNutritionData();
                                                  },
                                                  child: null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.outlined(
                                              onPressed: () {
                                                _changeMeal(meal: Meal.dinner);
                                              },
                                              icon: Icon(Icons.check),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.dinner);
                                                await UiHelpers.pushQuickEntryRoute(
                                                  context: (context),
                                                  initialEntryDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                                                  initialMeal: _eatsJournalScreenViewModel.currentMeal.value,
                                                );
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
                                              },
                                              icon: Icon(Icons.speed),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.dinner);
                                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
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
                                              //snacks nutrition button
                                              child: SizedBox(
                                                height: 48,
                                                child: OutlinedButton(
                                                  onPressed: () async {
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
                                                          child: EatsJournalEditScreen(
                                                            eatsJournalEditScreenViewModel: EatsJournalEditScreenViewModel(
                                                              journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                              settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                              meal: Meal.snacks,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    _eatsJournalScreenViewModel.refreshNutritionData();
                                                  },
                                                  child: null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.outlined(
                                              onPressed: () {
                                                _changeMeal(meal: Meal.snacks);
                                              },
                                              icon: Icon(Icons.check),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.snacks);
                                                await UiHelpers.pushQuickEntryRoute(
                                                  context: (context),
                                                  initialEntryDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                                                  initialMeal: _eatsJournalScreenViewModel.currentMeal.value,
                                                );
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
                                              },
                                              icon: Icon(Icons.speed),
                                            ),
                                            IconButton.outlined(
                                              onPressed: () async {
                                                _changeMeal(meal: Meal.snacks);
                                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                _eatsJournalScreenViewModel.refreshNutritionData();
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
                                    SizedBox(height: 207),
                                    Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                //weight button
                                                child: OutlinedButton(
                                                  onPressed: () async {
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
                                                          child: WeightJournalEditScreen(
                                                            weightEditScreenViewModel: WeightJournalEditScreenViewModel(
                                                              journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    _eatsJournalScreenViewModel.refreshCurrentWeight();
                                                  },
                                                  child: null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.outlined(
                                              onPressed: () async {
                                                if (await UiHelpers.showAddWeightDialog(
                                                  context: AppGlobal.navigatorKey.currentContext!,
                                                  initialDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                                                  initialWeight: await _eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                                                  saveCallback: _setWeightJournalEntry,
                                                )) {
                                                  _eatsJournalScreenViewModel.refreshCurrentWeight();
                                                }
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
                                    //main nutrition button
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.0))),
                                      onPressed: () async {
                                        await showDialog<void>(
                                          useSafeArea: true,
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext contextBuilder) {
                                            double horizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.05;
                                            double verticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.03;

                                            return Dialog(
                                              insetPadding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
                                              child: EatsJournalEditScreen(
                                                eatsJournalEditScreenViewModel: EatsJournalEditScreenViewModel(
                                                  journalRepository: _eatsJournalScreenViewModel.journalRepository,
                                                  settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                        _eatsJournalScreenViewModel.refreshNutritionData();
                                      },
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
                                    //settings button
                                    child: IconButton(
                                      onPressed: () async {
                                        double weight = await _eatsJournalScreenViewModel.getLastWeightJournalEntry();
                                        await showDialog<void>(
                                          useSafeArea: true,
                                          barrierDismissible: false,
                                          context: AppGlobal.navigatorKey.currentContext!,
                                          builder: (BuildContext contextBuilder) {
                                            return Dialog(
                                              insetPadding: EdgeInsets.fromLTRB(
                                                dialogHorizontalPadding,
                                                dialogVerticalPadding,
                                                dialogHorizontalPadding,
                                                dialogVerticalPadding,
                                              ),
                                              child: SettingsScreen(
                                                settingsScreenViewModel: SettingsScreenViewModel(
                                                  settingsRepository: _eatsJournalScreenViewModel.settingsRepository,
                                                  weight: weight,
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                        _eatsJournalScreenViewModel.refreshWeightTarget();
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
                          onPressed: () async {
                            _eatsJournalScreenViewModel.toggleFloatingActionButtons();

                            await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                            _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                            _eatsJournalScreenViewModel.refreshNutritionData();
                          },
                          label: Text(AppLocalizations.of(context)!.eats_journal_entry),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "4",
                          onPressed: () async {
                            _eatsJournalScreenViewModel.toggleFloatingActionButtons();

                            if (await UiHelpers.showAddWeightDialog(
                              context: AppGlobal.navigatorKey.currentContext!,
                              initialDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                              initialWeight: await _eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                              saveCallback: _setWeightJournalEntry,
                            )) {
                              _eatsJournalScreenViewModel.refreshCurrentWeight();
                            }
                          },
                          label: Text(AppLocalizations.of(context)!.weight_journal_entry),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "3",
                          onPressed: () {
                            _eatsJournalScreenViewModel.toggleFloatingActionButtons();

                            Navigator.pushNamed(
                              context,
                              OpenEatsJournalStrings.navigatorRouteFoodEdit,
                              arguments: Food(
                                name: OpenEatsJournalStrings.emptyString,
                                foodSource: FoodSource.user,
                                fromDb: true,
                                kJoule: NutritionCalculator.kJouleForOnekCal,
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
                        child: FloatingActionButton.extended(
                          heroTag: "2",
                          onPressed: () async {
                            _eatsJournalScreenViewModel.toggleFloatingActionButtons();
                            await UiHelpers.pushQuickEntryRoute(
                              context: (context),
                              initialEntryDate: _eatsJournalScreenViewModel.currentJournalDate.value,
                              initialMeal: _eatsJournalScreenViewModel.currentMeal.value,
                            );
                            _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                            _eatsJournalScreenViewModel.refreshNutritionData();
                          },
                          label: Text(AppLocalizations.of(context)!.quick_entry),
                        ),
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

  Future<void> _setWeightJournalEntry(double weight) async {
    await _eatsJournalScreenViewModel.setWeightJournalEntry(date: _eatsJournalScreenViewModel.currentJournalDate.value, weight: weight);
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));
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
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.carbohydrates != null ? mealNutritionsEntry.value.carbohydrates! : 0.0)
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
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.protein != null ? mealNutritionsEntry.value.protein! : 0.0)
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
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.fat != null ? mealNutritionsEntry.value.fat! : 0.0)
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

  void _changeMeal({required Meal meal}) {
    _eatsJournalScreenViewModel.currentMeal.value = meal;
    _eatsJournalScreenViewModel.updateCurrentMealInSettingsRepository();
  }

  void _changeDate({required DateTime date}) {
    _eatsJournalScreenViewModel.currentJournalDate.value = date;
    _eatsJournalScreenViewModel.updateCurrentJournalDateInSettingsRepository();
    _eatsJournalScreenViewModel.refreshCurrentWeight();
    _eatsJournalScreenViewModel.refreshNutritionData();
  }

  @override
  void dispose() {
    widget._eatsJournalScreenViewModel.dispose();
    if (widget._eatsJournalScreenViewModel != _eatsJournalScreenViewModel) {
      _eatsJournalScreenViewModel.dispose();
    }
    super.dispose();
  }
}

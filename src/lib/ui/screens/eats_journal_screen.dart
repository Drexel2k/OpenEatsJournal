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
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:openeatsjournal/ui/widgets/gauge_distribution.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/round_transparent_choice_chip.dart";
import "package:provider/provider.dart";

class EatsJournalScreen extends StatefulWidget {
  const EatsJournalScreen({super.key});

  @override
  State<EatsJournalScreen> createState() => _EatsJournalScreenState();
}

class _EatsJournalScreenState extends State<EatsJournalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  OverlayDisplay? _overlayDisplayQuickEntryBreakfast;
  OverlayDisplay? _overlayDisplayQuickEntryLunch;
  OverlayDisplay? _overlayDisplayQuickEntryDinner;
  OverlayDisplay? _overlayDisplayQuickEntrySnacks;
  OverlayDisplay? _overlayDisplayWeightEntry1;
  OverlayDisplay? _overlayDisplayWeightEntry2;
  OverlayDisplay? _overlayDisplayFood;
  OverlayDisplay? _overlayDisplayQuickEntry;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fabMenuWidth = 150;

    double dimension = 200;
    double radius = 0.9;

    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

    return Consumer<EatsJournalScreenViewModel>(
      builder: (context, eatsJournalScreenViewModel, _) => MainLayout(
        route: OpenEatsJournalStrings.navigatorRouteEatsJournal,
        title: AppLocalizations.of(context)!.eats_journal,
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalScreenViewModel.currentJournalDate,
                    builder: (_, _, _) {
                      return OutlinedButton(
                        onPressed: () async {
                          DateTime? date = await _selectDate(initialDate: eatsJournalScreenViewModel.currentJournalDate.value, context: context);
                          if (date != null) {
                            _changeDate(eatsJournalScreenViewModel: eatsJournalScreenViewModel, date: date);
                          }
                        },
                        style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          ConvertValidate.dateFormatterDisplayLongDateOnly.format(eatsJournalScreenViewModel.currentJournalDate.value),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalScreenViewModel.currentMeal,
                    builder: (_, _, _) {
                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.getByValue(mealValue!));
                        },
                        dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                        initialSelection: eatsJournalScreenViewModel.currentMeal.value.value,
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
              listenable: eatsJournalScreenViewModel.eatsJournalDataChanged,
              builder: (_, _) {
                return FutureBuilder<FoodRepositoryGetDayMealSumsResult>(
                  future: eatsJournalScreenViewModel.dayNutritionDataPerMeal,
                  builder: (BuildContext context, AsyncSnapshot<FoodRepositoryGetDayMealSumsResult> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      throw StateError("Something went wrong: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      final ColorScheme colorScheme = Theme.of(context).colorScheme;
                      final Color dayButtonsTextColor = eatsJournalScreenViewModel.darkMode ? colorScheme.inversePrimary : colorScheme.primary;

                      GaugeData kJouleGaugeData = _getKJouleGaugeData(
                        eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                        foodRepositoryGetDayDataResult: snapshot.data!,
                        colorScheme: colorScheme,
                      );
                      GaugeData carbohydratesGaugeData = _getCarbohydratesGaugeData(
                        eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                        foodRepositoryGetDayDataResult: snapshot.data!,
                        colorScheme: colorScheme,
                      );
                      GaugeData proteinGaugeData = _getProteinGaugeData(
                        eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                        foodRepositoryGetDayDataResult: snapshot.data!,
                        colorScheme: colorScheme,
                      );
                      GaugeData fatGaugeData = _getFatGaugeData(
                        eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                        foodRepositoryGetDayDataResult: snapshot.data!,
                        colorScheme: colorScheme,
                      );

                      double breakfastKJoule = _getBreakfastKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double breakfastPercent = _getBreakfastKJoulePercent(
                        foodRepositoryGetDayDataResult: snapshot.data!,
                        dayKJoule: kJouleGaugeData.currentValue,
                      );

                      double breakfastStartPoint = 0;
                      double breakfastEndpoint = breakfastPercent;

                      double lunchKJoule = _getLunchKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double lunchPercent = _getLunchKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double lunchStartPoint = breakfastPercent;
                      double lunchEndpoint = breakfastPercent + lunchPercent;

                      double dinnerKJoule = _getDinnerKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double dinnerPercent = _getDinnerKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double dinnerStartPoint = breakfastPercent + lunchPercent;
                      double dinnerEndpoint = breakfastPercent + lunchPercent + dinnerPercent;

                      double snacksKJoule = _getSnacksKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double snacksPercent = _getSnacksKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double snacksStartPoint = breakfastPercent + lunchPercent + dinnerPercent;
                      double snacksEndpoint = breakfastPercent + lunchPercent + dinnerPercent + snacksPercent;

                      return Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: 55),
                                ListenableBuilder(
                                  listenable: eatsJournalScreenViewModel.settingsChanged,
                                  builder: (_, _) {
                                    return Column(
                                      children: [
                                        Text(
                                          ConvertValidate.getLocalizedEnergyUnit(context: context),
                                          style: textTheme.titleLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.restaurant, size: 15, color: colorScheme.primary),
                                            Text(
                                              " ${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: (kJouleGaugeData.maxValue - kJouleGaugeData.currentValue).toDouble()))}",
                                              style: textTheme.titleMedium,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: kJouleGaugeData.currentValue.toDouble()))}/${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: kJouleGaugeData.maxValue.toDouble()))}",
                                          style: textTheme.titleSmall,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(height: 5),
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
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 155),
                              Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.fat, gaugeData: fatGaugeData),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.carbs, gaugeData: carbohydratesGaugeData),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.protein, gaugeData: proteinGaugeData),
                                    ),
                                  ),
                                ],
                              ),

                              FutureBuilder<Map<int, bool>>(
                                future: eatsJournalScreenViewModel.eatsJournalEntriesAvailableForLast8Days,
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
                                            ? TextStyle(color: dayButtonsTextColor, fontWeight: FontWeight.w900)
                                            : null;

                                        return RoundTransparentChoiceChip(
                                          selected: eatsJournalScreenViewModel.currentJournalDate.value == chipDate,
                                          onSelected: (bool selected) {
                                            _changeDate(eatsJournalScreenViewModel: eatsJournalScreenViewModel, date: chipDate);
                                          },
                                          label: Text(DateFormat("EEEE").format(chipDate).substring(0, 1), style: style),
                                        );
                                      }).toList(),
                                    );
                                  } else {
                                    return Text(AppLocalizations.of(context)!.no_data);
                                  }
                                },
                              ),
                              SizedBox(height: 4),
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
                                              Text(
                                                "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: breakfastPercent)}% / ${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: breakfastKJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                                              ),
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
                                                  Text(
                                                    "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: lunchPercent)}% / ${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: lunchKJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
                                                  Text(
                                                    "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: dinnerPercent)}% / ${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: dinnerKJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
                                                  Text(
                                                    "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: snacksPercent)}% / ${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: snacksKJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
                                                    listenable: eatsJournalScreenViewModel.currentWeightChanged,
                                                    builder: (_, _) {
                                                      return FutureBuilder<WeightJournalEntry?>(
                                                        future: eatsJournalScreenViewModel.currentWeight,
                                                        builder: (BuildContext context, AsyncSnapshot<WeightJournalEntry?> snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                                                          } else if (snapshot.hasError) {
                                                            throw StateError("Something went wrong: ${snapshot.error}");
                                                          } else if (snapshot.hasData) {
                                                            return ListenableBuilder(
                                                              listenable: eatsJournalScreenViewModel.settingsChanged,
                                                              builder: (_, _) {
                                                                return Text(
                                                                  snapshot.data != null
                                                                      ? "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: snapshot.data!.weight))}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)}"
                                                                      : AppLocalizations.of(context)!.na,
                                                                );
                                                              },
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
                                                            child: ChangeNotifierProvider(
                                                              create: (context) => EatsJournalEditScreenViewModel(
                                                                journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                                settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                                meal: Meal.breakfast,
                                                              ),
                                                              child: EatsJournalEditScreen(),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      eatsJournalScreenViewModel.refreshNutritionData();
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
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.breakfast);
                                                },
                                                icon: Icon(Icons.check),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.breakfast);
                                                  EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                                    context: (context),
                                                    initialEntryDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                                    initialMeal: eatsJournalScreenViewModel.currentMeal.value,
                                                  );
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();

                                                  if (eatsJournalEntryEdited != null) {
                                                    _overlayDisplayQuickEntryBreakfast = OverlayDisplay(
                                                      context: AppGlobal.navigatorKey.currentContext!,
                                                      displayText: eatsJournalEntryEdited.originalId == null
                                                          ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                                          : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                                      animationController: _animationController,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.speed),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.breakfast);
                                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();
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
                                                            child: ChangeNotifierProvider(
                                                              create: (context) => EatsJournalEditScreenViewModel(
                                                                journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                                settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                                meal: Meal.lunch,
                                                              ),
                                                              child: EatsJournalEditScreen(),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      eatsJournalScreenViewModel.refreshNutritionData();
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
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.lunch);
                                                },
                                                icon: Icon(Icons.check),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.lunch);
                                                  EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                                    context: (context),
                                                    initialEntryDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                                    initialMeal: eatsJournalScreenViewModel.currentMeal.value,
                                                  );
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();

                                                  if (eatsJournalEntryEdited != null) {
                                                    _overlayDisplayQuickEntryLunch = OverlayDisplay(
                                                      context: AppGlobal.navigatorKey.currentContext!,
                                                      displayText: eatsJournalEntryEdited.originalId == null
                                                          ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                                          : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                                      animationController: _animationController,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.speed),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.lunch);
                                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();
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
                                                            child: ChangeNotifierProvider(
                                                              create: (context) => EatsJournalEditScreenViewModel(
                                                                journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                                settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                                meal: Meal.dinner,
                                                              ),
                                                              child: EatsJournalEditScreen(),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      eatsJournalScreenViewModel.refreshNutritionData();
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
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.dinner);
                                                },
                                                icon: Icon(Icons.check),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.dinner);
                                                  EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                                    context: (context),
                                                    initialEntryDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                                    initialMeal: eatsJournalScreenViewModel.currentMeal.value,
                                                  );
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();

                                                  if (eatsJournalEntryEdited != null) {
                                                    _overlayDisplayQuickEntryDinner = OverlayDisplay(
                                                      context: AppGlobal.navigatorKey.currentContext!,
                                                      displayText: eatsJournalEntryEdited.originalId == null
                                                          ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                                          : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                                      animationController: _animationController,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.speed),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.dinner);
                                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();
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
                                                            child: ChangeNotifierProvider(
                                                              create: (context) => EatsJournalEditScreenViewModel(
                                                                journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                                settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                                meal: Meal.snacks,
                                                              ),
                                                              child: EatsJournalEditScreen(),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      eatsJournalScreenViewModel.refreshNutritionData();
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
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.snacks);
                                                },
                                                icon: Icon(Icons.check),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.snacks);
                                                  EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                                    context: (context),
                                                    initialEntryDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                                    initialMeal: eatsJournalScreenViewModel.currentMeal.value,
                                                  );
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();

                                                  if (eatsJournalEntryEdited != null) {
                                                    _overlayDisplayQuickEntrySnacks = OverlayDisplay(
                                                      context: AppGlobal.navigatorKey.currentContext!,
                                                      displayText: eatsJournalEntryEdited.originalId == null
                                                          ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                                          : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                                      animationController: _animationController,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.speed),
                                              ),
                                              IconButton.outlined(
                                                onPressed: () async {
                                                  _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: Meal.snacks);
                                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                                                  eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                                                  eatsJournalScreenViewModel.refreshNutritionData();
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
                                                            child: ChangeNotifierProvider(
                                                              create: (context) => WeightJournalEditScreenViewModel(
                                                                journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                              ),
                                                              child: WeightJournalEditScreen(),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      eatsJournalScreenViewModel.refreshCurrentWeight();
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
                                                  if (await _showAddWeightDialog(
                                                    context: AppGlobal.navigatorKey.currentContext!,
                                                    eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                                                    initialDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                                    initialWeight: await eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                                                  )) {
                                                    eatsJournalScreenViewModel.refreshCurrentWeight();
                                                    _overlayDisplayWeightEntry1 = OverlayDisplay(
                                                      context: AppGlobal.navigatorKey.currentContext!,
                                                      displayText: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.weight_journal_entry_added,
                                                      animationController: _animationController,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      //empty space to ensure that floating action button is not blocking controls, so controls can be scrolled higher than
                                      //the FAB's position
                                      SizedBox(height: 70),
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
                                                child: ChangeNotifierProvider(
                                                  create: (context) => EatsJournalEditScreenViewModel(
                                                    journalRepository: Provider.of<Repositories>(context, listen: false).journalRepository,
                                                    settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                  ),
                                                  child: EatsJournalEditScreen(),
                                                ),
                                              );
                                            },
                                          );

                                          eatsJournalScreenViewModel.refreshNutritionData();
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
                                          double weight = await eatsJournalScreenViewModel.getLastWeightJournalEntry();
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
                                                child: ChangeNotifierProvider(
                                                  create: (context) => SettingsScreenViewModel(
                                                    settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                                    weight: weight,
                                                  ),
                                                  child: SettingsScreen(),
                                                ),
                                              );
                                            },
                                          );

                                          eatsJournalScreenViewModel.refreshWeightTarget();
                                          eatsJournalScreenViewModel.notifySettingsChanged();
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
                valueListenable: eatsJournalScreenViewModel.floatingActionMenuElapsed,
                builder: (_, _, _) {
                  if (eatsJournalScreenViewModel.floatingActionMenuElapsed.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: fabMenuWidth,
                          child: FloatingActionButton.extended(
                            heroTag: "5",
                            onPressed: () async {
                              eatsJournalScreenViewModel.toggleFloatingActionButtons();

                              await Navigator.pushNamedAndRemoveUntil(context, OpenEatsJournalStrings.navigatorRouteFood, (Route<dynamic> route) => false);
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
                              eatsJournalScreenViewModel.toggleFloatingActionButtons();

                              if (await _showAddWeightDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                                initialDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                initialWeight: await eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                              )) {
                                eatsJournalScreenViewModel.refreshCurrentWeight();
                                _overlayDisplayWeightEntry2 = OverlayDisplay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.weight_journal_entry_added,
                                  animationController: _animationController,
                                );
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
                            onPressed: () async {
                              eatsJournalScreenViewModel.toggleFloatingActionButtons();

                              EntityEdited? foodEdited =
                                  await Navigator.pushNamed(
                                        context,
                                        OpenEatsJournalStrings.navigatorRouteFoodEdit,
                                        arguments: Food(
                                          name: OpenEatsJournalStrings.emptyString,
                                          foodSource: FoodSource.user,
                                          fromDb: true,
                                          kJoule: NutritionCalculator.kJouleForOnekCal,
                                          nutritionPerGramAmount: 100,
                                        ),
                                      )
                                      as EntityEdited?;

                              if (foodEdited != null) {
                                _overlayDisplayFood = OverlayDisplay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: foodEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_created
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_updated,
                                  animationController: _animationController,
                                );
                              }
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
                              eatsJournalScreenViewModel.toggleFloatingActionButtons();
                              EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                context: (context),
                                initialEntryDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                initialMeal: eatsJournalScreenViewModel.currentMeal.value,
                              );
                              eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                              eatsJournalScreenViewModel.refreshNutritionData();

                              if (eatsJournalEntryEdited != null) {
                                _overlayDisplayQuickEntry = OverlayDisplay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: eatsJournalEntryEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                  animationController: _animationController,
                                );
                              }
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
                  eatsJournalScreenViewModel.toggleFloatingActionButtons();
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));
  }

  GaugeData _getKJouleGaugeData({
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult,
    required ColorScheme colorScheme,
  }) {
    double dayTargetKJoule = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.kJoule.toDouble()
        : eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule();
    double daySumKJoule = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.kJoule)
              .reduce((kJouleEntry1, kJouleEntry2) => kJouleEntry1 + kJouleEntry2)
        : 0;

    return GaugeData(currentValue: daySumKJoule, maxValue: dayTargetKJoule, colorScheme: colorScheme);
  }

  GaugeData _getCarbohydratesGaugeData({
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult,
    required ColorScheme colorScheme,
  }) {
    double dayTargetCarbohydrates = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.carbohydrates!
        : NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
    double daySumCarbohydrates = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.carbohydrates != null ? mealNutritionsEntry.value.carbohydrates! : 0.0)
              .reduce((carbohydratesEntry1, carbohydratesEntry2) => carbohydratesEntry1 + carbohydratesEntry2)
        : 0;

    return GaugeData(currentValue: daySumCarbohydrates, maxValue: dayTargetCarbohydrates, colorScheme: colorScheme);
  }

  GaugeData _getProteinGaugeData({
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult,
    required ColorScheme colorScheme,
  }) {
    double dayTargetProtein = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.protein!
        : NutritionCalculator.calculateProteinDemandByKJoule(kJoule: eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
    double daySumProtein = foodRepositoryGetDayDataResult.mealNutritionSums != null
        ? foodRepositoryGetDayDataResult.mealNutritionSums!.entries
              .map((mealNutritionsEntry) => mealNutritionsEntry.value.protein != null ? mealNutritionsEntry.value.protein! : 0.0)
              .reduce((proteinEntry1, proteinEntry2) => proteinEntry1 + proteinEntry2)
        : 0;

    return GaugeData(currentValue: daySumProtein, maxValue: dayTargetProtein, colorScheme: colorScheme);
  }

  GaugeData _getFatGaugeData({
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult,
    required ColorScheme colorScheme,
  }) {
    double dayTargetFat = foodRepositoryGetDayDataResult.dayNutritionTargets != null
        ? foodRepositoryGetDayDataResult.dayNutritionTargets!.fat!
        : NutritionCalculator.calculateFatDemandByKJoule(kJoule: eatsJournalScreenViewModel.getCurrentJournalDayTargetKJoule());
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

  double _getBreakfastKJoule({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult}) {
    double kJoule = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.breakfast)) {
      return foodRepositoryGetDayDataResult.mealNutritionSums![Meal.breakfast]!.kJoule;
    }

    return kJoule;
  }

  double _getLunchKJoule({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult}) {
    double kJoule = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.lunch)) {
      kJoule = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.lunch]!.kJoule;
    }

    return kJoule;
  }

  double _getDinnerKJoule({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult}) {
    double kJoule = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.dinner)) {
      kJoule = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.dinner]!.kJoule;
    }

    return kJoule;
  }

  double _getSnacksKJoule({required FoodRepositoryGetDayMealSumsResult foodRepositoryGetDayDataResult}) {
    double kJoule = 0;
    if (foodRepositoryGetDayDataResult.mealNutritionSums != null && foodRepositoryGetDayDataResult.mealNutritionSums!.containsKey(Meal.snacks)) {
      kJoule = foodRepositoryGetDayDataResult.mealNutritionSums![Meal.snacks]!.kJoule;
    }

    return kJoule;
  }

  void _changeMeal({required EatsJournalScreenViewModel eatsJournalScreenViewModel, required Meal meal}) {
    eatsJournalScreenViewModel.currentMeal.value = meal;
    eatsJournalScreenViewModel.updateCurrentMealInSettingsRepository();
  }

  void _changeDate({required EatsJournalScreenViewModel eatsJournalScreenViewModel, required DateTime date}) {
    eatsJournalScreenViewModel.currentJournalDate.value = date;
    eatsJournalScreenViewModel.updateCurrentJournalDateInSettingsRepository();
    eatsJournalScreenViewModel.refreshCurrentWeight();
    eatsJournalScreenViewModel.refreshNutritionData();
  }

  Future<bool> _showAddWeightDialog({
    required BuildContext context,
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required DateTime initialDate,
    required double initialWeight,
  }) async {
    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

    WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel = WeightJournalEntryAddScreenViewModel(initialWeight: initialWeight);

    if ((await showDialog<bool>(
      useSafeArea: true,
      barrierDismissible: false,
      context: AppGlobal.navigatorKey.currentContext!,
      builder: (BuildContext contextBuilder) {
        return Dialog(
          insetPadding: EdgeInsets.fromLTRB(dialogHorizontalPadding, dialogVerticalPadding, dialogHorizontalPadding, dialogVerticalPadding),
          child: ChangeNotifierProvider.value(
            value: weightJournalEntryAddScreenViewModel,
            child: WeightJournalEntryAddScreen(date: initialDate),
          ),
        );
      },
    ))!) {
      await eatsJournalScreenViewModel.setWeightJournalEntry(
        date: eatsJournalScreenViewModel.currentJournalDate.value,
        weight: weightJournalEntryAddScreenViewModel.lastValidWeight,
      );
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    if (_overlayDisplayQuickEntryBreakfast != null) {
      _overlayDisplayQuickEntryBreakfast!.stop();
    }

    if (_overlayDisplayQuickEntryLunch != null) {
      _overlayDisplayQuickEntryLunch!.stop();
    }

    if (_overlayDisplayQuickEntryDinner != null) {
      _overlayDisplayQuickEntryDinner!.stop();
    }

    if (_overlayDisplayQuickEntrySnacks != null) {
      _overlayDisplayQuickEntrySnacks!.stop();
    }

    if (_overlayDisplayWeightEntry1 != null) {
      _overlayDisplayWeightEntry1!.stop();
    }

    if (_overlayDisplayWeightEntry2 != null) {
      _overlayDisplayWeightEntry2!.stop();
    }

    if (_overlayDisplayFood != null) {
      _overlayDisplayFood!.stop();
    }

    if (_overlayDisplayQuickEntry != null) {
      _overlayDisplayQuickEntry!.stop();
    }

    _animationController.dispose();

    super.dispose();
  }
}

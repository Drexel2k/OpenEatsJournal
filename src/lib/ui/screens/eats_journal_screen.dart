import "package:flutter/material.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/day_energy_target_editor_screen.dart";
import "package:openeatsjournal/ui/screens/day_energy_target_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/overlay_info.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_main_button.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_meal_button.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/round_transparent_choice_chip.dart";
import "package:provider/provider.dart";

class EatsJournalScreen extends StatefulWidget {
  const EatsJournalScreen({super.key});

  @override
  State<EatsJournalScreen> createState() => _EatsJournalScreenState();
}

class _EatsJournalScreenState extends State<EatsJournalScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(context, listen: false);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final double overlaySpacer = 170;

    final double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    final double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

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
                          convert.dateFormatterDisplayLongDateOnly.format(eatsJournalScreenViewModel.currentJournalDate.value),
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

                      double breakfastStartValue = 0;
                      double breakfastEndValue = breakfastPercent;

                      double lunchKJoule = _getLunchKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double lunchPercent = _getLunchKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double lunchStartValue = breakfastPercent;
                      double lunchEndValue = breakfastPercent + lunchPercent;

                      double dinnerKJoule = _getDinnerKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double dinnerPercent = _getDinnerKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double dinnerStartValue = breakfastPercent + lunchPercent;
                      double dinnerEndValue = breakfastPercent + lunchPercent + dinnerPercent;

                      double snacksKJoule = _getSnacksKJoule(foodRepositoryGetDayDataResult: snapshot.data!);
                      double snacksPercent = _getSnacksKJoulePercent(foodRepositoryGetDayDataResult: snapshot.data!, dayKJoule: kJouleGaugeData.currentValue);
                      double snacksStartValue = breakfastPercent + lunchPercent + dinnerPercent;
                      double snacksEndValue = breakfastPercent + lunchPercent + dinnerPercent + snacksPercent;

                      SettingsRepository settingsRepository = Provider.of<SettingsRepository>(context, listen: false);
                      JournalRepository journalRepository = Provider.of<JournalRepository>(context, listen: false);

                      //We now use gauge_indicator for display of gauges, instead of graphic, which we use now only for the statistics display. Graphic has
                      //the issue, that it reserves space for a whole circle when building a gauge with it, so spacing between widges became too large.
                      //We used stacks as a workaround, but that made other problems, e.g. if font size of android phone was change, texts become larger,
                      //but the gauges don't move, becaus they were in their own layer of the stack. And the code structure was not intuitive.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 10),
                          Stack(
                            children: [
                              EatsJournalMainButton(
                                kJouleGaugeData: kJouleGaugeData,
                                fatGaugeData: fatGaugeData,
                                carbohydratesGaugeData: carbohydratesGaugeData,
                                proteinGaugeData: proteinGaugeData,
                                eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                                journalRepository: journalRepository,
                                settingsRepository: settingsRepository,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: PopupMenuButton<String>(
                                  onSelected: (selected) {},
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      onTap: () async {
                                        DayEnergyTargetEditorScreenViewModel dayEnergyTargetEditorScreenViewModel = DayEnergyTargetEditorScreenViewModel(
                                          initialEnergyTargetKJoule: kJouleGaugeData.maxValue.toDouble(),
                                          convert: convert,
                                        );

                                        if ((await showDialog<bool>(
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
                                                create: (context) => dayEnergyTargetEditorScreenViewModel,
                                                child: DayEnergyTargetEditorScreen(date: eatsJournalScreenViewModel.currentJournalDate.value),
                                              ),
                                            );
                                          },
                                        ))!) {
                                          await eatsJournalScreenViewModel.setDayEnergyTarget(
                                            day: eatsJournalScreenViewModel.currentJournalDate.value,
                                            energyTargetKJoule: dayEnergyTargetEditorScreenViewModel.lastValidEnergyTargetKJoule,
                                          );
                                          //does reload stored day targets
                                          eatsJournalScreenViewModel.refreshNutritionData();
                                        }
                                      },
                                      child: ListTile(
                                        leading: Icon(Icons.vertical_align_top),
                                        title: Text(AppLocalizations.of(context)!.edit_day_energy_target(convert.getLocalizedEnergyUnit(context: context))),
                                      ),
                                    ),
                                    PopupMenuDivider(indent: 10, endIndent: 10),
                                    PopupMenuItem(
                                      onTap: () async {
                                        double weightKg = await eatsJournalScreenViewModel.getLastWeightJournalEntry();

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
                                                  settingsRepository: settingsRepository,
                                                  convert: convert,
                                                  currentWeightKg: weightKg,
                                                ),
                                                child: SettingsScreen(),
                                              ),
                                            );
                                          },
                                        );

                                        eatsJournalScreenViewModel.refreshEnergyTarget();
                                        eatsJournalScreenViewModel.notifySettingsChanged();
                                      },
                                      child: ListTile(leading: Icon(Icons.settings), title: Text(AppLocalizations.of(context)!.settings)),
                                    ),
                                  ],

                                  child: SizedBox(height: 30, width: 40, child: Icon(Icons.more_vert)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          FutureBuilder<Map<int, bool>>(
                            future: eatsJournalScreenViewModel.eatsJournalEntriesAvailableForLast8Days,
                            builder: (BuildContext context, AsyncSnapshot<Map<int, bool>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                              } else if (snapshot.hasError) {
                                throw StateError("Something went wrong: ${snapshot.error}");
                              } else if (snapshot.hasData) {
                                DateTime currentDate = eatsJournalScreenViewModel.today.subtract(Duration(days: 8));
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [-7, -6, -5, -4, -3, -2, -1, 0].map((int dayIndex) {
                                    currentDate = currentDate.add(Duration(days: 1));
                                    DateTime chipDate = currentDate;
                                    TextStyle? style = snapshot.data![dayIndex]! ? TextStyle(color: dayButtonsTextColor, fontWeight: FontWeight.w900) : null;

                                    return RoundTransparentChoiceChip(
                                      selected: eatsJournalScreenViewModel.currentJournalDate.value == chipDate,
                                      onSelected: (bool selected) {
                                        _changeDate(eatsJournalScreenViewModel: eatsJournalScreenViewModel, date: chipDate);
                                      },
                                      label: Text(
                                        _getDay1CharAbbreviation(context: context, date: chipDate),
                                        style: style,
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return Text(AppLocalizations.of(context)!.no_data);
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          EatsJournalMealButton(
                            meal: Meal.breakfast,
                            mealStartValue: breakfastStartValue,
                            mealEndValue: breakfastEndValue,
                            mealKJoule: breakfastKJoule,
                            mealPercent: breakfastPercent,
                            eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                            journalRepository: journalRepository,
                            settingsRepository: settingsRepository,
                            changeMealCallback: ({required Meal meal}) {
                              _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: meal);
                            },
                            pushQuickEntryScreenCallback: () async {
                              await _pushQuickEntryScreen(context: context, eatsJournalScreenViewModel: eatsJournalScreenViewModel);
                            },
                          ),
                          SizedBox(height: 3),
                          EatsJournalMealButton(
                            meal: Meal.lunch,
                            mealStartValue: lunchStartValue,
                            mealEndValue: lunchEndValue,
                            mealKJoule: lunchKJoule,
                            mealPercent: lunchPercent,
                            eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                            journalRepository: journalRepository,
                            settingsRepository: settingsRepository,
                            changeMealCallback: ({required Meal meal}) {
                              _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: meal);
                            },
                            pushQuickEntryScreenCallback: () async {
                              await _pushQuickEntryScreen(context: context, eatsJournalScreenViewModel: eatsJournalScreenViewModel);
                            },
                          ),
                          SizedBox(height: 3),
                          EatsJournalMealButton(
                            meal: Meal.dinner,
                            mealStartValue: dinnerStartValue,
                            mealEndValue: dinnerEndValue,
                            mealKJoule: dinnerKJoule,
                            mealPercent: dinnerPercent,
                            eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                            journalRepository: journalRepository,
                            settingsRepository: settingsRepository,
                            changeMealCallback: ({required Meal meal}) {
                              _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: meal);
                            },
                            pushQuickEntryScreenCallback: () async {
                              await _pushQuickEntryScreen(context: context, eatsJournalScreenViewModel: eatsJournalScreenViewModel);
                            },
                          ),
                          SizedBox(height: 3),
                          EatsJournalMealButton(
                            meal: Meal.snacks,
                            mealStartValue: snacksStartValue,
                            mealEndValue: snacksEndValue,
                            mealKJoule: snacksKJoule,
                            mealPercent: snacksPercent,
                            eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                            journalRepository: journalRepository,
                            settingsRepository: settingsRepository,
                            changeMealCallback: ({required Meal meal}) {
                              _changeMeal(eatsJournalScreenViewModel: eatsJournalScreenViewModel, meal: meal);
                            },
                            pushQuickEntryScreenCallback: () async {
                              await _pushQuickEntryScreen(context: context, eatsJournalScreenViewModel: eatsJournalScreenViewModel);
                            },
                          ),
                          SizedBox(height: 3),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
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
                                        create: (context) => WeightJournalEditScreenViewModel(journalRepository: journalRepository),
                                        child: WeightJournalEditScreen(),
                                      ),
                                    );
                                  },
                                );

                                eatsJournalScreenViewModel.refreshCurrentWeight();
                              },
                              child: Row(
                                children: [
                                  SizedBox(width: 17),
                                  SizedBox(
                                    width: 60,
                                    height: 54,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.scale, size: 45, color: colorScheme.primary),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
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
                                                              ? "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightKg(weightKg: snapshot.data!.weight))}${convert.getLocalizedWeightUnitKgAbbreviated(context: context)}"
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

                                  IconButton.outlined(
                                    onPressed: () async {
                                      if (await _showAddWeightDialog(
                                        context: AppGlobal.navigatorKey.currentContext!,
                                        eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                                        initialDate: eatsJournalScreenViewModel.currentJournalDate.value,
                                        initialWeight: await eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                                        convert: convert,
                                      )) {
                                        eatsJournalScreenViewModel.refreshCurrentWeight();
                                        overlayDisplay.enqueue(
                                          overlayInfo: OverlayInfo(
                                            message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.weight_journal_entry_added,
                                            spacer: overlaySpacer,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //empty space to ensure that floating action button is not blocking controls, so controls can be scrolled higher than
                          //the FAB's position
                          SizedBox(height: 70),
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
        floatingActionButton: Column(
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
                      FloatingActionButton.extended(
                        heroTag: "5",
                        onPressed: () async {
                          eatsJournalScreenViewModel.toggleFloatingActionButtons();

                          await Navigator.pushNamedAndRemoveUntil(context, OpenEatsJournalStrings.navigatorRouteFood, (Route<dynamic> route) => false);
                        },
                        label: Text(AppLocalizations.of(context)!.eats_journal_entry),
                        icon: Icon(Icons.menu_book),
                      ),

                      SizedBox(height: 5),
                      FloatingActionButton.extended(
                        heroTag: "4",
                        onPressed: () async {
                          eatsJournalScreenViewModel.toggleFloatingActionButtons();

                          if (await _showAddWeightDialog(
                            context: AppGlobal.navigatorKey.currentContext!,
                            eatsJournalScreenViewModel: eatsJournalScreenViewModel,
                            initialDate: eatsJournalScreenViewModel.currentJournalDate.value,
                            initialWeight: await eatsJournalScreenViewModel.getLastWeightJournalEntry(),
                            convert: convert,
                          )) {
                            eatsJournalScreenViewModel.refreshCurrentWeight();
                            overlayDisplay.enqueue(
                              overlayInfo: OverlayInfo(
                                message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.weight_journal_entry_added,
                                spacer: overlaySpacer,
                              ),
                            );
                          }
                        },
                        label: Text(AppLocalizations.of(context)!.weight_journal_entry),
                        icon: Icon(Icons.scale),
                      ),

                      SizedBox(height: 5),
                      FloatingActionButton.extended(
                        heroTag: "3",
                        onPressed: () async {
                          eatsJournalScreenViewModel.toggleFloatingActionButtons();

                          await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: eatsJournalScreenViewModel.getNewFood());
                        },
                        label: Text(AppLocalizations.of(context)!.food),
                        icon: Icon(Icons.lunch_dining),
                      ),

                      SizedBox(height: 5),
                      FloatingActionButton.extended(
                        heroTag: "2",
                        onPressed: () async {
                          eatsJournalScreenViewModel.toggleFloatingActionButtons();
                          await _pushQuickEntryScreen(context: context, eatsJournalScreenViewModel: eatsJournalScreenViewModel);
                          eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                          eatsJournalScreenViewModel.refreshNutritionData();
                        },
                        label: Text(AppLocalizations.of(context)!.quick_entry),
                        icon: Icon(Icons.speed),
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
    );
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime.utc(1900), lastDate: DateTime.utc(9999));
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
    required ConvertValidate convert,
  }) async {
    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

    WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel = WeightJournalEntryAddScreenViewModel(
      initialWeight: initialWeight,
      convert: convert,
    );

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
        weight: weightJournalEntryAddScreenViewModel.lastValidWeightKg,
      );
      return true;
    }

    return false;
  }

  void _changeMeal({required EatsJournalScreenViewModel eatsJournalScreenViewModel, required Meal meal}) {
    eatsJournalScreenViewModel.currentMeal.value = meal;
    eatsJournalScreenViewModel.updateCurrentMealInSettingsRepository();
  }

  Future<void> _pushQuickEntryScreen({required BuildContext context, required EatsJournalScreenViewModel eatsJournalScreenViewModel}) async {
    await Navigator.pushNamed(
      context,
      OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
      arguments: eatsJournalScreenViewModel.getNewQuickEntry(
        entryDate: eatsJournalScreenViewModel.currentJournalDate.value,
        meal: eatsJournalScreenViewModel.currentMeal.value,
      ),
    );
  }

  String _getDay1CharAbbreviation({required BuildContext context, required DateTime date}) {
    if (date.weekday == 1) {
      return AppLocalizations.of(context)!.monday_abbreviated_1char;
    }

    if (date.weekday == 2) {
      return AppLocalizations.of(context)!.tuesday_abbreviated_1char;
    }

    if (date.weekday == 3) {
      return AppLocalizations.of(context)!.wednesday_abbreviated_1char;
    }

    if (date.weekday == 4) {
      return AppLocalizations.of(context)!.thursday_abbreviated_1char;
    }

    if (date.weekday == 5) {
      return AppLocalizations.of(context)!.friday_abbreviated_1char;
    }

    if (date.weekday == 6) {
      return AppLocalizations.of(context)!.saturday_abbreviated_1char;
    }

    return AppLocalizations.of(context)!.sunday_abbreviated_1char;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

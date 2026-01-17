import "package:flutter/material.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_tab.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required FoodSearchScreenViewModel foodSearchScreenViewModel}) : _foodSearchScreenViewModel = foodSearchScreenViewModel;

  final FoodSearchScreenViewModel _foodSearchScreenViewModel;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  late FoodSearchScreenViewModel _foodSearchScreenViewModel;

  final TextEditingController _searchTextController = TextEditingController();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _foodSearchScreenViewModel = widget._foodSearchScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double fabMenuWidth = 150;

    Map<String, String> standardFoodUnitLocalizations = {
      OpenEatsJournalStrings.piece: AppLocalizations.of(context)!.piece,
      OpenEatsJournalStrings.serving: AppLocalizations.of(context)!.serving,
    };

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFood,
      title: AppLocalizations.of(context)!.food_management,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _foodSearchScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        await _selectDate(initialDate: _foodSearchScreenViewModel.currentJournalDate.value, context: context);
                      },
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_foodSearchScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _foodSearchScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _foodSearchScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: _foodSearchScreenViewModel.currentMeal.value.value,
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(child: Text(AppLocalizations.of(context)!.online)),
                      Tab(child: Text(AppLocalizations.of(context)!.offline)),
                      Tab(child: Text(AppLocalizations.of(context)!.recent)),
                    ],

                    onTap: (int tabIndex) {
                      _foodSearchScreenViewModel.finishSearchAndClearSearchResult();

                      if (tabIndex == 2) {
                        _foodSearchScreenViewModel.getFoodBySearchText(
                          searchText: OpenEatsJournalStrings.emptyString,
                          localizations: standardFoodUnitLocalizations,
                          searchMode: SearchMode.recent,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        FoodSearchScreenTab(
                          foodSearchScreenViewModel: _foodSearchScreenViewModel,
                          searchMode: SearchMode.online,
                          standardFoodUnitLocalizations: standardFoodUnitLocalizations,
                        ),
                        FoodSearchScreenTab(
                          foodSearchScreenViewModel: _foodSearchScreenViewModel,
                          searchMode: SearchMode.offline,
                          standardFoodUnitLocalizations: standardFoodUnitLocalizations,
                        ),
                        FoodSearchScreenTab(
                          foodSearchScreenViewModel: _foodSearchScreenViewModel,
                          searchMode: SearchMode.recent,
                          standardFoodUnitLocalizations: standardFoodUnitLocalizations,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
              valueListenable: _foodSearchScreenViewModel.floatingActionMenuElapsed,
              builder: (_, _, _) {
                if (_foodSearchScreenViewModel.floatingActionMenuElapsed.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "4",
                          onPressed: () async {
                            _foodSearchScreenViewModel.toggleFloatingActionButtons();
                            await UiHelpers.showAddWeightDialog(
                              context: AppGlobal.navigatorKey.currentContext!,
                              initialDate: _foodSearchScreenViewModel.currentJournalDate.value,
                              initialWeight: await _foodSearchScreenViewModel.getLastWeightJournalEntry(),
                              saveCallback: _addWeightJournalEntry,
                            );
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
                            _foodSearchScreenViewModel.toggleFloatingActionButtons();

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
                            _foodSearchScreenViewModel.toggleFloatingActionButtons();
                            await UiHelpers.pushQuickEntryRoute(
                              context: context,
                              initialEntryDate: _foodSearchScreenViewModel.currentJournalDate.value,
                              initialMeal: _foodSearchScreenViewModel.currentMeal.value,
                            );
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
                _foodSearchScreenViewModel.toggleFloatingActionButtons();
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addWeightJournalEntry(double weight) async {
    await _foodSearchScreenViewModel.setWeightJournalEntry(date: _foodSearchScreenViewModel.currentJournalDate.value, weight: weight);
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      _foodSearchScreenViewModel.currentJournalDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._foodSearchScreenViewModel.dispose();
    if (widget._foodSearchScreenViewModel != _foodSearchScreenViewModel) {
      _foodSearchScreenViewModel.dispose();
    }

    _searchTextController.dispose();

    super.dispose();
  }
}

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/layout_mode.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/food_card.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final TextEditingController _searchTextController = TextEditingController();
  late SearchMode _searchMode;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _searchMode = SearchMode.online;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double fabMenuWidth = 150;

    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.1;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.06;

    Map<String, String> standardFoodUnitLocalizations = {
      OpenEatsJournalStrings.piece: AppLocalizations.of(context)!.piece,
      OpenEatsJournalStrings.serving: AppLocalizations.of(context)!.serving,
    };

    return Consumer<FoodSearchScreenViewModel>(
      builder: (context, foodSearchScreenViewModel, _) => MainLayout(
        route: OpenEatsJournalStrings.navigatorRouteFood,
        layoutMode: LayoutMode.noScroll,
        title: AppLocalizations.of(context)!.food_management,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: foodSearchScreenViewModel.currentJournalDate,
                    builder: (_, _, _) {
                      return OutlinedButton(
                        onPressed: () async {
                          await _selectDate(
                            foodSearchScreenViewModel: foodSearchScreenViewModel,
                            initialDate: foodSearchScreenViewModel.currentJournalDate.value,
                            context: context,
                          );
                        },
                        style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          ConvertValidate.dateFormatterDisplayLongDateOnly.format(foodSearchScreenViewModel.currentJournalDate.value),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: foodSearchScreenViewModel.currentMeal,
                    builder: (_, _, _) {
                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          foodSearchScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                        },
                        dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                        initialSelection: foodSearchScreenViewModel.currentMeal.value.value,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OpenEatsJournalTextField(
                    controller: _searchTextController,
                    hintText: AppLocalizations.of(context)!.search_food,
                    decorationSuffixIcon: IconButton(
                      onPressed: () {
                        _searchTextController.clear();
                      },
                      icon: Icon(Icons.clear),
                      padding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) async {
                      await _search(foodSearchScreenViewModel: foodSearchScreenViewModel, standardFoodUnitLocalizations: standardFoodUnitLocalizations);
                    },
                  ),
                ),
                SizedBox(width: 5),
                RoundOutlinedButton(
                  onPressed: () async {
                    await _search(foodSearchScreenViewModel: foodSearchScreenViewModel, standardFoodUnitLocalizations: standardFoodUnitLocalizations);
                  },
                  child: Icon(Icons.search),
                ),
                SizedBox(width: 5),
                RoundOutlinedButton(
                  onPressed: () async {
                    Object? barcodeScanResult = await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteBarcodeScanner);
                    if (barcodeScanResult != null) {
                      String barcode = barcodeScanResult as String;
                      _searchTextController.text = "${OpenEatsJournalStrings.code}${OpenEatsJournalStrings.doublepoint}$barcode";
                      await _search(foodSearchScreenViewModel: foodSearchScreenViewModel, standardFoodUnitLocalizations: standardFoodUnitLocalizations);
                    }
                  },
                  child: Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(child: Text(AppLocalizations.of(context)!.online)),
                      Tab(child: Text(AppLocalizations.of(context)!.offline)),
                      Tab(child: Text(AppLocalizations.of(context)!.recent)),
                    ],

                    onTap: (int tabIndex) async {
                      foodSearchScreenViewModel.finishSearch();
                      if (tabIndex == 0) {
                        _searchMode = SearchMode.online;
                      }

                      if (tabIndex == 1) {
                        _searchMode = SearchMode.offline;
                      }

                      if (tabIndex == 2) {
                        _searchMode = SearchMode.recent;
                        await _search(foodSearchScreenViewModel: foodSearchScreenViewModel, standardFoodUnitLocalizations: standardFoodUnitLocalizations);
                      }
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: foodSearchScreenViewModel.showInitialLoading,
              builder: (_, _, _) {
                if (foodSearchScreenViewModel.showInitialLoading.value) {
                  return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                } else {
                  return SizedBox();
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: foodSearchScreenViewModel.showIsLoadingMessage,
              builder: (_, _, _) {
                if (foodSearchScreenViewModel.showIsLoadingMessage.value) {
                  TextStyle? style = textTheme.bodySmall;
                  if (style != null) {
                    style = style.copyWith(color: Colors.red);
                  } else {
                    style = TextStyle(color: Colors.red);
                  }

                  return Text(AppLocalizations.of(context)!.wait_search, style: style);
                } else {
                  return SizedBox();
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: foodSearchScreenViewModel.errorCode,
              builder: (_, _, _) {
                if (foodSearchScreenViewModel.errorCode.value != null) {
                  TextStyle? style = textTheme.bodySmall;
                  if (style != null) {
                    style = style.copyWith(color: Colors.red);
                  } else {
                    style = TextStyle(color: Colors.red);
                  }

                  if (foodSearchScreenViewModel.errorCode.value == 1) {
                    return Text(AppLocalizations.of(context)!.open_food_facts_exception(foodSearchScreenViewModel.errorMessage), style: style);
                  } else if (foodSearchScreenViewModel.errorCode.value == 2) {
                    return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_response, style: style);
                  } else if (foodSearchScreenViewModel.errorCode.value == 3) {
                    return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_status, style: style);
                  } else if (foodSearchScreenViewModel.errorCode.value == 4) {
                    return Text(AppLocalizations.of(context)!.enter_search_criteria, style: style);
                  } else if (foodSearchScreenViewModel.errorCode.value == 5) {
                    return Text(AppLocalizations.of(context)!.could_not_parse_open_food_facts_answer, style: style);
                  } else {
                    return Text(AppLocalizations.of(context)!.search_unexpected_error, style: style);
                  }
                } else {
                  return SizedBox();
                }
              },
            ),
            ListenableBuilder(
              listenable: foodSearchScreenViewModel.foodSearchResultChanged,
              builder: (_, _) {
                if (foodSearchScreenViewModel.foodSearchResult.isNotEmpty) {
                  return Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: foodSearchScreenViewModel.searchMessageCode,
                          builder: (_, _, _) {
                            if (foodSearchScreenViewModel.searchMessageCode.value != null) {
                              TextStyle? style = textTheme.bodySmall;
                              if (style != null) {
                                style = style.copyWith(color: Colors.red);
                              } else {
                                style = TextStyle(color: Colors.red);
                              }
                              if (foodSearchScreenViewModel.searchMessageCode.value == 1) {
                                return Text(AppLocalizations.of(context)!.too_many_results_for_sorting, style: style);
                              } else {
                                return Text(AppLocalizations.of(context)!.unknow_sorting_message, style: style);
                              }
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 5),
                      RoundOutlinedButton(
                        onPressed: () {
                          foodSearchScreenViewModel.changeSortDirection();
                        },
                        child: ValueListenableBuilder(
                          valueListenable: foodSearchScreenViewModel.sortDesc,
                          builder: (_, _, _) {
                            return Transform.flip(flipY: !foodSearchScreenViewModel.sortDesc.value, child: const Icon(Icons.sort));
                          },
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: foodSearchScreenViewModel.sortButtonChanged,
                          builder: (_, _) {
                            return OpenEatsJournalDropdownMenu<SortOrder>(
                              dropdownMenuEntries: [
                                DropdownMenuEntry<SortOrder>(value: SortOrder.popularity, label: AppLocalizations.of(context)!.popularity),
                                DropdownMenuEntry<SortOrder>(value: SortOrder.name, label: AppLocalizations.of(context)!.name),
                                DropdownMenuEntry<SortOrder>(value: SortOrder.kcal, label: AppLocalizations.of(context)!.kcal),
                              ],
                              initialSelection: foodSearchScreenViewModel.sortOrder,
                              onSelected: (SortOrder? sortOrder) {
                                foodSearchScreenViewModel.setSortOrder(sortOrder: sortOrder!, searchMode: _searchMode);
                              },
                              enabled: foodSearchScreenViewModel.sortButtonEnabled,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return SizedBox();
              },
            ),
            ListenableBuilder(
              listenable: foodSearchScreenViewModel.foodSearchResultChanged,
              builder: (contextBuilder, _) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: foodSearchScreenViewModel.hasMore
                        ? foodSearchScreenViewModel.foodSearchResult.length + 1
                        : foodSearchScreenViewModel.foodSearchResult.length,
                    itemBuilder: (context, listViewItemIndex) {
                      if (listViewItemIndex >= foodSearchScreenViewModel.foodSearchResult.length) {
                        if (!foodSearchScreenViewModel.isLoading) {
                          foodSearchScreenViewModel.getFoodBySearchTextLoadMore();
                        }
                        return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                      }

                      //food is null, when online search for barcode returned no result.
                      if (foodSearchScreenViewModel.foodSearchResult[listViewItemIndex].object != null) {
                        return FoodCard(
                          food: foodSearchScreenViewModel.foodSearchResult[listViewItemIndex].object!,
                          textTheme: textTheme,
                          onCardTap: ({required Food food}) async {
                            EntityEdited? eatsJournalEntryEdited =
                                await Navigator.pushNamed(
                                      context,
                                      OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                                      arguments: EatsJournalEntry.fromFood(
                                        entryDate: foodSearchScreenViewModel.currentJournalDate.value,
                                        food: food,
                                        amountMeasurementUnit: food.nutritionPerGramAmount != null ? MeasurementUnit.gram : MeasurementUnit.milliliter,
                                        meal: foodSearchScreenViewModel.currentMeal.value,
                                      ),
                                    )
                                    as EntityEdited?;

                            if (eatsJournalEntryEdited != null) {
                              UiHelpers.showOverlay(
                                context: AppGlobal.navigatorKey.currentContext!,
                                displayText: eatsJournalEntryEdited.originalId == null
                                    ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_added
                                    : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_updated,
                                animationController: _animationController,
                              );
                            }
                          },
                          onAddJournalEntryPressed: ({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) async {
                            await foodSearchScreenViewModel.addEatsJournalEntry(
                              EatsJournalEntry.fromFood(
                                food: food,
                                entryDate: foodSearchScreenViewModel.currentJournalDate.value,
                                amount: amount,
                                amountMeasurementUnit: amountMeasurementUnit,
                                meal: foodSearchScreenViewModel.currentMeal.value,
                              ),
                            );
                          },
                          onFoodEdited: ({required EntityEdited entityEdited}) {
                            UiHelpers.showOverlay(
                              context: AppGlobal.navigatorKey.currentContext!,
                              displayText: entityEdited.originalId == null
                                  ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_created
                                  : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_updated,
                              animationController: _animationController,
                            );
                          },
                        );
                      } else {
                        final borderRadius = BorderRadius.circular(8);
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: borderRadius),
                          child: InkWell(
                            borderRadius: borderRadius,
                            onTap: () async {
                              await showDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.fromLTRB(
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                    ),
                                    title: Text(AppLocalizations.of(context)!.no_online_result_found),
                                    content: SingleChildScrollView(
                                      child: RichText(
                                        text: TextSpan(
                                          style: textTheme.bodyMedium,
                                          text: AppLocalizations.of(context)!.adding_online_data_1,
                                          children: [
                                            TextSpan(
                                              text: " ${AppLocalizations.of(context)!.open_food_facts} ",
                                              style: TextStyle(color: colorScheme.primary),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  await launchUrl(Uri.parse("https://world.openfoodfacts.org/"), mode: LaunchMode.platformDefault);
                                                },
                                            ),
                                            TextSpan(text: AppLocalizations.of(context)!.adding_online_data_2),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(AppLocalizations.of(context)!.ok),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(horizontal: 7),
                              child: Text(AppLocalizations.of(context)!.no_result_from_online_source, textAlign: TextAlign.center),
                            ),
                          ),
                        );
                      }
                    },
                  ),
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
                valueListenable: foodSearchScreenViewModel.floatingActionMenuElapsed,
                builder: (_, _, _) {
                  if (foodSearchScreenViewModel.floatingActionMenuElapsed.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: fabMenuWidth,
                          child: FloatingActionButton.extended(
                            heroTag: "4",
                            onPressed: () async {
                              foodSearchScreenViewModel.toggleFloatingActionButtons();
                              if (await _showAddWeightDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                foodSearchScreenViewModel: foodSearchScreenViewModel,
                                initialDate: foodSearchScreenViewModel.currentJournalDate.value,
                                initialWeight: await foodSearchScreenViewModel.getLastWeightJournalEntry(),
                              )) {
                                UiHelpers.showOverlay(
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
                              foodSearchScreenViewModel.toggleFloatingActionButtons();

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
                                UiHelpers.showOverlay(
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
                              foodSearchScreenViewModel.toggleFloatingActionButtons();
                              EntityEdited? eatsJournalEntryEdited = await UiHelpers.pushQuickEntryRoute(
                                context: context,
                                initialEntryDate: foodSearchScreenViewModel.currentJournalDate.value,
                                initialMeal: foodSearchScreenViewModel.currentMeal.value,
                              );

                              if (eatsJournalEntryEdited != null) {
                                UiHelpers.showOverlay(
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
                  foodSearchScreenViewModel.toggleFloatingActionButtons();
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _search({required FoodSearchScreenViewModel foodSearchScreenViewModel, required Map<String, String> standardFoodUnitLocalizations}) async {
    String cleanSearchText = _searchTextController.text.trim();

    List<String> parts = cleanSearchText.split(OpenEatsJournalStrings.doublepoint);

    if (parts.length == 2 && parts[0].trim().toLowerCase() == OpenEatsJournalStrings.code) {
      int? barcode = int.tryParse(parts[1]);
      await foodSearchScreenViewModel.getFoodByBarcode(barcode: barcode, localizations: standardFoodUnitLocalizations, searchMode: _searchMode);
    } else {
      await foodSearchScreenViewModel.getFoodsBySearchText(searchText: cleanSearchText, localizations: standardFoodUnitLocalizations, searchMode: _searchMode);
    }
  }

  Future<void> _selectDate({required FoodSearchScreenViewModel foodSearchScreenViewModel, required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      foodSearchScreenViewModel.currentJournalDate.value = date;
    }
  }

  Future<bool> _showAddWeightDialog({
    required BuildContext context,
    required FoodSearchScreenViewModel foodSearchScreenViewModel,
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
      await foodSearchScreenViewModel.setWeightJournalEntry(
        date: foodSearchScreenViewModel.currentJournalDate.value,
        weight: weightJournalEntryAddScreenViewModel.lastValidWeight,
      );
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _searchTextController.dispose();

    super.dispose();
  }
}

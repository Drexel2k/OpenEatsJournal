import "dart:async";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";
import "package:openeatsjournal/ui/widgets/food_card.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required FoodSearchScreenViewModel foodSearchScreenViewModel}) : _foodSearchScreenViewModel = foodSearchScreenViewModel;

  final FoodSearchScreenViewModel _foodSearchScreenViewModel;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fabMenuWidth = 150;

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
                  valueListenable: widget._foodSearchScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        await _selectDate(initialDate: widget._foodSearchScreenViewModel.currentJournalDate.value, context: context);
                      },
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._foodSearchScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._foodSearchScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        widget._foodSearchScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: widget._foodSearchScreenViewModel.currentMeal.value.value,
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
                child: OpenEatsJournalTextField(controller: _searchTextController, hintText: AppLocalizations.of(context)!.search_food),
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: () async {
                  await _search(
                    languageCode: languageCode,
                    localilzations: {
                      OpenEatsJournalStrings.piece: AppLocalizations.of(context)!.piece,
                      OpenEatsJournalStrings.serving: AppLocalizations.of(context)!.serving,
                    },
                  );
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
                    await _search(
                      languageCode: languageCode,
                      localilzations: {
                        OpenEatsJournalStrings.piece: AppLocalizations.of(navigatorKey.currentContext!)!.piece,
                        OpenEatsJournalStrings.serving: AppLocalizations.of(navigatorKey.currentContext!)!.serving,
                      },
                    );
                  }
                },
                child: Icon(Icons.qr_code_scanner),
              ),
            ],
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: widget._foodSearchScreenViewModel.showInitialLoading,
            builder: (_, _, _) {
              if (widget._foodSearchScreenViewModel.showInitialLoading.value) {
                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
              } else {
                return SizedBox();
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: widget._foodSearchScreenViewModel.errorCode,
            builder: (_, _, _) {
              if (widget._foodSearchScreenViewModel.errorCode.value != null) {
                TextStyle? style = textTheme.bodySmall;
                if (style != null) {
                  style = style.copyWith(color: Colors.red);
                } else {
                  style = TextStyle(color: Colors.red);
                }

                if (widget._foodSearchScreenViewModel.errorCode.value == 1) {
                  return Text(AppLocalizations.of(context)!.open_food_facts_exception(widget._foodSearchScreenViewModel.errorMessage), style: style);
                } else if (widget._foodSearchScreenViewModel.errorCode.value == 2) {
                  return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_response, style: style);
                } else if (widget._foodSearchScreenViewModel.errorCode.value == 3) {
                  return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_status, style: style);
                } else {
                  return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_error, style: style);
                }
              } else {
                return SizedBox();
              }
            },
          ),
          ListenableBuilder(
            listenable: widget._foodSearchScreenViewModel.foodSearchResultChanged,
            builder: (_, _) {
              if (widget._foodSearchScreenViewModel.foodSearchResult.isNotEmpty) {
                return Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: widget._foodSearchScreenViewModel.searchMessageCode,
                        builder: (_, _, _) {
                          if (widget._foodSearchScreenViewModel.searchMessageCode.value != null) {
                            TextStyle? style = textTheme.bodySmall;
                            if (style != null) {
                              style = style.copyWith(color: Colors.red);
                            } else {
                              style = TextStyle(color: Colors.red);
                            }
                            if (widget._foodSearchScreenViewModel.searchMessageCode.value == 1) {
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
                        widget._foodSearchScreenViewModel.changeSortDirection();
                      },
                      child: ValueListenableBuilder(
                        valueListenable: widget._foodSearchScreenViewModel.sortDesc,
                        builder: (_, _, _) {
                          return Transform.flip(flipY: !widget._foodSearchScreenViewModel.sortDesc.value, child: const Icon(Icons.sort));
                        },
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: widget._foodSearchScreenViewModel.sortButtonChanged,
                        builder: (_, _) {
                          return OpenEatsJournalDropdownMenu<SortOrder>(
                            dropdownMenuEntries: [
                              DropdownMenuEntry<SortOrder>(value: SortOrder.popularity, label: AppLocalizations.of(context)!.popularity),
                              DropdownMenuEntry<SortOrder>(value: SortOrder.name, label: AppLocalizations.of(context)!.name),
                              DropdownMenuEntry<SortOrder>(value: SortOrder.kcal, label: AppLocalizations.of(context)!.kcal),
                            ],
                            initialSelection: widget._foodSearchScreenViewModel.sortOrder,
                            onSelected: (SortOrder? sortOrder) {
                              widget._foodSearchScreenViewModel.setSortOrder(sortOrder!);
                            },
                            enabled: widget._foodSearchScreenViewModel.sortButtonEnabled,
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
            listenable: widget._foodSearchScreenViewModel.foodSearchResultChanged,
            builder: (contextBuilder, _) {
              return Expanded(
                child: ListView.builder(
                  itemCount: widget._foodSearchScreenViewModel.hasMore
                      ? widget._foodSearchScreenViewModel.foodSearchResult.length + 1
                      : widget._foodSearchScreenViewModel.foodSearchResult.length,
                  itemBuilder: (context, listViewItemIndex) {
                    if (listViewItemIndex >= widget._foodSearchScreenViewModel.foodSearchResult.length) {
                      if (!widget._foodSearchScreenViewModel.isLoading) {
                        widget._foodSearchScreenViewModel.getFoodBySearchTextLoadMore();
                      }
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    return FoodCard(
                      food: widget._foodSearchScreenViewModel.foodSearchResult[listViewItemIndex].object,
                      textTheme: textTheme,
                      onCardTap: ({required Food food}) {
                        Navigator.pushNamed(
                          context,
                          OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                          arguments: EatsJournalEntry.fromFood(
                            entryDate: widget._foodSearchScreenViewModel.currentJournalDate.value,
                            food: food,
                            amount: 100,
                            amountMeasurementUnit: food.nutritionPerGramAmount != null ? MeasurementUnit.gram : MeasurementUnit.milliliter,
                            meal: widget._foodSearchScreenViewModel.currentMeal.value,
                          ),
                        );
                      },
                      onAddJournalEntryPressed: ({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) async {
                        await widget._foodSearchScreenViewModel.addEatsJournalEntry(
                          EatsJournalEntry.fromFood(
                            food: food,
                            entryDate: widget._foodSearchScreenViewModel.currentJournalDate.value,
                            amount: amount,
                            amountMeasurementUnit: amountMeasurementUnit,
                            meal: widget._foodSearchScreenViewModel.currentMeal.value,
                          ),
                        );
                      },
                    );
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
              valueListenable: widget._foodSearchScreenViewModel.floatingActionMenuElapsed,
              builder: (_, _, _) {
                if (widget._foodSearchScreenViewModel.floatingActionMenuElapsed.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: fabMenuWidth,
                        child: FloatingActionButton.extended(
                          heroTag: "4",
                          onPressed: () async {
                            widget._foodSearchScreenViewModel.toggleFloatingActionButtons();

                            double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
                            double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;
                            double weight = await widget._foodSearchScreenViewModel.getLastWeightJournalEntry();

                            WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel = WeightJournalEntryAddScreenViewModel(
                              initialWeight: weight,
                            );

                            if ((await showDialog<bool>(
                              useSafeArea: true,
                              barrierDismissible: false,
                              context: navigatorKey.currentContext!,
                              builder: (BuildContext contextBuilder) {
                                return Dialog(
                                  insetPadding: EdgeInsets.fromLTRB(
                                    dialogHorizontalPadding,
                                    dialogVerticalPadding,
                                    dialogHorizontalPadding,
                                    dialogVerticalPadding,
                                  ),
                                  child: WeightJournalEntryAddScreen(
                                    weightJournalEntryAddScreenViewModel: weightJournalEntryAddScreenViewModel,
                                    date: widget._foodSearchScreenViewModel.currentJournalDate.value,
                                  ),
                                );
                              },
                            ))!) {
                              await widget._foodSearchScreenViewModel.setWeightJournalEntry(
                                date: widget._foodSearchScreenViewModel.currentJournalDate.value,
                                weight: weightJournalEntryAddScreenViewModel.lastValidWeight,
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
                          onPressed: () {
                            widget._foodSearchScreenViewModel.toggleFloatingActionButtons();

                            Navigator.pushNamed(
                              context,
                              OpenEatsJournalStrings.navigatorRouteFoodEdit,
                              arguments: Food(
                                name: OpenEatsJournalStrings.emptyString,
                                foodSource: FoodSource.user,
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
                          onPressed: () {
                            widget._foodSearchScreenViewModel.toggleFloatingActionButtons();

                            Navigator.pushNamed(
                              context,
                              OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
                              arguments: EatsJournalEntry.quick(
                                entryDate: widget._foodSearchScreenViewModel.currentJournalDate.value,
                                name: OpenEatsJournalStrings.emptyString,
                                kJoule: NutritionCalculator.kJouleForOnekCal,
                                meal: widget._foodSearchScreenViewModel.currentMeal.value,
                              ),
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
                widget._foodSearchScreenViewModel.toggleFloatingActionButtons();
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _search({required String languageCode, required Map<String, String> localilzations}) async {
    String cleanSearchText = _searchTextController.text.trim();
    if (cleanSearchText != OpenEatsJournalStrings.emptyString) {
      List<String> parts = cleanSearchText.split(OpenEatsJournalStrings.doublepoint);

      if (parts.length == 2 && parts[0].trim().toLowerCase() == OpenEatsJournalStrings.code) {
        int? barcode = int.tryParse(parts[1]);
        if (barcode != null) {
          await widget._foodSearchScreenViewModel.getFoodByBarcode(barcode: barcode, languageCode: languageCode, localizations: localilzations);
        }
      } else {
        await widget._foodSearchScreenViewModel.getFoodBySearchText(searchText: cleanSearchText, languageCode: languageCode, localizations: localilzations);
      }
    }
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      widget._foodSearchScreenViewModel.currentJournalDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._foodSearchScreenViewModel.dispose();
    _searchTextController.dispose();

    super.dispose();
  }
}

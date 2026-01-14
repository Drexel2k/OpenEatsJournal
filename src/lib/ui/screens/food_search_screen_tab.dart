import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";
import "package:openeatsjournal/ui/widgets/food_card.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class FoodSearchScreenTab extends StatefulWidget {
  const FoodSearchScreenTab({
    super.key,
    required FoodSearchScreenViewModel foodSearchScreenViewModel,
    required SearchMode searchMode,
    required Map<String, String> standardFoodUnitLocalizations,
  }) : _foodSearchScreenViewModel = foodSearchScreenViewModel,
       _searchMode = searchMode,
       _standardFoodUnitLocalizations = standardFoodUnitLocalizations;

  final FoodSearchScreenViewModel _foodSearchScreenViewModel;
  final SearchMode _searchMode;
  final Map<String, String> _standardFoodUnitLocalizations;

  @override
  State<FoodSearchScreenTab> createState() => _FoodSearchScreenTabState();
}

class _FoodSearchScreenTabState extends State<FoodSearchScreenTab> {
  late FoodSearchScreenViewModel _foodSearchScreenViewModel;
  late SearchMode _searchMode;
  late Map<String, String> _standardFoodUnitLocalizations;

  final TextEditingController _searchTextController = TextEditingController();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _foodSearchScreenViewModel = widget._foodSearchScreenViewModel;
    _searchMode = widget._searchMode;
    _standardFoodUnitLocalizations = widget._standardFoodUnitLocalizations;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OpenEatsJournalTextField(controller: _searchTextController, hintText: AppLocalizations.of(context)!.search_food),
            ),
            SizedBox(width: 5),
            RoundOutlinedButton(
              onPressed: () {
                _search();
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
                  _search();
                }
              },
              child: Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
        SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: _foodSearchScreenViewModel.showInitialLoading,
          builder: (_, _, _) {
            if (_foodSearchScreenViewModel.showInitialLoading.value) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else {
              return SizedBox();
            }
          },
        ),
        ValueListenableBuilder(
          valueListenable: _foodSearchScreenViewModel.errorCode,
          builder: (_, _, _) {
            if (_foodSearchScreenViewModel.errorCode.value != null) {
              TextStyle? style = textTheme.bodySmall;
              if (style != null) {
                style = style.copyWith(color: Colors.red);
              } else {
                style = TextStyle(color: Colors.red);
              }

              if (_foodSearchScreenViewModel.errorCode.value == 1) {
                return Text(AppLocalizations.of(context)!.open_food_facts_exception(_foodSearchScreenViewModel.errorMessage), style: style);
              } else if (_foodSearchScreenViewModel.errorCode.value == 2) {
                return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_response, style: style);
              } else if (_foodSearchScreenViewModel.errorCode.value == 3) {
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
          listenable: _foodSearchScreenViewModel.foodSearchResultChanged,
          builder: (_, _) {
            if (_foodSearchScreenViewModel.foodSearchResult.isNotEmpty) {
              return Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _foodSearchScreenViewModel.searchMessageCode,
                      builder: (_, _, _) {
                        if (_foodSearchScreenViewModel.searchMessageCode.value != null) {
                          TextStyle? style = textTheme.bodySmall;
                          if (style != null) {
                            style = style.copyWith(color: Colors.red);
                          } else {
                            style = TextStyle(color: Colors.red);
                          }
                          if (_foodSearchScreenViewModel.searchMessageCode.value == 1) {
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
                      _foodSearchScreenViewModel.changeSortDirection();
                    },
                    child: ValueListenableBuilder(
                      valueListenable: _foodSearchScreenViewModel.sortDesc,
                      builder: (_, _, _) {
                        return Transform.flip(flipY: !_foodSearchScreenViewModel.sortDesc.value, child: const Icon(Icons.sort));
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _foodSearchScreenViewModel.sortButtonChanged,
                      builder: (_, _) {
                        return OpenEatsJournalDropdownMenu<SortOrder>(
                          dropdownMenuEntries: [
                            DropdownMenuEntry<SortOrder>(value: SortOrder.popularity, label: AppLocalizations.of(context)!.popularity),
                            DropdownMenuEntry<SortOrder>(value: SortOrder.name, label: AppLocalizations.of(context)!.name),
                            DropdownMenuEntry<SortOrder>(value: SortOrder.kcal, label: AppLocalizations.of(context)!.kcal),
                          ],
                          initialSelection: _foodSearchScreenViewModel.sortOrder,
                          onSelected: (SortOrder? sortOrder) {
                            _foodSearchScreenViewModel.setSortOrder(sortOrder!);
                          },
                          enabled: _foodSearchScreenViewModel.sortButtonEnabled,
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
          listenable: _foodSearchScreenViewModel.foodSearchResultChanged,
          builder: (contextBuilder, _) {
            return Expanded(
              child: ListView.builder(
                itemCount: _foodSearchScreenViewModel.hasMore
                    ? _foodSearchScreenViewModel.foodSearchResult.length + 1
                    : _foodSearchScreenViewModel.foodSearchResult.length,
                itemBuilder: (context, listViewItemIndex) {
                  if (listViewItemIndex >= _foodSearchScreenViewModel.foodSearchResult.length) {
                    if (!_foodSearchScreenViewModel.isLoading) {
                      _foodSearchScreenViewModel.getFoodBySearchTextLoadMore();
                    }
                    return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                  }

                  return FoodCard(
                    food: _foodSearchScreenViewModel.foodSearchResult[listViewItemIndex].object,
                    textTheme: textTheme,
                    onCardTap: ({required Food food}) {
                      Navigator.pushNamed(
                        context,
                        OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                        arguments: EatsJournalEntry.fromFood(
                          entryDate: _foodSearchScreenViewModel.currentJournalDate.value,
                          food: food,
                          amount: 100,
                          amountMeasurementUnit: food.nutritionPerGramAmount != null ? MeasurementUnit.gram : MeasurementUnit.milliliter,
                          meal: _foodSearchScreenViewModel.currentMeal.value,
                        ),
                      );
                    },
                    onAddJournalEntryPressed: ({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) async {
                      await _foodSearchScreenViewModel.addEatsJournalEntry(
                        EatsJournalEntry.fromFood(
                          food: food,
                          entryDate: _foodSearchScreenViewModel.currentJournalDate.value,
                          amount: amount,
                          amountMeasurementUnit: amountMeasurementUnit,
                          meal: _foodSearchScreenViewModel.currentMeal.value,
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
    );
  }

  Future<void> _search() async {
    String cleanSearchText = _searchTextController.text.trim();

    List<String> parts = cleanSearchText.split(OpenEatsJournalStrings.doublepoint);

    if (parts.length == 2 && parts[0].trim().toLowerCase() == OpenEatsJournalStrings.code) {
      int? barcode = int.tryParse(parts[1]);
      if (barcode != null) {
        await _foodSearchScreenViewModel.getFoodByBarcode(barcode: barcode, localizations: _standardFoodUnitLocalizations, searchMode: _searchMode);
      }
    } else {
      await _foodSearchScreenViewModel.getFoodBySearchText(searchText: cleanSearchText, localizations: _standardFoodUnitLocalizations, searchMode: _searchMode);
    }
  }
}

import "dart:async";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/meal.dart";

import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/localized_meal_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";
import "package:openeatsjournal/ui/widgets/food_card.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class FoodSearchScreen extends StatelessWidget {
  FoodSearchScreen({super.key, required FoodSearchScreenViewModel foodSearchScreenViewModel})
    : _foodSearchScreenViewModel = foodSearchScreenViewModel,
      _searchTextController = TextEditingController();

  final FoodSearchScreenViewModel _foodSearchScreenViewModel;
  final TextEditingController _searchTextController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFood,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: ValueListenableBuilder(
                  valueListenable: _foodSearchScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        try {
                          _selectDate(initialDate: _foodSearchScreenViewModel.currentJournalDate.value, context: context);
                        } on Exception catch (exc, stack) {
                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                        } on Error catch (error, stack) {
                          await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                        }
                      },
                      child: Text(
                        DateFormat.yMMMMd(_foodSearchScreenViewModel.languageCode).format(_foodSearchScreenViewModel.currentJournalDate.value),
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
                  valueListenable: _foodSearchScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _foodSearchScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedMealDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: _foodSearchScreenViewModel.currentMeal.value.value,
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
                  try {
                    await _search(
                      languageCode: languageCode,
                      localilzations: {
                        OpenEatsJournalStrings.piece: AppLocalizations.of(context)!.piece,
                        OpenEatsJournalStrings.serving: AppLocalizations.of(context)!.serving,
                      },
                    );
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                  }
                },
                child: Icon(Icons.search),
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: () async {
                  try {
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
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
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
            listenable: _foodSearchScreenViewModel.foodSearchResultChangedNotifier,
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
                    Icon(Icons.sort),
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
            listenable: _foodSearchScreenViewModel.foodSearchResultChangedNotifier,
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

                    return FoodCard(food: _foodSearchScreenViewModel.foodSearchResult[listViewItemIndex].object, textTheme: textTheme, onTap: () {});
                  },
                ),
              );
            },
          ),
        ],
      ),
      title: AppLocalizations.of(context)!.food_management,
    );
  }

  Future<void> _search({required String languageCode, required Map<String, String> localilzations}) async {
    String cleanSearchText = _searchTextController.text.trim();
    if (cleanSearchText != OpenEatsJournalStrings.emptyString) {
      List<String> parts = cleanSearchText.split(OpenEatsJournalStrings.doublepoint);

      if (parts.length == 2 && parts[0].trim().toLowerCase() == OpenEatsJournalStrings.code) {
        await _foodSearchScreenViewModel.getFoodByBarcode(barcode: parts[1], languageCode: languageCode, localizations: localilzations);
      } else {
        await _foodSearchScreenViewModel.getFoodBySearchText(searchText: cleanSearchText, languageCode: languageCode, localizations: localilzations);
      }
    }
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      _foodSearchScreenViewModel.currentJournalDate.value = date;
    }
  }
}

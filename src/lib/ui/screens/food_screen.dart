import "dart:async";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";

import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/food_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/utils/localized_meal_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class FoodScreen extends StatelessWidget {
  FoodScreen({super.key, required FoodViewModel foodViewModel})
    : _foodViewModel = foodViewModel,
      _searchTextController = TextEditingController();

  final FoodViewModel _foodViewModel;
  final TextEditingController _searchTextController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final InputDecorationTheme inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFood,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: ValueListenableBuilder(
                  valueListenable: _foodViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        try {
                          _selectDate(initialDate: _foodViewModel.currentJournalDate.value, context: context);
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
                        DateFormat.yMMMMd(_foodViewModel.languageCode).format(_foodViewModel.currentJournalDate.value),
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
                  valueListenable: _foodViewModel.currentMeal,
                  builder: (_, _, _) {
                    return DropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _foodViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedMealDropDownEntries.getMealDropDownMenuEntries(context: context),
                      inputDecorationTheme: inputDecorationTheme.copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _foodViewModel.currentMeal.value.value,
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
                ),
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: () async {
                  try {
                    await _search(languageCode: languageCode);
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
                child: Icon(Icons.search),
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: () async {
                  try {
                    Object? barcodeScanResult = await Navigator.pushNamed(
                      context,
                      OpenEatsJournalStrings.navigatorRouteBarcodeScanner,
                    );
                    if (barcodeScanResult != null) {
                      String barcode = barcodeScanResult as String;
                      _searchTextController.text =
                          "${OpenEatsJournalStrings.code}${OpenEatsJournalStrings.doublepoint}$barcode";
                      await _search(languageCode: languageCode);
                    }
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
                child: Icon(Icons.qr_code_scanner),
              ),
            ],
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: _foodViewModel.showInitialLoading,
            builder: (_, _, _) {
              if (_foodViewModel.showInitialLoading.value) {
                return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
              } else {
                return SizedBox();
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: _foodViewModel.errorCode,
            builder: (_, _, _) {
              if (_foodViewModel.errorCode.value != null) {
                TextStyle? style = textTheme.bodySmall;
                if (style != null) {
                  style = style.copyWith(color: Colors.red);
                } else {
                  style = TextStyle(color: Colors.red);
                }

                if (_foodViewModel.errorCode.value == 1) {
                  return Text(
                    AppLocalizations.of(context)!.open_food_facts_exception(_foodViewModel.errorMessage),
                    style: style,
                  );
                } else if (_foodViewModel.errorCode.value == 2) {
                  return Text(AppLocalizations.of(context)!.open_food_facts_unexpected_response, style: style);
                } else if (_foodViewModel.errorCode.value == 3) {
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
            listenable: _foodViewModel.foodSearchResultChangedNotifier,
            builder: (_, _) {
              if (_foodViewModel.foodSearchResult.isNotEmpty) {
                return Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _foodViewModel.searchMessageCode,
                        builder: (_, _, _) {
                          if (_foodViewModel.searchMessageCode.value != null) {
                            TextStyle? style = textTheme.bodySmall;
                            if (style != null) {
                              style = style.copyWith(color: Colors.red);
                            } else {
                              style = TextStyle(color: Colors.red);
                            }
                            if (_foodViewModel.searchMessageCode.value == 1) {
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
                    ListenableBuilder(
                      listenable: _foodViewModel.sortButtonChanged,
                      builder: (_, _) {
                        return DropdownButton(
                          items: [
                            DropdownMenuItem<SortOrder>(
                              value: SortOrder.popularity,
                              child: Text(AppLocalizations.of(context)!.popularity),
                            ),
                            DropdownMenuItem<SortOrder>(
                              value: SortOrder.name,
                              child: Text(AppLocalizations.of(context)!.name),
                            ),
                            DropdownMenuItem<SortOrder>(
                              value: SortOrder.kcal,
                              child: Text(AppLocalizations.of(context)!.kcal),
                            ),
                          ],
                          value: _foodViewModel.sortOrder,
                          onChanged: _foodViewModel.sortButtonEnabled
                              ? (SortOrder? value) {
                                  _foodViewModel.setSortOrder(value!);
                                }
                              : null,
                        );
                      },
                    ),
                  ],
                );
              }

              return SizedBox();
            },
          ),

          ListenableBuilder(
            listenable: _foodViewModel.foodSearchResultChangedNotifier,
            builder: (contextBuilder, _) {
              return Expanded(
                child: ListView.builder(
                  itemCount: _foodViewModel.hasMore
                      ? _foodViewModel.foodSearchResult.length + 1
                      : _foodViewModel.foodSearchResult.length,
                  itemBuilder: (context, listViewItemIndex) {
                    if (listViewItemIndex >= _foodViewModel.foodSearchResult.length) {
                      if (!_foodViewModel.isLoading) {
                        _foodViewModel.getFoodBySearchTextLoadMore();
                      }
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    return Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: textTheme.headlineSmall,
                                  _foodViewModel.foodSearchResult[listViewItemIndex].object.name !=
                                          OpenEatsJournalStrings.emptyString
                                      ? _foodViewModel.foodSearchResult[listViewItemIndex].object.name
                                      : AppLocalizations.of(context)!.no_name,
                                ),
                                Text(
                                  style: textTheme.labelLarge,
                                  _foodViewModel.foodSearchResult[listViewItemIndex].object.brands != null
                                      ? _foodViewModel.foodSearchResult[listViewItemIndex].object.brands!.join(", ")
                                      : AppLocalizations.of(context)!.no_brand,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            style: textTheme.headlineMedium,
                                            AppLocalizations.of(context)!.amount_kcal(
                                              NutritionCalculator.getKCalsFromKJoules(
                                                _foodViewModel
                                                    .foodSearchResult[listViewItemIndex]
                                                    .object
                                                    .energyKjPer100Units,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            style: textTheme.labelSmall,
                                            AppLocalizations.of(context)!.per_100_measurement_unit(
                                              _foodViewModel
                                                  .foodSearchResult[listViewItemIndex]
                                                  .object
                                                  .measurementUnit
                                                  .text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _foodViewModel
                                                      .foodSearchResult[listViewItemIndex]
                                                      .object
                                                      .carbohydratesPer100Units !=
                                                  null
                                              ? Text(
                                                  AppLocalizations.of(context)!.amount_carb(
                                                    _foodViewModel
                                                        .foodSearchResult[listViewItemIndex]
                                                        .object
                                                        .carbohydratesPer100Units!,
                                                  ),
                                                )
                                              : Text(AppLocalizations.of(context)!.na_carb),
                                          _foodViewModel.foodSearchResult[listViewItemIndex].object.fatPer100Units !=
                                                  null
                                              ? Text(
                                                  AppLocalizations.of(context)!.amount_fat(
                                                    _foodViewModel
                                                        .foodSearchResult[listViewItemIndex]
                                                        .object
                                                        .fatPer100Units!,
                                                  ),
                                                )
                                              : Text(AppLocalizations.of(context)!.na_fat),
                                          _foodViewModel
                                                      .foodSearchResult[listViewItemIndex]
                                                      .object
                                                      .proteinsPer100Units !=
                                                  null
                                              ? Text(
                                                  AppLocalizations.of(context)!.amount_prot(
                                                    _foodViewModel
                                                        .foodSearchResult[listViewItemIndex]
                                                        .object
                                                        .proteinsPer100Units!,
                                                  ),
                                                )
                                              : Text(AppLocalizations.of(context)!.na_prot),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: Badge(label: Text("OFF")),
                          ),
                          IconButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(Icons.more_vert),
                            iconSize: 36,
                            onPressed: null,
                          ),
                        ],
                      ),
                    );
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

  Future<void> _search({required String languageCode}) async {
    String cleanSearchText = _searchTextController.text.trim();
    if (cleanSearchText != OpenEatsJournalStrings.emptyString) {
      List<String> parts = cleanSearchText.split(OpenEatsJournalStrings.doublepoint);

      if (parts.length == 2 && parts[0].trim().toLowerCase() == OpenEatsJournalStrings.code) {
        await _foodViewModel.getFoodByBarcode(barcode: parts[1], languageCode: languageCode);
      } else {
        await _foodViewModel.getFoodBySearchText(searchText: cleanSearchText, languageCode: languageCode);
      }
    }
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(9999),
    );

    if (date != null) {
      _foodViewModel.currentJournalDate.value = date;
    }
  }
}

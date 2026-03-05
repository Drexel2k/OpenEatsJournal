import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/overlay_info.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class EatsJournalFoodEntryEditScreen extends StatefulWidget {
  const EatsJournalFoodEntryEditScreen({super.key});

  @override
  State<EatsJournalFoodEntryEditScreen> createState() => _EatsJournalFoodEntryEditScreenState();
}

class _EatsJournalFoodEntryEditScreenState extends State<EatsJournalFoodEntryEditScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _eatsAmountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _eatsAmountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    final EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodEntryEditScreenViewModel = Provider.of<EatsJournalFoodEntryEditScreenViewModel>(
      context,
      listen: false,
    );
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);

    _amountController.text = eatsJournalFoodEntryEditScreenViewModel.amount.value != null
        ? convert.numberFomatterInt.format(eatsJournalFoodEntryEditScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _eatsAmountController.text = eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null
        ? convert.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value!)
        : OpenEatsJournalStrings.emptyString;
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double overlaySpacer = 100;
    final double inputFieldsWidth = 110;

    return Consumer<EatsJournalFoodEntryEditScreenViewModel>(
      builder: (context, eatsJournalFoodEntryEditScreenViewModel, _) => MainLayout(
        route: OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
        title: eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
            ? AppLocalizations.of(context)!.add_eats_journal_entry
            : AppLocalizations.of(context)!.edit_eats_journal_entry,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.currentEntryDate,
                    builder: (_, _, _) {
                      return OutlinedButton(
                        onPressed: () async {
                          //for creating entries take value from setting, for editing entries take value from entry
                          DateTime initialDate = eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                              ? eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value
                              : eatsJournalFoodEntryEditScreenViewModel.foodEntry.entryDate;
                          await _selectDate(
                            eatsJournalFoodEntryEditScreenViewModel: eatsJournalFoodEntryEditScreenViewModel,
                            initialDate: initialDate,
                            context: context,
                          );
                        },
                        style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          convert.dateFormatterDisplayLongDateOnly.format(eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.currentMeal,
                    builder: (_, _, _) {
                      //for creating entries take value from setting, for editing entries take value from entry
                      int initialSelection = eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                          ? eatsJournalFoodEntryEditScreenViewModel.currentMeal.value.value
                          : eatsJournalFoodEntryEditScreenViewModel.foodEntry.meal.value;

                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          eatsJournalFoodEntryEditScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                        },
                        dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                        initialSelection: initialSelection,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        softWrap: true,
                        style: textTheme.headlineSmall,
                        eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.name != OpenEatsJournalStrings.emptyString
                            ? eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.name
                            : AppLocalizations.of(context)!.no_name,
                      ),
                      Text(
                        style: textTheme.labelLarge,
                        eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.brands.isNotEmpty
                            ? eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.brands.join(", ")
                            : AppLocalizations.of(context)!.no_brand,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (selected) {},
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuItem<String>> menuItems = [];

                    menuItems.add(
                      PopupMenuItem(
                        onTap: () async {
                          EntityEdited? foodEdited =
                              await Navigator.pushNamed(
                                    context,
                                    OpenEatsJournalStrings.navigatorRouteFoodEdit,
                                    arguments: Food.copyAsNewUserFood(food: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!),
                                  )
                                  as EntityEdited?;

                          if (foodEdited != null) {
                            overlayDisplay.enqueue(
                              overlayInfo: OverlayInfo(
                                message: foodEdited.originalId == null
                                    ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_created
                                    : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_updated,
                                spacer: overlaySpacer,
                              ),
                            );
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.as_new_food),
                      ),
                    );

                    if (eatsJournalFoodEntryEditScreenViewModel.foodEntry.id != null) {
                      menuItems.add(
                        PopupMenuItem(
                          onTap: () async {
                            EntityEdited? eatsJournalEntryEdited =
                                await Navigator.pushNamed(
                                      context,
                                      OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                                      arguments: EatsJournalEntry.fromFood(
                                        entryDate: eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value,
                                        food: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                                        amount: eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value,
                                        amountMeasurementUnit: eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value,
                                        meal: eatsJournalFoodEntryEditScreenViewModel.currentMeal.value,
                                      ),
                                    )
                                    as EntityEdited?;

                            if (eatsJournalEntryEdited != null) {
                              overlayDisplay.enqueue(
                                overlayInfo: OverlayInfo(
                                  message: eatsJournalEntryEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_added
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_updated,
                                  spacer: overlaySpacer,
                                ),
                              );
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.as_new_eats_journal_entry),
                        ),
                      );
                    }

                    if (eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.foodSource == FoodSource.user) {
                      menuItems.add(
                        PopupMenuItem(
                          onTap: () async {
                            EntityEdited? foodEdited =
                                await Navigator.pushNamed(
                                      context,
                                      OpenEatsJournalStrings.navigatorRouteFoodEdit,
                                      arguments: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                                    )
                                    as EntityEdited?;

                            if (foodEdited != null) {
                              overlayDisplay.enqueue(
                                overlayInfo: OverlayInfo(
                                  message: foodEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_created
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_updated,
                                  spacer: overlaySpacer,
                                ),
                              );
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.edit),
                        ),
                      );
                    }

                    return menuItems;
                  },
                  child: SizedBox(height: 30, width: 40, child: Icon(Icons.more_vert)),
                ),
              ],
            ),
            SizedBox(height: 5),
            ListTileTheme(
              minVerticalPadding: 0,
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                minTileHeight: 0,
                title: Text(
                  "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.kJoule))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                  style: textTheme.titleSmall,
                ),
                subtitle: Text(
                  "/ ${convert.getCleanDoubleString3DecimalDigits(
                    doubleValue: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null ? convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount!) : convert.getDisplayVolume(volumeMl: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerMilliliterAmount!),
                  )}${eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null ? convert.getLocalizedWeightUnitGAbbreviated(context: context) : convert.getLocalizedVolumeUnitAbbreviated(context: context)}",
                  style: textTheme.labelSmall,
                ),
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates != null
                                  ? AppLocalizations.of(context)!.amount_carb(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar != null
                                  ? AppLocalizations.of(context)!.amount_sugar(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_sugar(AppLocalizations.of(context)!.na),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.fat != null
                                  ? AppLocalizations.of(context)!.amount_fat(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.fat!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat != null
                                  ? AppLocalizations.of(context)!.amount_saturated_fat(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_saturated_fat(AppLocalizations.of(context)!.na),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.protein != null
                                  ? AppLocalizations.of(context)!.amount_prot(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.protein!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt != null
                                  ? AppLocalizations.of(context)!.amount_salt(
                                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}",
                                    )
                                  : AppLocalizations.of(context)!.amount_salt(AppLocalizations.of(context)!.na),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.kJoule,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.kJoule.value != null
                          ? Text(
                              "${convert.numberFomatterInt.format(eatsJournalFoodEntryEditScreenViewModel.kJoule.value!)}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                              style: textTheme.titleMedium,
                            )
                          : Text(AppLocalizations.of(context)!.na_kcal);
                    },
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: eatsJournalFoodEntryEditScreenViewModel.amountRelvantChanged,
                    builder: (_, _) {
                      String amountTotalInfo;
                      if (eatsJournalFoodEntryEditScreenViewModel.amount.value != null && eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null) {
                        amountTotalInfo = convert.getCleanDoubleString3DecimalDigits(
                          doubleValue: eatsJournalFoodEntryEditScreenViewModel.amount.value! * eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value!,
                        );
                      } else {
                        amountTotalInfo = AppLocalizations.of(context)!.na;
                      }

                      return Text(
                        "$amountTotalInfo ${eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram ? convert.getLocalizedWeightUnitG(context: context) : convert.getLocalizedVolumeUnit(context: context)}",
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.carbohydrates,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.carbohydrates.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.carbohydrates.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                            );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.sugar,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.sugar.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.sugar.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.sugar}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.sugar}",
                            );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.fat,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.fat.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.fat.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                            );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.saturatedFat,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.saturated_fat}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.saturated_fat}",
                            );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.protein,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.protein.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.protein.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein}",
                            );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.salt,
                    builder: (_, _, _) {
                      return eatsJournalFoodEntryEditScreenViewModel.salt.value != null
                          ? Text(
                              "${convert.getCleanDoubleString1DecimalDigit(doubleValue: eatsJournalFoodEntryEditScreenViewModel.salt.value!)}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.salt}",
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.na}${convert.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.salt}",
                            );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: eatsJournalFoodEntryEditScreenViewModel.amount,
                  builder: (_, _, _) {
                    return SizedBox(
                      width: inputFieldsWidth,
                      child: OpenEatsJournalTextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final String text = newValue.text.trim();
                            if (text.isEmpty) {
                              return newValue;
                            }

                            num? doubleValue = convert.numberFomatterDouble1DecimalDigit.tryParse(text);
                            if (doubleValue != null) {
                              if (convert.decimalHasMoreThan1DecimalDigit(decimalstring: text)) {
                                return oldValue;
                              }

                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }),
                        ],
                        focusNode: _amountFocusNode,
                        onTap: () {
                          //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                          //effect.
                          if (!_amountFocusNode.hasFocus) {
                            _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                          }
                        },
                        onChanged: (value) {
                          double? doubleValue = convert.numberFomatterDouble1DecimalDigit.tryParse(value) as double?;
                          eatsJournalFoodEntryEditScreenViewModel.amount.value = doubleValue;

                          if (doubleValue != null) {
                            _amountController.text = convert.getCleanDoubleEditString1DecimalDigit(doubleValue: doubleValue, doubleValueString: value);
                          }
                        },
                      ),
                    );
                  },
                ),
                SizedBox(width: 5),
                Text("x"),
                SizedBox(width: 5),
                ValueListenableBuilder(
                  valueListenable: eatsJournalFoodEntryEditScreenViewModel.eatsAmount,
                  builder: (_, _, _) {
                    return SizedBox(
                      width: inputFieldsWidth,
                      child: OpenEatsJournalTextField(
                        controller: _eatsAmountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final String text = newValue.text.trim();
                            if (text.isEmpty) {
                              return newValue;
                            }

                            num? doubleValue = convert.numberFomatterDouble3DecimalDigits.tryParse(text);
                            if (doubleValue != null) {
                              if (convert.decimalHasMoreThan3DecimalDigits(decimalstring: text)) {
                                return oldValue;
                              }

                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }),
                        ],
                        focusNode: _eatsAmountFocusNode,
                        onTap: () {
                          //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                          //effect.
                          if (!_eatsAmountFocusNode.hasFocus) {
                            _eatsAmountController.selection = TextSelection(baseOffset: 0, extentOffset: _eatsAmountController.text.length);
                          }
                        },
                        onChanged: (value) {
                          double? doubleValue = convert.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                          eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = doubleValue;

                          if (doubleValue != null) {
                            _eatsAmountController.text = convert.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                          }
                        },
                      ),
                    );
                  },
                ),
                SizedBox(width: 5),
                RoundOutlinedButton(
                  onPressed: eatsJournalFoodEntryEditScreenViewModel.measurementSelectionEnabled
                      ? () {
                          if (eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram) {
                            eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.milliliter;
                          } else {
                            eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.gram;
                          }
                        }
                      : null,
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit,
                    builder: (_, _, _) {
                      return Text(
                        eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                            ? convert.getLocalizedWeightUnitGAbbreviated(context: context)
                            : convert.getLocalizedVolumeUnit2char(context: context),
                      );
                    },
                  ),
                ),
                Spacer(),
                RoundOutlinedButton(
                  onPressed: () async {
                    bool dataValid = true;

                    if (eatsJournalFoodEntryEditScreenViewModel.amount.value == null) {
                      dataValid = false;
                      SnackBar snackBar = SnackBar(
                        content: Text(AppLocalizations.of(context)!.enter_valid_amount),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.close,
                          onPressed: () {
                            //Click on SnackbarAction closes the SnackBar,
                            //nothing else to do here...
                          },
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    if (eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value == null) {
                      dataValid = false;
                      SnackBar snackBar = SnackBar(
                        content: Text(AppLocalizations.of(context)!.enter_valid_eats_amount),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.close,
                          onPressed: () {
                            //Click on SnackbarAction closes the SnackBar,
                            //nothing else to do here...
                          },
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    if (dataValid) {
                      int? originalFoodEntryId = eatsJournalFoodEntryEditScreenViewModel.foodEntry.id;
                      await eatsJournalFoodEntryEditScreenViewModel.setFoodEntry();

                      Navigator.pop(AppGlobal.navigatorKey.currentContext!, EntityEdited(originalId: originalFoodEntryId));
                    }
                  },
                  child: eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                      ? Icon(Icons.add_circle_outline, size: 36)
                      : Icon(Icons.save_alt, size: 30),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _getFoodUnitButtons(
                context: context,
                eatsJournalFoodEntryEditScreenViewModel: eatsJournalFoodEntryEditScreenViewModel,
                food: eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                textTheme: textTheme,
                convert: convert,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<OutlinedButton> _getFoodUnitButtons({
    required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodEntryEditScreenViewModel,
    required Food food,
    required TextTheme textTheme,
    required BuildContext context,
    required ConvertValidate convert,
  }) {
    String displayAmount;
    String amountInfo;
    List<OutlinedButton> buttons = [];
    if (food.defaultFoodUnit != null) {
      displayAmount = convert.getCleanDoubleString1DecimalDigit(
        doubleValue: food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram
            ? convert.getDisplayWeightG(weightG: food.defaultFoodUnit!.amount)
            : convert.getDisplayVolume(volumeMl: food.defaultFoodUnit!.amount),
      );

      amountInfo =
          "$displayAmount${food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram ? convert.getLocalizedWeightUnitGAbbreviated(context: context) : convert.getLocalizedVolumeUnitAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = convert.numberFomatterInt.format(food.defaultFoodUnit!.amount);
            eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
          },
          child: Column(
            children: [
              Text(
                "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _getKJouleFromFoodUnit(food, food.defaultFoodUnit!)))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                style: textTheme.titleSmall,
              ),
              Text("${food.defaultFoodUnit!.name} ($amountInfo)", style: textTheme.labelSmall),
            ],
          ),
        ),
      );
    }

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object != food.defaultFoodUnit) {
        displayAmount = convert.getCleanDoubleString1DecimalDigit(
          doubleValue: foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram
              ? convert.getDisplayWeightG(weightG: foodUnitWithOrder.object.amount)
              : convert.getDisplayVolume(volumeMl: foodUnitWithOrder.object.amount),
        );

        amountInfo =
            "$displayAmount${foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram ? convert.getLocalizedWeightUnitGAbbreviated(context: context) : convert.getLocalizedVolumeUnitAbbreviated(context: context)}";

        buttons.add(
          OutlinedButton(
            onPressed: () {
              _eatsAmountController.text = convert.numberFomatterInt.format(foodUnitWithOrder.object.amount);
              eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
            },
            child: Column(
              children: [
                Text(
                  "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _getKJouleFromFoodUnit(food, foodUnitWithOrder.object)))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                  style: textTheme.titleSmall,
                ),
                Text("${foodUnitWithOrder.object.name} ($amountInfo)", style: textTheme.labelSmall),
              ],
            ),
          ),
        );
      }
    }

    if (food.nutritionPerGramAmount != null) {
      displayAmount = convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: 100));
      amountInfo = "$displayAmount${convert.getLocalizedWeightUnitGAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = convert.numberFomatterInt.format(food.nutritionPerGramAmount);
            eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
          },
          child: Column(
            children: [
              Text(
                "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: (food.kJoule * (100 / food.nutritionPerGramAmount!))))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                style: textTheme.titleSmall,
              ),
              Text(amountInfo, style: textTheme.labelSmall),
            ],
          ),
        ),
      );
    }

    if (food.nutritionPerMilliliterAmount != null) {
      displayAmount = convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayVolume(volumeMl: 100));
      amountInfo = "$displayAmount${convert.getLocalizedVolumeUnitAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = convert.numberFomatterInt.format(food.nutritionPerMilliliterAmount);
            eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
          },
          child: Column(
            children: [
              Text(
                "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: (food.kJoule * (100 / food.nutritionPerMilliliterAmount!))))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                style: textTheme.titleSmall,
              ),
              Text(amountInfo, style: textTheme.labelSmall),
            ],
          ),
        ),
      );
    }

    return buttons;
  }

  double _getKJouleFromFoodUnit(Food food, FoodUnit foodUnit) {
    if (!List<FoodUnit>.from(food.foodUnitsWithOrder.map((source) => source.object)).contains(foodUnit)) {
      throw ArgumentError("Food doesn't contain given food unit.");
    }

    return (food.kJoule *
        (foodUnit.amount / (foodUnit.amountMeasurementUnit == MeasurementUnit.gram ? food.nutritionPerGramAmount! : food.nutritionPerMilliliterAmount!)));
  }

  Future<void> _selectDate({
    required BuildContext context,
    required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodEntryEditScreenViewModel,
    required DateTime initialDate,
  }) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _eatsAmountController.dispose();

    _amountFocusNode.dispose();
    _eatsAmountFocusNode.dispose();

    super.dispose();
  }
}

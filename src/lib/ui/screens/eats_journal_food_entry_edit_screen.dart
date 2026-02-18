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
import "package:openeatsjournal/ui/utils/layout_mode.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class EatsJournalFoodEntryEditScreen extends StatefulWidget {
  const EatsJournalFoodEntryEditScreen({super.key, required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodEntryEditScreenViewModel})
    : _eatsJournalFoodEntryEditScreenViewModel = eatsJournalFoodEntryEditScreenViewModel;

  final EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodEntryEditScreenViewModel;

  @override
  State<EatsJournalFoodEntryEditScreen> createState() => _EatsJournalFoodEntryEditScreenState();
}

class _EatsJournalFoodEntryEditScreenState extends State<EatsJournalFoodEntryEditScreen> with SingleTickerProviderStateMixin {
  late EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodEntryEditScreenViewModel;
  late AnimationController _animationController;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _eatsAmountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _eatsAmountFocusNode = FocusNode();

  @override
  void initState() {
    _eatsJournalFoodEntryEditScreenViewModel = widget._eatsJournalFoodEntryEditScreenViewModel;
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _amountController.text = _eatsJournalFoodEntryEditScreenViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalFoodEntryEditScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _eatsAmountController.text = _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value!)
        : OpenEatsJournalStrings.emptyString;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    double inputFieldsWidth = 110;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
      layoutMode: LayoutMode.intrinsicHeightFixedHeight,
      title: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
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
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.currentEntryDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        //for creating entries take value from setting, for editing entries take value from entry
                        DateTime initialDate = _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                            ? _eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value
                            : _eatsJournalFoodEntryEditScreenViewModel.foodEntry.entryDate;
                        await _selectDate(initialDate: initialDate, context: context);
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    //for creating entries take value from setting, for editing entries take value from entry
                    int initialSelection = _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                        ? _eatsJournalFoodEntryEditScreenViewModel.currentMeal.value.value
                        : _eatsJournalFoodEntryEditScreenViewModel.foodEntry.meal.value;

                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalFoodEntryEditScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
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
                      _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.name != OpenEatsJournalStrings.emptyString
                          ? _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.name
                          : AppLocalizations.of(context)!.no_name,
                    ),
                    Text(
                      style: textTheme.labelLarge,
                      _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.brands.isNotEmpty
                          ? _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.brands.join(", ")
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
                                  arguments: Food.copyAsNewUserFood(food: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!),
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
                      child: Text(AppLocalizations.of(context)!.as_new_food),
                    ),
                  );

                  if (_eatsJournalFoodEntryEditScreenViewModel.foodEntry.id != null) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () async {
                          EntityEdited? eatsJournalEntryEdited =
                              await Navigator.pushNamed(
                                    context,
                                    OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                                    arguments: EatsJournalEntry.fromFood(
                                      entryDate: _eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value,
                                      food: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                                      amount: _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value,
                                      amountMeasurementUnit: _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value,
                                      meal: _eatsJournalFoodEntryEditScreenViewModel.currentMeal.value,
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
                        child: Text(AppLocalizations.of(context)!.as_new_eats_journal_entry),
                      ),
                    );
                  }

                  if (_eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.foodSource == FoodSource.user) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () async {
                          EntityEdited? foodEdited =
                              await Navigator.pushNamed(
                                    context,
                                    OpenEatsJournalStrings.navigatorRouteFoodEdit,
                                    arguments: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
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
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.kJoule,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.kJoule.value != null
                        ? Text(
                            "${ConvertValidate.numberFomatterInt.format(_eatsJournalFoodEntryEditScreenViewModel.kJoule.value!)}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                            style: textTheme.titleMedium,
                          )
                        : Text(AppLocalizations.of(context)!.na_kcal);
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _eatsJournalFoodEntryEditScreenViewModel.amountRelvantChanged,
                  builder: (_, _) {
                    String amountTotalInfo;
                    if (_eatsJournalFoodEntryEditScreenViewModel.amount.value != null && _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null) {
                      amountTotalInfo = ConvertValidate.getCleanDoubleString3DecimalDigits(
                        doubleValue: _eatsJournalFoodEntryEditScreenViewModel.amount.value! * _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value!,
                      );
                    } else {
                      amountTotalInfo = AppLocalizations.of(context)!.na;
                    }

                    return Text(
                      "$amountTotalInfo ${_eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitG(context: context) : ConvertValidate.getLocalizedVolumeUnit(context: context)}",
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
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.carbohydrates,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.carbohydrates.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.carbohydrates.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                          );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.sugar.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.sugar.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.sugar}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.sugar}",
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
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.fat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.fat.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.fat.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                          );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.saturated_fat}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.saturated_fat}",
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
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.protein,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.protein.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.protein.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein}",
                          );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.salt,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.salt.value != null
                        ? Text(
                            "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.salt.value!)}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.salt}",
                          )
                        : Text(
                            "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.salt}",
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
                valueListenable: _eatsJournalFoodEntryEditScreenViewModel.amount,
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

                          num? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(text);
                          if (doubleValue != null) {
                            if (ConvertValidate.decimalHasMoreThan1DecimalDigit(decimalstring: text)) {
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
                        double? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(value) as double?;
                        _eatsJournalFoodEntryEditScreenViewModel.amount.value = doubleValue;

                        if (doubleValue != null) {
                          _amountController.text = ConvertValidate.getCleanDoubleEditString1DecimalDigit(doubleValue: doubleValue, doubleValueString: value);
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
                valueListenable: _eatsJournalFoodEntryEditScreenViewModel.eatsAmount,
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

                          num? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(text);
                          if (doubleValue != null) {
                            if (ConvertValidate.decimalHasMoreThan3DecimalDigits(decimalstring: text)) {
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
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = doubleValue;

                        if (doubleValue != null) {
                          _eatsAmountController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(
                            doubleValue: doubleValue,
                            doubleValueString: value,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: _eatsJournalFoodEntryEditScreenViewModel.measurementSelectionEnabled
                    ? () {
                        if (_eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram) {
                          _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.milliliter;
                        } else {
                          _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.gram;
                        }
                      }
                    : null,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit,
                  builder: (_, _, _) {
                    return Text(
                      _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                          ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)
                          : ConvertValidate.getLocalizedVolumeUnit2char(context: context),
                    );
                  },
                ),
              ),
              Spacer(),
              RoundOutlinedButton(
                onPressed: () async {
                  bool dataValid = true;

                  if (_eatsJournalFoodEntryEditScreenViewModel.amount.value == null) {
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

                  if (_eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value == null) {
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
                    int? originalFoodEntryId = _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id;
                    await _eatsJournalFoodEntryEditScreenViewModel.setFoodEntry();

                    Navigator.pop(AppGlobal.navigatorKey.currentContext!, EntityEdited(originalId: originalFoodEntryId));
                  }
                },
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                    ? Icon(Icons.add_circle_outline, size: 36)
                    : Icon(Icons.save_alt, size: 30),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _getFoodUnitButtons(food: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!, textTheme: textTheme, context: context),
              ),
            ),
          ),
          Divider(thickness: 2, height: 20),
          Text(
            "${AppLocalizations.of(context)!.per} ${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null ? _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount! : _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerMilliliterAmount!)}${_eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}",
            style: textTheme.labelSmall,
          ),
          SizedBox(height: 10),
          Text(
            "${ConvertValidate.numberFomatterInt.format(_eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.kJoule)}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
            style: textTheme.titleMedium,
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_carb(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_sugar(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_sugar(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.fat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_fat(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.fat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_saturated_fat(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_saturated_fat(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.protein != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_prot(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.protein!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_salt(
                          "${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_salt(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  List<OutlinedButton> _getFoodUnitButtons({required Food food, required TextTheme textTheme, required BuildContext context}) {
    String displayAmount;
    String amountInfo;
    List<OutlinedButton> buttons = [];
    if (food.defaultFoodUnit != null) {
      displayAmount = ConvertValidate.getCleanDoubleString1DecimalDigit(
        doubleValue: food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram
            ? ConvertValidate.getDisplayWeightG(weightG: food.defaultFoodUnit!.amount)
            : ConvertValidate.getDisplayVolume(volumeMl: food.defaultFoodUnit!.amount),
      );

      amountInfo =
          "$displayAmount${food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.defaultFoodUnit!.amount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
          },
          child: Column(
            children: [
              Text(
                "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _getKJouleFromFoodUnit(food, food.defaultFoodUnit!)))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
        displayAmount = ConvertValidate.getCleanDoubleString1DecimalDigit(
          doubleValue: foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram
              ? ConvertValidate.getDisplayWeightG(weightG: foodUnitWithOrder.object.amount)
              : ConvertValidate.getDisplayVolume(volumeMl: foodUnitWithOrder.object.amount),
        );

        amountInfo =
            "$displayAmount${foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";

        buttons.add(
          OutlinedButton(
            onPressed: () {
              _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(foodUnitWithOrder.object.amount);
              _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
            },
            child: Column(
              children: [
                Text(
                  "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _getKJouleFromFoodUnit(food, foodUnitWithOrder.object)))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
      displayAmount = ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayWeightG(weightG: 100));
      amountInfo = "$displayAmount${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.nutritionPerGramAmount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
          },
          child: Column(
            children: [
              Text(
                "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: (food.kJoule * (100 / food.nutritionPerGramAmount!))))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                style: textTheme.titleSmall,
              ),
              Text(amountInfo, style: textTheme.labelSmall),
            ],
          ),
        ),
      );
    }

    if (food.nutritionPerMilliliterAmount != null) {
      displayAmount = ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayVolume(volumeMl: 100));
      amountInfo = "$displayAmount${ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";

      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.nutritionPerMilliliterAmount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
          },
          child: Column(
            children: [
              Text(
                "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: (food.kJoule * (100 / food.nutritionPerMilliliterAmount!))))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      _eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._eatsJournalFoodEntryEditScreenViewModel.dispose();
    if (widget._eatsJournalFoodEntryEditScreenViewModel != _eatsJournalFoodEntryEditScreenViewModel) {
      _eatsJournalFoodEntryEditScreenViewModel.dispose();
    }

    _amountController.dispose();
    _eatsAmountController.dispose();

    _amountFocusNode.dispose();
    _eatsAmountFocusNode.dispose();

    super.dispose();
  }
}

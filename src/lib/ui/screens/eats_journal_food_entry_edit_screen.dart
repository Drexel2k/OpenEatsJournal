import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/layout_mode.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
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

class _EatsJournalFoodEntryEditScreenState extends State<EatsJournalFoodEntryEditScreen> {
  late EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodEntryEditScreenViewModel;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _eatsAmountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _eatsAmountFocusNode = FocusNode();

  @override
  void initState() {
    _eatsJournalFoodEntryEditScreenViewModel = widget._eatsJournalFoodEntryEditScreenViewModel;

    _amountController.text = _eatsJournalFoodEntryEditScreenViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalFoodEntryEditScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _eatsAmountController.text = _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value)
        : OpenEatsJournalStrings.emptyString;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          OpenEatsJournalStrings.navigatorRouteFoodEdit,
                          arguments: Food.copyAsNewUserFood(food: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.as_new_food),
                    ),
                  );

                  if (_eatsJournalFoodEntryEditScreenViewModel.foodEntry.id != null) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                            arguments: EatsJournalEntry.fromFood(
                              entryDate: _eatsJournalFoodEntryEditScreenViewModel.currentEntryDate.value,
                              food: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                              amount: _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value,
                              amountMeasurementUnit: _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value,
                              meal: _eatsJournalFoodEntryEditScreenViewModel.currentMeal.value,
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.as_new_eats_journal_entry),
                      ),
                    );
                  }

                  if (_eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.foodSource == FoodSource.user) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OpenEatsJournalStrings.navigatorRouteFoodEdit,
                            arguments: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!,
                          );
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
                            style: textTheme.titleMedium,
                            AppLocalizations.of(context)!.amount_kcal(
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalFoodEntryEditScreenViewModel.kJoule.value!),
                              ),
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.na_kcal);
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _eatsJournalFoodEntryEditScreenViewModel.amountRelvantChanged,
                  builder: (_, _) {
                    String amountTotal =
                        _eatsJournalFoodEntryEditScreenViewModel.amount.value != null && _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value != null
                        ? ConvertValidate.getCleanDoubleString(
                            doubleValue: _eatsJournalFoodEntryEditScreenViewModel.amount.value! * _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value!,
                          )
                        : AppLocalizations.of(context)!.na;

                    String amountInformation = _eatsJournalFoodEntryEditScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                        ? AppLocalizations.of(context)!.amount_gram(amountTotal)
                        : AppLocalizations.of(context)!.amount_milliliter(amountTotal);

                    return Text(amountInformation);
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
                            AppLocalizations.of(context)!.amount_carb(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.carbohydrates.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.sugar.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_sugar(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.sugar.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_sugar(AppLocalizations.of(context)!.na));
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
                            AppLocalizations.of(context)!.amount_fat(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.fat.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_saturated_fat(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.saturatedFat.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_saturated_fat(AppLocalizations.of(context)!.na));
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
                            AppLocalizations.of(context)!.amount_prot(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.protein.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.salt,
                  builder: (_, _, _) {
                    return _eatsJournalFoodEntryEditScreenViewModel.salt.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_salt(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.salt.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_salt(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.amount,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          if (text.isEmpty) {
                            return newValue;
                          }

                          num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(text);
                          if (doubleValue != null) {
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
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _eatsJournalFoodEntryEditScreenViewModel.amount.value = doubleValue;

                        if (doubleValue != null) {
                          _amountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: Align(alignment: AlignmentGeometry.center, child: Text("x")),
              ),
              Expanded(
                flex: 3,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodEntryEditScreenViewModel.eatsAmount,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _eatsAmountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          if (text.isEmpty) {
                            return newValue;
                          }

                          num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(text);
                          if (doubleValue != null) {
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
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = doubleValue;

                        if (doubleValue != null) {
                          _eatsAmountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: RoundOutlinedButton(
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
                            ? AppLocalizations.of(context)!.gram_abbreviated
                            : AppLocalizations.of(context)!.milliliter_abbreviated,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: OutlinedButton(
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
                      await _eatsJournalFoodEntryEditScreenViewModel.setFoodEntry();
                      Navigator.pop(AppGlobal.navigatorKey.currentContext!);
                    }
                  },
                  style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.id == null
                      ? Text(AppLocalizations.of(context)!.add)
                      : Text(AppLocalizations.of(context)!.update_abbreviated),
                ),
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
            style: textTheme.labelSmall,
            AppLocalizations.of(context)!.per_100_measurement_unit(
              _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null
                  ? MeasurementUnit.gram.text
                  : MeasurementUnit.milliliter.text,
            ),
          ),
          SizedBox(height: 10),
          Text(
            style: textTheme.titleMedium,
            AppLocalizations.of(context)!.amount_kcal(
              ConvertValidate.numberFomatterInt.format(
                NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.kJoule),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_carb(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.carbohydrates!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_sugar(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.sugar!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.fat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_saturated_fat(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.saturatedFat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.protein!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_salt(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodEntryEditScreenViewModel.foodEntry.food!.salt!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
    List<OutlinedButton> buttons = [];
    if (food.defaultFoodUnit != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.defaultFoodUnit!.amount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(context)!.amount_kcal(
                  ConvertValidate.numberFomatterInt.format(
                    NutritionCalculator.getKCalsFromKJoules(kJoules: _getKJouleFromFoodUnit(food, food.defaultFoodUnit!)),
                  ),
                ),
              ),
              Text(
                style: textTheme.labelSmall,
                "${food.defaultFoodUnit!.name} (${ConvertValidate.numberFomatterInt.format(food.defaultFoodUnit!.amount)}${food.defaultFoodUnit!.amountMeasurementUnit.text})",
              ),
            ],
          ),
        ),
      );
    }

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object != food.defaultFoodUnit) {
        buttons.add(
          OutlinedButton(
            onPressed: () {
              _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(foodUnitWithOrder.object.amount);
              _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
            },
            child: Column(
              children: [
                Text(
                  style: textTheme.titleSmall,
                  AppLocalizations.of(context)!.amount_kcal(
                    ConvertValidate.numberFomatterInt.format(
                      NutritionCalculator.getKCalsFromKJoules(kJoules: _getKJouleFromFoodUnit(food, foodUnitWithOrder.object)),
                    ),
                  ),
                ),
                Text(
                  style: textTheme.labelSmall,
                  "${foodUnitWithOrder.object.name} (${ConvertValidate.numberFomatterInt.format(foodUnitWithOrder.object.amount)}${foodUnitWithOrder.object.amountMeasurementUnit.text})",
                ),
              ],
            ),
          ),
        );
      }
    }

    if (food.nutritionPerGramAmount != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.nutritionPerGramAmount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(context)!.amount_kcal(
                  ConvertValidate.numberFomatterInt.format(
                    NutritionCalculator.getKCalsFromKJoules(kJoules: (food.kJoule * (100 / food.nutritionPerGramAmount!)).round()),
                  ),
                ),
              ),
              Text(style: textTheme.labelSmall, "${ConvertValidate.numberFomatterInt.format(100)}${MeasurementUnit.gram.text}"),
            ],
          ),
        ),
      );
    }

    if (food.nutritionPerMilliliterAmount != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(food.nutritionPerMilliliterAmount);
            _eatsJournalFoodEntryEditScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(context)!.amount_kcal(
                  ConvertValidate.numberFomatterInt.format(
                    NutritionCalculator.getKCalsFromKJoules(kJoules: (food.kJoule * (100 / food.nutritionPerMilliliterAmount!))),
                  ),
                ),
              ),
              Text(style: textTheme.labelSmall, "${ConvertValidate.numberFomatterInt.format(100)}${MeasurementUnit.milliliter.text}"),
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

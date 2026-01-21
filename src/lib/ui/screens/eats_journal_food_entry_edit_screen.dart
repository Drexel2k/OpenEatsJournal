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
  const EatsJournalFoodEntryEditScreen({super.key, required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodAddScreenViewModel})
    : _eatsJournalFoodAddScreenViewModel = eatsJournalFoodAddScreenViewModel;

  final EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodAddScreenViewModel;

  @override
  State<EatsJournalFoodEntryEditScreen> createState() => _EatsJournalFoodEntryEditScreenState();
}

class _EatsJournalFoodEntryEditScreenState extends State<EatsJournalFoodEntryEditScreen> {
  late EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodAddScreenViewModel;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _eatsAmountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _eatsAmountFocusNode = FocusNode();

  @override
  void initState() {
    _eatsJournalFoodAddScreenViewModel = widget._eatsJournalFoodAddScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _amountController.text = _eatsJournalFoodAddScreenViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalFoodAddScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _eatsAmountController.text = _eatsJournalFoodAddScreenViewModel.eatsAmount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalFoodAddScreenViewModel.eatsAmount.value)
        : OpenEatsJournalStrings.emptyString;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
      layoutMode: LayoutMode.intrinsicHeightFixedHeight,
      title: _eatsJournalFoodAddScreenViewModel.foodEntry.id == null
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.currentEntryDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        //for creating entries take value from setting, for editing entries take value from entry
                        DateTime initialDate = _eatsJournalFoodAddScreenViewModel.foodEntry.id == null
                            ? _eatsJournalFoodAddScreenViewModel.currentEntryDate.value
                            : _eatsJournalFoodAddScreenViewModel.foodEntry.entryDate;
                        await _selectDate(initialDate: initialDate, context: context);
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalFoodAddScreenViewModel.currentEntryDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    //for creating entries take value from setting, for editing entries take value from entry
                    int initialSelection = _eatsJournalFoodAddScreenViewModel.foodEntry.id == null
                        ? _eatsJournalFoodAddScreenViewModel.currentMeal.value.value
                        : _eatsJournalFoodAddScreenViewModel.foodEntry.meal.value;

                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalFoodAddScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
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
                      _eatsJournalFoodAddScreenViewModel.foodEntry.food!.name != OpenEatsJournalStrings.emptyString
                          ? _eatsJournalFoodAddScreenViewModel.foodEntry.food!.name
                          : AppLocalizations.of(context)!.no_name,
                    ),
                    Text(
                      style: textTheme.labelLarge,
                      _eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands.isNotEmpty
                          ? _eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands.join(", ")
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
                          arguments: Food.copyAsNewUserFood(food: _eatsJournalFoodAddScreenViewModel.foodEntry.food!),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.as_new_food),
                    ),
                  );

                  if (_eatsJournalFoodAddScreenViewModel.foodEntry.id != null) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
                            arguments: EatsJournalEntry.fromFood(
                              entryDate: _eatsJournalFoodAddScreenViewModel.currentEntryDate.value,
                              food: _eatsJournalFoodAddScreenViewModel.foodEntry.food!,
                              amount: _eatsJournalFoodAddScreenViewModel.eatsAmount.value,
                              amountMeasurementUnit: _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value,
                              meal: _eatsJournalFoodAddScreenViewModel.currentMeal.value,
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.as_new_eats_journal_entry),
                      ),
                    );
                  }

                  if (_eatsJournalFoodAddScreenViewModel.foodEntry.food!.foodSource == FoodSource.user) {
                    menuItems.add(
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OpenEatsJournalStrings.navigatorRouteFoodEdit,
                            arguments: _eatsJournalFoodAddScreenViewModel.foodEntry.food!,
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.kJoule,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.kJoule.value != null
                        ? Text(
                            style: textTheme.titleMedium,
                            AppLocalizations.of(context)!.amount_kcal(
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalFoodAddScreenViewModel.kJoule.value!),
                              ),
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.na_kcal);
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _eatsJournalFoodAddScreenViewModel.amountRelvantChanged,
                  builder: (_, _) {
                    String amountTotal = _eatsJournalFoodAddScreenViewModel.amount.value != null && _eatsJournalFoodAddScreenViewModel.eatsAmount.value != null
                        ? ConvertValidate.getCleanDoubleString(
                            doubleValue: _eatsJournalFoodAddScreenViewModel.amount.value! * _eatsJournalFoodAddScreenViewModel.eatsAmount.value!,
                          )
                        : AppLocalizations.of(context)!.na;

                    String amountInformation = _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.carbohydrates,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.carbohydrates.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_carb(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.carbohydrates.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.sugar.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_sugar(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.sugar.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.fat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.fat.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_fat(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.fat.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.saturatedFat.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_saturated_fat(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.saturatedFat.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.protein,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.protein.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_prot(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.protein.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.salt,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.salt.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_salt(
                              "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.salt.value!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.amount,
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
                        _eatsJournalFoodAddScreenViewModel.amount.value = doubleValue;

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
                  valueListenable: _eatsJournalFoodAddScreenViewModel.eatsAmount,
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
                        _eatsJournalFoodAddScreenViewModel.eatsAmount.value = doubleValue;

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
                  onPressed: _eatsJournalFoodAddScreenViewModel.measurementSelectionEnabled
                      ? () {
                          if (_eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram) {
                            _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.milliliter;
                          } else {
                            _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.gram;
                          }
                        }
                      : null,
                  child: ValueListenableBuilder(
                    valueListenable: _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit,
                    builder: (_, _, _) {
                      return Text(
                        _eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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

                    if (_eatsJournalFoodAddScreenViewModel.amount.value == null) {
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

                    if (_eatsJournalFoodAddScreenViewModel.eatsAmount.value == null) {
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
                      await _eatsJournalFoodAddScreenViewModel.setFoodEntry();
                      Navigator.pop(AppGlobal.navigatorKey.currentContext!);
                    }
                  },
                  style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: _eatsJournalFoodAddScreenViewModel.foodEntry.id == null
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
                children: _getFoodUnitButtons(food: _eatsJournalFoodAddScreenViewModel.foodEntry.food!, textTheme: textTheme, context: context),
              ),
            ),
          ),
          Divider(thickness: 2, height: 20),
          Text(
            style: textTheme.labelSmall,
            AppLocalizations.of(context)!.per_100_measurement_unit(
              _eatsJournalFoodAddScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null ? MeasurementUnit.gram.text : MeasurementUnit.milliliter.text,
            ),
          ),
          SizedBox(height: 10),
          Text(
            style: textTheme.titleMedium,
            AppLocalizations.of(context)!.amount_kcal(
              ConvertValidate.numberFomatterInt.format(
                NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.kJoule),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.carbohydrates != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_carb(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.carbohydrates!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_sugar(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_sugar(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_fat(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_saturated_fat(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_saturated_fat(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_prot(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein!)}${AppLocalizations.of(context)!.gram_abbreviated}",
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_salt(
                          "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt!)}${AppLocalizations.of(context)!.gram_abbreviated}",
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
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
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
              _eatsJournalFoodAddScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
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
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
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
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
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
      _eatsJournalFoodAddScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._eatsJournalFoodAddScreenViewModel.dispose();
    if (widget._eatsJournalFoodAddScreenViewModel != _eatsJournalFoodAddScreenViewModel) {
      _eatsJournalFoodAddScreenViewModel.dispose();
    }

    _amountController.dispose();
    _eatsAmountController.dispose();

    _amountFocusNode.dispose();
    _eatsAmountFocusNode.dispose();

    super.dispose();
  }
}

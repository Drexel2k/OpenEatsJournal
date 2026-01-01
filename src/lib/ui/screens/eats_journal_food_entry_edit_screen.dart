import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/global_navigator_key.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen_viewmodel.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/utils/localized_drop_down_entries.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class EatsJournalFoodEntryEditScreen extends StatelessWidget {
  EatsJournalFoodEntryEditScreen({super.key, required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodAddScreenViewModel})
    : _eatsJournalFoodAddScreenViewModel = eatsJournalFoodAddScreenViewModel,
      _amountController = TextEditingController(),
      _eatsAmountController = TextEditingController();

  final EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodAddScreenViewModel;
  final TextEditingController _amountController;
  final TextEditingController _eatsAmountController;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _amountController.text = ConvertValidate.numberFomatterInt.format(_eatsJournalFoodAddScreenViewModel.amount.value);
    _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(_eatsJournalFoodAddScreenViewModel.eatsAmount.value);

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
      title: AppLocalizations.of(context)!.add_eats_journal_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        await _selectDate(initialDate: _eatsJournalFoodAddScreenViewModel.currentJournalDate.value, context: context);
                      },
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalFoodAddScreenViewModel.currentJournalDate.value),
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
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalFoodAddScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: _eatsJournalFoodAddScreenViewModel.currentMeal.value.value,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            softWrap: true,
            style: textTheme.headlineSmall,
            _eatsJournalFoodAddScreenViewModel.foodEntry.food!.name != OpenEatsJournalStrings.emptyString
                ? _eatsJournalFoodAddScreenViewModel.foodEntry.food!.name
                : AppLocalizations.of(context)!.no_name,
          ),
          Text(
            style: textTheme.labelLarge,
            _eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands != null
                ? _eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands!.join(", ")
                : AppLocalizations.of(context)!.no_brand,
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
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

          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.carbohydrates,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.carbohydrates.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_carb(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.carbohydrates.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_carb);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.sugar.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_sugar(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.sugar.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_sugar);
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
                            AppLocalizations.of(
                              context,
                            )!.amount_fat(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.fat.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_fat);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.saturatedFat.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_saturated_fat(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.saturatedFat.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_saturated_fat);
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
                            AppLocalizations.of(
                              context,
                            )!.amount_prot(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.protein.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_prot);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.salt,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.salt.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_salt(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.salt.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.na_salt);
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
                      Navigator.pop(navigatorKey.currentContext!);
                    }
                  },
                  child: _eatsJournalFoodAddScreenViewModel.foodEntryId == null
                      ? Text(AppLocalizations.of(context)!.add)
                      : Text(AppLocalizations.of(context)!.update),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getFoodUnitButtons(food: _eatsJournalFoodAddScreenViewModel.foodEntry.food!, textTheme: textTheme, context: context),
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
                        AppLocalizations.of(
                          context,
                        )!.amount_carb(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.carbohydrates!)),
                      )
                    : Text(AppLocalizations.of(context)!.na_carb),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_sugar(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar!)),
                      )
                    : Text(AppLocalizations.of(context)!.na_sugar),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_fat(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat!)),
                      )
                    : Text(AppLocalizations.of(context)!.na_fat),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_saturated_fat(
                          ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat!),
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.na_saturated_fat),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_prot(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein!)),
                      )
                    : Text(AppLocalizations.of(context)!.na_prot),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_salt(ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt!)),
                      )
                    : Text(AppLocalizations.of(context)!.na_salt),
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
      _eatsJournalFoodAddScreenViewModel.currentJournalDate.value = date;
    }
  }
}

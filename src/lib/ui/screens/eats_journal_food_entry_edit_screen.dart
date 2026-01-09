import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/app_global.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen_viewmodel.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/utils/localized_drop_down_entries.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class EatsJournalFoodEntryEditScreen extends StatefulWidget {
  const EatsJournalFoodEntryEditScreen({super.key, required EatsJournalFoodEntryEditScreenViewModel eatsJournalFoodAddScreenViewModel})
    : _eatsJournalFoodAddScreenViewModel = eatsJournalFoodAddScreenViewModel;

  final EatsJournalFoodEntryEditScreenViewModel _eatsJournalFoodAddScreenViewModel;

  @override
  State<EatsJournalFoodEntryEditScreen> createState() => _EatsJournalFoodEntryEditScreenState();
}

class _EatsJournalFoodEntryEditScreenState extends State<EatsJournalFoodEntryEditScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _eatsAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _amountController.text = ConvertValidate.numberFomatterInt.format(widget._eatsJournalFoodAddScreenViewModel.amount.value);
    _eatsAmountController.text = ConvertValidate.numberFomatterInt.format(widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value);

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEntryEdit,
      title: widget._eatsJournalFoodAddScreenViewModel.foodEntryId == null
          ? AppLocalizations.of(context)!.add_eats_journal_entry
          : AppLocalizations.of(context)!.edit_eats_journal_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        await _selectDate(initialDate: widget._eatsJournalFoodAddScreenViewModel.currentJournalDate.value, context: context);
                      },
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._eatsJournalFoodAddScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        widget._eatsJournalFoodAddScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: widget._eatsJournalFoodAddScreenViewModel.currentMeal.value.value,
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
            widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.name != OpenEatsJournalStrings.emptyString
                ? widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.name
                : AppLocalizations.of(context)!.no_name,
          ),
          Text(
            style: textTheme.labelLarge,
            widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands != null
                ? widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.brands!.join(", ")
                : AppLocalizations.of(context)!.no_brand,
          ),
          SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.kJoule,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.kJoule.value != null
                        ? Text(
                            style: textTheme.titleMedium,
                            AppLocalizations.of(context)!.amount_kcal(
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(kJoules: widget._eatsJournalFoodAddScreenViewModel.kJoule.value!),
                              ),
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.na_kcal);
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget._eatsJournalFoodAddScreenViewModel.amountRelvantChanged,
                  builder: (_, _) {
                    String amountTotal =
                        widget._eatsJournalFoodAddScreenViewModel.amount.value != null && widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value != null
                        ? ConvertValidate.getCleanDoubleString(
                            doubleValue: widget._eatsJournalFoodAddScreenViewModel.amount.value! * widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value!,
                          )
                        : AppLocalizations.of(context)!.na;

                    String amountInformation = widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.carbohydrates,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.carbohydrates.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_carb(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.carbohydrates.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.sugar.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_sugar(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.sugar.value!)),
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
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.fat,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.fat.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_fat(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.fat.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.saturatedFat.value != null
                        ? Text(
                            AppLocalizations.of(context)!.amount_saturated_fat(
                              ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.saturatedFat.value!),
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
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.protein,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.protein.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_prot(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.protein.value!)),
                          )
                        : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na));
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.salt,
                  builder: (_, _, _) {
                    return widget._eatsJournalFoodAddScreenViewModel.salt.value != null
                        ? Text(
                            AppLocalizations.of(
                              context,
                            )!.amount_salt(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.salt.value!)),
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
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.amount,
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
                      onTap: () {
                        _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalFoodAddScreenViewModel.amount.value = doubleValue;

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
                  valueListenable: widget._eatsJournalFoodAddScreenViewModel.eatsAmount,
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
                      onTap: () {
                        _eatsAmountController.selection = TextSelection(baseOffset: 0, extentOffset: _eatsAmountController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value = doubleValue;

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
                  onPressed: widget._eatsJournalFoodAddScreenViewModel.measurementSelectionEnabled
                      ? () {
                          if (widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram) {
                            widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.milliliter;
                          } else {
                            widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value = MeasurementUnit.gram;
                          }
                        }
                      : null,
                  child: ValueListenableBuilder(
                    valueListenable: widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit,
                    builder: (_, _, _) {
                      return Text(
                        widget._eatsJournalFoodAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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

                    if (widget._eatsJournalFoodAddScreenViewModel.amount.value == null) {
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

                    if (widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value == null) {
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
                      await widget._eatsJournalFoodAddScreenViewModel.setFoodEntry();
                      Navigator.pop(AppGlobal.navigatorKey.currentContext!);
                    }
                  },
                  child: widget._eatsJournalFoodAddScreenViewModel.foodEntryId == null
                      ? Text(AppLocalizations.of(context)!.add)
                      : Text(AppLocalizations.of(context)!.update),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getFoodUnitButtons(food: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!, textTheme: textTheme, context: context),
            ),
          ),
          Divider(thickness: 2, height: 20),
          Text(
            style: textTheme.labelSmall,
            AppLocalizations.of(context)!.per_100_measurement_unit(
              widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.nutritionPerGramAmount != null
                  ? MeasurementUnit.gram.text
                  : MeasurementUnit.milliliter.text,
            ),
          ),
          SizedBox(height: 10),
          Text(
            style: textTheme.titleMedium,
            AppLocalizations.of(context)!.amount_kcal(
              ConvertValidate.numberFomatterInt.format(
                NutritionCalculator.getKCalsFromKJoules(kJoules: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.kJoule),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.carbohydrates != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_carb(
                          ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.carbohydrates!),
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_sugar(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.sugar!)),
                      )
                    : Text(AppLocalizations.of(context)!.amount_sugar(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_fat(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.fat!)),
                      )
                    : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat != null
                    ? Text(
                        AppLocalizations.of(context)!.amount_saturated_fat(
                          ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.saturatedFat!),
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.amount_saturated_fat(AppLocalizations.of(context)!.na)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_prot(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.protein!)),
                      )
                    : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na)),
              ),
              Expanded(
                child: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt != null
                    ? Text(
                        AppLocalizations.of(
                          context,
                        )!.amount_salt(ConvertValidate.getCleanDoubleString(doubleValue: widget._eatsJournalFoodAddScreenViewModel.foodEntry.food!.salt!)),
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
            widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
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
              widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
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
            widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
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
            widget._eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
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
      widget._eatsJournalFoodAddScreenViewModel.currentJournalDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._eatsJournalFoodAddScreenViewModel.dispose();
    _amountController.dispose();
    _eatsAmountController.dispose();

    super.dispose();
  }
}

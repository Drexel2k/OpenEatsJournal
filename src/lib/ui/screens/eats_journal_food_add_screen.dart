import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/global_navigator_key.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/ui/screens/eats_journal_food_add_screen_viewmodel.dart';
import 'package:openeatsjournal/ui/utils/error_handlers.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class EatsJournalFoodAddScreen extends StatelessWidget {
  EatsJournalFoodAddScreen({super.key, required EatsJournalFoodAddScreenViewModel eatsJournalFoodAddScreenViewModel})
    : _eatsJournalFoodAddScreenViewModel = eatsJournalFoodAddScreenViewModel,
      _amountController = TextEditingController(),
      _eatsAmountController = TextEditingController();

  final EatsJournalFoodAddScreenViewModel _eatsJournalFoodAddScreenViewModel;
  final TextEditingController _amountController;
  final TextEditingController _eatsAmountController;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final NumberFormat numberFormatter = NumberFormat(null, languageCode);

    _amountController.text = numberFormatter.format(_eatsJournalFoodAddScreenViewModel.amount.value);
    _eatsAmountController.text = numberFormatter.format(_eatsJournalFoodAddScreenViewModel.eatsAmount.value);

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteEatsAdd,
      title: AppLocalizations.of(context)!.add_eats_journal_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            softWrap: true,
            style: textTheme.headlineSmall,
            _eatsJournalFoodAddScreenViewModel.food.name != OpenEatsJournalStrings.emptyString
                ? _eatsJournalFoodAddScreenViewModel.food.name
                : AppLocalizations.of(context)!.no_name,
          ),
          Text(
            style: textTheme.labelLarge,
            _eatsJournalFoodAddScreenViewModel.food.brands != null ? _eatsJournalFoodAddScreenViewModel.food.brands!.join(", ") : AppLocalizations.of(context)!.no_brand,
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: _eatsJournalFoodAddScreenViewModel.kJoule,
            builder: (_, _, _) {
              return _eatsJournalFoodAddScreenViewModel.kJoule.value != null
                  ? Text(
                      style: textTheme.titleMedium,
                      AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_eatsJournalFoodAddScreenViewModel.kJoule.value!)),
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
                        ? Text(AppLocalizations.of(context)!.amount_carb(_eatsJournalFoodAddScreenViewModel.carbohydrates.value!))
                        : Text(AppLocalizations.of(context)!.na_carb);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.sugar.value != null
                        ? Text(AppLocalizations.of(context)!.amount_sugar(_eatsJournalFoodAddScreenViewModel.sugar.value!))
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
                        ? Text(AppLocalizations.of(context)!.amount_fat(_eatsJournalFoodAddScreenViewModel.fat.value!))
                        : Text(AppLocalizations.of(context)!.na_fat);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.saturatedFat.value != null
                        ? Text(AppLocalizations.of(context)!.amount_saturated_fat(_eatsJournalFoodAddScreenViewModel.saturatedFat.value!))
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
                        ? Text(AppLocalizations.of(context)!.amount_prot(_eatsJournalFoodAddScreenViewModel.protein.value!))
                        : Text(AppLocalizations.of(context)!.na_prot);
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.salt,
                  builder: (_, _, _) {
                    return _eatsJournalFoodAddScreenViewModel.salt.value != null
                        ? Text(AppLocalizations.of(context)!.amount_salt(_eatsJournalFoodAddScreenViewModel.salt.value!))
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
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.amount,
                  builder: (_, _, _) {
                    return TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        _eatsJournalFoodAddScreenViewModel.amount.value = intValue;
                        if (intValue != null) {
                          {
                            _amountController.text = numberFormatter.format(intValue);
                          }
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
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalFoodAddScreenViewModel.eatsAmount,
                  builder: (_, _, _) {
                    return TextField(
                      controller: _eatsAmountController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        _eatsJournalFoodAddScreenViewModel.eatsAmount.value = intValue;
                        if (intValue != null) {
                          {
                            _eatsAmountController.text = numberFormatter.format(intValue);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: RoundOutlinedButton(
                  onPressed: _eatsJournalFoodAddScreenViewModel.measurementSelectionEnabled
                      ? () {
                          if (_eatsJournalFoodAddScreenViewModel.currentMesaureMentUnit.value == MeasurementUnit.gram) {
                            _eatsJournalFoodAddScreenViewModel.currentMesaureMentUnit.value = MeasurementUnit.milliliter;
                          } else {
                            _eatsJournalFoodAddScreenViewModel.currentMesaureMentUnit.value = MeasurementUnit.gram;
                          }
                        }
                      : null,
                  child: ValueListenableBuilder(
                    valueListenable: _eatsJournalFoodAddScreenViewModel.salt,
                    builder: (_, _, _) {
                      return Text(_eatsJournalFoodAddScreenViewModel.currentMesaureMentUnit.value.text);
                    },
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
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
                        await _eatsJournalFoodAddScreenViewModel.addEatsJournalEntry();
                      }
                    } on Exception catch (exc, stack) {
                      await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                    } on Error catch (error, stack) {
                      await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                    }
                  },
                  child: Text("Add"),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getFoodUnitButtons(food: _eatsJournalFoodAddScreenViewModel.food, textTheme: textTheme, context: context, numberFormatter: numberFormatter),
            ),
          ),
          Divider(thickness: 2, height: 20),
          Text(
            style: textTheme.labelSmall,
            AppLocalizations.of(context)!.per_100_measurement_unit(
              _eatsJournalFoodAddScreenViewModel.food.nutritionPerGramAmount != null ? MeasurementUnit.gram.text : MeasurementUnit.milliliter.text,
            ),
          ),
          SizedBox(height: 10),
          Text(
            style: textTheme.titleMedium,
            AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_eatsJournalFoodAddScreenViewModel.food.kJoule)),
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.carbohydrates != null
                    ? Text(AppLocalizations.of(context)!.amount_carb(_eatsJournalFoodAddScreenViewModel.food.carbohydrates!))
                    : Text(AppLocalizations.of(context)!.na_carb),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.sugar != null
                    ? Text(AppLocalizations.of(context)!.amount_sugar(_eatsJournalFoodAddScreenViewModel.food.sugar!))
                    : Text(AppLocalizations.of(context)!.na_sugar),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.fat != null
                    ? Text(AppLocalizations.of(context)!.amount_fat(_eatsJournalFoodAddScreenViewModel.food.fat!))
                    : Text(AppLocalizations.of(context)!.na_fat),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.saturatedFat != null
                    ? Text(AppLocalizations.of(context)!.amount_saturated_fat(_eatsJournalFoodAddScreenViewModel.food.saturatedFat!))
                    : Text(AppLocalizations.of(context)!.na_saturated_fat),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.protein != null
                    ? Text(AppLocalizations.of(context)!.amount_prot(_eatsJournalFoodAddScreenViewModel.food.protein!))
                    : Text(AppLocalizations.of(context)!.na_prot),
              ),
              Expanded(
                child: _eatsJournalFoodAddScreenViewModel.food.salt != null
                    ? Text(AppLocalizations.of(context)!.amount_salt(_eatsJournalFoodAddScreenViewModel.food.salt!))
                    : Text(AppLocalizations.of(context)!.na_salt),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  List<OutlinedButton> _getFoodUnitButtons({
    required Food food,
    required TextTheme textTheme,
    required BuildContext context,
    required NumberFormat numberFormatter,
  }) {
    List<OutlinedButton> buttons = [];
    if (food.defaultFoodUnit != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = numberFormatter.format(food.defaultFoodUnit!.amount);
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.defaultFoodUnit!.amount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_getKJouleFromFoodUnit(food, food.defaultFoodUnit!))),
              ),
              Text(
                style: textTheme.labelSmall,
                "${food.defaultFoodUnit!.name} (${numberFormatter.format(food.defaultFoodUnit!.amount)}${food.defaultFoodUnit!.amountMeasurementUnit.text})",
              ),
            ],
          ),
        ),
      );
    }

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnits) {
      if (foodUnitWithOrder.object != food.defaultFoodUnit) {
        buttons.add(
          OutlinedButton(
            onPressed: () {
              _eatsAmountController.text = numberFormatter.format(foodUnitWithOrder.object.amount);
              _eatsJournalFoodAddScreenViewModel.eatsAmount.value = foodUnitWithOrder.object.amount;
            },
            child: Column(
              children: [
                Text(
                  style: textTheme.titleSmall,
                  AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_getKJouleFromFoodUnit(food, foodUnitWithOrder.object))),
                ),
                Text(
                  style: textTheme.labelSmall,
                  "${foodUnitWithOrder.object.name} (${numberFormatter.format(foodUnitWithOrder.object.amount)}${foodUnitWithOrder.object.amountMeasurementUnit.text})",
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
            _eatsAmountController.text = numberFormatter.format(food.nutritionPerGramAmount);
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerGramAmount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(
                  context,
                )!.amount_kcal(NutritionCalculator.getKCalsFromKJoules((food.kJoule * (100 / food.nutritionPerGramAmount!)).round())),
              ),
              Text(style: textTheme.labelSmall, "${numberFormatter.format(100)}${MeasurementUnit.gram.text}"),
            ],
          ),
        ),
      );
    }

    if (food.nutritionPerMilliliterAmount != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            _eatsAmountController.text = numberFormatter.format(food.nutritionPerMilliliterAmount);
            _eatsJournalFoodAddScreenViewModel.eatsAmount.value = food.nutritionPerMilliliterAmount;
          },
          child: Column(
            children: [
              Text(
                style: textTheme.titleSmall,
                AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules((food.kJoule * (100 / food.nutritionPerMilliliterAmount!)))),
              ),
              Text(style: textTheme.labelSmall, "${numberFormatter.format(100)}${MeasurementUnit.milliliter.text}"),
            ],
          ),
        ),
      );
    }

    return buttons;
  }

  double _getKJouleFromFoodUnit(Food food, FoodUnit foodUnit) {
    if (!List<FoodUnit>.from(food.foodUnits.map((source) => source.object)).contains(foodUnit)) {
      throw ArgumentError("Food doesn't contain given food unit.");
    }

    return (food.kJoule *
        (foodUnit.amount / (foodUnit.amountMeasurementUnit == MeasurementUnit.gram ? food.nutritionPerGramAmount! : food.nutritionPerMilliliterAmount!)));
  }
}

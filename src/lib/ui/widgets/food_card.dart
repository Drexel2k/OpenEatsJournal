import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/utils/food_source_format.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required Food food,
    required TextTheme textTheme,
    required void Function({required Food food}) onCardTap,
    required Future<void> Function({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) onAddJournalEntryPressed,
  }) : _textTheme = textTheme,
       _food = food,
       _onCardTap = onCardTap,
       _onAddJournalEntryPressed = onAddJournalEntryPressed;

  final TextTheme _textTheme;
  final Food _food;
  final void Function({required Food food}) _onCardTap;
  final Future<void> Function({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) _onAddJournalEntryPressed;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    MeasurementUnit measurementUnit = _getMeasurementUnit();
    String foodSourceLabel = FoodSourceFormat.getFoodSourceLabel(food: _food, context: context);
    Color foodSourceColor = FoodSourceFormat.getFoodSourceColor(food: _food, context: context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          _onCardTap(food: _food);
        },
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          softWrap: true,
                          style: _textTheme.headlineSmall,
                          _food.name != OpenEatsJournalStrings.emptyString ? _food.name : AppLocalizations.of(context)!.no_name,
                        ),
                        Text(style: _textTheme.labelLarge, _food.brands != null ? _food.brands!.join(", ") : AppLocalizations.of(context)!.no_brand),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                    child: Badge(label: Text(foodSourceLabel), backgroundColor: foodSourceColor),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (selected) {},
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuItem<String>> menuItems = [];

                      menuItems.add(
                        PopupMenuItem(
                          onTap: () {
                            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: Food.asUserFood(food: _food));
                          },
                          child: Text(AppLocalizations.of(context)!.as_new_food),
                        ),
                      );

                      if (_food.foodSource == FoodSource.user) {
                        menuItems.add(
                          PopupMenuItem(
                            onTap: () {
                              Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: _food);
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
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style: _textTheme.titleMedium,
                          AppLocalizations.of(
                            context,
                          )!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: _food.kJoule))),
                        ),
                        Text(
                          style: _textTheme.labelSmall,
                          AppLocalizations.of(
                            context,
                          )!.per_100_measurement_unit(_food.nutritionPerGramAmount != null ? MeasurementUnit.gram.text : MeasurementUnit.milliliter.text),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 77,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _food.carbohydrates != null
                            ? Text(AppLocalizations.of(context)!.amount_carb(ConvertValidate.getCleanDoubleString(doubleValue: _food.carbohydrates!)))
                            : Text(AppLocalizations.of(context)!.amount_carb(AppLocalizations.of(context)!.na)),
                        _food.fat != null
                            ? Text(AppLocalizations.of(context)!.amount_fat(ConvertValidate.getCleanDoubleString(doubleValue: _food.fat!)))
                            : Text(AppLocalizations.of(context)!.amount_fat(AppLocalizations.of(context)!.na)),
                        _food.protein != null
                            ? Text(AppLocalizations.of(context)!.amount_prot(ConvertValidate.getCleanDoubleString(doubleValue: _food.protein!)))
                            : Text(AppLocalizations.of(context)!.amount_prot(AppLocalizations.of(context)!.na)),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 145,
                    child: OutlinedButton(
                      onPressed: () {
                        _onAddJournalEntryPressed(
                          food: _food,
                          amount: _food.defaultFoodUnit != null ? _food.defaultFoodUnit!.amount : 100,
                          amountMeasurementUnit: _getMeasurementUnit(),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            style: _textTheme.titleSmall,
                            "+${AppLocalizations.of(context)!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: _getKJoulesToAdd())))}",
                          ),
                          Text(
                            style: _textTheme.labelSmall,
                            _getKJoulesToAddText(measurementUnit: measurementUnit, context: context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getKJoulesToAddText({required MeasurementUnit measurementUnit, required BuildContext context}) {
    String kJoulsAddName = AppLocalizations.of(context)!.hundred_measurement_unit(measurementUnit.text);

    if (_food.defaultFoodUnit != null) {
      kJoulsAddName = "${_food.defaultFoodUnit!.name} (${ConvertValidate.numberFomatterInt.format(_food.defaultFoodUnit!.amount)}${measurementUnit.text})";
    }
    return kJoulsAddName;
  }

  MeasurementUnit _getMeasurementUnit() {
    if (_food.defaultFoodUnit != null) {
      return _food.defaultFoodUnit!.amountMeasurementUnit;
    } else {
      if (_food.nutritionPerGramAmount != null) {
        return MeasurementUnit.gram;
      } else {
        return MeasurementUnit.milliliter;
      }
    }
  }

  int _getKJoulesToAdd() {
    if (_food.defaultFoodUnit != null) {
      if (_food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return (_food.kJoule * (_food.defaultFoodUnit!.amount / _food.nutritionPerGramAmount!)).round();
      } else {
        return (_food.kJoule * (_food.defaultFoodUnit!.amount / _food.nutritionPerMilliliterAmount!)).round();
      }
    } else {
      if (_food.nutritionPerGramAmount != null) {
        return (_food.kJoule * (100 / _food.nutritionPerGramAmount!)).round();
      } else {
        return (_food.kJoule * (100 / _food.nutritionPerMilliliterAmount!)).round();
      }
    }
  }
}

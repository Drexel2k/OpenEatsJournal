import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_strings.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required Food food,
    required TextTheme textTheme,
    required void Function(Food) onCardTap,
    required void Function(Food, int, MeasurementUnit) onAddJournalEntryPressed,
  }) : _textTheme = textTheme,
       _food = food,
       _onCardTap = onCardTap,
       _onAddJournalEntryPressed = onAddJournalEntryPressed;

  final TextTheme _textTheme;
  final Food _food;
  final void Function(Food) _onCardTap;
  final void Function(Food, int, MeasurementUnit) _onAddJournalEntryPressed;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final NumberFormat numberFormatter = NumberFormat(null, languageCode);
    final borderRadius = BorderRadius.circular(8);

    MeasurementUnit measurementUnit = _getMeasurementUnit();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          _onCardTap(_food);
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
                    child: Badge(label: Text("OFF")),
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
                        Text(style: _textTheme.titleMedium, AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_food.kJoule))),
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
                            ? Text(AppLocalizations.of(context)!.amount_carb(_food.carbohydrates!))
                            : Text(AppLocalizations.of(context)!.na_carb),
                        _food.fat != null ? Text(AppLocalizations.of(context)!.amount_fat(_food.fat!)) : Text(AppLocalizations.of(context)!.na_fat),
                        _food.protein != null ? Text(AppLocalizations.of(context)!.amount_prot(_food.protein!)) : Text(AppLocalizations.of(context)!.na_prot),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 145,
                    child: OutlinedButton(
                      onPressed: () {
                        _onAddJournalEntryPressed(_food, _food.defaultFoodUnit != null ? _food.defaultFoodUnit!.amount : 100, _getMeasurementUnit());
                      },
                      child: Column(
                        children: [
                          Text(
                            style: _textTheme.titleSmall,
                            "+${AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_getKJoulesToAdd()))}",
                          ),
                          Text(
                            style: _textTheme.labelSmall,
                            _getKJoulesToAddText(measurementUnit: measurementUnit, context: context, formatter: numberFormatter),
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

  String _getKJoulesToAddText({required MeasurementUnit measurementUnit, required BuildContext context, required NumberFormat formatter}) {
    String kJoulsAddName = AppLocalizations.of(context)!.hundred_measurement_unit(measurementUnit.text);

    if (_food.defaultFoodUnit != null) {
      kJoulsAddName = "${_food.defaultFoodUnit!.name} (${formatter.format(_food.defaultFoodUnit!.amount)}${measurementUnit.text})";
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

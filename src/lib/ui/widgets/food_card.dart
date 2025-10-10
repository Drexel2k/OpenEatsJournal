import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_strings.dart';

class FoodCard extends StatelessWidget {
  FoodCard({
    super.key,
    required Food food,
    required TextTheme textTheme,
    required GestureTapCallback onCardTap,
    required void Function(Food, int, MeasurementUnit) onAddJournalEntryPressed,
  }) : _textTheme = textTheme,
       _food = food,
       _onCardTap = onCardTap,
       _onAddJournalEntryPressed = onAddJournalEntryPressed,
       _measurementUnit = food.nutritionPerGramAmount != null ? MeasurementUnit.gram : MeasurementUnit.milliliter,
       _kJoulesAdd = food.defaultFoodUnit != null ? (food.energyKj * ((food.defaultFoodUnit!.amount / 100))).round() : food.energyKj;
      
  final TextTheme _textTheme;
  final Food _food;
  final GestureTapCallback _onCardTap;
  final void Function(Food, int, MeasurementUnit) _onAddJournalEntryPressed;
  
  final int _kJoulesAdd;
  final MeasurementUnit _measurementUnit;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final NumberFormat formatter = NumberFormat(null, languageCode);
    final borderRadius = BorderRadius.circular(8);

    String kJoulsAddName = AppLocalizations.of(context)!.hundred_measurement_unit(_measurementUnit.text);

    if (_food.defaultFoodUnit != null) {
      kJoulsAddName = "${_food.defaultFoodUnit!.name} (${formatter.format(_food.defaultFoodUnit!.amount)}${_measurementUnit.text})";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: _onCardTap,
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
                        Text(style: _textTheme.titleLarge, AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_food.energyKj))),
                        Text(
                          style: _textTheme.labelSmall,
                          AppLocalizations.of(
                            context,
                          )!.per_100_measurement_unit(_food.nutritionPerGramAmount != null ? MeasurementUnit.gram : MeasurementUnit.milliliter),
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
                        _onAddJournalEntryPressed(_food, _kJoulesAdd, _measurementUnit);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                style: _textTheme.titleSmall,
                                "+${AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_kJoulesAdd))}",
                              ),
                              Text(style: _textTheme.labelSmall, kJoulsAddName),
                            ],
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
}

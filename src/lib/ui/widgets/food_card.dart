import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_strings.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required Food food, required TextTheme textTheme, GestureTapCallback? onTap})
    : _textTheme = textTheme,
      _food = food,
      _onTap = onTap;

  final TextTheme _textTheme;
  final Food _food;
  final GestureTapCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final NumberFormat formatter = NumberFormat(null, languageCode);
    final borderRadius = BorderRadius.circular(8);

    int kJoulesAdd = _food.energyKjPer100Units;
    String nameAdd = AppLocalizations.of(context)!.hundred_measurement_unit(_food.measurementUnit.text);

    if (_food.defaultFoodUnit != null) {
      kJoulesAdd = (_food.energyKjPer100Units * ((_food.defaultFoodUnit!.amount / 100))).round();
      nameAdd = "${_food.defaultFoodUnit!.name} (${formatter.format(_food.defaultFoodUnit!.amount)}${_food.measurementUnit.text})";
    }
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: _onTap,
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
                        Text(
                          style: _textTheme.titleLarge,
                          AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_food.energyKjPer100Units)),
                        ),
                        Text(style: _textTheme.labelSmall, AppLocalizations.of(context)!.per_100_measurement_unit(_food.measurementUnit.text)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 77,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _food.carbohydratesPer100Units != null
                            ? Text(AppLocalizations.of(context)!.amount_carb(_food.carbohydratesPer100Units!))
                            : Text(AppLocalizations.of(context)!.na_carb),
                        _food.fatPer100Units != null
                            ? Text(AppLocalizations.of(context)!.amount_fat(_food.fatPer100Units!))
                            : Text(AppLocalizations.of(context)!.na_fat),
                        _food.proteinsPer100Units != null
                            ? Text(AppLocalizations.of(context)!.amount_prot(_food.proteinsPer100Units!))
                            : Text(AppLocalizations.of(context)!.na_prot),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 145,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                style: _textTheme.titleSmall,
                                "+${AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(kJoulesAdd))}",
                              ),
                              Text(style: _textTheme.labelSmall, nameAdd),
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

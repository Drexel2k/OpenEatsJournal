import "package:flutter/material.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";

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
    String foodSourceLabel = UiHelpers.getFoodSourceLabel(food: _food, context: context);
    Color foodSourceColor = UiHelpers.getFoodSourceColor(food: _food, context: context);

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
                        Text(style: _textTheme.labelLarge, _food.brands.isNotEmpty ? _food.brands.join(", ") : AppLocalizations.of(context)!.no_brand),
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
                            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: Food.copyAsNewUserFood(food: _food));
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
                          "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _food.kJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                          style: _textTheme.titleMedium,
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.per} ${ConvertValidate.getCleanDoubleString(
                            doubleValue: _food.nutritionPerGramAmount != null ? ConvertValidate.getDisplayWeightG(weightG: _food.nutritionPerGramAmount!) : ConvertValidate.getDisplayVolume(volumeMl: _food.nutritionPerMilliliterAmount!),
                          )}${_food.nutritionPerGramAmount != null ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}",
                          style: _textTheme.labelSmall,
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
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: _food.carbohydrates!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                              ),
                        _food.fat != null
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: _food.fat!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                              ),
                        _food.protein != null
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: _food.protein!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein_abbreviated}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein_abbreviated}",
                              ),
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
                            "+${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _getKJoulesToAdd()))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                            style: _textTheme.titleSmall,
                          ),
                          Text(
                            style: _textTheme.labelSmall,
                            _getKJoulesToAddText(measurementUnit: measurementUnit, context: context),
                            textAlign: TextAlign.center,
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
    String kJoulsAddName;
    if (_food.defaultFoodUnit != null) {
      kJoulsAddName =
          "${_food.defaultFoodUnit!.name} (${ConvertValidate.getCleanDoubleString(
            doubleValue: measurementUnit == MeasurementUnit.gram ? ConvertValidate.getDisplayWeightG(weightG: _food.defaultFoodUnit!.amount) : ConvertValidate.getDisplayVolume(volumeMl: _food.defaultFoodUnit!.amount),
          )}${measurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)})";
    } else {
      kJoulsAddName =
          "${ConvertValidate.getCleanDoubleString(
            doubleValue: measurementUnit == MeasurementUnit.gram ? ConvertValidate.getDisplayWeightG(weightG: _food.nutritionPerGramAmount!) : ConvertValidate.getDisplayWeightG(weightG: _food.nutritionPerMilliliterAmount!),
          )}${measurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";
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

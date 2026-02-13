import "dart:async";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_colors.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";

class FoodCard extends StatefulWidget {
  const FoodCard({
    super.key,
    required Food food,
    required TextTheme textTheme,
    required void Function({required Food food}) onCardTap,
    required Future<void> Function({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) onAddJournalEntryPressed,
  }) : _food = food,
       _onCardTap = onCardTap,
       _onAddJournalEntryPressed = onAddJournalEntryPressed;

  final Food _food;
  final void Function({required Food food}) _onCardTap;
  final Future<void> Function({required Food food, required double amount, required MeasurementUnit amountMeasurementUnit}) _onAddJournalEntryPressed;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _checkVisible = false;
  static const int _checkAnimationDuration = 150;
  static const int _checkDisplayDuration = 500;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final OpenEatsJournalColors openEatsJournalColors = Theme.of(context).extension<OpenEatsJournalColors>()!;
    final borderRadius = BorderRadius.circular(8);

    MeasurementUnit measurementUnit = _getMeasurementUnit();
    String foodSourceLabel = UiHelpers.getFoodSourceLabel(food: widget._food, context: context);
    Color foodSourceColor = UiHelpers.getFoodSourceColor(food: widget._food, context: context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          widget._onCardTap(food: widget._food);
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
                          style: textTheme.headlineSmall,
                          widget._food.name != OpenEatsJournalStrings.emptyString ? widget._food.name : AppLocalizations.of(context)!.no_name,
                        ),
                        Text(
                          style: textTheme.labelLarge,
                          widget._food.brands.isNotEmpty ? widget._food.brands.join(", ") : AppLocalizations.of(context)!.no_brand,
                        ),
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
                            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: Food.copyAsNewUserFood(food: widget._food));
                          },
                          child: Text(AppLocalizations.of(context)!.as_new_food),
                        ),
                      );

                      if (widget._food.foodSource == FoodSource.user) {
                        menuItems.add(
                          PopupMenuItem(
                            onTap: () {
                              Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEdit, arguments: widget._food);
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
                          "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: widget._food.kJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.per} ${ConvertValidate.getCleanDoubleString(
                            doubleValue: widget._food.nutritionPerGramAmount != null ? ConvertValidate.getDisplayWeightG(weightG: widget._food.nutritionPerGramAmount!) : ConvertValidate.getDisplayVolume(volumeMl: widget._food.nutritionPerMilliliterAmount!),
                          )}${widget._food.nutritionPerGramAmount != null ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}",
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 77,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget._food.carbohydrates != null
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: widget._food.carbohydrates!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.carbs}",
                              ),
                        widget._food.fat != null
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: widget._food.fat!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.fat}",
                              ),
                        widget._food.protein != null
                            ? Text(
                                "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: widget._food.protein!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein_abbreviated}",
                              )
                            : Text(
                                "${AppLocalizations.of(context)!.na}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)} ${AppLocalizations.of(context)!.protein_abbreviated}",
                              ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      SizedBox(
                        width: 145,
                        child: OutlinedButton(
                          onPressed: () {
                            widget._onAddJournalEntryPressed(
                              food: widget._food,
                              amount: widget._food.defaultFoodUnit != null ? widget._food.defaultFoodUnit!.amount : 100,
                              amountMeasurementUnit: _getMeasurementUnit(),
                            );
                            setState(() {
                              _checkVisible = true;
                            });
                            Timer(Duration(milliseconds: _checkAnimationDuration + _checkDisplayDuration), _fadeOutCheck);
                          },
                          child: Column(
                            children: [
                              Text(
                                "+${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _getKJoulesToAdd()))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                                style: textTheme.titleSmall,
                              ),
                              Text(
                                style: textTheme.labelSmall,
                                _getKJoulesToAddText(measurementUnit: measurementUnit, context: context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              // If the widget is visible, animate to 0.0 (invisible).
                              // If the widget is hidden, animate to 1.0 (fully visible).
                              opacity: _checkVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: _checkAnimationDuration),
                              // The green box must be a child of the AnimatedOpacity widget.
                              child: Container(
                                decoration: BoxDecoration(color: openEatsJournalColors.confirmationBackgroundColor, borderRadius: BorderRadius.circular(15)),
                                child: Icon(Icons.check, color: Colors.green, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fadeOutCheck() {
    setState(() {
      _checkVisible = false;
    });
  }

  String _getKJoulesToAddText({required MeasurementUnit measurementUnit, required BuildContext context}) {
    String kJoulsAddName;
    if (widget._food.defaultFoodUnit != null) {
      kJoulsAddName =
          "${widget._food.defaultFoodUnit!.name} (${ConvertValidate.getCleanDoubleString(
            doubleValue: measurementUnit == MeasurementUnit.gram ? ConvertValidate.getDisplayWeightG(weightG: widget._food.defaultFoodUnit!.amount) : ConvertValidate.getDisplayVolume(volumeMl: widget._food.defaultFoodUnit!.amount),
          )}${measurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)})";
    } else {
      kJoulsAddName =
          "${ConvertValidate.getCleanDoubleString(
            doubleValue: measurementUnit == MeasurementUnit.gram ? ConvertValidate.getDisplayWeightG(weightG: widget._food.nutritionPerGramAmount!) : ConvertValidate.getDisplayWeightG(weightG: widget._food.nutritionPerMilliliterAmount!),
          )}${measurementUnit == MeasurementUnit.gram ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context) : ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";
    }

    return kJoulsAddName;
  }

  MeasurementUnit _getMeasurementUnit() {
    if (widget._food.defaultFoodUnit != null) {
      return widget._food.defaultFoodUnit!.amountMeasurementUnit;
    } else {
      if (widget._food.nutritionPerGramAmount != null) {
        return MeasurementUnit.gram;
      } else {
        return MeasurementUnit.milliliter;
      }
    }
  }

  double _getKJoulesToAdd() {
    if (widget._food.defaultFoodUnit != null) {
      if (widget._food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return (widget._food.kJoule * (widget._food.defaultFoodUnit!.amount / widget._food.nutritionPerGramAmount!));
      } else {
        return (widget._food.kJoule * (widget._food.defaultFoodUnit!.amount / widget._food.nutritionPerMilliliterAmount!));
      }
    } else {
      if (widget._food.nutritionPerGramAmount != null) {
        return (widget._food.kJoule * (100 / widget._food.nutritionPerGramAmount!));
      } else {
        return (widget._food.kJoule * (100 / widget._food.nutritionPerMilliliterAmount!));
      }
    }
  }
}

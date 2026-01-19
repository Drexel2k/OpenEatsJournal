import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class FoodUnitEditorData {
  FoodUnitEditorData({
    required String name,
    required MeasurementUnit amountMeasurementUnit,
    required bool isDefault,
    FoodUnit? foodUnit,
    double? amount,
    String? originalFoodSourceFoodUnitId,
  }) : _foodUnit = foodUnit,
       _name = name,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit,
       _isDefault = isDefault,
       _originalFoodSourceFoodUnitId = originalFoodSourceFoodUnitId;

  final FoodUnit? _foodUnit;
  String _name;
  double? _amount;
  MeasurementUnit _amountMeasurementUnit;
  bool _isDefault;
  String? _originalFoodSourceFoodUnitId;

  set name(String value) => _name = value;
  set amount(double? value) => _amount = value;
  set amountMeasurementUnit(MeasurementUnit value) => _amountMeasurementUnit = value;
  set isDefault(bool value) => _isDefault = value;
  set originalFoodSourceFoodUnitId(String? value) => _originalFoodSourceFoodUnitId = value;

  FoodUnit? get foodUnit => _foodUnit;
  String get name => _name;
  double? get amount => _amount;
  MeasurementUnit get amountMeasurementUnit => _amountMeasurementUnit;
  bool get isDefault => _isDefault;
  String? get originalFoodSourceFoodUnitId => _originalFoodSourceFoodUnitId;

  bool isValid({required double? foodNutritionPerGramAmount, required double? foodNutritionPerMilliliterAmount}) {
    bool foodUnitValid = true;

    if (_name.trim() == OpenEatsJournalStrings.emptyString) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _amount == null) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _amountMeasurementUnit == MeasurementUnit.gram && foodNutritionPerGramAmount == null) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _amountMeasurementUnit == MeasurementUnit.milliliter && foodNutritionPerMilliliterAmount == null) {
      foodUnitValid = false;
    }

    return foodUnitValid;
  }
}

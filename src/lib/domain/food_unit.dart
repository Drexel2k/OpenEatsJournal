import "package:openeatsjournal/domain/measurement_unit.dart";

class FoodUnit {
  FoodUnit({required String name, required double amount, required MeasurementUnit amountMeasurementUnit, int? id, String? originalFoodSourceFoodUnitId})
    : _id = id,
      _name = name,
      _amount = amount,
      _amountMeasurementUnit = amountMeasurementUnit,
      _originalFoodSourceFoodUnitId = originalFoodSourceFoodUnitId;

  int? _id;
  String _name;
  double _amount;
  MeasurementUnit _amountMeasurementUnit;

  final String? _originalFoodSourceFoodUnitId;

  set id(int? id) {
    if (_id != null) {
      throw ArgumentError("Existing id must must not be overriden.");
    }

    if (id == null) {
      throw ArgumentError("Id must be set to value.");
    }

    _id = id;
  }

  set name(String name) => _name = name;

  set amount(double value) {
    if (value < 0) {
      throw ArgumentError("Amount must not be negative.");
    }

    _amount = value;
  }

  set amountMeasurementUnit(MeasurementUnit value) {
    _amountMeasurementUnit = value;
  }

  int? get id => _id;
  String get name => _name;
  double get amount => _amount;
  MeasurementUnit get amountMeasurementUnit => _amountMeasurementUnit;
  String? get originalFoodSourceFoodUnitId => _originalFoodSourceFoodUnitId;
}

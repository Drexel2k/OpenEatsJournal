import 'package:openeatsjournal/domain/food_unit_type.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';

class FoodUnit {
  FoodUnit({required String name, required int amount, required MeasurementUnit amountMeasurementUnit, int? id, FoodUnitType? foodUnitType})
    : _id = id,
      _name = name,
      _amount = amount,
      _amountMeasurementUnit = amountMeasurementUnit,
      _foodUnitType = foodUnitType;

  int? _id;
  String _name;
  int _amount;
  MeasurementUnit _amountMeasurementUnit;

  final FoodUnitType? _foodUnitType;

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

  set amount(int value) {
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
  int get amount => _amount;
  MeasurementUnit get amountMeasurementUnit => _amountMeasurementUnit;
  FoodUnitType? get foodUnitType => _foodUnitType;
}

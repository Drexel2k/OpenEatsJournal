import 'package:openeatsjournal/domain/food_unit_type.dart';

class FoodUnit {
  FoodUnit({required String name, required int amount, int? id, FoodUnitType? foodUnitType}) : _name = name, _amount = amount, _id = id, _foodUnitType = foodUnitType;

  String _name;
  final int _amount;
  int? _id;
  final FoodUnitType? _foodUnitType;

  set name(String name) => _name = name;
  set id(int? id) {
    if (_id != null) {
      throw ArgumentError("Existing id must must not be overriden.");
    }

    if (id == null) {
      throw ArgumentError("Id must be set to value.");
    }

    _id = id;
  }

  String get name => _name;
  int get amount => _amount;
  int? get id => _id;
  FoodUnitType? get foodUnitType => _foodUnitType;
}

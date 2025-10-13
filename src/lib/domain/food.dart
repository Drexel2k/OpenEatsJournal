import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_type.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";

class Food {
  Food({
    required String name,
    required FoodSource foodSource,
    required int kJoule,
    int? id,
    String? foodSourceIdExternal,
    List<String>? brands,
    int? nutritionPerGramAmount,
    int? nutritionPerMilliliterAmount,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? saturatedFat,
    double? protein,
    double? salt,
    String? quantity,
  }) : _name = name,
       _brands = brands,
       _foodSource = foodSource,
       _id = id,
       _foodSourceIdExternal = foodSourceIdExternal,
       _nutritionPerGramAmount = nutritionPerGramAmount,
       _nutritionPerMilliliterAmount = nutritionPerMilliliterAmount,
       _kJoule = kJoule,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = saturatedFat,
       _protein = protein,
       _salt = salt,
       _foodUnits = [];

  final String _name;
  final List<String>? _brands;
  final FoodSource _foodSource;
  int? _id;
  final String? _foodSourceIdExternal;
  final int _kJoule;
  final int? _nutritionPerGramAmount;
  final int? _nutritionPerMilliliterAmount;
  final double? _carbohydrates;
  final double? _sugar;
  final double? _fat;
  final double? _saturatedFat;
  final double? _protein;
  final double? _salt;
  final List<ObjectWithOrder<FoodUnit>> _foodUnits;
  FoodUnit? _defaultFoodUnit;

  set id(int? id) {
    if (_foodSource == FoodSource.standard) {
      throw ArgumentError("Id of standard food does always exist and can't be set after object creation.");
    }

    if (_id != null) {
      throw ArgumentError("Existing id must must not be overriden.");
    }

    if (id == null) {
      throw ArgumentError("Id must be set to value.");
    }

    _id = id;
  }

  String get name => _name;
  List<String>? get brands => _brands;
  FoodSource get foodSource => _foodSource;
  int? get id => _id;
  String? get foodSourceIdExternal => _foodSourceIdExternal;
  int? get nutritionPerGramAmount => _nutritionPerGramAmount;
  int? get nutritionPerMilliliterAmount => _nutritionPerMilliliterAmount;
  int get kJoule => _kJoule;
  double? get carbohydrates => _carbohydrates;
  double? get sugar => _sugar;
  double? get fat => _fat;
  double? get saturatedFat => _saturatedFat;
  double? get protein => _protein;
  double? get salt => _salt;
  List<ObjectWithOrder<FoodUnit>> get foodUnits => _foodUnits.toList();
  FoodUnit? get defaultFoodUnit => _defaultFoodUnit;

  bool addFoodUnit({required String name, required int amount, required MeasurementUnit amountMeasurementUnit, FoodUnitType? foodUnitType}) {
    if (amountMeasurementUnit == MeasurementUnit.gram) {
      if (_nutritionPerGramAmount == null) {
        return false;
      }
    } else {
      if (_nutritionPerMilliliterAmount == null) {
        return false;
      }
    }

    FoodUnit foodUnit = FoodUnit(name: name, amount: amount, amountMeasurementUnit: amountMeasurementUnit, foodUnitType: foodUnitType);

    //ensure list ist sorted by sort order to generate the new order value.
    int order = 1;
    if (_foodUnits.isNotEmpty) {
      _foodUnits.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);
      order = _foodUnits.last.order + 1;
    }

    _foodUnits.add(ObjectWithOrder(object: foodUnit, order: order));

    if (_foodUnits.length <= 1) {
      _defaultFoodUnit = foodUnit;
    }

    return true;
  }
}

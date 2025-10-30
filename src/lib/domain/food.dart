import "package:collection/collection.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
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
       _foodUnitsWithOrder = [];

  final String _name;
  final List<String>? _brands;
  final FoodSource _foodSource;
  int? _id;
  final String? _foodSourceIdExternal;
  int _kJoule;
  int? _nutritionPerGramAmount;
  int? _nutritionPerMilliliterAmount;
  double? _carbohydrates;
  double? _sugar;
  double? _fat;
  double? _saturatedFat;
  double? _protein;
  double? _salt;
  final List<ObjectWithOrder<FoodUnit>> _foodUnitsWithOrder;
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

  set nutritionPerGramAmount(int? amount) {
    if (amount != null || _nutritionPerMilliliterAmount != null) {
      if (amount == null) {
        _removeFoodUnitWithMeasurementUnit(measurementUnit: MeasurementUnit.gram);
      }

      _nutritionPerGramAmount = amount;
    } else {
      throw ArgumentError("Can't set nutritionPerGramAmount to null when nutritionPerMilliliterAmount is also null");
    }
  }

  set nutritionPerMilliliterAmount(int? amount) {
    if (amount != null || _nutritionPerGramAmount != null) {
      if (amount == null) {
        _removeFoodUnitWithMeasurementUnit(measurementUnit: MeasurementUnit.milliliter);
      }

      _nutritionPerMilliliterAmount = amount;
    } else {
      throw ArgumentError("Can't set nutritionPerMilliliterAmount to null when nutritionPerGramAmount is also null");
    }
  }

  set kJoule(int kJoule) {
    _kJoule = kJoule;
  }

  set carbohydrates(double? carbohydrates) {
    _carbohydrates = carbohydrates;
  }

  set sugar(double? sugar) {
    _sugar = sugar;
  }

  set fat(double? fat) {
    _fat = fat;
  }

  set saturatedFat(double? saturatedFat) {
    _saturatedFat = saturatedFat;
  }

  set protein(double? protein) {
    _protein = protein;
  }

  set salt(double? salt) {
    _salt = salt;
  }

  set defaultFoodUnit(FoodUnit? foodUnit) {
    if(foodUnit == null) {
      throw ArgumentError("Default food unit must not be null.");
    }

    ObjectWithOrder<FoodUnit>? foodUnitWithOrder = _foodUnitsWithOrder.firstWhereOrNull(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object == foodUnit,
    );

    if(foodUnitWithOrder == null) {
      throw ArgumentError("Can't set default food unit must which is not in list of food units.");
    }

    _defaultFoodUnit = foodUnit;
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
  List<ObjectWithOrder<FoodUnit>> get foodUnitsWithOrder => List.unmodifiable(_foodUnitsWithOrder);
  FoodUnit? get defaultFoodUnit => _defaultFoodUnit;

  bool addFoodUnit({required FoodUnit foodUnit}) {
    if (foodUnit.amountMeasurementUnit == MeasurementUnit.gram) {
      if (_nutritionPerGramAmount == null) {
        return false;
      }
    } else {
      if (_nutritionPerMilliliterAmount == null) {
        return false;
      }
    }

    //ensure list ist sorted by sort order to generate the new order value.
    int order = 1;
    if (_foodUnitsWithOrder.isNotEmpty) {
      _foodUnitsWithOrder.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);
      order = _foodUnitsWithOrder.last.order + 1;
    }

    _foodUnitsWithOrder.add(ObjectWithOrder(object: foodUnit, order: order));

    if (_foodUnitsWithOrder.length <= 1) {
      _defaultFoodUnit = foodUnit;
    }

    return true;
  }

  void _removeFoodUnitWithMeasurementUnit({required MeasurementUnit measurementUnit}) {
    _foodUnitsWithOrder.removeWhere((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.amountMeasurementUnit == measurementUnit);

    if (_foodUnitsWithOrder.isEmpty) {
      _defaultFoodUnit = null;
    } else {
      ObjectWithOrder<FoodUnit>? foodUnitWithOrder = _foodUnitsWithOrder.firstWhereOrNull(
        (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object == _defaultFoodUnit,
      );

      if (foodUnitWithOrder == null) {
        _defaultFoodUnit = _foodUnitsWithOrder[0].object;
      }
    }
  }
}

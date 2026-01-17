import "package:collection/collection.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/ordered_default_food_unit.dart";

class Food {
  Food({
    required String name,
    required FoodSource foodSource,
    required int kJoule,
    required bool fromDb,
    int? id,
    FoodSource? originalFoodSource,
    String? originalFoodSourceFoodId,
    int? barcode,
    List<String>? brands,
    double? nutritionPerGramAmount,
    double? nutritionPerMilliliterAmount,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? saturatedFat,
    double? protein,
    double? salt,
    String? quantity,
  }) : _name = name,
       _brands = brands ?? [],
       _foodSource = foodSource,
       _id = id,
       _originalFoodSource = originalFoodSource,
       _fromDb = fromDb,
       _originalFoodSourceFoodId = originalFoodSourceFoodId,
       _barcode = barcode,
       _nutritionPerGramAmount = nutritionPerGramAmount,
       _nutritionPerMilliliterAmount = nutritionPerMilliliterAmount,
       _kJoule = kJoule,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = saturatedFat,
       _protein = protein,
       _salt = salt,
       _quantity = quantity,
       _foodUnitsWithOrder = [];

  Food.copyAsNewUserFood({required Food food})
    : _name = food.name,
      _brands = List.from(food.brands),
      _foodSource = FoodSource.user,
      _fromDb = true,
      _originalFoodSource =
          food.originalFoodSource ??
          food.foodSource, //when set it must be a user food, keep the original source. If not set it comes from a different source, so take the orignal source.
      _originalFoodSourceFoodId = food.originalFoodSourceFoodId,
      _barcode = food.barcode,
      _kJoule = food.kJoule,
      _nutritionPerGramAmount = food.nutritionPerGramAmount,
      _nutritionPerMilliliterAmount = food.nutritionPerMilliliterAmount,
      _carbohydrates = food.carbohydrates,
      _sugar = food.sugar,
      _fat = food.fat,
      _saturatedFat = food.saturatedFat,
      _protein = food.protein,
      _quantity = food.quantity,
      _foodUnitsWithOrder = [] {
    ObjectWithOrder<FoodUnit> foodUnitWithOrderCopy;
    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      foodUnitWithOrderCopy = ObjectWithOrder<FoodUnit>(
        object: FoodUnit(
          name: foodUnitWithOrder.object.name,
          amount: foodUnitWithOrder.object.amount,
          amountMeasurementUnit: foodUnitWithOrder.object.amountMeasurementUnit,
          originalFoodSourceFoodUnitId: foodUnitWithOrder.object.originalFoodSourceFoodUnitId,
        ),
        order: foodUnitWithOrder.order,
      );

      _foodUnitsWithOrder.add(foodUnitWithOrderCopy);

      if (food.defaultFoodUnit == foodUnitWithOrder.object) {
        _defaultFoodUnit = foodUnitWithOrderCopy.object;
      }
    }
  }

  Food.fromData({
    required String name,
    required FoodSource foodSource,
    required int kJoule,
    required bool fromDb,
    int? id,
    List<String>? brands,
    FoodSource? originalFoodSource,
    String? originalFoodSourceFoodId,
    int? barcode,
    double? nutritionPerGramAmount,
    double? nutritionPerMilliliterAmount,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? saturatedFat,
    double? protein,
    double? salt,
    String? quantity,
    List<OrderedDefaultFoodUnit>? orderedDefaultFoodUnits,
  }) : _name = name,
       _brands = brands ?? [],
       _id = id,
       _foodSource = foodSource,
       _kJoule = kJoule,
       _originalFoodSource = originalFoodSource,
       _fromDb = fromDb,
       _originalFoodSourceFoodId = originalFoodSourceFoodId,
       _barcode = barcode,
       _nutritionPerGramAmount = nutritionPerGramAmount,
       _nutritionPerMilliliterAmount = nutritionPerMilliliterAmount,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = saturatedFat,
       _protein = protein,
       _salt = salt,
       _quantity = quantity,
       _foodUnitsWithOrder = [] {
    if (orderedDefaultFoodUnits != null && orderedDefaultFoodUnits.isNotEmpty) {
      for (OrderedDefaultFoodUnit orderedDefaultFoodUnit in orderedDefaultFoodUnits) {
        _addFoodUnitWithOrder(orderedDefaultFoodUnit.foodUnitWithOrder);

        if (orderedDefaultFoodUnit.isDefault) {
          if (_defaultFoodUnit != null) {
            throw StateError("Default food unit was already set.");
          }

          _defaultFoodUnit = orderedDefaultFoodUnit.foodUnitWithOrder.object;
        }
      }

      if (_foodUnitsWithOrder.isNotEmpty && _defaultFoodUnit == null) {
        throw ("Food units exist, but no default food unit is set.");
      }
    }
  }

  String _name;
  final List<String> _brands;
  int? _id;
  final FoodSource _foodSource;
  //to distinguish between data from objects from online services or cached versions which wer loaded from database
  final bool _fromDb;
  final FoodSource? _originalFoodSource;
  final String? _originalFoodSourceFoodId;
  int? _barcode;
  int _kJoule;
  double? _nutritionPerGramAmount;
  double? _nutritionPerMilliliterAmount;
  double? _carbohydrates;
  double? _sugar;
  double? _fat;
  double? _saturatedFat;
  double? _protein;
  double? _salt;
  final String? _quantity;
  final List<ObjectWithOrder<FoodUnit>> _foodUnitsWithOrder;
  FoodUnit? _defaultFoodUnit;

  set id(int? value) {
    if (value == null) {
      throw ArgumentError("Id must be set to value.");
    }

    if (_id != null) {
      throw ArgumentError("Existing id must must not be overriden.");
    }

    _id = value;
  }

  set name(String value) {
    _checkUserFood();

    _name = value;
  }

  set barcode(int? value) {
    _checkUserFood();

    _barcode = value;
  }

  set nutritionPerGramAmount(double? value) {
    _checkUserFood();

    if (value != null || _nutritionPerMilliliterAmount != null) {
      if (value == null) {
        _removeFoodUnitWithMeasurementUnit(measurementUnit: MeasurementUnit.gram);
      }

      _nutritionPerGramAmount = value;
    } else {
      throw ArgumentError("Can't set nutritionPerGramAmount to null when nutritionPerMilliliterAmount is also null.");
    }
  }

  set nutritionPerMilliliterAmount(double? value) {
    _checkUserFood();

    if (value != null || _nutritionPerGramAmount != null) {
      if (value == null) {
        _removeFoodUnitWithMeasurementUnit(measurementUnit: MeasurementUnit.milliliter);
      }

      _nutritionPerMilliliterAmount = value;
    } else {
      throw ArgumentError("Can't set nutritionPerMilliliterAmount to null when nutritionPerGramAmount is also null.");
    }
  }

  set kJoule(int value) {
    _checkUserFood();

    _kJoule = value;
  }

  set carbohydrates(double? value) {
    _checkUserFood();

    _carbohydrates = value;
  }

  set sugar(double? value) {
    _checkUserFood();

    _sugar = value;
  }

  set fat(double? value) {
    _checkUserFood();

    _fat = value;
  }

  set saturatedFat(double? value) {
    _checkUserFood();

    _saturatedFat = value;
  }

  set protein(double? value) {
    _checkUserFood();

    _protein = value;
  }

  set salt(double? value) {
    _checkUserFood();

    _salt = value;
  }

  set defaultFoodUnit(FoodUnit? value) {
    _checkUserFood();

    if (value == null) {
      throw ArgumentError("Default food unit must not be null.");
    }

    ObjectWithOrder<FoodUnit>? foodUnitWithOrder = _foodUnitsWithOrder.firstWhereOrNull(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object == value,
    );

    if (foodUnitWithOrder == null) {
      throw ArgumentError("Can't set default food unit must which is not in list of food units.");
    }

    _defaultFoodUnit = value;
  }

  String get name => _name;
  List<String> get brands => _brands;
  //food source and original food source can differ on user food.
  FoodSource get foodSource => _foodSource;
  bool get fromDb => _fromDb;
  FoodSource? get originalFoodSource => _originalFoodSource;
  int? get barcode => _barcode;
  int? get id => _id;
  String? get originalFoodSourceFoodId => _originalFoodSourceFoodId;
  double? get nutritionPerGramAmount => _nutritionPerGramAmount;
  double? get nutritionPerMilliliterAmount => _nutritionPerMilliliterAmount;
  int get kJoule => _kJoule;
  double? get carbohydrates => _carbohydrates;
  double? get sugar => _sugar;
  double? get fat => _fat;
  double? get saturatedFat => _saturatedFat;
  double? get protein => _protein;
  double? get salt => _salt;
  String? get quantity => _quantity;
  List<ObjectWithOrder<FoodUnit>> get foodUnitsWithOrder => List.unmodifiable(_foodUnitsWithOrder);
  FoodUnit? get defaultFoodUnit => _defaultFoodUnit;

  bool get isExternalFoodSource {
    return _foodSource != FoodSource.standard && _foodSource != FoodSource.user;
  }

  bool addFoodUnit({required FoodUnit foodUnit, int? order}) {
    _checkUserFood();

    if (foodUnit.amountMeasurementUnit == MeasurementUnit.gram) {
      if (_nutritionPerGramAmount == null) {
        return false;
      }
    } else {
      if (_nutritionPerMilliliterAmount == null) {
        return false;
      }
    }

    ObjectWithOrder<FoodUnit> foodUnitWithOrder;
    //ensure list ist sorted by sort order to generate the new order value.
    _foodUnitsWithOrder.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);
    if (order == null) {
      foodUnitWithOrder = ObjectWithOrder(
        object: foodUnit,
        order:
            _foodUnitsWithOrder.fold(
              0,
              (maxOrder, foodUnitWithOrderInternal) => foodUnitWithOrderInternal.order > maxOrder ? foodUnitWithOrderInternal.order : maxOrder,
            ) +
            1,
      );
    } else {
      _foodUnitsWithOrder.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);

      for (int foodUnitIndex = order - 1; foodUnitIndex < _foodUnitsWithOrder.length; foodUnitIndex++) {
        _foodUnitsWithOrder[foodUnitIndex].order = _foodUnitsWithOrder[foodUnitIndex].order + 1;
      }

      foodUnitWithOrder = ObjectWithOrder(object: foodUnit, order: order);
    }

    _addFoodUnitWithOrder(foodUnitWithOrder);

    if (_foodUnitsWithOrder.length <= 1) {
      _defaultFoodUnit = foodUnit;
    }

    return true;
  }

  void upadteFoodUnitOrder({required FoodUnit foodUnit, required int newOrder}) {
    _checkUserFood();

    ObjectWithOrder<FoodUnit> foodUnitWithOrder = _foodUnitsWithOrder.firstWhere(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrderInternal) => foodUnitWithOrderInternal.object == foodUnit,
    );

    if (foodUnitWithOrder.order != newOrder) {
      _foodUnitsWithOrder.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);

      int currentIndex = foodUnitWithOrder.order - 1;
      int newIndex = newOrder - 1;
      if (newIndex < currentIndex) {
        for (int foodUnitIndex = newIndex; foodUnitIndex < currentIndex; foodUnitIndex++) {
          _foodUnitsWithOrder[foodUnitIndex].order = _foodUnitsWithOrder[foodUnitIndex].order + 1;
        }
      }

      if (newIndex > currentIndex) {
        for (int foodUnitIndex = currentIndex + 1; foodUnitIndex <= newIndex; foodUnitIndex++) {
          _foodUnitsWithOrder[foodUnitIndex].order = _foodUnitsWithOrder[foodUnitIndex].order - 1;
        }
      }

      foodUnitWithOrder.order = newOrder;
    }
  }

  void _addFoodUnitWithOrder(ObjectWithOrder<FoodUnit> foodUnitWithOrder) {
    ObjectWithOrder<FoodUnit>? foodUnitWithOrderExists = _foodUnitsWithOrder.firstWhereOrNull(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrderInternal) => foodUnitWithOrderInternal.object == foodUnitWithOrder.object,
    );

    if (foodUnitWithOrderExists != null) {
      throw ArgumentError("Can't add same food unit a second time.");
    }

    if (_foodUnitsWithOrder.firstWhereOrNull((foodUnitWithOrderInteral) => foodUnitWithOrderInteral.order == foodUnitWithOrder.order) != null) {
      throw ArgumentError("Can't add food unit with same order number a second time.");
    }

    if (foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram && (_nutritionPerGramAmount == null || _nutritionPerGramAmount! <= 0)) {
      throw ArgumentError("Can't add food unit measurementunit gram when food's nutritionPerGramAmount is null or 0.");
    }

    if (foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.milliliter &&
        (_nutritionPerMilliliterAmount == null || _nutritionPerMilliliterAmount! <= 0)) {
      throw ArgumentError("Can't add food unit measurementunit milliliter when food's nutritionPerMilliliterAmount is null or 0.");
    }

    _foodUnitsWithOrder.add(foodUnitWithOrder);
  }

  void removeFoodUnit({required FoodUnit foodUnit}) {
    _checkUserFood();

    _foodUnitsWithOrder.removeWhere((ObjectWithOrder<FoodUnit> foodUnitWithOrderInternal) => foodUnitWithOrderInternal.object == foodUnit);
    _ensureDefaultFoodUnit();
  }

  void _removeFoodUnitWithMeasurementUnit({required MeasurementUnit measurementUnit}) {
    _foodUnitsWithOrder.removeWhere((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.amountMeasurementUnit == measurementUnit);

    int order = 1;
    if (_foodUnitsWithOrder.isNotEmpty) {
      _foodUnitsWithOrder.sort((foodUnit1, foodUnit2) => foodUnit2.order - foodUnit1.order);
      for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in _foodUnitsWithOrder) {
        foodUnitWithOrder.order = order;
      }

      order++;
    }
    _ensureDefaultFoodUnit();
  }

  void _ensureDefaultFoodUnit() {
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

  void _checkUserFood() {
    if (_foodSource != FoodSource.user) {
      throw StateError("Only user foods can be updated.");
    }
  }
}

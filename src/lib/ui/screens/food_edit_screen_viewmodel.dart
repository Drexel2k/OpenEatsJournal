import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_edit_wrapper.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class FoodEditScreenViewModel extends ChangeNotifier {
  FoodEditScreenViewModel({required Food food, required FoodRepository foodRepository})
    : _food = food,
      _foodRepository = foodRepository,
      _name = ValueNotifier(food.name),
      _nutritionPerGramAmount = ValueNotifier(food.nutritionPerGramAmount),
      _lastValidNutritionPerGramAmount = ValueNotifier(food.nutritionPerGramAmount),
      _nutritionPerMilliliterAmount = ValueNotifier(food.nutritionPerMilliliterAmount),
      _lastValidNutritionPerMilliliterAmount = ValueNotifier(food.nutritionPerMilliliterAmount),
      _amountsValid = food.nutritionPerGramAmount != null || food.nutritionPerMilliliterAmount != null ? ValueNotifier(true) : ValueNotifier(false),
      _kJoule = ValueNotifier(food.kJoule),
      _carbohydrates = ValueNotifier(food.carbohydrates),
      _sugar = ValueNotifier(food.sugar),
      _fat = ValueNotifier(food.fat),
      _saturatedFat = ValueNotifier(food.saturatedFat),
      _protein = ValueNotifier(food.protein),
      _salt = ValueNotifier(food.salt),
      _foodUnitsWithOrderCopy = food.foodUnitsWithOrder
          .map(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => ObjectWithOrder(
              object: FoodUnitEditWrapper(foodUnit: foodUnitWithOrder.object),
              order: foodUnitWithOrder.order,
            ),
          )
          .toList(),
      _defaultFoodUnit = food.defaultFoodUnit {
    _foodUnitsWithOrderCopy.sort((ObjectWithOrder<FoodUnitEditWrapper> unit1, ObjectWithOrder<FoodUnitEditWrapper> unit2) => unit1.order - unit2.order);
    _nutritionPerGramAmount.addListener(_amountsChanged);
    _nutritionPerMilliliterAmount.addListener(_amountsChanged);
    _kJoule.addListener(_kJouleChanged);
  }

  final Food _food;
  final FoodRepository _foodRepository;

  //Work on a copy to remain invalid states during editing by the user, e.g. when gram amount is set to null while milliliter amount is not null all food units
  //with unit grams are removed from the food object. That might be annoying for the user as he maybe sets the gram amount to null to immediately enter a new
  //value.
  final List<ObjectWithOrder<FoodUnitEditWrapper>> _foodUnitsWithOrderCopy;
  final ValueNotifier<String> _name;
  final ValueNotifier<int?> _nutritionPerGramAmount;
  final ValueNotifier<int?> _lastValidNutritionPerGramAmount;
  final ValueNotifier<int?> _nutritionPerMilliliterAmount;
  final ValueNotifier<int?> _lastValidNutritionPerMilliliterAmount;
  final ValueNotifier<bool> _amountsValid;
  final ValueNotifier<int?> _kJoule;
  final ValueNotifier<bool> _kJouleValid = ValueNotifier(true);
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  final ExternalTriggerChangedNotifier _reorderableStateChanged = ExternalTriggerChangedNotifier();
  final ValueNotifier<bool> _foodUnitsCopyValid = ValueNotifier(true);
  FoodUnit? _defaultFoodUnit;
  final ValueNotifier<bool> _foodUnitsEditMode = ValueNotifier(true);

  final Debouncer _amountsDebouncer = Debouncer();

  ValueNotifier<String> get name => _name;
  ValueNotifier<int?> get nutritionPerGramAmount => _nutritionPerGramAmount;
  ValueNotifier<int?> get lastValidNutritionPerGramAmount => _lastValidNutritionPerGramAmount;
  ValueNotifier<int?> get nutritionPerMilliliterAmount => _nutritionPerMilliliterAmount;
  ValueNotifier<int?> get lastValidNutritionPerMilliliterAmount => _lastValidNutritionPerMilliliterAmount;
  ValueNotifier<bool> get amountsValid => _amountsValid;
  ValueNotifier<int?> get kJoule => _kJoule;
  ValueNotifier<bool> get kJouleValid => _kJouleValid;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

  ExternalTriggerChangedNotifier get reorderableStateChanged => _reorderableStateChanged;
  ValueNotifier<bool> get foodUnitsCopyValid => _foodUnitsCopyValid;
  ValueNotifier<bool> get foodUnitsEditMode => _foodUnitsEditMode;

  int get foodkJoule => _food.kJoule;
  List<ObjectWithOrder<FoodUnitEditWrapper>> get foodFoodUnitsWithOrderCopy => _foodUnitsWithOrderCopy;

  FoodUnit? get defaultFoodUnit => _defaultFoodUnit;

  void addFoddUnit({required MeasurementUnit measurementUnit}) {
    FoodUnit foodUnit = FoodUnit(name: "", amount: 100, amountMeasurementUnit: measurementUnit);
    int order = 1;
    if (_foodUnitsWithOrderCopy.isEmpty) {
      _defaultFoodUnit = foodUnit;
    } else {
      order = _foodUnitsWithOrderCopy.last.order + 1;
    }

    ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithOrder = ObjectWithOrder(
      object: FoodUnitEditWrapper(foodUnit: foodUnit),
      order: order,
    );
    _foodUnitsWithOrderCopy.add(foodUnitWithOrder);
    _reorderableStateChanged.notify();
  }

  void _amountsChanged() {
    if (_nutritionPerGramAmount.value != null || _nutritionPerMilliliterAmount.value != null) {
      _amountsValid.value = true;
      checkFoodUnitsCopyValid();

      _amountsDebouncer.run(
        callback: () {
          //Always set bot values. If one was null and the other was set to null, too, it isn't stored in food object in this moment, because it would be an invalid
          // conig. Now with with one value not null, the other value can bet set to null.
          _lastValidNutritionPerGramAmount.value = _nutritionPerGramAmount.value;
          _lastValidNutritionPerMilliliterAmount.value = _nutritionPerMilliliterAmount.value;
        },
      );
    } else {
      _amountsDebouncer.cancel();
      _amountsValid.value = false;
    }
  }

  void checkFoodUnitsCopyValid() {
    bool foodUnitsValid = true;
    ObjectWithOrder<FoodUnitEditWrapper>? foodUnitWithOrder = _foodUnitsWithOrderCopy.firstWhereOrNull(
      (ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithOrder) => foodUnitWithOrder.object.foodUnit.amountMeasurementUnit == MeasurementUnit.gram,
    );
    if (_nutritionPerGramAmount.value == null && foodUnitWithOrder != null) {
      foodUnitsValid = false;
    }

    foodUnitWithOrder = null;
    foodUnitWithOrder = _foodUnitsWithOrderCopy.firstWhereOrNull(
      (ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithOrder) => foodUnitWithOrder.object.foodUnit.amountMeasurementUnit == MeasurementUnit.milliliter,
    );
    if (_nutritionPerMilliliterAmount.value == null && foodUnitWithOrder != null) {
      foodUnitsValid = false;
    }

    _foodUnitsCopyValid.value = foodUnitsValid;
  }

  void changeDefaultFoodUnit(FoodUnit foodUnit) {
    _defaultFoodUnit = foodUnit;
    _reorderableStateChanged.notify();
  }

  void removeFoodUnit(FoodUnit foodUnit) {
    _foodUnitsWithOrderCopy.removeWhere((ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithOrderInteral) {
      return foodUnitWithOrderInteral.object.foodUnit == foodUnit;
    });

    if (_defaultFoodUnit == foodUnit) {
      if (_foodUnitsWithOrderCopy.isEmpty) {
        _defaultFoodUnit = null;
      } else {
        _defaultFoodUnit = _foodUnitsWithOrderCopy.first.object.foodUnit;
      }
    }

    int order = 1;
    for (ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithOrder in _foodUnitsWithOrderCopy) {
      foodUnitWithOrder.order = order;
      order++;
    }

    checkFoodUnitsCopyValid();
    _reorderableStateChanged.notify();
  }

  void _kJouleChanged() {
    if (_kJoule.value != null) {
      _kJouleValid.value = true;
    } else {
      _kJouleValid.value = false;
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithorder = _foodUnitsWithOrderCopy.removeAt(oldIndex);
    _foodUnitsWithOrderCopy.insert(newIndex, foodUnitWithorder);

    int order = 0;
    for (ObjectWithOrder<FoodUnitEditWrapper> foodUnitWithorderInteral in _foodUnitsWithOrderCopy) {
      foodUnitWithorderInteral.order = order;
      order++;
    }

    _reorderableStateChanged.notify();
  }

  @override
  void dispose() {
    _nutritionPerGramAmount.dispose();
    _nutritionPerMilliliterAmount.dispose();
    _kJoule.dispose();
    _carbohydrates.dispose();
    _sugar.dispose();
    _fat.dispose();
    _saturatedFat.dispose();
    _protein.dispose();
    _salt.dispose();

    super.dispose();
  }
}

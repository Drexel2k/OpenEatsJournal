import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";
import "package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart";

class FoodEditScreenViewModel extends ChangeNotifier {
  FoodEditScreenViewModel({required Food food, required FoodRepository foodRepository})
    : _food = food,
      _foodRepository = foodRepository,
      _name = ValueNotifier(food.name),
      _nameValid = ValueNotifier(food.name.trim() != OpenEatsJournalStrings.emptyString),
      _nutritionPerGramAmount = ValueNotifier(food.nutritionPerGramAmount),
      _nutritionPerMilliliterAmount = ValueNotifier(food.nutritionPerMilliliterAmount),
      _amountsValid = food.nutritionPerGramAmount != null || food.nutritionPerMilliliterAmount != null ? ValueNotifier(true) : ValueNotifier(false),
      _kJoule = ValueNotifier(food.kJoule),
      _carbohydrates = ValueNotifier(food.carbohydrates),
      _sugar = ValueNotifier(food.sugar),
      _fat = ValueNotifier(food.fat),
      _saturatedFat = ValueNotifier(food.saturatedFat),
      _protein = ValueNotifier(food.protein),
      _salt = ValueNotifier(food.salt),
      _foodUnitsWithOrderCopy = food.foodUnitsWithOrder
          .map((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => ObjectWithOrder(object: foodUnitWithOrder.object, order: foodUnitWithOrder.order))
          .toList() {
    _foodUnitsWithOrderCopy.sort((ObjectWithOrder<FoodUnit> unit1, ObjectWithOrder<FoodUnit> unit2) => unit1.order - unit2.order);
    _foodUnitEditorViewModels.addAll(
      food.foodUnitsWithOrder
          .map(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => FoodUnitEditorViewModel(
              foodUnit: foodUnitWithOrder.object,
              defaultFoodUnit: food.defaultFoodUnit == foodUnitWithOrder.object,
              changeMeasurementUnit: checkFoodUnitsCopyValid,
              changeDefault: changeDefaultFoodUnit,
              removeFoodUnit: removeFoodUnit,
              foodUnitsEditMode: _foodUnitsEditMode,
              foodNutritionPerGram: _nutritionPerGramAmount,
              foodNutritionPerMilliliter: _nutritionPerMilliliterAmount,
            ),
          )
          .toList(),
    );

    _name.addListener(_nameChanged);
    _nutritionPerGramAmount.addListener(_amountsChanged);
    _nutritionPerMilliliterAmount.addListener(_amountsChanged);
    _kJoule.addListener(_kJouleChanged);
  }

  final Food _food;
  final FoodRepository _foodRepository;

  final ValueNotifier<String> _name;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<int?> _nutritionPerGramAmount;
  final ValueNotifier<int?> _nutritionPerMilliliterAmount;
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
  final ValueNotifier<bool> _foodUnitsEditMode = ValueNotifier(true);

  //Work on a copy to remain invalid states during editing by the user, e.g. when gram amount is set to null while milliliter amount is not null all food units
  //with unit grams are removed from the food object. That might be annoying for the user as he maybe sets the gram amount to null to immediately enter a new
  //value.
  final List<ObjectWithOrder<FoodUnit>> _foodUnitsWithOrderCopy;
  final List<FoodUnitEditorViewModel> _foodUnitEditorViewModels = [];

  ValueNotifier<String> get name => _name;
  ValueNotifier<bool> get nameValid => _nameValid;
  ValueNotifier<int?> get nutritionPerGramAmount => _nutritionPerGramAmount;
  ValueNotifier<int?> get nutritionPerMilliliterAmount => _nutritionPerMilliliterAmount;
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

  List<ObjectWithOrder<FoodUnit>> get foodFoodUnitsWithOrderCopy => _foodUnitsWithOrderCopy;
  List<FoodUnitEditorViewModel> get foodUnitEditorViewModels => _foodUnitEditorViewModels;

  void addFoddUnit({required MeasurementUnit measurementUnit}) {
    FoodUnit foodUnit = FoodUnit(name: "", amount: 100, amountMeasurementUnit: measurementUnit);
    int order = 1;
    if (_foodUnitsWithOrderCopy.isNotEmpty) {
      order = _foodUnitsWithOrderCopy.last.order + 1;
    }

    ObjectWithOrder<FoodUnit> foodUnitWithOrder = ObjectWithOrder(object: foodUnit, order: order);
    _foodUnitsWithOrderCopy.add(foodUnitWithOrder);
    _foodUnitEditorViewModels.add(
      FoodUnitEditorViewModel(
        foodUnit: foodUnit,
        defaultFoodUnit: _foodUnitEditorViewModels.isEmpty,
        changeMeasurementUnit: checkFoodUnitsCopyValid,
        changeDefault: changeDefaultFoodUnit,
        removeFoodUnit: removeFoodUnit,
        foodUnitsEditMode: _foodUnitsEditMode,
        foodNutritionPerGram: _nutritionPerGramAmount,
        foodNutritionPerMilliliter: _nutritionPerMilliliterAmount,
      ),
    );

    _reorderableStateChanged.notify();
  }

  void removeFoodUnit(FoodUnit foodUnit) {
    _foodUnitsWithOrderCopy.removeWhere((ObjectWithOrder<FoodUnit> foodUnitWithOrder) {
      return foodUnitWithOrder.object == foodUnit;
    });

    FoodUnitEditorViewModel foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
      (FoodUnitEditorViewModel foodUnitEditorViewModelInteral) => foodUnitEditorViewModelInteral.foodUnit == foodUnit,
    );
    _foodUnitEditorViewModels.remove(foodUnitEditorViewModel);

    if (foodUnitEditorViewModel.defaultFoodUnit.value) {
      if (_foodUnitEditorViewModels.isNotEmpty) {
        _foodUnitEditorViewModels.first.defaultFoodUnit.value = true;
      }
    }

    int order = 1;
    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in _foodUnitsWithOrderCopy) {
      foodUnitWithOrder.order = order;
      order++;
    }

    checkFoodUnitsCopyValid();
    _reorderableStateChanged.notify();
  }

  void _nameChanged() {
    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      _nameValid.value = false;
    } else {
      _nameValid.value = true;
    }
  }

  void _amountsChanged() {
    if (_nutritionPerGramAmount.value != null || _nutritionPerMilliliterAmount.value != null) {
      _amountsValid.value = true;
      checkFoodUnitsCopyValid();
    } else {
      _amountsValid.value = false;
    }
  }

  void checkFoodUnitsCopyValid() {
    bool foodUnitsValid = true;
    ObjectWithOrder<FoodUnit>? foodUnitWithOrder = _foodUnitsWithOrderCopy.firstWhereOrNull(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrderInternal) => foodUnitWithOrderInternal.object.amountMeasurementUnit == MeasurementUnit.gram,
    );
    if (_nutritionPerGramAmount.value == null && foodUnitWithOrder != null) {
      foodUnitsValid = false;
    }

    foodUnitWithOrder = null;
    foodUnitWithOrder = _foodUnitsWithOrderCopy.firstWhereOrNull(
      (ObjectWithOrder<FoodUnit> foodUnitWithOrderInternal) => foodUnitWithOrderInternal.object.amountMeasurementUnit == MeasurementUnit.milliliter,
    );
    if (_nutritionPerMilliliterAmount.value == null && foodUnitWithOrder != null) {
      foodUnitsValid = false;
    }

    _foodUnitsCopyValid.value = foodUnitsValid;
  }

  void changeDefaultFoodUnit(FoodUnit foodUnit) {
    FoodUnitEditorViewModel foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
      (FoodUnitEditorViewModel foodUnitEditorViewModelInteral) => foodUnitEditorViewModelInteral.defaultFoodUnit.value,
    );

    foodUnitEditorViewModel.defaultFoodUnit.value = false;

    foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
      (FoodUnitEditorViewModel foodUnitEditorViewModelInteral) => foodUnitEditorViewModelInteral.foodUnit == foodUnit,
    );

    foodUnitEditorViewModel.defaultFoodUnit.value = true;
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

    final ObjectWithOrder<FoodUnit> foodUnitWithorder = _foodUnitsWithOrderCopy.removeAt(oldIndex);
    _foodUnitsWithOrderCopy.insert(newIndex, foodUnitWithorder);

    int order = 0;
    for (ObjectWithOrder<FoodUnit> foodUnitWithorderInteral in _foodUnitsWithOrderCopy) {
      foodUnitWithorderInteral.order = order;
      order++;
    }

    _reorderableStateChanged.notify();
  }

  bool createFood() {
    bool foodValid = true;

    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      foodValid = false;
    }

    if (foodValid && _nutritionPerGramAmount.value == null && _nutritionPerMilliliterAmount.value == null) {
      foodValid = false;
    }

    if (foodValid && _kJoule.value == null) {
      foodValid = false;
    }

    if (foodValid) {
      if (_foodUnitsWithOrderCopy.isNotEmpty) {
        if (_foodUnitEditorViewModels
                .where((FoodUnitEditorViewModel foodUnitEditorViewModel) => foodUnitEditorViewModel.defaultFoodUnit.value)
                .toList()
                .length !=
            1) {
          foodValid = false;
        }
      }
    }

    if (foodValid) {
      for (FoodUnitEditorViewModel foodUnitEditorViewModel in _foodUnitEditorViewModels) {
        if (!foodUnitEditorViewModel.isValid(
          foodNutritionPerGramAmount: _nutritionPerGramAmount.value,
          foodNutritionPerMilliliterAmount: _nutritionPerMilliliterAmount.value,
        )) {
          foodValid = false;
          break;
        }
      }
    }

    if (foodValid) {
      _food.name = _name.value;
      _food.nutritionPerGramAmount = _nutritionPerGramAmount.value;
      _food.nutritionPerMilliliterAmount = _nutritionPerMilliliterAmount.value;
      _food.kJoule = _kJoule.value!;
      _food.carbohydrates = _carbohydrates.value;
      _food.sugar = _sugar.value;
      _food.fat = _fat.value;
      _food.saturatedFat = _saturatedFat.value;
      _food.protein = _protein.value;
      _food.salt = salt.value;

      for (FoodUnitEditorViewModel foodUnitEditorViewModel in _foodUnitEditorViewModels) {
        ObjectWithOrder<FoodUnit>? foodUnitWithorder = _food.foodUnitsWithOrder.firstWhereOrNull(
          (ObjectWithOrder<FoodUnit> foodUnitWithorderInternal) => foodUnitWithorderInternal.object == foodUnitEditorViewModel.foodUnit,
        );

        //update if exists already
        foodUnitEditorViewModel.foodUnit.name = foodUnitEditorViewModel.name.value;
        foodUnitEditorViewModel.foodUnit.amount = foodUnitEditorViewModel.amount.value!;
        foodUnitEditorViewModel.foodUnit.amountMeasurementUnit = foodUnitEditorViewModel.currentMeasurementUnit.value;

        //add to food's unit if not exists
        if (foodUnitWithorder == null) {
          _food.addFoodUnit(foodUnit: foodUnitEditorViewModel.foodUnit);
        }
      }

      List<FoodUnit> foodUnitsToRemove = [];
      for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in _food.foodUnitsWithOrder) {
        FoodUnitEditorViewModel? foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhereOrNull(
          (FoodUnitEditorViewModel foodUnitEditorViewModel) => foodUnitEditorViewModel.foodUnit == foodUnitWithOrder.object,
        );

        if (foodUnitEditorViewModel == null) {
          foodUnitsToRemove.add(foodUnitWithOrder.object);
        }
      }

      for (FoodUnit foodUnit in foodUnitsToRemove) {
        _food.removeFoodUnit(foodUnit: foodUnit);
      }

      if (_foodUnitsWithOrderCopy.isNotEmpty) {
        FoodUnitEditorViewModel foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
          (FoodUnitEditorViewModel foodUnitEditorViewModelInternal) => foodUnitEditorViewModelInternal.defaultFoodUnit.value,
        );
        _food.defaultFoodUnit = foodUnitEditorViewModel.foodUnit;
      }

      _foodRepository.setFood(food: _food);
    }

    return foodValid;
  }

  @override
  void dispose() {
    _name.dispose();
    _nameValid.dispose();
    _nutritionPerGramAmount.dispose();
    _nutritionPerMilliliterAmount.dispose();
    _amountsValid.dispose();
    _kJoule.dispose();
    _kJouleValid.dispose();
    _carbohydrates.dispose();
    _sugar.dispose();
    _fat.dispose();
    _saturatedFat.dispose();
    _protein.dispose();
    _salt.dispose();
    _reorderableStateChanged.dispose();
    _foodUnitsCopyValid.dispose();
    _foodUnitsEditMode.dispose();

    super.dispose();
  }
}

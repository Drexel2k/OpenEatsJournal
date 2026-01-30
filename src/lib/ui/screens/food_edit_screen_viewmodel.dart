import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_editor_data.dart";
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
      _brands = ValueNotifier(food.brands.join(", ")),
      _nameValid = ValueNotifier(food.name.trim() != OpenEatsJournalStrings.emptyString),
      _barcode = ValueNotifier(food.barcode),
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
      _foodUnitEditorsData = food.foodUnitsWithOrder
          .map(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) => FoodUnitEditorData(
              name: foodUnitWithOrder.object.name,
              amountMeasurementUnit: foodUnitWithOrder.object.amountMeasurementUnit,
              isDefault: foodUnitWithOrder.object == food.defaultFoodUnit,
              foodUnit: foodUnitWithOrder.object,
              amount: foodUnitWithOrder.object.amount,
              originalFoodSourceFoodUnitId: foodUnitWithOrder.object.originalFoodSourceFoodUnitId,
            ),
          )
          .toList(),
      _foodId = food.id {
    if (food.foodSource != FoodSource.user) {
      throw ArgumentError("Only user foods can be edited");
    }

    _name.addListener(_nameChanged);
    _nutritionPerGramAmount.addListener(_amountsChanged);
    _nutritionPerMilliliterAmount.addListener(_amountsChanged);
    _kJoule.addListener(_kJouleChanged);
  }

  final Food _food;
  final FoodRepository _foodRepository;

  final ValueNotifier<String> _name;
  final ValueNotifier<String> _brands;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<int?> _barcode;
  final ValueNotifier<double?> _nutritionPerGramAmount;
  final ValueNotifier<double?> _nutritionPerMilliliterAmount;
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
  final ValueNotifier<bool> _foodUnitEditorsDataValid = ValueNotifier(true);
  final ValueNotifier<bool> _foodUnitsEditMode = ValueNotifier(true);
  final int? _foodId;

  //Work on a temporary data to remain invalid states during editing by the user, e.g. when gram amount is set to null while milliliter amount is not null all
  //food units with unit grams are removed from the food object. That might be annoying for the user as he maybe sets the gram amount to null to immediately
  //enter a new value. A change in one food unit viewmodel may have effect on other food unit view models, e.g. changind the default food unit. Therefore we
  //need the viewmodels to update the defautl food unit and reflect the change in the ui. And we need the data of the viewmodels, because the food unit editor
  //widgets and viewmodels gets disposed when changing from edit to sort view.
  final List<FoodUnitEditorData> _foodUnitEditorsData;
  final List<FoodUnitEditorViewModel> _foodUnitEditorViewModels = [];

  ValueNotifier<String> get name => _name;
  ValueNotifier<String> get brands => _brands;
  ValueNotifier<bool> get nameValid => _nameValid;
  ValueNotifier<int?> get barcode => _barcode;
  ValueNotifier<double?> get nutritionPerGramAmount => _nutritionPerGramAmount;
  ValueNotifier<double?> get nutritionPerMilliliterAmount => _nutritionPerMilliliterAmount;
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
  ValueNotifier<bool> get foodUnitEditorsDataValid => _foodUnitEditorsDataValid;
  ValueNotifier<bool> get foodUnitsEditMode => _foodUnitsEditMode;

  List<FoodUnitEditorData> get foodUnitEditorsData => _foodUnitEditorsData;
  List<FoodUnitEditorViewModel> get foodUnitEditorViewModels => _foodUnitEditorViewModels;
  int? get foodId => _foodId;

  void addFoddUnit({required MeasurementUnit measurementUnit}) {
    FoodUnitEditorData foodUnitEditorData = FoodUnitEditorData(
      name: OpenEatsJournalStrings.emptyString,
      amountMeasurementUnit: measurementUnit,
      isDefault: _foodUnitEditorsData.isEmpty,
    );

    _foodUnitEditorsData.add(foodUnitEditorData);

    _foodUnitEditorViewModels.add(
      FoodUnitEditorViewModel(
        foodUnitEditorData: foodUnitEditorData,
        changeMeasurementUnit: checkFoodUnitsCopyValid,
        changeDefaultCallback: changeDefaultFoodUnit,
        removeFoodUnitCallback: removeFoodUnit,
        foodUnitsEditMode: _foodUnitsEditMode,
        foodNutritionPerGram: _nutritionPerGramAmount,
        foodNutritionPerMilliliter: _nutritionPerMilliliterAmount,
      ),
    );

    _reorderableStateChanged.notify();
  }

  void removeFoodUnit(FoodUnitEditorData foodUnitEditorData) {
    _foodUnitEditorsData.removeWhere((FoodUnitEditorData foodUnitEditorDataInternal) {
      return foodUnitEditorDataInternal == foodUnitEditorData;
    });

    FoodUnitEditorViewModel foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
      (FoodUnitEditorViewModel foodUnitEditorViewModelInteral) => foodUnitEditorViewModelInteral.foodUnitEditorData == foodUnitEditorData,
    );

    _foodUnitEditorViewModels.remove(foodUnitEditorViewModel);

    if (foodUnitEditorData.isDefault) {
      if (_foodUnitEditorViewModels.isNotEmpty) {
        _foodUnitEditorViewModels.first.defaultFoodUnit.value = true;
      }
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
    if (_nutritionPerGramAmount.value == null) {
      FoodUnitEditorData? foodUnitEditorData = _foodUnitEditorsData.firstWhereOrNull(
        (FoodUnitEditorData foodUnitEditorDataInternal) => foodUnitEditorDataInternal.amountMeasurementUnit == MeasurementUnit.gram,
      );
      if (foodUnitEditorData != null) {
        foodUnitsValid = false;
      }
    }

    if (_nutritionPerMilliliterAmount.value == null) {
      FoodUnitEditorData? foodUnitEditorData = _foodUnitEditorsData.firstWhereOrNull(
        (FoodUnitEditorData foodUnitEditorDataInternal) => foodUnitEditorDataInternal.amountMeasurementUnit == MeasurementUnit.milliliter,
      );
      if (foodUnitEditorData != null) {
        foodUnitsValid = false;
      }
    }

    _foodUnitEditorsDataValid.value = foodUnitsValid;
  }

  void changeDefaultFoodUnit(FoodUnitEditorData foodUnitEditorData) {
    FoodUnitEditorViewModel foodUnitEditorViewModel = _foodUnitEditorViewModels.firstWhere(
      (FoodUnitEditorViewModel foodUnitEditorViewModelInteral) => foodUnitEditorViewModelInteral.defaultFoodUnit.value,
    );

    foodUnitEditorViewModel.defaultFoodUnit.value = false;
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

    final FoodUnitEditorData foodUnitEditorData = _foodUnitEditorsData.removeAt(oldIndex);
    _foodUnitEditorsData.insert(newIndex, foodUnitEditorData);

    _reorderableStateChanged.notify();
  }

  Future<bool> saveFood() async {
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
      if (_foodUnitEditorsData.isNotEmpty) {
        //check if one food unit has defaultFoodUnit set to true
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
      for (FoodUnitEditorData foodUnitEditorData in _foodUnitEditorsData) {
        if (!foodUnitEditorData.isValid(
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
      _food.brands.clear();
      _food.brands.addAll(_brands.value.split(",").map((brand) => brand.trim()));
      _food.barcode = _barcode.value;

      //It is important to set non null values first, before setting null values, otherwise it can be that both ambounts may get null, which is throws an
      //exception in the food...
      if (_nutritionPerGramAmount.value != null) {
        _food.nutritionPerGramAmount = _nutritionPerGramAmount.value;
      }

      if (_nutritionPerMilliliterAmount.value != null) {
        _food.nutritionPerMilliliterAmount = _nutritionPerMilliliterAmount.value;
      }

      if (_nutritionPerGramAmount.value == null) {
        _food.nutritionPerGramAmount = null;
      }

      if (_nutritionPerMilliliterAmount.value == null) {
        _food.nutritionPerMilliliterAmount = null;
      }

      _food.kJoule = _kJoule.value!;
      _food.carbohydrates = _carbohydrates.value;
      _food.sugar = _sugar.value;
      _food.fat = _fat.value;
      _food.saturatedFat = _saturatedFat.value;
      _food.protein = _protein.value;
      _food.salt = salt.value;

      //remove deleted food units from food
      List<FoodUnit> foodUnitsToRemove = [];
      for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in _food.foodUnitsWithOrder) {
        FoodUnitEditorData? foodUnitEditorData = _foodUnitEditorsData.firstWhereOrNull(
          (FoodUnitEditorData foodUnitEditorDataInternal) => foodUnitEditorDataInternal.foodUnit == foodUnitWithOrder.object,
        );

        if (foodUnitEditorData == null) {
          foodUnitsToRemove.add(foodUnitWithOrder.object);
        }

        for (FoodUnit foodUnit in foodUnitsToRemove) {
          _food.removeFoodUnit(foodUnit: foodUnit);
        }
      }

      //updating food units in food and removing deleted ones, editors work only on temporary data and don't change the food.
      int order = 1;
      for (FoodUnitEditorData foodUnitEditorData in _foodUnitEditorsData) {
        //get food unit if it already existed and update
        if (foodUnitEditorData.foodUnit != null) {
          //update if exists already, other properties are noit editable in ui
          foodUnitEditorData.foodUnit!.name = foodUnitEditorData.name;
          foodUnitEditorData.foodUnit!.amount = foodUnitEditorData.amount!;
          foodUnitEditorData.foodUnit!.amountMeasurementUnit = foodUnitEditorData.amountMeasurementUnit;
          _food.upadteFoodUnitOrder(foodUnit: foodUnitEditorData.foodUnit!, newOrder: order);
        } else {
          //add to food's unit if not exists, other properties are not editable in ui
          FoodUnit foodUnit = FoodUnit(
            name: foodUnitEditorData.name,
            amount: foodUnitEditorData.amount!,
            amountMeasurementUnit: foodUnitEditorData.amountMeasurementUnit,
          );

          _food.addFoodUnit(foodUnit: foodUnit, order: order);

          if (foodUnitEditorData.isDefault) {
            _food.defaultFoodUnit = foodUnit;
          }
        }

        order++;
      }

      await _foodRepository.setFood(food: _food);
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
    _foodUnitEditorsDataValid.dispose();
    _foodUnitsEditMode.dispose();

    super.dispose();
  }
}

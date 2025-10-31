import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_edit_wrapper.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class FoodUnitEditorViewModel extends ChangeNotifier {
  FoodUnitEditorViewModel({
    required FoodUnitEditWrapper foodUnitEditWrapper,
    required bool defaultFoodUnit,
    required VoidCallback changeMeasurementUnit,
    required void Function(FoodUnit) changeDefault,
    required void Function(FoodUnit) removeFoodUnit,
    required ValueListenable<bool> foodUnitsEditMode,
    required ValueNotifier<int?> foodNutritionPerGram,
    required ValueNotifier<int?> foodNutritionPerMilliliter,
  }) : _foodUnitEditWrapper = foodUnitEditWrapper,
       _defaultFoodUnit = ValueNotifier(defaultFoodUnit),
       _changeMeasurementUnit = changeMeasurementUnit,
       _changeDefault = changeDefault,
       _removeFoodUnit = removeFoodUnit,
       _foodUnitsEditMode = foodUnitsEditMode,
       _foodNutritionPerGram = foodNutritionPerGram,
       _foodNutritionPerMilliliter = foodNutritionPerMilliliter,
       _name = ValueNotifier(foodUnitEditWrapper.foodUnit.name),
       _amount = ValueNotifier(foodUnitEditWrapper.amount),
       _amountValid = ValueNotifier(foodUnitEditWrapper.amount != null),
       _currentMeasurementUnit = ValueNotifier(foodUnitEditWrapper.foodUnit.amountMeasurementUnit),
       _measurementUnitSwitchButtonEnabled = ValueNotifier(
         _getMeasurementUnitSwitchButtonEnabled(foodNutritionPerGram.value, foodNutritionPerMilliliter.value, foodUnitEditWrapper.foodUnit.amountMeasurementUnit),
       ) {
    _name.addListener(_nameChanged);
    _amount.addListener(_amountChanged);
    _defaultFoodUnit.addListener(_defaultFoodUnitChanged);
    _foodNutritionPerGram.addListener(_foodAmountsChanged);
    _foodNutritionPerMilliliter.addListener(_foodAmountsChanged);
    _currentMeasurementUnit.addListener(_currentMeasurementUnitChanged);
  }

  final FoodUnitEditWrapper _foodUnitEditWrapper;

  final ValueNotifier<bool> _defaultFoodUnit;
  final ValueNotifier<String> _name;
  final ValueNotifier<int?> _amount;
  final ValueNotifier<bool> _amountValid;
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final ValueNotifier<bool> _measurementUnitSwitchButtonEnabled;
  final void Function(FoodUnit) _changeDefault;
  final VoidCallback _changeMeasurementUnit;
  final void Function(FoodUnit) _removeFoodUnit;
  final ValueListenable<bool> _foodUnitsEditMode;
  final ValueNotifier<int?> _foodNutritionPerGram;
  final ValueNotifier<int?> _foodNutritionPerMilliliter;
  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  final Debouncer _nameDebouncer = Debouncer();
  final Debouncer _amountDebouncer = Debouncer();

  ValueNotifier<bool> get defaultFoodUnit => _defaultFoodUnit;
  ValueNotifier<String> get name => _name;
  ValueNotifier<int?> get amount => _amount;
  ValueNotifier<MeasurementUnit> get currentMeasurementUnit => _currentMeasurementUnit;
  ValueNotifier<bool> get measurementUnitSwitchButtonEnabled => _measurementUnitSwitchButtonEnabled;
  ValueListenable<bool> get foodUnitsEditMode => _foodUnitsEditMode;
  ValueNotifier<bool> get amountValid => _amountValid;

  int get foodUnitAmount => _foodUnitEditWrapper.foodUnit.amount;

  ExternalTriggerChangedNotifier get measurementUnitSwitchButtonChanged => _measurementUnitSwitchButtonChanged;

  void _nameChanged() {
    _nameDebouncer.run(
      callback: () {
        _foodUnitEditWrapper.foodUnit.name = _name.value;
      },
    );
  }

  void _amountChanged() {
    if (_amount.value != null) {
      _amountValid.value = true;
      _amountDebouncer.run(
        callback: () {
          _foodUnitEditWrapper.amount = _amount.value!;
          _foodUnitEditWrapper.foodUnit.amount = _amount.value!;
        },
      );
    } else {
      _amountDebouncer.cancel();
      _foodUnitEditWrapper.amount = _amount.value;
      _amountValid.value = false;
    }
  }

  void _defaultFoodUnitChanged() {
    if (_defaultFoodUnit.value) {
      _changeDefault(_foodUnitEditWrapper.foodUnit);
    } else {
      //can't deselect a default food unit, only select a new one.
      _defaultFoodUnit.value = true;
    }
  }

  void _foodAmountsChanged() {
    _updatedMeasurementUnitSwitchButtonEnabled();
  }

  static bool _getMeasurementUnitSwitchButtonEnabled(
    int? foodNutritionPerGram,
    int? foodNutritionPerMilliliter,
    MeasurementUnit currentMeasurementUnitInternal,
  ) {
    bool measurementSwitchEnabled = true;
    if (foodNutritionPerGram == null && currentMeasurementUnitInternal == MeasurementUnit.milliliter) {
      measurementSwitchEnabled = false;
    }

    if (foodNutritionPerMilliliter == null && currentMeasurementUnitInternal == MeasurementUnit.gram) {
      measurementSwitchEnabled = false;
    }

    return measurementSwitchEnabled;
  }

  void _currentMeasurementUnitChanged() {
    _foodUnitEditWrapper.foodUnit.amountMeasurementUnit = _currentMeasurementUnit.value;
    _changeMeasurementUnit();
    _updatedMeasurementUnitSwitchButtonEnabled();
  }

  void _updatedMeasurementUnitSwitchButtonEnabled() {
    _measurementUnitSwitchButtonEnabled.value = _getMeasurementUnitSwitchButtonEnabled(
      _foodNutritionPerGram.value,
      _foodNutritionPerMilliliter.value,
      _currentMeasurementUnit.value,
    );

    _measurementUnitSwitchButtonChanged.notify();
  }

  void removeFoodUnit() {
    _removeFoodUnit(_foodUnitEditWrapper.foodUnit);
  }

  @override
  void dispose() {
    _defaultFoodUnit.dispose();

    super.dispose();
  }
}

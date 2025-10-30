import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class FoodUnitEditorViewModel extends ChangeNotifier {
  FoodUnitEditorViewModel({
    required FoodUnit foodUnit,
    required bool defaultFoodUnit,
    required VoidCallback changeMeasurementUnit,
    required void Function(FoodUnit) changeDefault,
    required void Function(FoodUnit) removeFoodUnit,
    required ValueNotifier<int?> foodNutritionPerGram,
    required ValueNotifier<int?> foodNutritionPerMilliliter,
  }) : _foodUnit = foodUnit,
       _defaultFoodUnit = ValueNotifier(defaultFoodUnit),
       _changeMeasurementUnit = changeMeasurementUnit,
       _changeDefault = changeDefault,
       _removeFoodUnit = removeFoodUnit,
       _foodNutritionPerGram = foodNutritionPerGram,
       _foodNutritionPerMilliliter = foodNutritionPerMilliliter,
       _name = ValueNotifier(foodUnit.name),
       _amount = ValueNotifier(foodUnit.amount),
       _currentMeasurementUnit = ValueNotifier(foodUnit.amountMeasurementUnit),
       _measurementUnitSwitchButtonEnabled = ValueNotifier(
         _getMeasurementUnitSwitchButtonEnabled(foodNutritionPerGram.value, foodNutritionPerMilliliter.value, foodUnit.amountMeasurementUnit),
       ) {
    _name.addListener(_nameChanged);
    _amount.addListener(_amountChanged);
    _defaultFoodUnit.addListener(_defaultFoodUnitChanged);
    _foodNutritionPerGram.addListener(_foodAmountsChanged);
    _foodNutritionPerMilliliter.addListener(_foodAmountsChanged);
    _currentMeasurementUnit.addListener(_currentMeasurementUnitChanged);
  }

  final FoodUnit _foodUnit;

  final ValueNotifier<bool> _defaultFoodUnit;
  final ValueNotifier<String> _name;
  final ValueNotifier<int?> _amount;
  final ValueNotifier<bool> _amountValid = ValueNotifier(true);
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final ValueNotifier<bool> _measurementUnitSwitchButtonEnabled;
  final void Function(FoodUnit) _changeDefault;
  final VoidCallback _changeMeasurementUnit;
  final void Function(FoodUnit) _removeFoodUnit;
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
  ValueNotifier<bool> get amountValid => _amountValid;

  int get foodUnitAmount => _foodUnit.amount;

  ExternalTriggerChangedNotifier get measurementUnitSwitchButtonChanged => _measurementUnitSwitchButtonChanged;

  void _nameChanged() {
    _nameDebouncer.run(
      callback: () {
        _foodUnit.name = _name.value;
      },
    );
  }

  void _amountChanged() {
    if (_amount.value != null) {
      _amountValid.value = true;
      _amountDebouncer.run(
        callback: () {
          _foodUnit.amount = _amount.value!;
        },
      );
    } else {
      _amountDebouncer.cancel();
      _amountValid.value = false;
    }
  }

  void _defaultFoodUnitChanged() {
    if (_defaultFoodUnit.value) {
      _changeDefault(_foodUnit);
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
    _foodUnit.amountMeasurementUnit = _currentMeasurementUnit.value;
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
    _removeFoodUnit(_foodUnit);
  }

  @override
  void dispose() {
    _defaultFoodUnit.dispose();

    super.dispose();
  }
}

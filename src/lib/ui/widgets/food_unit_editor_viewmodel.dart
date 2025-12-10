import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class FoodUnitEditorViewModel extends ChangeNotifier {
  FoodUnitEditorViewModel({
    required FoodUnit foodUnit,
    required bool defaultFoodUnit,
    required VoidCallback changeMeasurementUnit,
    required void Function(FoodUnit) changeDefault,
    required void Function(FoodUnit) removeFoodUnit,
    required ValueNotifier<bool> foodUnitsEditMode,
    required ValueNotifier<double?> foodNutritionPerGram,
    required ValueNotifier<double?> foodNutritionPerMilliliter,
  }) : _foodUnit = foodUnit,
       _defaultFoodUnit = ValueNotifier(defaultFoodUnit),
       _changeMeasurementUnit = changeMeasurementUnit,
       _changeDefault = changeDefault,
       _removeFoodUnit = removeFoodUnit,
       _foodUnitsEditMode = foodUnitsEditMode,
       _foodNutritionPerGram = foodNutritionPerGram,
       _foodNutritionPerMilliliter = foodNutritionPerMilliliter,
       _name = ValueNotifier(foodUnit.name),
       _nameValid = ValueNotifier(foodUnit.name.trim() != OpenEatsJournalStrings.emptyString),
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
    _foodUnitsEditMode.addListener(_foodUnitsEditModeChanged);
  }

  final FoodUnit _foodUnit;

  final ValueNotifier<bool> _defaultFoodUnit;
  final ValueNotifier<String> _name;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<double?> _amount;
  final ValueNotifier<bool> _amountValid = ValueNotifier(true);
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final ValueNotifier<bool> _measurementUnitSwitchButtonEnabled;
  final void Function(FoodUnit) _changeDefault;
  final ExternalTriggerChangedNotifier _defaultButtonChanged = ExternalTriggerChangedNotifier();
  final VoidCallback _changeMeasurementUnit;
  final void Function(FoodUnit) _removeFoodUnit;
  final ValueNotifier<bool> _foodUnitsEditMode;
  final ValueNotifier<double?> _foodNutritionPerGram;
  final ValueNotifier<double?> _foodNutritionPerMilliliter;
  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  FoodUnit get foodUnit => _foodUnit;
  ValueNotifier<bool> get defaultFoodUnit => _defaultFoodUnit;
  ExternalTriggerChangedNotifier get defaultButtonChanged => _defaultButtonChanged;
  ValueNotifier<String> get name => _name;
  ValueNotifier<bool> get nameValid => _nameValid;
  ValueNotifier<double?> get amount => _amount;
  ValueNotifier<MeasurementUnit> get currentMeasurementUnit => _currentMeasurementUnit;
  ValueNotifier<bool> get measurementUnitSwitchButtonEnabled => _measurementUnitSwitchButtonEnabled;
  ValueNotifier<bool> get foodUnitsEditMode => _foodUnitsEditMode;
  ValueNotifier<bool> get amountValid => _amountValid;

  ExternalTriggerChangedNotifier get measurementUnitSwitchButtonChanged => _measurementUnitSwitchButtonChanged;

  void _nameChanged() {
    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      _nameValid.value = false;
    } else {
      _nameValid.value = true;
    }
  }

  void _amountChanged() {
    if (_amount.value != null) {
      _amountValid.value = true;
    } else {
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

    _defaultButtonChanged.notify();
  }

  void _foodAmountsChanged() {
    _updatedMeasurementUnitSwitchButtonEnabled();
  }

  static bool _getMeasurementUnitSwitchButtonEnabled(
    double? foodNutritionPerGram,
    double? foodNutritionPerMilliliter,
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

  void _foodUnitsEditModeChanged() {
    _measurementUnitSwitchButtonChanged.notify();
    _defaultButtonChanged.notify();
  }

  bool isValid({required double? foodNutritionPerGramAmount, required double? foodNutritionPerMilliliterAmount}) {
    bool foodUnitValid = true;

    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _amount.value == null) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _currentMeasurementUnit.value == MeasurementUnit.gram && foodNutritionPerGramAmount == null) {
      foodUnitValid = false;
    }

    if (foodUnitValid && _currentMeasurementUnit.value == MeasurementUnit.milliliter && foodNutritionPerMilliliterAmount == null) {
      foodUnitValid = false;
    }

    return foodUnitValid;
  }

  @override
  void dispose() {
    _defaultFoodUnit.dispose();
    _name.dispose();
    _nameValid.dispose();
    _amount.dispose();
    _amountValid.dispose();
    _currentMeasurementUnit.dispose();
    _measurementUnitSwitchButtonEnabled.dispose();
    _defaultButtonChanged.dispose();
    _measurementUnitSwitchButtonChanged.dispose();

    //From food edit screen, the food edit screen disposes these.
    //_foodUnitsEditMode.dispose();
    //_foodNutritionPerGram.dispose();
    //_foodNutritionPerMilliliter.dispose();

    super.dispose();
  }
}

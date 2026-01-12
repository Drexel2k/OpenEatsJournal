import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food_unit_editor_data.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class FoodUnitEditorViewModel extends ChangeNotifier {
  FoodUnitEditorViewModel({
    required FoodUnitEditorData foodUnitEditorData,
    required VoidCallback changeMeasurementUnit,
    required void Function(FoodUnitEditorData) changeDefaultCallback,
    required void Function(FoodUnitEditorData) removeFoodUnitCallback,
    required ValueNotifier<bool> foodUnitsEditMode,
    required ValueNotifier<double?> foodNutritionPerGram,
    required ValueNotifier<double?> foodNutritionPerMilliliter,
  }) : _foodUnitEditorData = foodUnitEditorData,
       _defaultFoodUnit = ValueNotifier(foodUnitEditorData.isDefault),
       _changeMeasurementUnit = changeMeasurementUnit,
       _changeDefaultCallback = changeDefaultCallback,
       _removeFoodUnitCallback = removeFoodUnitCallback,
       _foodUnitsEditMode = foodUnitsEditMode,
       _foodNutritionPerGram = foodNutritionPerGram,
       _foodNutritionPerMilliliter = foodNutritionPerMilliliter,
       _name = ValueNotifier(foodUnitEditorData.name),
       _nameValid = ValueNotifier(foodUnitEditorData.name.trim() != OpenEatsJournalStrings.emptyString),
       _amount = ValueNotifier(foodUnitEditorData.amount),
       _amountValid = ValueNotifier(foodUnitEditorData.amount != null),
       _currentMeasurementUnit = ValueNotifier(foodUnitEditorData.amountMeasurementUnit),
       _measurementUnitSwitchButtonEnabled = ValueNotifier(
         _getMeasurementUnitSwitchButtonEnabled(foodNutritionPerGram.value, foodNutritionPerMilliliter.value, foodUnitEditorData.amountMeasurementUnit),
       ) {
    _name.addListener(_nameChanged);
    _amount.addListener(_amountChanged);
    _defaultFoodUnit.addListener(_defaultFoodUnitChanged);
    _foodNutritionPerGram.addListener(_foodAmountsChanged);
    _foodNutritionPerMilliliter.addListener(_foodAmountsChanged);
    _currentMeasurementUnit.addListener(_currentMeasurementUnitChanged);
    _foodUnitsEditMode.addListener(_foodUnitsEditModeChanged);
  }

  final FoodUnitEditorData _foodUnitEditorData;

  final ValueNotifier<bool> _defaultFoodUnit;
  final ValueNotifier<String> _name;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<double?> _amount;
  final ValueNotifier<bool> _amountValid;
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final ValueNotifier<bool> _measurementUnitSwitchButtonEnabled;
  final void Function(FoodUnitEditorData) _changeDefaultCallback;
  final ExternalTriggerChangedNotifier _defaultButtonChanged = ExternalTriggerChangedNotifier();
  final VoidCallback _changeMeasurementUnit;
  final void Function(FoodUnitEditorData) _removeFoodUnitCallback;
  final ValueNotifier<bool> _foodUnitsEditMode;
  final ValueNotifier<double?> _foodNutritionPerGram;
  final ValueNotifier<double?> _foodNutritionPerMilliliter;

  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  FoodUnitEditorData get foodUnitEditorData => _foodUnitEditorData;
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
    _foodUnitEditorData.name = _name.value;
    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      _nameValid.value = false;
    } else {
      _nameValid.value = true;
    }
  }

  void _amountChanged() {
    _foodUnitEditorData.amount = _amount.value;
    if (_amount.value != null) {
      _amountValid.value = true;
    } else {
      _amountValid.value = false;
    }
  }

  void _defaultFoodUnitChanged() {
    _foodUnitEditorData.isDefault = _defaultFoodUnit.value;
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
    _foodUnitEditorData.amountMeasurementUnit = _currentMeasurementUnit.value;
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
    _removeFoodUnitCallback(_foodUnitEditorData);
  }

  void _foodUnitsEditModeChanged() {
    _measurementUnitSwitchButtonChanged.notify();
    _defaultButtonChanged.notify();
  }

  void triggerDefaultChangedCallback() {
    _changeDefaultCallback(_foodUnitEditorData);
  }

  @override
  void dispose() {
    _foodNutritionPerGram.removeListener(_foodAmountsChanged);
    _foodNutritionPerMilliliter.removeListener(_foodAmountsChanged);
    _foodUnitsEditMode.removeListener(_foodUnitsEditModeChanged);

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

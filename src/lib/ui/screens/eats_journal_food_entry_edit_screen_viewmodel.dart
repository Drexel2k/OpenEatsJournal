import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalFoodEntryEditScreenViewModel extends ChangeNotifier {
  EatsJournalFoodEntryEditScreenViewModel({
    required EatsJournalEntry foodEntry,
    required JournalRepository journalRepository,
    required FoodRepository foodRepository,
    required SettingsRepository settingsRepository,
  }) : _journalRepository = journalRepository,
       _foodRepository = foodRepository,
       _foodEntry = foodEntry,
       _settingsRepository = settingsRepository,
       _eatsAmount = ValueNotifier(
         foodEntry.amountMeasurementUnit != null
             ? (foodEntry.amountMeasurementUnit! == MeasurementUnit.gram
                   ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.amount!)
                   : ConvertValidate.getDisplayVolume(volumeMl: foodEntry.amount!))
             : null,
       ),
       _currentMeasurementUnit = ValueNotifier(foodEntry.amountMeasurementUnit!),
       _measurementSelectionEnabled = _getInitialMeasurementSelectionEnabled(foodEntry.food!),
       _energy = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: foodEntry.kJoule)),
       _carbohydrates = ValueNotifier(foodEntry.carbohydrates != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.carbohydrates!) : null),
       _sugar = ValueNotifier(foodEntry.sugar != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.sugar!) : null),
       _fat = ValueNotifier(foodEntry.fat != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.fat!) : null),
       _saturatedFat = ValueNotifier(foodEntry.saturatedFat != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.saturatedFat!) : null),
       _protein = ValueNotifier(foodEntry.protein != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.protein!) : null),
       _salt = ValueNotifier(foodEntry.salt != null ? ConvertValidate.getDisplayWeightG(weightG: foodEntry.salt!) : null),
       _currentMeal = ValueNotifier(foodEntry.meal),
       _currentEntryDate = ValueNotifier(foodEntry.entryDate) {
    if (_foodEntry.food == null) {
      throw StateError("Food entry must not have a food.");
    }

    _currentEntryDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
    _amount.addListener(_amountsChanged);
    _eatsAmount.addListener(_amountsChanged);
    _currentMeasurementUnit.addListener(_amountsChanged);
  }

  final JournalRepository _journalRepository;
  final FoodRepository _foodRepository;

  final ValueNotifier<DateTime> _currentEntryDate;
  final ValueNotifier<Meal> _currentMeal;

  final EatsJournalEntry _foodEntry;

  final SettingsRepository _settingsRepository;
  final ValueNotifier<double?> _amount = ValueNotifier(1);
  final ValueNotifier<double?> _eatsAmount;
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final bool _measurementSelectionEnabled;
  final ExternalTriggerChangedNotifier _amountRelvantChanged = ExternalTriggerChangedNotifier();

  final ValueNotifier<int?> _energy;
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  ValueNotifier<DateTime> get currentEntryDate => _currentEntryDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  EatsJournalEntry get foodEntry => _foodEntry;

  ValueNotifier<double?> get amount => _amount;
  ValueNotifier<double?> get eatsAmount => _eatsAmount;
  ValueNotifier<MeasurementUnit> get currentMeasurementUnit => _currentMeasurementUnit;
  bool get measurementSelectionEnabled => _measurementSelectionEnabled;
  ExternalTriggerChangedNotifier get amountRelvantChanged => _amountRelvantChanged;

  ValueNotifier<int?> get kJoule => _energy;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

  void _currentJournalDateChanged() {
    //set value back to global settings onyl when creating new entries not on editing existing ones
    if (_foodEntry.id == null) {
      _settingsRepository.currentJournalDate.value = _currentEntryDate.value;
    }
  }

  void _currentMealChanged() {
    //set value back to global settings onyl when creating new entries not on editing existing ones
    if (_foodEntry.id == null) {
      _settingsRepository.currentMeal.value = _currentMeal.value;
    }
  }

  void _amountsChanged() {
    if (_amount.value != null && _eatsAmount.value != null) {
      double eatsAmount;
      if (currentMeasurementUnit.value == MeasurementUnit.gram) {
        eatsAmount = ConvertValidate.getWeightG(displayWeight: _eatsAmount.value!);

        _energy.value = ConvertValidate.getDisplayEnergy(
          energyKJ: (_foodEntry.food!.kJoule * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!)).round(),
        );
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.carbohydrates! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.sugar! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.fat! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.saturatedFat! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.protein! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.salt! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerGramAmount!),
              )
            : null;
      } else {
        eatsAmount = ConvertValidate.getVolumeMl(displayVolume: _eatsAmount.value!);
        _energy.value = ConvertValidate.getDisplayEnergy(
          energyKJ: (_foodEntry.food!.kJoule * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!)).round(),
        );
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.carbohydrates! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.sugar! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.fat! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.saturatedFat! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.protein! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? ConvertValidate.getDisplayWeightG(
                weightG: _foodEntry.food!.salt! * ((_amount.value! * eatsAmount) / _foodEntry.food!.nutritionPerMilliliterAmount!),
              )
            : null;
      }
    } else {
      _energy.value = null;
      _carbohydrates.value = null;
      _sugar.value = null;
      _fat.value = null;
      _saturatedFat.value = null;
      _protein.value = null;
      _salt.value = null;
    }

    _amountRelvantChanged.notify();
  }

  Future<void> setFoodEntry() async {
    if (_amount.value != null && eatsAmount.value != null) {
      await _foodRepository.setFoodByExternalIdIfNecessary(food: _foodEntry.food!);

      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _currentEntryDate.value,
        dayTargetKJoule: _settingsRepository.getTargetKJouleForDay(day: _currentEntryDate.value),
      );

      double eatsAmount = currentMeasurementUnit.value == MeasurementUnit.gram
          ? ConvertValidate.getWeightG(displayWeight: _eatsAmount.value!)
          : ConvertValidate.getVolumeMl(displayVolume: _eatsAmount.value!);

      _foodEntry.amount = _amount.value! * eatsAmount;
      _foodEntry.amountMeasurementUnit = _currentMeasurementUnit.value;

      //taking the local values (not from settings repository) ensures correct values for creating new and editing existing entries
      _foodEntry.entryDate = _currentEntryDate.value;
      _foodEntry.meal = _currentMeal.value;

      await _journalRepository.setEatsJournalEntry(eatsJournalEntry: _foodEntry);
    }
  }

  static bool _getInitialMeasurementSelectionEnabled(Food food) {
    if (food.nutritionPerGramAmount != null && food.nutritionPerMilliliterAmount != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _currentEntryDate.dispose();
    _currentMeal.dispose();
    _amount.dispose();
    _eatsAmount.dispose();
    _amountRelvantChanged.dispose();

    _currentMeasurementUnit.dispose();
    _energy.dispose();
    _carbohydrates.dispose();
    _sugar.dispose();
    _fat.dispose();
    _saturatedFat.dispose();
    _protein.dispose();
    _salt.dispose();

    super.dispose();
  }
}

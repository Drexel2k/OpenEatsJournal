import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
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
       _eatsAmount = ValueNotifier(foodEntry.amount),
       _currentMeasurementUnit = ValueNotifier(foodEntry.amountMeasurementUnit!),
       _measurementSelectionEnabled = _getInitialMeasurementSelectionEnabled(foodEntry.food!),
       _kJoule = ValueNotifier(foodEntry.kJoule),
       _carbohydrates = ValueNotifier(foodEntry.carbohydrates),
       _sugar = ValueNotifier(foodEntry.sugar),
       _fat = ValueNotifier(foodEntry.fat),
       _saturatedFat = ValueNotifier(foodEntry.saturatedFat),
       _protein = ValueNotifier(foodEntry.protein),
       _salt = ValueNotifier(foodEntry.salt) {
    if (_foodEntry.food == null) {
      throw StateError("Food entry must not have a food.");
    }

    _currentEntryDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentEntryDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
    _amount.addListener(_amountsChanged);
    _eatsAmount.addListener(_amountsChanged);
    _currentMeasurementUnit.addListener(_amountsChanged);
  }

  final JournalRepository _journalRepository;
  final FoodRepository _foodRepository;

  final ValueNotifier<DateTime> _currentEntryDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  final EatsJournalEntry _foodEntry;

  final SettingsRepository _settingsRepository;
  final ValueNotifier<double?> _amount = ValueNotifier(1);
  final ValueNotifier<double?> _eatsAmount;
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final bool _measurementSelectionEnabled;
  final ExternalTriggerChangedNotifier _amountRelvantChanged = ExternalTriggerChangedNotifier();

  final ValueNotifier<int?> _kJoule;
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

  ValueNotifier<int?> get kJoule => _kJoule;
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
      if (currentMeasurementUnit.value == MeasurementUnit.gram) {
        _kJoule.value = (_foodEntry.food!.kJoule * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)).round();
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? _foodEntry.food!.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? _foodEntry.food!.sugar! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? _foodEntry.food!.fat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? _foodEntry.food!.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? _foodEntry.food!.protein! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? _foodEntry.food!.salt! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
      } else {
        _kJoule.value = (_foodEntry.food!.kJoule * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)).round();
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? _foodEntry.food!.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? _foodEntry.food!.sugar! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? _foodEntry.food!.fat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? _foodEntry.food!.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? _foodEntry.food!.protein! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? _foodEntry.food!.salt! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
      }
    } else {
      _kJoule.value = null;
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
      if (_foodEntry.food!.isExternalFoodSource && _foodEntry.food!.id != null && !_foodEntry.food!.fromDb) {
        await _foodRepository.setFoodByExternalId(food: _foodEntry.food!);
      }

      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _currentEntryDate.value,
        dayTargetKJoule: _settingsRepository.getTargetKJouleForDay(day: _currentEntryDate.value),
      );

      _foodEntry.amount = _amount.value! * _eatsAmount.value!;
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

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalQuickEntryEditScreenViewModel extends ChangeNotifier {
  EatsJournalQuickEntryEditScreenViewModel({
    required EatsJournalEntry quickEntry,
    required JournalRepository journalRepository,
    required SettingsRepository settingsRepository,
  }) : _journalRepository = journalRepository,
       _settingsRepository = settingsRepository,
       _quickEntry = quickEntry,
       _name = ValueNotifier(quickEntry.name),
       _nameValid = ValueNotifier(quickEntry.name.trim() != OpenEatsJournalStrings.emptyString),
       _amount = ValueNotifier(quickEntry.amount),
       _amountMeasurementUnit = ValueNotifier(quickEntry.amountMeasurementUnit != null ? quickEntry.amountMeasurementUnit! : MeasurementUnit.gram),
       _kJoule = ValueNotifier(quickEntry.kJoule),
       _kJouleValid = ValueNotifier(quickEntry.kJoule > 0),
       _carbohydrates = ValueNotifier(quickEntry.carbohydrates),
       _sugar = ValueNotifier(quickEntry.sugar),
       _fat = ValueNotifier(quickEntry.fat),
       _saturatedFat = ValueNotifier(quickEntry.saturatedFat),
       _protein = ValueNotifier(quickEntry.protein),
       _salt = ValueNotifier(quickEntry.salt),
       _currentEntryDate = ValueNotifier(quickEntry.entryDate),
       _currentMeal = ValueNotifier(quickEntry.meal),
       _currentMeasurementUnit = ValueNotifier(quickEntry.amountMeasurementUnit != null ? quickEntry.amountMeasurementUnit! : MeasurementUnit.gram) {
    if (_quickEntry.food != null) {
      throw StateError("Quick entry must not have a food.");
    }

    _currentEntryDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
    _name.addListener(_nameChanged);
    _kJoule.addListener(_kJouleChanged);
    _currentMeasurementUnit.addListener(_currentMeasurementUnitChanged);
  }

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  final ValueNotifier<DateTime> _currentEntryDate;
  final ValueNotifier<Meal> _currentMeal;

  final EatsJournalEntry _quickEntry;
  final ValueNotifier<String> _name;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<double?> _amount;
  final ValueNotifier<MeasurementUnit> _amountMeasurementUnit;
  final ValueNotifier<int?> _kJoule;
  final ValueNotifier<bool> _kJouleValid;
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  ValueNotifier<DateTime> get currentEntryDate => _currentEntryDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  EatsJournalEntry get quickEntry => _quickEntry;

  ValueNotifier<String> get name => _name;
  ValueNotifier<bool> get nameValid => _nameValid;
  ValueNotifier<double?> get amount => _amount;
  ValueNotifier<MeasurementUnit> get amountMeasurementUnit => _amountMeasurementUnit;
  ValueNotifier<int?> get kJoule => _kJoule;
  ValueNotifier<bool> get kJouleValid => _kJouleValid;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

  ValueNotifier<MeasurementUnit> get currentMeasurementUnit => _currentMeasurementUnit;
  ExternalTriggerChangedNotifier get measurementUnitSwitchButtonChanged => _measurementUnitSwitchButtonChanged;

  void _currentJournalDateChanged() {
    //set value back to global settings onyl when creating new entries not on editing existing ones
    if (_quickEntry.id == null) {
      _settingsRepository.currentJournalDate.value = _currentEntryDate.value;
    }
  }

  void _currentMealChanged() {
    //set value back to global settings onyl when creating new entries not on editing existing ones
    if (_quickEntry.id == null) {
      _settingsRepository.currentMeal.value = _currentMeal.value;
    }
  }

  void _nameChanged() {
    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      _nameValid.value = false;
    } else {
      _nameValid.value = true;
    }
  }

  void _kJouleChanged() {
    if (_kJoule.value != null) {
      _kJouleValid.value = true;
    } else {
      _kJouleValid.value = false;
    }
  }

  Future<bool> setQuickEntry() async {
    bool quickEntryValid = true;

    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      quickEntryValid = false;
    }

    if (quickEntryValid && _kJoule.value == null) {
      quickEntryValid = false;
    }

    if (quickEntryValid) {
      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _currentEntryDate.value,
        dayTargetKJoule: _settingsRepository.getTargetKJouleForDay(day: _currentEntryDate.value),
      );

      _quickEntry.entryDate = _currentEntryDate.value;
      _quickEntry.meal = _currentMeal.value;
      _quickEntry.name = _name.value;
      _quickEntry.kJoule = _kJoule.value!;
      _quickEntry.amount = _amount.value;
      _quickEntry.amountMeasurementUnit = _amount.value != null ? _amountMeasurementUnit.value : null;
      _quickEntry.carbohydrates = _carbohydrates.value;
      _quickEntry.sugar = _sugar.value;
      _quickEntry.fat = _fat.value;
      _quickEntry.saturatedFat = _saturatedFat.value;
      _quickEntry.protein = _protein.value;
      _quickEntry.salt = _salt.value;

      await _journalRepository.setEatsJournalEntry(eatsJournalEntry: _quickEntry);
    }

    return quickEntryValid;
  }

  void _currentMeasurementUnitChanged() {
    _measurementUnitSwitchButtonChanged.notify();
  }

  @override
  void dispose() {
    _currentEntryDate.dispose();
    _currentMeal.dispose();
    _name.dispose();
    _nameValid.dispose();
    _amount.dispose();
    _amountMeasurementUnit.dispose();
    _kJoule.dispose();
    _kJouleValid.dispose();
    _carbohydrates.dispose();
    _sugar.dispose();
    _fat.dispose();
    _saturatedFat.dispose();
    _protein.dispose();
    _salt.dispose();
    _measurementUnitSwitchButtonChanged.dispose();

    super.dispose();
  }
}

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
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
       _amount = ValueNotifier(
         quickEntry.amount != null
             ? (quickEntry.amountMeasurementUnit! == MeasurementUnit.gram
                   ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.amount!)
                   : ConvertValidate.getDisplayVolume(volumeMl: quickEntry.amount!))
             : null,
       ),
       _amountMeasurementUnit = ValueNotifier(quickEntry.amountMeasurementUnit != null ? quickEntry.amountMeasurementUnit! : MeasurementUnit.gram),
       _energy = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: quickEntry.kJoule)),
       _energyValid = ValueNotifier(quickEntry.kJoule > 0),
       _carbohydrates = ValueNotifier(quickEntry.carbohydrates != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.carbohydrates!) : null),
       _sugar = ValueNotifier(quickEntry.sugar != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.sugar!) : null),
       _fat = ValueNotifier(quickEntry.fat != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.fat!) : null),
       _saturatedFat = ValueNotifier(quickEntry.saturatedFat != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.saturatedFat!) : null),
       _protein = ValueNotifier(quickEntry.protein != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.protein!) : null),
       _salt = ValueNotifier(quickEntry.salt != null ? ConvertValidate.getDisplayWeightG(weightG: quickEntry.salt!) : null),
       _currentEntryDate = ValueNotifier(quickEntry.entryDate),
       _currentMeal = ValueNotifier(quickEntry.meal) {
    if (_quickEntry.food != null) {
      throw StateError("Quick entry must not have a food.");
    }

    _currentEntryDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
    _name.addListener(_nameChanged);
    _energy.addListener(_kJouleChanged);
    _amountMeasurementUnit.addListener(_amountMeasurementUnitChanged);
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
  final ValueNotifier<int?> _energy;
  final ValueNotifier<bool> _energyValid;
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  ValueNotifier<DateTime> get currentEntryDate => _currentEntryDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  EatsJournalEntry get quickEntry => _quickEntry;

  ValueNotifier<String> get name => _name;
  ValueNotifier<bool> get nameValid => _nameValid;
  ValueNotifier<double?> get amount => _amount;
  ValueNotifier<MeasurementUnit> get amountMeasurementUnit => _amountMeasurementUnit;
  ValueNotifier<int?> get energy => _energy;
  ValueNotifier<bool> get energyValid => _energyValid;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

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
    if (_energy.value != null) {
      _energyValid.value = true;
    } else {
      _energyValid.value = false;
    }
  }

  Future<bool> setQuickEntry() async {
    bool quickEntryValid = true;

    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      quickEntryValid = false;
    }

    if (quickEntryValid && _energy.value == null) {
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
      _quickEntry.kJoule = ConvertValidate.getEnergyKJ(displayEnergy: _energy.value!);
      _quickEntry.amount = _amount.value != null ? ConvertValidate.getWeightG(displayWeight: _amount.value!) : null;
      _quickEntry.amountMeasurementUnit = _amount.value != null ? _amountMeasurementUnit.value : null;
      _quickEntry.carbohydrates = _carbohydrates.value != null ? ConvertValidate.getWeightG(displayWeight: _carbohydrates.value!) : null;
      _quickEntry.sugar = _sugar.value != null ? ConvertValidate.getWeightG(displayWeight: _sugar.value!) : null;
      _quickEntry.fat = _fat.value != null ? ConvertValidate.getWeightG(displayWeight: _fat.value!) : null;
      _quickEntry.saturatedFat = _saturatedFat.value != null ? ConvertValidate.getWeightG(displayWeight: _saturatedFat.value!) : null;
      _quickEntry.protein = _protein.value != null ? ConvertValidate.getWeightG(displayWeight: _protein.value!) : null;
      _quickEntry.salt = _salt.value != null ? ConvertValidate.getWeightG(displayWeight: _salt.value!) : null;

      await _journalRepository.setEatsJournalEntry(eatsJournalEntry: _quickEntry);
    }

    return quickEntryValid;
  }

  void _amountMeasurementUnitChanged() {
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
    _energy.dispose();
    _energyValid.dispose();
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

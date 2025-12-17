import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalQuickEntryAddScreenViewModel extends ChangeNotifier {
  EatsJournalQuickEntryAddScreenViewModel({required JournalRepository journalRepository, required SettingsRepository settingsRepository})
    : _journalRepository = journalRepository,
      _settingsRepository = settingsRepository,
      _quickEntry = EatsJournalEntry.quick(
        entryDate: settingsRepository.currentJournalDate.value,
        name: OpenEatsJournalStrings.emptyString,
        kJoule: NutritionCalculator.kJouleForOnekCal,
        meal: settingsRepository.currentMeal.value,
      ),
      _quickEntryId = ValueNotifier(null),
      _name = ValueNotifier(OpenEatsJournalStrings.emptyString),
      _nameValid = ValueNotifier(false),
      _amount = ValueNotifier(null),
      _amountMeasurementUnit = ValueNotifier(MeasurementUnit.gram),
      _kJoule = ValueNotifier(null),
      _carbohydrates = ValueNotifier(null),
      _sugar = ValueNotifier(null),
      _fat = ValueNotifier(null),
      _saturatedFat = ValueNotifier(null),
      _protein = ValueNotifier(null),
      _salt = ValueNotifier(null) {
    _name.addListener(_nameChanged);
    _kJoule.addListener(_kJouleChanged);
    _currentMeasurementUnit.addListener(_currentMeasurementUnitChanged);
  }

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  final EatsJournalEntry _quickEntry;
  final ValueNotifier<int?> _quickEntryId;
  final ValueNotifier<String> _name;
  final ValueNotifier<bool> _nameValid;
  final ValueNotifier<double?> _amount;
  final ValueNotifier<MeasurementUnit> _amountMeasurementUnit;
  final ValueNotifier<int?> _kJoule;
  final ValueNotifier<bool> _kJouleValid = ValueNotifier(false);
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit = ValueNotifier(MeasurementUnit.gram);
  final ExternalTriggerChangedNotifier _measurementUnitSwitchButtonChanged = ExternalTriggerChangedNotifier();

  ValueNotifier<int?> get quickEntryId => _quickEntryId;
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

  Future<bool> createQuickEntry() async {
    bool quickEntryValid = true;

    if (_name.value.trim() == OpenEatsJournalStrings.emptyString) {
      quickEntryValid = false;
    }

    if (quickEntryValid && _kJoule.value == null) {
      quickEntryValid = false;
    }

    if (quickEntryValid) {
      _quickEntry.entryDate = _settingsRepository.currentJournalDate.value;
      _quickEntry.name = _name.value;
      _quickEntry.kJoule = _kJoule.value!;
      _quickEntry.meal = _settingsRepository.currentMeal.value;
      _quickEntry.amount = _amount.value;
      _quickEntry.amountMeasurementUnit = _amount.value != null ? _amountMeasurementUnit.value : null;
      _quickEntry.carbohydrates = _carbohydrates.value;
      _quickEntry.sugar = _sugar.value;
      _quickEntry.fat = _fat.value;
      _quickEntry.saturatedFat = _saturatedFat.value;
      _quickEntry.protein = _protein.value;
      _quickEntry.salt = _salt.value;

      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _settingsRepository.currentJournalDate.value,
        dayTargetKJoule: _settingsRepository.getCurrentJournalDayTargetKJoule(),
      );
      
      await _journalRepository.setEatsJournalEntry(eatsJournalEntry: _quickEntry);
      _quickEntryId.value = _quickEntry.id;
    }

    return quickEntryValid;
  }

  void _currentMeasurementUnitChanged() {
    _measurementUnitSwitchButtonChanged.notify();
  }

  @override
  void dispose() {
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

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalScreenViewModel extends ChangeNotifier {
  EatsJournalScreenViewModel({required JournalRepository journalRepository, required SettingsRepository settingsRepository})
    : _journalRepository = journalRepository,
      _settingsRepository = settingsRepository,
      _dayData = journalRepository.getDayMealSums(date: settingsRepository.currentJournalDate.value),
      _currentWeight = journalRepository.getWeightJournalEntryFor(settingsRepository.currentJournalDate.value) {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
  }

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);
  final ValueNotifier<bool> _floatincActionMenuElapsed = ValueNotifier(false);
  final ExternalTriggerChangedNotifier _eatsJournalDataChanged = ExternalTriggerChangedNotifier();
  Future<FoodRepositoryGetDayMealSumsResult> _dayData;
  Future<WeightJournalEntry?> _currentWeight;
  final ExternalTriggerChangedNotifier _currentWeightChanged = ExternalTriggerChangedNotifier();

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get languageCode => _settingsRepository.languageCode.value;
  ValueListenable<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;
  ExternalTriggerChangedNotifier get eatsJournalDataChanged => _eatsJournalDataChanged;
  Future<FoodRepositoryGetDayMealSumsResult> get dayData => _dayData;
  Future<WeightJournalEntry?> get currentWeight => _currentWeight;
  SettingsRepository get settingsRepository => _settingsRepository;
  JournalRepository get journalRepository => _journalRepository;

  ExternalTriggerChangedNotifier get currentWeightChanged => _currentWeightChanged;

  void _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
    _dayData = _journalRepository.getDayMealSums(date: settingsRepository.currentJournalDate.value);
    _currentWeight = _journalRepository.getWeightJournalEntryFor(_settingsRepository.currentJournalDate.value);
    _eatsJournalDataChanged.notify();
  }

  void _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  void toggleFloatingActionButtons() {
    _floatincActionMenuElapsed.value = !_floatincActionMenuElapsed.value;
  }

  int getCurrentJournalDayTargetKJoule() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  int getCurrentJournalDayTargeCarbohydrates() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  int getCurrentJournalDayTargetProtein() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  int getCurrentJournalDayTargetFat() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  refreshData() {
    //no need to refresh data _dayData, either the screen was opened with saved day targets then they remain the same,
    //or the screen was opened without saved day targets then the target is requeried in EatsJournalScreen._getKJouleGaugeData e.g.
    //requery may be required when quick entries are implemented.
    _eatsJournalDataChanged.notify();
  }

  void refreshCurrentWeight() {
    _currentWeight = journalRepository.getWeightJournalEntryFor(settingsRepository.currentJournalDate.value);
    _currentWeightChanged.notify();
  }

  Future<double> getLastWeightJournalEntry() async {
    return await _journalRepository.getLastWeightJournalEntry();
  }

  Future<void> setWeightJournalEntry({required DateTime date, required double weight}) async {
    await _journalRepository.setWeightJournalEntry(date: date, weight: weight);
  }

  @override
  void dispose() {
    _currentJournalDate.dispose();
    _currentMeal.dispose();
    _floatincActionMenuElapsed.dispose();
    _eatsJournalDataChanged.dispose();
    _currentWeightChanged.dispose();

    super.dispose();
  }
}

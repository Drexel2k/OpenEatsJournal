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
      _dayNutritionDataPerMeal = journalRepository.getDayMealSums(date: settingsRepository.currentJournalDate.value),
      _currentWeight = journalRepository.getWeightJournalEntryFor(settingsRepository.currentJournalDate.value),
      _eatsJournalEntriesAvailableForLast8Days = journalRepository.getEatsJournalEntriesAvailableForLast8Days() {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;
  }

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);
  final ValueNotifier<bool> _floatincActionMenuElapsed = ValueNotifier(false);
  final ExternalTriggerChangedNotifier _eatsJournalDataChanged = ExternalTriggerChangedNotifier();
  Future<FoodRepositoryGetDayMealSumsResult> _dayNutritionDataPerMeal;
  Future<WeightJournalEntry?> _currentWeight;
  Future<Map<int, bool>> _eatsJournalEntriesAvailableForLast8Days;
  final ExternalTriggerChangedNotifier _currentWeightChanged = ExternalTriggerChangedNotifier();
  final ExternalTriggerChangedNotifier _settingsChanged = ExternalTriggerChangedNotifier();

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get languageCode => _settingsRepository.languageCode.value;
  ValueNotifier<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;
  ExternalTriggerChangedNotifier get eatsJournalDataChanged => _eatsJournalDataChanged;
  Future<FoodRepositoryGetDayMealSumsResult> get dayNutritionDataPerMeal => _dayNutritionDataPerMeal;
  Future<WeightJournalEntry?> get currentWeight => _currentWeight;
  Future<Map<int, bool>> get eatsJournalEntriesAvailableForLast8Days => _eatsJournalEntriesAvailableForLast8Days;

  ExternalTriggerChangedNotifier get currentWeightChanged => _currentWeightChanged;
  ExternalTriggerChangedNotifier get settingsChanged => _settingsChanged;

  bool get darkMode => _settingsRepository.darkMode.value;

  void updateCurrentJournalDateInSettingsRepository() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  void updateCurrentMealInSettingsRepository() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  void refreshNutritionData() {
    _eatsJournalEntriesAvailableForLast8Days = _journalRepository.getEatsJournalEntriesAvailableForLast8Days();
    _dayNutritionDataPerMeal = _journalRepository.getDayMealSums(date: _settingsRepository.currentJournalDate.value);
    _eatsJournalDataChanged.notify();
  }

  void refreshCurrentJournalDateAndMeal() {
    if (_settingsRepository.currentJournalDate.value != _currentJournalDate.value) {
      _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    }

    if (_settingsRepository.currentMeal.value != _currentMeal.value) {
      _currentMeal.value = _settingsRepository.currentMeal.value;
    }
  }

  void refreshWeightTarget() {
    //no need to refresh data _dayData, either the screen was opened with saved day targets then they remain the same in _dayData,
    //or the screen was opened without saved day targets then the target is requeried in EatsJournalScreen._getKJouleGaugeData e.g.
    _eatsJournalDataChanged.notify();
  }

  void notifySettingsChanged() {
    _settingsChanged.notify();
  }

  void refreshCurrentWeight() {
    _currentWeight = _journalRepository.getWeightJournalEntryFor(_settingsRepository.currentJournalDate.value);
    _currentWeightChanged.notify();
  }

  void toggleFloatingActionButtons() {
    _floatincActionMenuElapsed.value = !_floatincActionMenuElapsed.value;
  }

  double getCurrentJournalDayTargetKJoule() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  double getCurrentJournalDayTargeCarbohydrates() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  double getCurrentJournalDayTargetProtein() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
  }

  double getCurrentJournalDayTargetFat() {
    return _settingsRepository.getCurrentJournalDayTargetKJoule();
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

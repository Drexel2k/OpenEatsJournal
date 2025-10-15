import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalScreenViewModel extends ChangeNotifier {
  EatsJournalScreenViewModel({required JournalRepository journalRepository, required SettingsRepository settingsRepository})
    : _journalRepository = journalRepository,
      _settingsRepository = settingsRepository,
      _dayData = journalRepository.getDayData(date: settingsRepository.currentJournalDate.value) {
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
  Future<FoodRepositoryGetDayDataResult> _dayData;

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get languageCode => _settingsRepository.languageCode.value;
  ValueListenable<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;
  ExternalTriggerChangedNotifier get eatsJournalDataChanged => _eatsJournalDataChanged;
  Future<FoodRepositoryGetDayDataResult> get dayData => _dayData;
  SettingsRepository get settingsRepository => _settingsRepository;

  _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
    _dayData = _journalRepository.getDayData(date: settingsRepository.currentJournalDate.value);
    _eatsJournalDataChanged.notify();
  }

  _currentMealChanged() {
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
    _eatsJournalDataChanged.notify();
  }

  @override
  void dispose() {
    _currentJournalDate.dispose();
    _currentMeal.dispose();
    _floatincActionMenuElapsed.dispose();
    _eatsJournalDataChanged.dispose();

    super.dispose();
  }
}

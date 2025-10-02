import "package:flutter/material.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class DailyOverviewViewModel extends ChangeNotifier {
  DailyOverviewViewModel({required SettingsRepository settingsRepository}) : _settingsRepository = settingsRepository {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);  
  }

  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get languageCode => _settingsRepository.languageCode.value;

  _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  @override
  void dispose() {
    _currentJournalDate.dispose();
    _currentMeal.dispose();

    super.dispose();
  }
}

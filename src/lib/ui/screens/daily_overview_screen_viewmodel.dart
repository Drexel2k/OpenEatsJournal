import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class DailyOverviewScreenViewModel extends ChangeNotifier {
  DailyOverviewScreenViewModel({required SettingsRepository settingsRepository}) : _settingsRepository = settingsRepository {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);  
  }

  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);
  final ValueNotifier<bool> _floatincActionMenuElapsed = ValueNotifier(false);

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get languageCode => _settingsRepository.languageCode.value;

  ValueListenable<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;

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
    _floatincActionMenuElapsed.dispose();

    super.dispose();
  }

  void toggleFloatingActionButtons() {
    _floatincActionMenuElapsed.value = !_floatincActionMenuElapsed.value;
  }
}

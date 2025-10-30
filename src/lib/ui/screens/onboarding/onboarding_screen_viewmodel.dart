import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";

class OnboardingScreenViewModel extends ChangeNotifier {
  OnboardingScreenViewModel({required SettingsRepository settingsRepository, required JournalRepository journalRepository})
    : _settingsRepository = settingsRepository,
      _journalRepository = journalRepository,
      _gender = ValueNotifier(null),
      _birthday = ValueNotifier(null),
      _height = ValueNotifier(null),
      _weight = ValueNotifier(null),
      _activityFactor = ValueNotifier(null),
      _weightTarget = ValueNotifier(null),
      _dailyNeedKJoule = ValueNotifier(0),
      _dailyTargetKJoule = ValueNotifier(0) {
    _weightTarget.addListener(_calculateKJoule);
  }

  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);
  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  final ValueNotifier<Gender?> _gender;
  final ValueNotifier<DateTime?> _birthday;
  final ValueNotifier<int?> _height;
  final ValueNotifier<double?> _weight;
  final ValueNotifier<double?> _activityFactor;
  final ValueNotifier<WeightTarget?> _weightTarget;
  final ValueNotifier<int> _dailyNeedKJoule;
  final ValueNotifier<int> _dailyTargetKJoule;

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  bool get darkMode => _settingsRepository.darkMode.value;
  ValueNotifier<Gender?> get gender => _gender;
  ValueNotifier<DateTime?> get birthday => _birthday;
  ValueNotifier<int?> get height => _height;
  ValueNotifier<double?> get weight => _weight;
  ValueNotifier<double?> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget?> get weightTarget => _weightTarget;
  ValueNotifier<int> get dailyNeedKJoule => _dailyNeedKJoule;
  ValueNotifier<int> get dailyTargetKJoule => _dailyTargetKJoule;

  Future<void> saveOnboardingData() async {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _birthday.value!.year;
    final month = today.month - _birthday.value!.month;

    if (month < 0) {
      age = age - 1;
    }

    double weightLossKg = 0;
    if (_weightTarget.value == WeightTarget.lose025) {
      weightLossKg = 0.25;
    }

    if (_weightTarget.value == WeightTarget.lose05) {
      weightLossKg = 0.5;
    }

    if (_weightTarget.value == WeightTarget.lose075) {
      weightLossKg = 0.75;
    }

    double dailyKCaloriesD = NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: _weight.value!,
        heightCm: _height.value!,
        ageYear: age,
        gender: _gender.value!,
      ),
      activityFactor: _activityFactor.value!,
    );

    int dailyTargetKJoule = NutritionCalculator.calculateTargetKJoulePerDay(kJoulePerDay: dailyKCaloriesD, weightLossPerWeekKg: weightLossKg).round();

    await _settingsRepository.saveAllSettings(
      AllSettings(
        darkMode: _settingsRepository.darkMode.value,
        gender: _gender.value!,
        birthday: _birthday.value!,
        height: _height.value!,
        weight: _weight.value!,
        activityFactor: _activityFactor.value!,
        weightTarget: _weightTarget.value!,
        kJouleMonday: dailyTargetKJoule,
        kJouleTuesday: dailyTargetKJoule,
        kJouleWednesday: dailyTargetKJoule,
        kJouleThursday: dailyTargetKJoule,
        kJouleFriday: dailyTargetKJoule,
        kJouleSaturday: dailyTargetKJoule,
        kJouleSunday: dailyTargetKJoule,
        languageCode: _settingsRepository.languageCode.value,
      ),
    );

    await _journalRepository.addWeightJournalEntry(date: DateTime.now(), weight: _weight.value!);
  }

  void _calculateKJoule() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _birthday.value!.year;
    final month = today.month - _birthday.value!.month;

    if (month < 0) {
      age = age - 1;
    }

    double weightLossKg = 0;
    if (_weightTarget.value == WeightTarget.lose025) {
      weightLossKg = 0.25;
    }

    if (_weightTarget.value == WeightTarget.lose05) {
      weightLossKg = 0.5;
    }

    if (_weightTarget.value == WeightTarget.lose075) {
      weightLossKg = 0.75;
    }

    double dailyNeedKJouleDouble = NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: _weight.value!,
        heightCm: _height.value!,
        ageYear: age,
        gender: _gender.value!,
      ),
      activityFactor: _activityFactor.value!,
    );

    double dailyTargetKJouleDouble = NutritionCalculator.calculateTargetKJoulePerDay(kJoulePerDay: dailyNeedKJouleDouble, weightLossPerWeekKg: weightLossKg);

    _dailyNeedKJoule.value = dailyNeedKJouleDouble.round();
    _dailyTargetKJoule.value = dailyTargetKJouleDouble.round();
  }

  @override
  void dispose() {
    _gender.dispose();
    _birthday.dispose();
    _height.dispose();
    _weight.dispose();
    _activityFactor.dispose();
    _weightTarget.dispose();

    super.dispose();
  }
}

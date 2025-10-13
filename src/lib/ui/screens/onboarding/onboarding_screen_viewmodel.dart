import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";

class OnboardingScreenViewModel extends ChangeNotifier {
  OnboardingScreenViewModel({required SettingsRepository settingsRepository, required JournalRepository weightRepository})
    : _settingsRepository = settingsRepository,
      _weightRepository = weightRepository,
      _gender = ValueNotifier(null),
      _birthday = ValueNotifier(null),
      _height = ValueNotifier(null),
      _weight = ValueNotifier(null),
      _activityFactor = ValueNotifier(null),
      _weightTarget = ValueNotifier(null),
      _dailyNeedKCalories = ValueNotifier(0),
      _dailyTargetCalories = ValueNotifier(0) {
    _weightTarget.addListener(_calculateKCalories);
  }

  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);
  final JournalRepository _weightRepository;
  final SettingsRepository _settingsRepository;

  final ValueNotifier<Gender?> _gender;
  final ValueNotifier<DateTime?> _birthday;
  final ValueNotifier<int?> _height;
  final ValueNotifier<double?> _weight;
  final ValueNotifier<double?> _activityFactor;
  final ValueNotifier<WeightTarget?> _weightTarget;
  final ValueNotifier<int> _dailyNeedKCalories;
  final ValueNotifier<int> _dailyTargetCalories;

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  bool get darkMode => _settingsRepository.darkMode.value;
  ValueNotifier<Gender?> get gender => _gender;
  ValueNotifier<DateTime?> get birthday => _birthday;
  ValueNotifier<int?> get height => _height;
  ValueNotifier<double?> get weight => _weight;
  ValueNotifier<double?> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget?> get weightTarget => _weightTarget;
  ValueNotifier<int> get dailyNeedKCalories => _dailyNeedKCalories;
  ValueNotifier<int> get dailyTargetCalories => _dailyTargetCalories;

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

    double dailyKCaloriesD = NutritionCalculator.calculateTotalKCaloriesPerDay(
      kCaloriesPerDay: NutritionCalculator.calculateBasalMetabolicRate(
        weightKg: _weight.value!,
        heightCm: _height.value!,
        ageYear: age,
        gender: _gender.value!,
      ),
      activityFactor: _activityFactor.value!,
    );

    int dailyTargetCalories = NutritionCalculator.calculateTargetCaloriesPerDay(kCaloriesPerDay: dailyKCaloriesD, weightLossPerWeekKg: weightLossKg).round();

    await _settingsRepository.saveAllSettings(
      AllSettings(
        darkMode: _settingsRepository.darkMode.value,
        gender: _gender.value!,
        birthday: _birthday.value!,
        height: _height.value!,
        weight: _weight.value!,
        activityFactor: _activityFactor.value!,
        weightTarget: _weightTarget.value!,
        kCalsMonday: dailyTargetCalories,
        kCalsTuesday: dailyTargetCalories,
        kCalsWednesday: dailyTargetCalories,
        kCalsThursday: dailyTargetCalories,
        kCalsFriday: dailyTargetCalories,
        kCalsSaturday: dailyTargetCalories,
        kCalsSunday: dailyTargetCalories,
        languageCode: _settingsRepository.languageCode.value,
      ),
    );

    await _weightRepository.addWeightJournalEntry(date: DateTime.now(), weight: _weight.value!);
  }

  void _calculateKCalories() {
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

    double dailyKCaloriesD = NutritionCalculator.calculateTotalKCaloriesPerDay(
      kCaloriesPerDay: NutritionCalculator.calculateBasalMetabolicRate(
        weightKg: _weight.value!,
        heightCm: _height.value!,
        ageYear: age,
        gender: _gender.value!,
      ),
      activityFactor: _activityFactor.value!,
    );
    double dailyTargetCaloriesD = NutritionCalculator.calculateTargetCaloriesPerDay(kCaloriesPerDay: dailyKCaloriesD, weightLossPerWeekKg: weightLossKg);

    _dailyNeedKCalories.value = dailyKCaloriesD.round();
    _dailyTargetCalories.value = dailyTargetCaloriesD.round();
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

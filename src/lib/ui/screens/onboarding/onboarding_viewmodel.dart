import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/settings.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";

class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({required SettingsRepository settingsRepository,
    required WeightRepository weightRepository}) :
      _settingsRepository = settingsRepository,
      _weightRepository = weightRepository,
      _gender = ValueNotifier(null),
      _birthday = ValueNotifier(null),
      _height = ValueNotifier(null),
      _weight = ValueNotifier(null),
      _activityFactor = ValueNotifier(null),
      _weightTarget = ValueNotifier(WeightTarget.keep);

  final WeightRepository _weightRepository;
  final SettingsRepository _settingsRepository;

  final ValueNotifier<Gender?> _gender;
  final ValueNotifier<DateTime?> _birthday;
  final ValueNotifier<int?> _height;
  final ValueNotifier<double?> _weight;
  final ValueNotifier<double?> _activityFactor;
  final ValueNotifier<WeightTarget> _weightTarget;

  bool get darkMode => _settingsRepository.darkMode.value;
  ValueNotifier<Gender?> get gender => _gender;
  ValueNotifier<DateTime?> get birthday => _birthday;
  ValueNotifier<int?> get height => _height;
  ValueNotifier<double?> get weight => _weight;
  ValueNotifier<double?> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget> get weightTarget => _weightTarget;

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
      NutritionCalculator.calculateBasalMetabolicRate(
        _weight.value!,
        _height.value!,
        age,
        _gender.value!,
      ),
      _activityFactor.value!,
    );
    double dailyWeightLossCaloriesD =
        NutritionCalculator.calculateTotalWithWeightLoss(
          dailyKCaloriesD,
          weightLossKg,
        );

    await _settingsRepository.setSettings(
      Settings(
        darkMode: _settingsRepository.darkMode.value,
        gender: _gender.value!,
        birthday: _birthday.value!,
        height: _height.value!,
        weight: _weight.value!,
        activityFactor: _activityFactor.value!,
        weightTarget: _weightTarget.value,
        kCalsMonday: dailyWeightLossCaloriesD,
        kCalsTuesday: dailyWeightLossCaloriesD,
        kCalsWednesday: dailyWeightLossCaloriesD,
        kCalsThursday: dailyWeightLossCaloriesD,
        kCalsFriday: dailyWeightLossCaloriesD,
        kCalsSaturday: dailyWeightLossCaloriesD,
        kCalsSunday: dailyWeightLossCaloriesD,
        languageCode: _settingsRepository.languageCode.value
      ),
    );

    await _weightRepository.insertWeight(DateTime.now(), _weight.value!);
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

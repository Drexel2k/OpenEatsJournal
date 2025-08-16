import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      _darkMode = ValueNotifier(settingsRepository.darkMode.value),
      _languageCode = ValueNotifier(settingsRepository.languageCode.value),
      _dailyCalories = ValueNotifier(1),
      _dailyWeightLossCalories = ValueNotifier(1),
      _gender = ValueNotifier(settingsRepository.gender),
      _birthday = ValueNotifier(settingsRepository.birthday),
      _height = ValueNotifier(settingsRepository.height),
      _weight = ValueNotifier(settingsRepository.weight),
      _activityFactor = ValueNotifier(settingsRepository.activityFactor),
      _weightTarget = ValueNotifier(settingsRepository.weightTarget) {
    _setDailyCalories();
    _setDailyWeightlossKCalories();
    _darkMode.addListener(_darkModeChanged);
    _languageCode.addListener(_languageCodeChanged);
    _gender.addListener(_genderChanged);
    _birthday.addListener(_birthdayChanged);
    _height.addListener(_heightChanged);
    _weight.addListener(_weightChanged);
    _activityFactor.addListener(_activityFactorChanged);
    _weightTarget.addListener(_weightTargetChanged);
  }

  final SettingsRepository _settingsRepository;

  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<String> _languageCode;
  final ValueNotifier<int> _dailyCalories;
  final ValueNotifier<int> _dailyWeightLossCalories;
  final ValueNotifier<Gender> _gender;
  final ValueNotifier<DateTime> _birthday;
  final ValueNotifier<int> _height;
  final ValueNotifier<double> _weight;
  final ValueNotifier<double> _activityFactor;
  final ValueNotifier<WeightTarget> _weightTarget;

  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  ValueNotifier<int> get dailyCalories => _dailyCalories;
  ValueNotifier<int> get dailyWeightLossCalories => _dailyWeightLossCalories;
  ValueNotifier<Gender> get gender => _gender;
  ValueNotifier<DateTime> get birthday => _birthday;
  ValueNotifier<int> get height => _height;
  ValueNotifier<double> get weight => _weight;
  ValueNotifier<double> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget> get weightTarget => _weightTarget;

  int get kCalsMonday => _settingsRepository.kCalsMonday;
  int get kCalsTuesday => _settingsRepository.kCalsTuesday;
  int get kCalsWednesday => _settingsRepository.kCalsWednesday;
  int get kCalsThursday => _settingsRepository.kCalsThursday;
  int get kCalsFriday => _settingsRepository.kCalsFriday;
  int get kCalsSaturday => _settingsRepository.kCalsSaturday;
  int get kCalsSunday => _settingsRepository.kCalsSunday;

  void _setDailyWeightlossKCalories() {
    _dailyWeightLossCalories.value =
        ((_settingsRepository.kCalsMonday +
                    _settingsRepository.kCalsTuesday +
                    _settingsRepository.kCalsWednesday +
                    _settingsRepository.kCalsThursday +
                    _settingsRepository.kCalsFriday +
                    _settingsRepository.kCalsSaturday +
                    _settingsRepository.kCalsSunday) /
                7)
            .round();
  }

  double _getDailyCalories() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _birthday.value.year;
    final month = today.month - _birthday.value.month;

    if (month < 0) {
      age = age - 1;
    }

    return NutritionCalculator.calculateTotalKCaloriesPerDay(
      NutritionCalculator.calculateBasalMetabolicRate(
        _weight.value,
        _height.value,
        age,
        _gender.value,
      ),
      _activityFactor.value,
    );
  }

  _setDailyCalories() {
    _dailyCalories.value = _getDailyCalories().round();
  }

  void _darkModeChanged() {
    _settingsRepository.darkMode.value = _darkMode.value;
  }

  void _languageCodeChanged() {
    _settingsRepository.languageCode.value = _languageCode.value;
  }

  void _genderChanged() {
    _settingsRepository.gender = _gender.value;
    _setDailyCalories();
  }

  void _birthdayChanged() {
    _settingsRepository.birthday = _birthday.value;
    _setDailyCalories();
  }

  void _heightChanged() {
    _settingsRepository.height = _height.value;
    _setDailyCalories();
  }

  void _weightChanged() {
    _settingsRepository.weight = _weight.value;
    _setDailyCalories();
  }

  void _activityFactorChanged() {
    _settingsRepository.activityFactor = _activityFactor.value;
    _setDailyCalories();
  }

  void _weightTargetChanged() {
    _settingsRepository.weightTarget = _weightTarget.value;
  }

  Future<void> recalculateDailyCalTargetsAndSave() async {
    double weightLossKg = 0;
    if (_settingsRepository.weightTarget == WeightTarget.lose025) {
      weightLossKg = 0.25;
    }

    if (_settingsRepository.weightTarget == WeightTarget.lose05) {
      weightLossKg = 0.5;
    }

    if (_settingsRepository.weightTarget == WeightTarget.lose075) {
      weightLossKg = 0.75;
    }

    int dailyWeightLossCalories =
        NutritionCalculator.calculateTotalWithWeightLoss(
          _getDailyCalories(),
          weightLossKg,
        ).round();

    await _settingsRepository.saveDailyCaloriesTargetsSame(
      dailyWeightLossCalories,
    );

    _dailyWeightLossCalories.value = dailyWeightLossCalories;
  }

  Future<void> setDailyCaloriesAndSave(KCalSettings kCalSettings) async {
    _settingsRepository.saveDailyCaloriesTargetsSameIndividual(kCalSettings);

    _dailyWeightLossCalories.value =
        ((kCalSettings.kCalsMonday +
                    kCalSettings.kCalsTuesday +
                    kCalSettings.kCalsWednesday +
                    kCalSettings.kCalsThursday +
                    kCalSettings.kCalsFriday +
                    kCalSettings.kCalsSaturday +
                    kCalSettings.kCalsSunday) /
                7)
            .round();
  }

  @override
  void dispose() {
    _darkMode.dispose();
    _languageCode.dispose();
    _dailyCalories.dispose();
    _dailyWeightLossCalories.dispose();
    _gender.dispose();
    _birthday.dispose();
    _height.dispose();
    _weight.dispose();
    _activityFactor.dispose();
    _weightTarget.dispose();

    super.dispose();
  }
}

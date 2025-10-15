import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class SettingsScreenViewModel extends ChangeNotifier {
  SettingsScreenViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      _darkMode = ValueNotifier(settingsRepository.darkMode.value),
      _languageCode = ValueNotifier(settingsRepository.languageCode.value),
      _dailyKJoule = ValueNotifier(1),
      _dailyTargetKJoule = ValueNotifier(1),
      _gender = ValueNotifier(settingsRepository.gender),
      _birthday = ValueNotifier(settingsRepository.birthday),
      _height = ValueNotifier(settingsRepository.height),
      _heightValid = ValueNotifier(true),
      _weight = ValueNotifier(settingsRepository.weight),
      _weightValid = ValueNotifier(true),
      _activityFactor = ValueNotifier(settingsRepository.activityFactor),
      _weightTarget = ValueNotifier(settingsRepository.weightTarget) {
    _setDailyKJoule();
    _setDailyTargetKJoule();
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

  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);
  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<String> _languageCode;
  final ValueNotifier<int> _dailyKJoule;
  final ValueNotifier<int> _dailyTargetKJoule;
  final ValueNotifier<Gender> _gender;
  final ValueNotifier<DateTime> _birthday;
  final ValueNotifier<int> _height;
  final ValueNotifier<bool> _heightValid;
  final ValueNotifier<double> _weight;
  final ValueNotifier<bool> _weightValid;
  final ValueNotifier<double> _activityFactor;
  final ValueNotifier<WeightTarget> _weightTarget;

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  ValueNotifier<int> get dailyKJoule => _dailyKJoule;
  ValueNotifier<int> get dailyTargetKJoule => _dailyTargetKJoule;
  ValueNotifier<Gender> get gender => _gender;
  ValueNotifier<DateTime> get birthday => _birthday;
  ValueNotifier<int> get height => _height;
  ValueNotifier<bool> get heightValid => _heightValid;
  ValueNotifier<double> get weight => _weight;
  ValueNotifier<bool> get weightValid => _weightValid;
  ValueNotifier<double> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget> get weightTarget => _weightTarget;

  int get kJouleMonday => _settingsRepository.kJouleMonday;
  int get kJouleTuesday => _settingsRepository.kJouleTuesday;
  int get kJouleWednesday => _settingsRepository.kJouleWednesday;
  int get kJouleThursday => _settingsRepository.kJouleThursday;
  int get kJouleFriday => _settingsRepository.kJouleFriday;
  int get kJouleSaturday => _settingsRepository.kJouleSaturday;
  int get kJouleSunday => _settingsRepository.kJouleSunday;

  void _setDailyTargetKJoule() {
    _dailyTargetKJoule.value =
        ((_settingsRepository.kJouleMonday +
                    _settingsRepository.kJouleTuesday +
                    _settingsRepository.kJouleWednesday +
                    _settingsRepository.kJouleThursday +
                    _settingsRepository.kJouleFriday +
                    _settingsRepository.kJouleSaturday +
                    _settingsRepository.kJouleSunday) /
                7)
            .round();
  }

  double _getDailyKJoule() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _birthday.value.year;
    final month = today.month - _birthday.value.month;

    if (month < 0) {
      age = age - 1;
    }

    return NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: _weight.value,
        heightCm: _height.value,
        ageYear: age,
        gender: _gender.value,
      ),
      activityFactor: _activityFactor.value,
    );
  }

  _setDailyKJoule() {
    _dailyKJoule.value = _getDailyKJoule().round();
  }

  void _darkModeChanged() {
    _settingsRepository.darkMode.value = _darkMode.value;
  }

  void _languageCodeChanged() {
    _settingsRepository.languageCode.value = _languageCode.value;
  }

  void _genderChanged() {
    _settingsRepository.gender = _gender.value;
    _setDailyKJoule();
  }

  void _birthdayChanged() {
    _settingsRepository.birthday = _birthday.value;
    _setDailyKJoule();
  }

  void _heightChanged() {
    _settingsRepository.height = _height.value;
    _setDailyKJoule();
  }

  void _weightChanged() {
    _settingsRepository.weight = _weight.value;
    _setDailyKJoule();
  }

  void _activityFactorChanged() {
    _settingsRepository.activityFactor = _activityFactor.value;
    _setDailyKJoule();
  }

  void _weightTargetChanged() {
    _settingsRepository.weightTarget = _weightTarget.value;
  }

  Future<void> recalculateDailykJouleTargetsAndSave() async {
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

    int dailyTargetKJoule = NutritionCalculator.calculateTargetKJoulePerDay(kJoulePerDay: _getDailyKJoule(), weightLossPerWeekKg: weightLossKg).round();

    await _settingsRepository.saveDailyKJouleTargetsSame(dailyTargetKJoule);

    _dailyTargetKJoule.value = dailyTargetKJoule;
  }

  Future<void> setDailyKJouleAndSave(KJoulePerDay kJouleSettings) async {
    _settingsRepository.saveDailyKJouleTargetsSameIndividual(kJouleSettings);

    _dailyTargetKJoule.value =
        ((kJouleSettings.kJouleMonday +
                    kJouleSettings.kJouleTuesday +
                    kJouleSettings.kJouleWednesday +
                    kJouleSettings.kJouleThursday +
                    kJouleSettings.kJouleFriday +
                    kJouleSettings.kJouleSaturday +
                    kJouleSettings.kJouleSunday) /
                7)
            .round();
  }

  @override
  void dispose() {
    _currentPageIndex.dispose();
    _darkMode.dispose();
    _languageCode.dispose();
    _dailyKJoule.dispose();
    _dailyTargetKJoule.dispose();
    _gender.dispose();
    _birthday.dispose();
    _height.dispose();
    _heightValid.dispose();
    _weight.dispose();
    _weightValid.dispose();
    _activityFactor.dispose();
    _weightTarget.dispose();

    super.dispose();
  }
}

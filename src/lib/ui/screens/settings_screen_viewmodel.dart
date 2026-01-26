import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class SettingsScreenViewModel extends ChangeNotifier {
  SettingsScreenViewModel({required SettingsRepository settingsRepository, required double weight})
    : _settingsRepository = settingsRepository,
      _darkMode = ValueNotifier(settingsRepository.darkMode.value),
      _languageCode = ValueNotifier(settingsRepository.languageCode.value),
      _gender = ValueNotifier(settingsRepository.gender),
      _birthday = ValueNotifier(settingsRepository.birthday),
      _height = ValueNotifier(settingsRepository.height),
      _lastValidWeight = weight,
      _weight = ValueNotifier(weight),
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
  final ValueNotifier<int> _dailyKJoule = ValueNotifier(1);
  final ValueNotifier<int> _dailyTargetKJoule = ValueNotifier(1);
  final ValueNotifier<Gender> _gender;
  final ValueNotifier<DateTime> _birthday;
  final ValueNotifier<int?> _height;
  final ValueNotifier<bool> _heightValid = ValueNotifier(true);
  double _lastValidWeight;
  final ValueNotifier<double?> _weight;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);
  final ValueNotifier<double> _activityFactor;
  final ValueNotifier<WeightTarget> _weightTarget;

  final Debouncer _heightDebouncer = Debouncer();
  final Debouncer _weightDebouncer = Debouncer();

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  ValueNotifier<int> get dailyKJoule => _dailyKJoule;
  ValueNotifier<int> get dailyTargetKJoule => _dailyTargetKJoule;
  ValueNotifier<Gender> get gender => _gender;
  ValueNotifier<DateTime> get birthday => _birthday;
  ValueNotifier<int?> get height => _height;
  ValueNotifier<bool> get heightValid => _heightValid;
  double get lastValidWeight => _lastValidWeight;
  ValueNotifier<double?> get weight => _weight;
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
  int get repositoryHeight => _settingsRepository.height;

  SettingsRepository get settingsRepository => _settingsRepository;

  String get githubUrl => _settingsRepository.githubUrl;
  String get paypalUrl => _settingsRepository.paypalUrl!;
  String get donateUrl => _settingsRepository.donateUrl;
  String get contactData => _settingsRepository.contactData!;
  String get appVersion => _settingsRepository.appVersion;

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

  int _getDailyKJoule() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _settingsRepository.birthday.year;
    final month = today.month - _settingsRepository.birthday.month;

    if (month < 0) {
      age = age - 1;
    }

    int dailyTargetKJoule = NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: _lastValidWeight,
        heightCm: _settingsRepository.height,
        ageYear: age,
        gender: _settingsRepository.gender,
      ),
      activityFactor: _settingsRepository.activityFactor,
    ).round();

    if (dailyTargetKJoule < 1) {
      dailyTargetKJoule = 1;
    }

    return dailyTargetKJoule;
  }

  void _setDailyKJoule() {
    _dailyKJoule.value = _getDailyKJoule();
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
    if (_height.value != null && _height.value! > 0 && _height.value! < 1000) {
      _heightValid.value = true;

      _heightDebouncer.run(
        callback: () async {
          _settingsRepository.height = _height.value!;
          _setDailyKJoule();
        },
      );
    } else {
      _heightDebouncer.cancel();
      _heightValid.value = false;
    }
  }

  void _weightChanged() {
    if (_weight.value != null && _weight.value! > 0 && _weight.value! <= 1000) {
      _weightValid.value = true;

      _weightDebouncer.run(
        callback: () async {
          _lastValidWeight = _weight.value!;
          _setDailyKJoule();
        },
      );
    } else {
      _weightDebouncer.cancel();
      _weightValid.value = false;
    }
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

    int dailyTargetKJoule = NutritionCalculator.calculateTargetKJoulePerDay(
      kJoulePerDay: _getDailyKJoule().toDouble(),
      weightLossPerWeekKg: weightLossKg,
    ).round();
    if (dailyTargetKJoule < 1) {
      dailyTargetKJoule = 1;
    }

    await _settingsRepository.saveDailyKJouleTargetsSame(dailyTargetKJoule: dailyTargetKJoule);

    _dailyTargetKJoule.value = dailyTargetKJoule;
  }

  Future<bool> exportDatabase() async {
    return await _settingsRepository.exportDatabase();
  }

  Future<bool> importDatabase() async {
    return await _settingsRepository.importDatabase();
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

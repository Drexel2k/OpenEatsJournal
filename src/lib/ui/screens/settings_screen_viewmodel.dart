import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
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
      _height = ValueNotifier(ConvertValidate.getDisplayHeight(heightCm: settingsRepository.height)),
      _lastValidWeight = weight,
      _weight = ValueNotifier(ConvertValidate.getDisplayWeightKg(weightKg: weight)),
      _activityFactor = ValueNotifier(settingsRepository.activityFactor),
      _weightTarget = ValueNotifier(settingsRepository.weightTarget),
      _energyUnit = ValueNotifier(settingsRepository.energyUnit),
      _heightUnit = ValueNotifier(settingsRepository.heightUnit),
      _weightUnit = ValueNotifier(settingsRepository.weightUnit),
      _volumeUnit = ValueNotifier(settingsRepository.volumeUnit),
      _displayWeightTarget1 = _getDisplayWeightTarget1(weightUnit: settingsRepository.weightUnit),
      _displayWeightTarget2 = _getDisplayWeightTarget2(weightUnit: settingsRepository.weightUnit),
      _displayWeightTarget3 = _getDisplayWeightTarget3(weightUnit: settingsRepository.weightUnit) {
    _setDailyKJoule();
    _setDailyTargetKJoule();
    _darkMode.addListener(_darkModeChanged);
    _languageCode.addListener(_languageCodeChanged);
    _gender.addListener(_genderChanged);
    _birthday.addListener(_birthdayChanged);
    _activityFactor.addListener(_activityFactorChanged);
    _weightTarget.addListener(_weightTargetChanged);
    _energyUnit.addListener(_energyUnitChanged);
    _heightUnit.addListener(_heightUnitChanged);
    _weightUnit.addListener(_weightUnitChanged);
    _volumeUnit.addListener(_volumeUnitChanged);
  }

  final SettingsRepository _settingsRepository;

  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);
  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<String> _languageCode;
  final ValueNotifier<int> _dailyKJoule = ValueNotifier(1);
  final ValueNotifier<int> _dailyTargetKJoule = ValueNotifier(1);
  final ValueNotifier<Gender> _gender;
  final ValueNotifier<DateTime> _birthday;
  final ValueNotifier<double?> _height;
  final ValueNotifier<bool> _heightValid = ValueNotifier(true);
  double _lastValidWeight;
  final ValueNotifier<double?> _weight;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);
  final ValueNotifier<double> _activityFactor;
  final ValueNotifier<WeightTarget> _weightTarget;
  final ValueNotifier<EnergyUnit> _energyUnit;
  final ValueNotifier<HeightUnit> _heightUnit;
  final ValueNotifier<WeightUnit> _weightUnit;
  final ValueNotifier<VolumeUnit> _volumeUnit;
  //needed for display and use of nice weight target values depending on weight unit setting, e.g. 0.5kg/1lb instead of 0.5kg/1.102lb
  double _displayWeightTarget1;
  double _displayWeightTarget2;
  double _displayWeightTarget3;

  final Debouncer _heightDebouncer = Debouncer();
  final Debouncer _weightDebouncer = Debouncer();

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  ValueNotifier<int> get dailyKJoule => _dailyKJoule;
  ValueNotifier<int> get dailyTargetKJoule => _dailyTargetKJoule;
  ValueNotifier<Gender> get gender => _gender;
  ValueNotifier<DateTime> get birthday => _birthday;
  ValueNotifier<double?> get height => _height;
  ValueNotifier<bool> get heightValid => _heightValid;
  double get lastValidWeight => ConvertValidate.getDisplayWeightKg(weightKg: _lastValidWeight);
  ValueNotifier<double?> get weight => _weight;
  ValueNotifier<bool> get weightValid => _weightValid;
  ValueNotifier<double> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget> get weightTarget => _weightTarget;
  ValueNotifier<EnergyUnit> get energyUnit => _energyUnit;
  ValueNotifier<HeightUnit> get heightUnit => _heightUnit;
  ValueNotifier<WeightUnit> get weightUnit => _weightUnit;
  ValueNotifier<VolumeUnit> get volumeUnit => _volumeUnit;
  double get displayWeightTarget1 => _displayWeightTarget1;
  double get displayWeightTarget2 => _displayWeightTarget2;
  double get displayWeightTarget3 => _displayWeightTarget3;

  double get kJouleMonday => _settingsRepository.kJouleMonday;
  double get kJouleTuesday => _settingsRepository.kJouleTuesday;
  double get kJouleWednesday => _settingsRepository.kJouleWednesday;
  double get kJouleThursday => _settingsRepository.kJouleThursday;
  double get kJouleFriday => _settingsRepository.kJouleFriday;
  double get kJouleSaturday => _settingsRepository.kJouleSaturday;
  double get kJouleSunday => _settingsRepository.kJouleSunday;
  double get repositoryHeight => ConvertValidate.getDisplayHeight(heightCm: _settingsRepository.height);

  bool get useStagingServices => _settingsRepository.useStagingServices;
  String get contactData => _settingsRepository.contactData!;
  String get appVersion => _settingsRepository.appVersion;

  void _setDailyTargetKJoule() {
    _dailyTargetKJoule.value = ConvertValidate.getDisplayEnergy(
      energyKJ:
          (_settingsRepository.kJouleMonday +
              _settingsRepository.kJouleTuesday +
              _settingsRepository.kJouleWednesday +
              _settingsRepository.kJouleThursday +
              _settingsRepository.kJouleFriday +
              _settingsRepository.kJouleSaturday +
              _settingsRepository.kJouleSunday) /
          7,
    );
  }

  double _getDailyKJoule() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - _settingsRepository.birthday.year;
    final month = today.month - _settingsRepository.birthday.month;

    if (month < 0) {
      age = age - 1;
    }

    double dailyKJoule = NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: _lastValidWeight,
        heightCm: _settingsRepository.height,
        ageYear: age,
        gender: _settingsRepository.gender,
      ),
      activityFactor: _settingsRepository.activityFactor,
    );

    if (dailyKJoule < 1) {
      dailyKJoule = 1;
    }

    return dailyKJoule;
  }

  void _setDailyKJoule() {
    _dailyKJoule.value = ConvertValidate.getDisplayEnergy(energyKJ: _getDailyKJoule());
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

  void setHeight({required double? height, onlyUnitChange = false}) {
    _height.value = height;

    if (!onlyUnitChange) {
      if (ConvertValidate.heightValid(displayHeight: _height.value?.toDouble())) {
        _heightValid.value = true;

        _heightDebouncer.run(
          callback: () async {
            _settingsRepository.height = ConvertValidate.getHeightCm(displayHeight: _height.value!.toDouble());
            _setDailyKJoule();
          },
        );
      } else {
        _heightDebouncer.cancel();
        _heightValid.value = false;
      }
    }
  }

  void setWeight({required double? weight, onlyUnitChange = false}) {
    _weight.value = weight;

    if (!onlyUnitChange) {
      if (ConvertValidate.weightValid(displayWeight: _weight.value)) {
        _weightValid.value = true;

        _weightDebouncer.run(
          callback: () async {
            _lastValidWeight = ConvertValidate.getWeightKg(displayWeight: _weight.value!);
            _setDailyKJoule();
          },
        );
      } else {
        _weightDebouncer.cancel();
        _weightValid.value = false;
      }
    }
  }

  void _activityFactorChanged() {
    _settingsRepository.activityFactor = _activityFactor.value;
    _setDailyKJoule();
  }

  void _weightTargetChanged() {
    _settingsRepository.weightTarget = _weightTarget.value;
  }

  void _energyUnitChanged() {
    _settingsRepository.energyUnit = _energyUnit.value;
    _updateConvertValidate();

    _setDailyKJoule();
    _setDailyTargetKJoule();
  }

  void _heightUnitChanged() {
    _settingsRepository.heightUnit = _heightUnit.value;
    _updateConvertValidate();

    setHeight(height: ConvertValidate.getDisplayHeight(heightCm: _settingsRepository.height), onlyUnitChange: true);
  }

  void _weightUnitChanged() {
    _settingsRepository.weightUnit = _weightUnit.value;
    _updateConvertValidate();

    setWeight(weight: ConvertValidate.getDisplayWeightKg(weightKg: _lastValidWeight), onlyUnitChange: true);

    _displayWeightTarget1 = _getDisplayWeightTarget1(weightUnit: _settingsRepository.weightUnit);
    _displayWeightTarget2 = _getDisplayWeightTarget2(weightUnit: _settingsRepository.weightUnit);
    _displayWeightTarget3 = _getDisplayWeightTarget3(weightUnit: _settingsRepository.weightUnit);
  }

  void _volumeUnitChanged() {
    _settingsRepository.volumeUnit = _volumeUnit.value;
    _updateConvertValidate();
  }

  void _updateConvertValidate() {
    ConvertValidate.init(
      languageCode: _settingsRepository.languageCode.value,
      energyUnit: _settingsRepository.energyUnit,
      heightUnit: _settingsRepository.heightUnit,
      weightUnit: _settingsRepository.weightUnit,
      volumeUnit: _settingsRepository.volumeUnit,
    );
  }

  Future<void> recalculateDailykJouleTargetsAndSave() async {
    double weightLossKg = 0;
    if (_settingsRepository.weightTarget == WeightTarget.lose025) {
      weightLossKg = ConvertValidate.getWeightKg(displayWeight: displayWeightTarget1);
    }

    if (_settingsRepository.weightTarget == WeightTarget.lose05) {
      weightLossKg = ConvertValidate.getWeightKg(displayWeight: displayWeightTarget2);
    }

    if (_settingsRepository.weightTarget == WeightTarget.lose075) {
      weightLossKg = ConvertValidate.getWeightKg(displayWeight: displayWeightTarget3);
    }

    double dailyTargetKJoule = NutritionCalculator.calculateTargetKJoulePerDay(kJoulePerDay: _getDailyKJoule(), weightLossPerWeekKg: weightLossKg);
    if (dailyTargetKJoule < 1) {
      dailyTargetKJoule = 1;
    }

    await _settingsRepository.saveDailyKJouleTargetsSame(dailyTargetKJoule: dailyTargetKJoule);

    _dailyTargetKJoule.value = ConvertValidate.getDisplayEnergy(energyKJ: dailyTargetKJoule);
  }

  Future<bool> exportDatabase() async {
    return await _settingsRepository.exportDatabase();
  }

  Future<bool> importDatabase() async {
    return await _settingsRepository.importDatabase();
  }

  static double _getDisplayWeightTarget1({required WeightUnit weightUnit}) {
    return weightUnit == WeightUnit.g ? 0.25 : 0.5;
  }

  static double _getDisplayWeightTarget2({required WeightUnit weightUnit}) {
    return weightUnit == WeightUnit.g ? 0.5 : 1;
  }

  static double _getDisplayWeightTarget3({required WeightUnit weightUnit}) {
    return weightUnit == WeightUnit.g ? 0.75 : 1.5;
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

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";

class OnboardingScreenViewModel extends ChangeNotifier {
  OnboardingScreenViewModel({
    required SettingsRepository settingsRepository,
    required JournalRepository journalRepository,
    required bool darkMode,
    required String languageCode,
  }) : _settingsRepository = settingsRepository,
       _journalRepository = journalRepository,
       _gender = ValueNotifier(null),
       _birthday = ValueNotifier(null),
       _height = ValueNotifier(null),
       _weight = ValueNotifier(null),
       _activityFactor = ValueNotifier(null),
       _weightTarget = ValueNotifier(null),
       _dailyNeedEnergy = ValueNotifier(null),
       _dailyTargetEnergy = ValueNotifier(null),
       _volumeUnit = ValueNotifier(VolumeUnit.ml),
       _darkMode = darkMode,
       _languageCode = languageCode {
    _gender.addListener(calculateKJoule);
    _birthday.addListener(calculateKJoule);
    _height.addListener(calculateKJoule);
    _weight.addListener(calculateKJoule);
    _activityFactor.addListener(calculateKJoule);
    _weightTarget.addListener(calculateKJoule);
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
  final ValueNotifier<int?> _dailyNeedEnergy;
  final ValueNotifier<int?> _dailyTargetEnergy;
  //we use the volume unite here because with this we can uniquely identy all other unit settings.
  final ValueNotifier<VolumeUnit> _volumeUnit;
  final bool _darkMode;
  final String _languageCode;

  ValueNotifier<int> get currentPageIndex => _currentPageIndex;
  bool get darkMode => _darkMode;
  ValueNotifier<Gender?> get gender => _gender;
  ValueNotifier<DateTime?> get birthday => _birthday;
  ValueNotifier<int?> get height => _height;
  ValueNotifier<double?> get weight => _weight;
  ValueNotifier<double?> get activityFactor => _activityFactor;
  ValueNotifier<WeightTarget?> get weightTarget => _weightTarget;
  ValueNotifier<int?> get dailyNeedEnergy => _dailyNeedEnergy;
  ValueNotifier<int?> get dailyTargetEnergy => _dailyTargetEnergy;
  ValueNotifier<VolumeUnit> get volumeUnit => _volumeUnit;

  String get contactData => _settingsRepository.contactData!;
  String get languageCode => _languageCode;

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

    double dailyNeedKJouleDouble = NutritionCalculator.calculateTotalKJoulePerDay(
      kJoulePerDay: NutritionCalculator.calculateBasalMetabolicRateInKJoule(
        weightKg: ConvertValidate.getWeightKg(displayWeight: _weight.value!),
        heightCm: ConvertValidate.getHeightCm(displayHeight: _height.value!.toDouble()),
        ageYear: age,
        gender: _gender.value!,
      ),
      activityFactor: _activityFactor.value!,
    );

    if (dailyNeedKJouleDouble < 1) {
      dailyNeedKJouleDouble = 1;
    }

    int dailyTargetKJoule = NutritionCalculator.calculateTargetKJoulePerDay(kJoulePerDay: dailyNeedKJouleDouble, weightLossPerWeekKg: weightLossKg).round();
    if (dailyTargetKJoule < 1) {
      dailyTargetKJoule = 1;
    }

    await _settingsRepository.saveAllOnboardingSettings(
      settings: AllSettings(
        darkMode: _darkMode,
        gender: _gender.value!,
        birthday: _birthday.value!,
        height: ConvertValidate.getHeightCm(displayHeight: _height.value!.toDouble()),
        activityFactor: _activityFactor.value!,
        weightTarget: _weightTarget.value!,
        kJouleMonday: dailyTargetKJoule,
        kJouleTuesday: dailyTargetKJoule,
        kJouleWednesday: dailyTargetKJoule,
        kJouleThursday: dailyTargetKJoule,
        kJouleFriday: dailyTargetKJoule,
        kJouleSaturday: dailyTargetKJoule,
        kJouleSunday: dailyTargetKJoule,
        languageCode: _languageCode,
        energyUnit: EnergyUnit.kcal,
        heightUnit: _getHeightUnit(),
        weightUnit: _getWeightUnit(),
        volumeUnit: _volumeUnit.value,
      ),
    );

    await _journalRepository.setWeightJournalEntry(
      date: DateTime.now(),
      weight: ConvertValidate.getWeightKg(displayWeight: _weight.value!),
    );
  }

  void calculateKJoule() {
    bool dailyNeedKJouleCalculationPossible = true;
    bool dailyTargetKJouleCalculationPossible = true;
    if (_gender.value == null || _birthday.value == null || _height.value == null || _weight.value == null || _activityFactor.value == null) {
      _dailyNeedEnergy.value = null;
      dailyNeedKJouleCalculationPossible = false;
    }

    if (_weightTarget.value == null) {
      _dailyTargetEnergy.value = null;
      dailyTargetKJouleCalculationPossible = false;
    }

    if (dailyNeedKJouleCalculationPossible) {
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
          weightKg: ConvertValidate.getWeightKg(displayWeight: _weight.value!),
          heightCm: ConvertValidate.getHeightCm(displayHeight: _height.value!.toDouble()),
          ageYear: age,
          gender: _gender.value!,
        ),
        activityFactor: _activityFactor.value!,
      );

      if (dailyNeedKJouleDouble < 1) {
        dailyNeedKJouleDouble = 1;
      }

      _dailyNeedEnergy.value = ConvertValidate.getDisplayEnergy(energyKJ: dailyNeedKJouleDouble.round());

      if (dailyTargetKJouleCalculationPossible) {
        double dailyTargetKJouleDouble = NutritionCalculator.calculateTargetKJoulePerDay(
          kJoulePerDay: dailyNeedKJouleDouble,
          weightLossPerWeekKg: weightLossKg,
        );
        if (dailyTargetKJouleDouble < 1) {
          dailyTargetKJouleDouble = 1;
        }

        _dailyTargetEnergy.value = ConvertValidate.getDisplayEnergy(energyKJ: dailyTargetKJouleDouble.round());
      }
    }
  }

  HeightUnit _getHeightUnit() {
    if (_volumeUnit.value == VolumeUnit.ml) {
      return HeightUnit.cm;
    }

    return HeightUnit.inch;
  }

  WeightUnit _getWeightUnit() {
    if (_volumeUnit.value == VolumeUnit.ml) {
      return WeightUnit.g;
    }

    return WeightUnit.oz;
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

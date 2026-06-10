import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class DailyEnergyTargetEditorScreenViewModel extends ChangeNotifier {
  DailyEnergyTargetEditorScreenViewModel({
    required KJoulePerDay targetkJoulePerDay,
    required double currentWeightKg,
    required SettingsRepository settingsRepository,
    required ConvertValidate convert,
  }) : _settingsRepository = settingsRepository,
       _convert = convert,
       _energyTargetDailyKjoule = ValueNotifier(
         (targetkJoulePerDay.kJouleMonday +
                 targetkJoulePerDay.kJouleTuesday +
                 targetkJoulePerDay.kJouleWednesday +
                 targetkJoulePerDay.kJouleThursday +
                 targetkJoulePerDay.kJouleFriday +
                 targetkJoulePerDay.kJouleSaturday +
                 targetkJoulePerDay.kJouleSunday) /
             7,
       ),
       _lastValidTargetKJoulePerDay = targetkJoulePerDay,
       _currentWeightKg = currentWeightKg,
       _energyMondayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleMonday)),
       _energyMondayValid = ValueNotifier(true),
       _energyTuesdayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleTuesday)),
       _energyTuesdayValid = ValueNotifier(true),
       _energyWednesdayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleWednesday)),
       _energyWednesdayValid = ValueNotifier(true),
       _energyThursdayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleThursday)),
       _energyThursdayValid = ValueNotifier(true),
       _energyFridayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleFriday)),
       _energyFridayValid = ValueNotifier(true),
       _energySaturdayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleSaturday)),
       _energySaturdayValid = ValueNotifier(true),
       _energySundayDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: targetkJoulePerDay.kJouleSunday)),
       _energySundayValid = ValueNotifier(true) {
    _energyMondayDisplay.addListener(_kJouleMondayChanged);
    _energyTuesdayDisplay.addListener(_kJouleTuesdayChanged);
    _energyWednesdayDisplay.addListener(_kJouleWednesdayChanged);
    _energyThursdayDisplay.addListener(_kJouleThursdayChanged);
    _energyFridayDisplay.addListener(_kJouleFridayChanged);
    _energySaturdayDisplay.addListener(_kJouleSaturdayChanged);
    _energySundayDisplay.addListener(_kJouleSundayChanged);
  }

  final SettingsRepository _settingsRepository;
  final ConvertValidate _convert;

  final KJoulePerDay _lastValidTargetKJoulePerDay;
  final double _currentWeightKg;
  final ValueNotifier<double> _energyTargetDailyKjoule;
  final ValueNotifier<int?> _energyMondayDisplay;
  final ValueNotifier<bool> _energyMondayValid;
  final ValueNotifier<int?> _energyTuesdayDisplay;
  final ValueNotifier<bool> _energyTuesdayValid;
  final ValueNotifier<int?> _energyWednesdayDisplay;
  final ValueNotifier<bool> _energyWednesdayValid;
  final ValueNotifier<int?> _energyThursdayDisplay;
  final ValueNotifier<bool> _energyThursdayValid;
  final ValueNotifier<int?> _energyFridayDisplay;
  final ValueNotifier<bool> _energyFridayValid;
  final ValueNotifier<int?> _energySaturdayDisplay;
  final ValueNotifier<bool> _energySaturdayValid;
  final ValueNotifier<int?> _energySundayDisplay;
  final ValueNotifier<bool> _energySundayValid;

  final Debouncer _energyMondayDebouncer = Debouncer();
  final Debouncer _energyTuesdayDebouncer = Debouncer();
  final Debouncer _energyWednesdayDebouncer = Debouncer();
  final Debouncer _energyThursdayDebouncer = Debouncer();
  final Debouncer _energyFridayDebouncer = Debouncer();
  final Debouncer _energySaturdayDebouncer = Debouncer();
  final Debouncer _energySundayDebouncer = Debouncer();

  double get currentWeightKg => _currentWeightKg;
  ValueNotifier<double> get energyTargetDailyKJoule => _energyTargetDailyKjoule;
  ValueNotifier<int?> get energyMondayDisplay => _energyMondayDisplay;
  ValueNotifier<bool> get energyMondayValid => _energyMondayValid;
  ValueNotifier<int?> get energyTuesdayDisplay => _energyTuesdayDisplay;
  ValueNotifier<bool> get energyTuesdayValid => _energyTuesdayValid;
  ValueNotifier<int?> get energyWednesdayDisplay => _energyWednesdayDisplay;
  ValueNotifier<bool> get energyWednesdayValid => _energyWednesdayValid;
  ValueNotifier<int?> get energyThursdayDisplay => _energyThursdayDisplay;
  ValueNotifier<bool> get energyThursdayValid => _energyThursdayValid;
  ValueNotifier<int?> get energyFridayDisplay => _energyFridayDisplay;
  ValueNotifier<bool> get energyFridayValid => _energyFridayValid;
  ValueNotifier<int?> get energySaturdayDisplay => _energySaturdayDisplay;
  ValueNotifier<bool> get energySaturdayValid => _energySaturdayValid;
  ValueNotifier<int?> get energySundayDisplay => _energySundayDisplay;
  ValueNotifier<bool> get energySundayValid => _energySundayValid;

  int get lastValidEnergyTargetMondayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleMonday);
  int get lastValidEnergyTargetTuesdayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleTuesday);
  int get lastValidEnergyTargetWednesdayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleWednesday);
  int get lastValidEnergyTargetThursdayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleThursday);
  int get lastValidEnergyTargetFridayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleFriday);
  int get lastValidEnergyTargetSaturdayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleSaturday);
  int get lastValidEnergyTargetSundayDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidTargetKJoulePerDay.kJouleSunday);

  void _kJouleMondayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energyMondayDisplay.value)) {
      _energyMondayValid.value = true;
      _energyMondayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleMonday = _convert.getEnergyKJ(displayEnergy: _energyMondayDisplay.value!);
          await _settingsRepository.saveKJouleMonday(kJoule: _lastValidTargetKJoulePerDay.kJouleMonday);
        },
      );
    } else {
      _energyMondayDebouncer.cancel();
      _energyMondayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleTuesdayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energyTuesdayDisplay.value)) {
      _energyTuesdayValid.value = true;
      _energyTuesdayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleTuesday = _convert.getEnergyKJ(displayEnergy: _energyTuesdayDisplay.value!);
          await _settingsRepository.saveKJouleTuesday(kJoule: _lastValidTargetKJoulePerDay.kJouleTuesday);
        },
      );
    } else {
      _energyTuesdayDebouncer.cancel();
      _energyTuesdayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleWednesdayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energyWednesdayDisplay.value)) {
      _energyWednesdayValid.value = true;
      _energyWednesdayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleWednesday = _convert.getEnergyKJ(displayEnergy: _energyWednesdayDisplay.value!);
          await _settingsRepository.saveKJouleWednesday(kJoule: _lastValidTargetKJoulePerDay.kJouleWednesday);
        },
      );
    } else {
      _energyWednesdayDebouncer.cancel();
      _energyWednesdayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleThursdayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energyThursdayDisplay.value)) {
      _energyThursdayValid.value = true;
      _energyThursdayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleThursday = _convert.getEnergyKJ(displayEnergy: _energyThursdayDisplay.value!);
          await _settingsRepository.saveKJouleThursday(kJoule: _lastValidTargetKJoulePerDay.kJouleThursday);
        },
      );
    } else {
      _energyThursdayDebouncer.cancel();
      _energyThursdayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleFridayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energyFridayDisplay.value)) {
      _energyFridayValid.value = true;
      _energyFridayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleFriday = _convert.getEnergyKJ(displayEnergy: _energyFridayDisplay.value!);
          await _settingsRepository.saveKJouleFriday(kJoule: _lastValidTargetKJoulePerDay.kJouleFriday);
        },
      );
    } else {
      _energyFridayDebouncer.cancel();
      _energyFridayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleSaturdayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energySaturdayDisplay.value)) {
      _energySaturdayValid.value = true;
      _energySaturdayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleSaturday = _convert.getEnergyKJ(displayEnergy: _energySaturdayDisplay.value!);
          await _settingsRepository.saveKJouleSaturday(kJoule: _lastValidTargetKJoulePerDay.kJouleSaturday);
        },
      );
    } else {
      _energySaturdayDebouncer.cancel();
      _energySaturdayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _kJouleSundayChanged() async {
    if (_convert.dailyEnergyValid(displayEnergy: _energySundayDisplay.value)) {
      _energySundayValid.value = true;
      _energySundayDebouncer.run(
        callback: () async {
          _lastValidTargetKJoulePerDay.kJouleSunday = _convert.getEnergyKJ(displayEnergy: _energySundayDisplay.value!);
          await _settingsRepository.saveKJouleSunday(kJoule: _lastValidTargetKJoulePerDay.kJouleSunday);
        },
      );
    } else {
      _energySundayDebouncer.cancel();
      _energySundayValid.value = false;
    }

    _calculateEnergyTargetDailyKJoule();
  }

  void _calculateEnergyTargetDailyKJoule() {
    if (_energyMondayDisplay.value != null &&
        _energyTuesdayDisplay.value != null &&
        _energyWednesdayDisplay.value != null &&
        _energyThursdayDisplay.value != null &&
        _energyFridayDisplay.value != null &&
        _energySaturdayDisplay.value != null &&
        _energySundayDisplay.value != null) {
      _energyTargetDailyKjoule.value =
          (_convert.getEnergyKJ(
            displayEnergy:
                (_energyMondayDisplay.value! +
                _energyTuesdayDisplay.value! +
                _energyWednesdayDisplay.value! +
                _energyThursdayDisplay.value! +
                _energyFridayDisplay.value! +
                _energySaturdayDisplay.value! +
                _energySundayDisplay.value!),
          ) /
          7);
    }
  }

  @override
  void dispose() {
    _energyTargetDailyKjoule.dispose();
    _energyMondayDisplay.dispose();
    _energyMondayValid.dispose();
    _energyTuesdayDisplay.dispose();
    _energyTuesdayValid.dispose();
    _energyWednesdayDisplay.dispose();
    _energyWednesdayValid.dispose();
    _energyThursdayDisplay.dispose();
    _energyThursdayValid.dispose();
    _energyFridayDisplay.dispose();
    _energyFridayValid.dispose();
    _energySaturdayDisplay.dispose();
    _energySaturdayValid.dispose();
    _energySundayDisplay.dispose();
    _energySundayValid.dispose();

    super.dispose();
  }
}

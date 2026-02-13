import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class DailyCaloriesEditorScreenViewModel extends ChangeNotifier {
  DailyCaloriesEditorScreenViewModel({required KJoulePerDay kJoulePerDay, required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      _energyTargetDaily = ValueNotifier(
        ConvertValidate.getDisplayEnergy(
          energyKJ:
              (kJoulePerDay.kJouleMonday +
                  kJoulePerDay.kJouleTuesday +
                  kJoulePerDay.kJouleWednesday +
                  kJoulePerDay.kJouleThursday +
                  kJoulePerDay.kJouleFriday +
                  kJoulePerDay.kJouleSaturday +
                  kJoulePerDay.kJouleSunday) /
              7,
        ),
      ),
      _kJoulePerDay = kJoulePerDay,
      _energyMonday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleMonday)),
      _energyMondayValid = ValueNotifier(true),
      _energyTuesday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleTuesday)),
      _energyTuesdayValid = ValueNotifier(true),
      _energyWednesday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleWednesday)),
      _energyWednesdayValid = ValueNotifier(true),
      _energyThursday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleThursday)),
      _energyThursdayValid = ValueNotifier(true),
      _energyFriday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleFriday)),
      _energyFridayValid = ValueNotifier(true),
      _energySaturday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleSaturday)),
      _energySaturdayValid = ValueNotifier(true),
      _energySunday = ValueNotifier(ConvertValidate.getDisplayEnergy(energyKJ: kJoulePerDay.kJouleSunday)),
      _energySundayValid = ValueNotifier(true) {
    _energyMonday.addListener(_kJouleMondayChanged);
    _energyTuesday.addListener(_kJouleTuesdayChanged);
    _energyWednesday.addListener(_kJouleWednesdayChanged);
    _energyThursday.addListener(_kJouleThursdayChanged);
    _energyFriday.addListener(_kJouleFridayChanged);
    _energySaturday.addListener(_kJouleSaturdayChanged);
    _energySunday.addListener(_kJouleSundayChanged);
  }

  final SettingsRepository _settingsRepository;

  //last valid value
  final KJoulePerDay _kJoulePerDay;
  final ValueNotifier<int> _energyTargetDaily;
  final ValueNotifier<int?> _energyMonday;
  final ValueNotifier<bool> _energyMondayValid;
  final ValueNotifier<int?> _energyTuesday;
  final ValueNotifier<bool> _energyTuesdayValid;
  final ValueNotifier<int?> _energyWednesday;
  final ValueNotifier<bool> _energyWednesdayValid;
  final ValueNotifier<int?> _energyThursday;
  final ValueNotifier<bool> _energyThursdayValid;
  final ValueNotifier<int?> _energyFriday;
  final ValueNotifier<bool> _energyFridayValid;
  final ValueNotifier<int?> _energySaturday;
  final ValueNotifier<bool> _energySaturdayValid;
  final ValueNotifier<int?> _energySunday;
  final ValueNotifier<bool> _energySundayValid;

  final Debouncer _energyMondayDebouncer = Debouncer();
  final Debouncer _energyTuesdayDebouncer = Debouncer();
  final Debouncer _energyWednesdayDebouncer = Debouncer();
  final Debouncer _energyThursdayDebouncer = Debouncer();
  final Debouncer _energyFridayDebouncer = Debouncer();
  final Debouncer _energySaturdayDebouncer = Debouncer();
  final Debouncer _energySundayDebouncer = Debouncer();

  ValueNotifier<int> get kJouleTargetDaily => _energyTargetDaily;
  ValueNotifier<int?> get energyMonday => _energyMonday;
  ValueNotifier<bool> get energyMondayValid => _energyMondayValid;
  ValueNotifier<int?> get energyTuesday => _energyTuesday;
  ValueNotifier<bool> get energyTuesdayValid => _energyTuesdayValid;
  ValueNotifier<int?> get energyWednesday => _energyWednesday;
  ValueNotifier<bool> get energyWednesdayValid => _energyWednesdayValid;
  ValueNotifier<int?> get energyThursday => _energyThursday;
  ValueNotifier<bool> get energyThursdayValid => _energyThursdayValid;
  ValueNotifier<int?> get energyFriday => _energyFriday;
  ValueNotifier<bool> get energyFridayValid => _energyFridayValid;
  ValueNotifier<int?> get energySaturday => _energySaturday;
  ValueNotifier<bool> get energySaturdayValid => _energySaturdayValid;
  ValueNotifier<int?> get energySunday => _energySunday;
  ValueNotifier<bool> get energySundayValid => _energySundayValid;

  int get energyPerdayMonday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleMonday);
  int get energyPerdayTuesday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleTuesday);
  int get energyPerdayWednesday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleWednesday);
  int get energyPerdayThursday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleThursday);
  int get energyPerdayFriday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleFriday);
  int get energyPerdaySaturday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleSaturday);
  int get energyPerdaySunday => ConvertValidate.getDisplayEnergy(energyKJ: _kJoulePerDay.kJouleSunday);

  void _kJouleMondayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energyMonday.value)) {
      _energyMondayValid.value = true;
      _energyMondayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleMonday = ConvertValidate.getEnergyKJ(displayEnergy: _energyMonday.value!);
          await _settingsRepository.saveKJouleMonday(kJoule: _kJoulePerDay.kJouleMonday);
        },
      );
    } else {
      _energyMondayDebouncer.cancel();
      _energyMondayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleTuesdayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energyTuesday.value)) {
      _energyTuesdayValid.value = true;
      _energyTuesdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleTuesday = ConvertValidate.getEnergyKJ(displayEnergy: _energyTuesday.value!);
          await _settingsRepository.saveKJouleTuesday(kJoule: _kJoulePerDay.kJouleTuesday);
        },
      );
    } else {
      _energyTuesdayDebouncer.cancel();
      _energyTuesdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleWednesdayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energyWednesday.value)) {
      _energyWednesdayValid.value = true;
      _energyWednesdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleWednesday = ConvertValidate.getEnergyKJ(displayEnergy: _energyWednesday.value!);
          await _settingsRepository.saveKJouleWednesday(kJoule: _kJoulePerDay.kJouleWednesday);
        },
      );
    } else {
      _energyWednesdayDebouncer.cancel();
      _energyWednesdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleThursdayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energyThursday.value)) {
      _energyThursdayValid.value = true;
      _energyThursdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleThursday = ConvertValidate.getEnergyKJ(displayEnergy: _energyThursday.value!);
          await _settingsRepository.saveKJouleThursday(kJoule: _kJoulePerDay.kJouleThursday);
        },
      );
    } else {
      _energyThursdayDebouncer.cancel();
      _energyThursdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleFridayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energyFriday.value)) {
      _energyFridayValid.value = true;
      _energyFridayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleFriday = ConvertValidate.getEnergyKJ(displayEnergy: _energyFriday.value!);
          await _settingsRepository.saveKJouleFriday(kJoule: _kJoulePerDay.kJouleFriday);
        },
      );
    } else {
      _energyFridayDebouncer.cancel();
      _energyFridayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleSaturdayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energySaturday.value)) {
      _energySaturdayValid.value = true;
      _energySaturdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleSaturday = ConvertValidate.getEnergyKJ(displayEnergy: _energySaturday.value!);
          await _settingsRepository.saveKJouleSaturday(kJoule: _kJoulePerDay.kJouleSaturday);
        },
      );
    } else {
      _energySaturdayDebouncer.cancel();
      _energySaturdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleSundayChanged() async {
    if (ConvertValidate.dailyEnergyValid(displayEnergy: _energySunday.value)) {
      _energySundayValid.value = true;
      _energySundayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleSunday = ConvertValidate.getEnergyKJ(displayEnergy: _energySunday.value!);
          await _settingsRepository.saveKJouleSunday(kJoule: _kJoulePerDay.kJouleSunday);
        },
      );
    } else {
      _energySundayDebouncer.cancel();
      _energySundayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _calculateKJouleTargetDaily() {
    if (_energyMonday.value != null &&
        _energyTuesday.value != null &&
        _energyWednesday.value != null &&
        _energyThursday.value != null &&
        _energyFriday.value != null &&
        _energySaturday.value != null &&
        _energySunday.value != null) {
      _energyTargetDaily.value = ConvertValidate.getDisplayEnergy(
        energyKJ:
            ((_energyMonday.value! +
                _energyTuesday.value! +
                _energyWednesday.value! +
                _energyThursday.value! +
                _energyFriday.value! +
                _energySaturday.value! +
                _energySunday.value!) /
            7),
      );
    }
  }

  @override
  void dispose() {
    _energyTargetDaily.dispose();
    _energyMonday.dispose();
    _energyMondayValid.dispose();
    _energyTuesday.dispose();
    _energyTuesdayValid.dispose();
    _energyWednesday.dispose();
    _energyWednesdayValid.dispose();
    _energyThursday.dispose();
    _energyThursdayValid.dispose();
    _energyFriday.dispose();
    _energyFridayValid.dispose();
    _energySaturday.dispose();
    _energySaturdayValid.dispose();
    _energySunday.dispose();
    _energySundayValid.dispose();

    super.dispose();
  }
}

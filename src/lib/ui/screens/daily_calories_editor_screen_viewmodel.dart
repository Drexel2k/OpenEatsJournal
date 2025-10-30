import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class DailyCaloriesEditorScreenViewModel extends ChangeNotifier {
  DailyCaloriesEditorScreenViewModel({required KJoulePerDay kJoulePerDay, required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      _kJouleTargetDaily = ValueNotifier(
        ((kJoulePerDay.kJouleMonday +
                    kJoulePerDay.kJouleTuesday +
                    kJoulePerDay.kJouleWednesday +
                    kJoulePerDay.kJouleThursday +
                    kJoulePerDay.kJouleFriday +
                    kJoulePerDay.kJouleSaturday +
                    kJoulePerDay.kJouleSunday) /
                7)
            .round(),
      ),
      _kJoulePerDay = kJoulePerDay,
      _kJouleMonday = ValueNotifier(kJoulePerDay.kJouleMonday),
      _kJouleMondayValid = ValueNotifier(true),
      _kJouleTuesday = ValueNotifier(kJoulePerDay.kJouleTuesday),
      _kJouleTuesdayValid = ValueNotifier(true),
      _kJouleWednesday = ValueNotifier(kJoulePerDay.kJouleWednesday),
      _kJouleWednesdayValid = ValueNotifier(true),
      _kJouleThursday = ValueNotifier(kJoulePerDay.kJouleThursday),
      _kJouleThursdayValid = ValueNotifier(true),
      _kJouleFriday = ValueNotifier(kJoulePerDay.kJouleFriday),
      _kJouleFridayValid = ValueNotifier(true),
      _kJouleSaturday = ValueNotifier(kJoulePerDay.kJouleSaturday),
      _kJouleSaturdayValid = ValueNotifier(true),
      _kJouleSunday = ValueNotifier(kJoulePerDay.kJouleSunday),
      _kJouleSundayValid = ValueNotifier(true) {
    _kJouleMonday.addListener(_kJouleMondayChanged);
    _kJouleTuesday.addListener(_kJouleTuesdayChanged);
    _kJouleWednesday.addListener(_kJouleWednesdayChanged);
    _kJouleThursday.addListener(_kJouleThursdayChanged);
    _kJouleFriday.addListener(_kJouleFridayChanged);
    _kJouleSaturday.addListener(_kJouleSaturdayChanged);
    _kJouleSunday.addListener(_kJouleSundayChanged);
  }

  final SettingsRepository _settingsRepository;

  final KJoulePerDay _kJoulePerDay;
  final ValueNotifier<int> _kJouleTargetDaily;
  final ValueNotifier<int?> _kJouleMonday;
  final ValueNotifier<bool> _kJouleMondayValid;
  final ValueNotifier<int?> _kJouleTuesday;
  final ValueNotifier<bool> _kJouleTuesdayValid;
  final ValueNotifier<int?> _kJouleWednesday;
  final ValueNotifier<bool> _kJouleWednesdayValid;
  final ValueNotifier<int?> _kJouleThursday;
  final ValueNotifier<bool> _kJouleThursdayValid;
  final ValueNotifier<int?> _kJouleFriday;
  final ValueNotifier<bool> _kJouleFridayValid;
  final ValueNotifier<int?> _kJouleSaturday;
  final ValueNotifier<bool> _kJouleSaturdayValid;
  final ValueNotifier<int?> _kJouleSunday;
  final ValueNotifier<bool> _kJouleSundayValid;

  // ignore: constant_identifier_names
  static const int _10000kCalInKjoule = 41840;

  final Debouncer _kCalMondayDebouncer = Debouncer();
  final Debouncer _kCalTuesdayDebouncer = Debouncer();
  final Debouncer _kCalWednesdayDebouncer = Debouncer();
  final Debouncer _kCalThursdayDebouncer = Debouncer();
  final Debouncer _kCalFridayDebouncer = Debouncer();
  final Debouncer _kCalSaturdayDebouncer = Debouncer();
  final Debouncer _kCalSundayDebouncer = Debouncer();

  ValueNotifier<int> get kJouleTargetDaily => _kJouleTargetDaily;
  ValueNotifier<int?> get kJouleMonday => _kJouleMonday;
  ValueNotifier<bool> get kJouleMondayValid => _kJouleMondayValid;
  ValueNotifier<int?> get kJouleTuesday => _kJouleTuesday;
  ValueNotifier<bool> get kJouleTuesdayValid => _kJouleTuesdayValid;
  ValueNotifier<int?> get kJouleWednesday => _kJouleWednesday;
  ValueNotifier<bool> get kJouleWednesdayValid => _kJouleWednesdayValid;
  ValueNotifier<int?> get kJouleThursday => _kJouleThursday;
  ValueNotifier<bool> get kJouleThursdayValid => _kJouleThursdayValid;
  ValueNotifier<int?> get kJouleFriday => _kJouleFriday;
  ValueNotifier<bool> get kJouleFridayValid => _kJouleFridayValid;
  ValueNotifier<int?> get kJouleSaturday => _kJouleSaturday;
  ValueNotifier<bool> get kJouleSaturdayValid => _kJouleSaturdayValid;
  ValueNotifier<int?> get kJouleSunday => _kJouleSunday;
  ValueNotifier<bool> get kJouleSundayValid => _kJouleSundayValid;

  int get kJoulePerdayKJouleMonday => _kJoulePerDay.kJouleMonday;
  int get kJoulePerdayKJouleTuesday => _kJoulePerDay.kJouleTuesday;
  int get kJoulePerdayKJouleWednesday => _kJoulePerDay.kJouleWednesday;
  int get kJoulePerdayKJouleThursday => _kJoulePerDay.kJouleThursday;
  int get kJoulePerdayKJouleFriday => _kJoulePerDay.kJouleFriday;
  int get kJoulePerdayKJouleSaturday => _kJoulePerDay.kJouleSaturday;
  int get kJoulePerdayKJouleSunday => _kJoulePerDay.kJouleSunday;

  void _kJouleMondayChanged() async {
    if (_kJouleMonday.value != null && _kJouleMonday.value! > 0 && _kJouleMonday.value! < _10000kCalInKjoule) {
      _kJouleMondayValid.value = true;
      _kCalMondayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleMonday = _kJouleMonday.value!;
          await _settingsRepository.saveKJouleMonday(_kJoulePerDay.kJouleMonday);
        },
      );
    } else {
      _kCalMondayDebouncer.cancel();
      _kJouleMondayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleTuesdayChanged() async {
    if (_kJouleTuesday.value != null && _kJouleTuesday.value! > 0 && _kJouleTuesday.value! < _10000kCalInKjoule) {
      _kJouleTuesdayValid.value = true;
      _kCalTuesdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleTuesday = _kJouleTuesday.value!;
          await _settingsRepository.saveKJouleTuesday(_kJoulePerDay.kJouleTuesday);
        },
      );
    } else {
      _kCalTuesdayDebouncer.cancel();
      _kJouleTuesdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleWednesdayChanged() async {
    if (_kJouleWednesday.value != null && _kJouleWednesday.value! > 0 && _kJouleWednesday.value! < _10000kCalInKjoule) {
      _kJouleWednesdayValid.value = true;
      _kCalWednesdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleWednesday = _kJouleWednesday.value!;
          await _settingsRepository.saveKJouleWednesday(_kJoulePerDay.kJouleWednesday);
        },
      );
    } else {
      _kCalWednesdayDebouncer.cancel();
      _kJouleWednesdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleThursdayChanged() async {
    if (_kJouleThursday.value != null && _kJouleThursday.value! > 0 && _kJouleThursday.value! < _10000kCalInKjoule) {
      _kJouleThursdayValid.value = true;
      _kCalThursdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleThursday = _kJouleThursday.value!;
          await _settingsRepository.saveKJouleThursday(_kJoulePerDay.kJouleThursday);
        },
      );
    } else {
      _kCalThursdayDebouncer.cancel();
      _kJouleThursdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleFridayChanged() async {
    if (_kJouleFriday.value != null && _kJouleFriday.value! > 0 && _kJouleFriday.value! < _10000kCalInKjoule) {
      _kJouleFridayValid.value = true;
      _kCalFridayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleFriday = _kJouleFriday.value!;
          await _settingsRepository.saveKJouleFriday(_kJoulePerDay.kJouleFriday);
        },
      );
    } else {
      _kCalFridayDebouncer.cancel();
      _kJouleFridayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleSaturdayChanged() async {
    if (_kJouleSaturday.value != null && _kJouleSaturday.value! > 0 && _kJouleSaturday.value! < _10000kCalInKjoule) {
      _kJouleSaturdayValid.value = true;
      _kCalSaturdayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleSaturday = _kJouleSaturday.value!;
          await _settingsRepository.saveKJouleSaturday(_kJoulePerDay.kJouleSaturday);
        },
      );
    } else {
      _kCalSaturdayDebouncer.cancel();
      _kJouleSaturdayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _kJouleSundayChanged() async {
    if (_kJouleSunday.value != null && _kJouleSunday.value! > 0 && _kJouleSunday.value! < _10000kCalInKjoule) {
      _kJouleSundayValid.value = true;
      _kCalSundayDebouncer.run(
        callback: () async {
          _kJoulePerDay.kJouleSunday = _kJouleSunday.value!;
          await _settingsRepository.saveKJouleSunday(_kJoulePerDay.kJouleSunday);
        },
      );
    } else {
      _kCalSundayDebouncer.cancel();
      _kJouleSundayValid.value = false;
    }

    _calculateKJouleTargetDaily();
  }

  void _calculateKJouleTargetDaily() {
    if (_kJouleMonday.value != null &&
        _kJouleTuesday.value != null &&
        _kJouleWednesday.value != null &&
        _kJouleThursday.value != null &&
        _kJouleFriday.value != null &&
        _kJouleSaturday.value != null &&
        _kJouleSunday.value != null) {
      _kJouleTargetDaily.value =
          ((_kJouleMonday.value! +
                      _kJouleTuesday.value! +
                      _kJouleWednesday.value! +
                      _kJouleThursday.value! +
                      _kJouleFriday.value! +
                      _kJouleSaturday.value! +
                      _kJouleSunday.value!) /
                  7)
              .round();
    }
  }

  @override
  void dispose() {
    _kJouleTargetDaily.dispose();
    _kJouleMonday.dispose();
    _kJouleMondayValid.dispose();
    _kJouleTuesday.dispose();
    _kJouleTuesdayValid.dispose();
    _kJouleWednesday.dispose();
    _kJouleWednesdayValid.dispose();
    _kJouleThursday.dispose();
    _kJouleThursdayValid.dispose();
    _kJouleFriday.dispose();
    _kJouleFridayValid.dispose();
    _kJouleSaturday.dispose();
    _kJouleSaturdayValid.dispose();
    _kJouleSunday.dispose();
    _kJouleSundayValid.dispose();

    super.dispose();
  }
}

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";

class DailyCaloriesEditorScreenViewModel extends ChangeNotifier {
  DailyCaloriesEditorScreenViewModel(KJoulePerDay kJouleSettings)
    : _kJouleTargetDaily = ValueNotifier(
        ((kJouleSettings.kJouleMonday +
                    kJouleSettings.kJouleTuesday +
                    kJouleSettings.kJouleWednesday +
                    kJouleSettings.kJouleThursday +
                    kJouleSettings.kJouleFriday +
                    kJouleSettings.kJouleSaturday +
                    kJouleSettings.kJouleSunday) /
                7)
            .round(),
      ),
      _kJouleMonday = ValueNotifier(kJouleSettings.kJouleMonday),
      _kJouleMondayValid = ValueNotifier(true),
      _kJouleTuesday = ValueNotifier(kJouleSettings.kJouleTuesday),
      _kJouleTuesdayValid = ValueNotifier(true),
      _kJouleWednesday = ValueNotifier(kJouleSettings.kJouleWednesday),
      _kJouleWednesdayValid = ValueNotifier(true),
      _kJouleThursday = ValueNotifier(kJouleSettings.kJouleThursday),
      _kJouleThursdayValid = ValueNotifier(true),
      _kJouleFriday = ValueNotifier(kJouleSettings.kJouleFriday),
      _kJouleFridayValid = ValueNotifier(true),
      _kJouleSaturday = ValueNotifier(kJouleSettings.kJouleSaturday),
      _kJouleSaturdayValid = ValueNotifier(true),
      _kJouleSunday = ValueNotifier(kJouleSettings.kJouleSunday),
      _kJouleSundayValid = ValueNotifier(true) {
    _kJouleMonday.addListener(_dayKJouleChanged);
    _kJouleTuesday.addListener(_dayKJouleChanged);
    _kJouleWednesday.addListener(_dayKJouleChanged);
    _kJouleThursday.addListener(_dayKJouleChanged);
    _kJouleFriday.addListener(_dayKJouleChanged);
    _kJouleSaturday.addListener(_dayKJouleChanged);
    _kJouleSunday.addListener(_dayKJouleChanged);
  }

  final ValueNotifier<int> _kJouleTargetDaily;
  final ValueNotifier<int> _kJouleMonday;
  final ValueNotifier<bool> _kJouleMondayValid;
  final ValueNotifier<int> _kJouleTuesday;
  final ValueNotifier<bool> _kJouleTuesdayValid;
  final ValueNotifier<int> _kJouleWednesday;
  final ValueNotifier<bool> _kJouleWednesdayValid;
  final ValueNotifier<int> _kJouleThursday;
  final ValueNotifier<bool> _kJouleThursdayValid;
  final ValueNotifier<int> _kJouleFriday;
  final ValueNotifier<bool> _kJouleFridayValid;
  final ValueNotifier<int> _kJouleSaturday;
  final ValueNotifier<bool> _kJouleSaturdayValid;
  final ValueNotifier<int> _kJouleSunday;
  final ValueNotifier<bool> _kJouleSundayValid;

  ValueNotifier<int> get kJouleTargetDaily => _kJouleTargetDaily;
  ValueNotifier<int> get kJouleMonday => _kJouleMonday;
  ValueNotifier<bool> get kJouleMondayValid => _kJouleMondayValid;
  ValueNotifier<int> get kJouleTuesday => _kJouleTuesday;
  ValueNotifier<bool> get kJouleTuesdayValid => _kJouleTuesdayValid;
  ValueNotifier<int> get kJouleWednesday => _kJouleWednesday;
  ValueNotifier<bool> get kJouleWednesdayValid => _kJouleWednesdayValid;
  ValueNotifier<int> get kJouleThursday => _kJouleThursday;
  ValueNotifier<bool> get kJouleThursdayValid => _kJouleThursdayValid;
  ValueNotifier<int> get kJouleFriday => _kJouleFriday;
  ValueNotifier<bool> get kJouleFridayValid => _kJouleFridayValid;
  ValueNotifier<int> get kJouleSaturday => _kJouleSaturday;
  ValueNotifier<bool> get kJouleSaturdayValid => _kJouleSaturdayValid;
  ValueNotifier<int> get kJouleSunday => _kJouleSunday;
  ValueNotifier<bool> get kJouleSundayValid => _kJouleSundayValid;

  void _dayKJouleChanged() {
    _kJouleTargetDaily.value =
        ((_kJouleMonday.value +
                    _kJouleTuesday.value +
                    _kJouleWednesday.value +
                    _kJouleThursday.value +
                    _kJouleFriday.value +
                    _kJouleSaturday.value +
                    _kJouleSunday.value) /
                7)
            .round();
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

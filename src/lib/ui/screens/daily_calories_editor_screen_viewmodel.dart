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
      _kJouleTuesday = ValueNotifier(kJouleSettings.kJouleTuesday),
      _kJouleWednesday = ValueNotifier(kJouleSettings.kJouleWednesday),
      _kJouleThursday = ValueNotifier(kJouleSettings.kJouleThursday),
      _kJouleFriday = ValueNotifier(kJouleSettings.kJouleFriday),
      _kJouleSaturday = ValueNotifier(kJouleSettings.kJouleSaturday),
      _kJouleSunday = ValueNotifier(kJouleSettings.kJouleSunday) {
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
  final ValueNotifier<int> _kJouleTuesday;
  final ValueNotifier<int> _kJouleWednesday;
  final ValueNotifier<int> _kJouleThursday;
  final ValueNotifier<int> _kJouleFriday;
  final ValueNotifier<int> _kJouleSaturday;
  final ValueNotifier<int> _kJouleSunday;

  ValueNotifier<int> get kJouleTargetDaily => _kJouleTargetDaily;
  ValueNotifier<int> get kJouleMonday => _kJouleMonday;
  ValueNotifier<int> get kJouleTuesday => _kJouleTuesday;
  ValueNotifier<int> get kJouleWednesday => _kJouleWednesday;
  ValueNotifier<int> get kJouleThursday => _kJouleThursday;
  ValueNotifier<int> get kJouleFriday => _kJouleFriday;
  ValueNotifier<int> get kJouleSaturday => _kJouleSaturday;
  ValueNotifier<int> get kJouleSunday => _kJouleSunday;

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
    _kJouleTuesday.dispose();
    _kJouleWednesday.dispose();
    _kJouleThursday.dispose();
    _kJouleFriday.dispose();
    _kJouleSaturday.dispose();
    _kJouleSunday.dispose();

    super.dispose();
  }
}

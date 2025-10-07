import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";

class DailyCaloriesEditorScreenViewModel extends ChangeNotifier {
  DailyCaloriesEditorScreenViewModel(KCalSettings kCalSettings)
    : _kCalsTargetDaily = ValueNotifier(
        ((kCalSettings.kCalsMonday +
                    kCalSettings.kCalsTuesday +
                    kCalSettings.kCalsWednesday +
                    kCalSettings.kCalsThursday +
                    kCalSettings.kCalsFriday +
                    kCalSettings.kCalsSaturday +
                    kCalSettings.kCalsSunday) /
                7)
            .round(),
      ),
      _kCalsMonday = ValueNotifier(kCalSettings.kCalsMonday),
      _kCalsTuesday = ValueNotifier(kCalSettings.kCalsTuesday),
      _kCalsWednesday = ValueNotifier(kCalSettings.kCalsWednesday),
      _kCalsThursday = ValueNotifier(kCalSettings.kCalsThursday),
      _kCalsFriday = ValueNotifier(kCalSettings.kCalsFriday),
      _kCalsSaturday = ValueNotifier(kCalSettings.kCalsSaturday),
      _kCalsSunday = ValueNotifier(kCalSettings.kCalsSunday) {
    _kCalsMonday.addListener(_dayKCalsChanged);
    _kCalsTuesday.addListener(_dayKCalsChanged);
    _kCalsWednesday.addListener(_dayKCalsChanged);
    _kCalsThursday.addListener(_dayKCalsChanged);
    _kCalsFriday.addListener(_dayKCalsChanged);
    _kCalsSaturday.addListener(_dayKCalsChanged);
    _kCalsSunday.addListener(_dayKCalsChanged);
  }

  final ValueNotifier<int> _kCalsTargetDaily;
  final ValueNotifier<int> _kCalsMonday;
  final ValueNotifier<int> _kCalsTuesday;
  final ValueNotifier<int> _kCalsWednesday;
  final ValueNotifier<int> _kCalsThursday;
  final ValueNotifier<int> _kCalsFriday;
  final ValueNotifier<int> _kCalsSaturday;
  final ValueNotifier<int> _kCalsSunday;

  ValueNotifier<int> get kCalsTargetDaily => _kCalsTargetDaily;
  ValueNotifier<int> get kCalsMonday => _kCalsMonday;
  ValueNotifier<int> get kCalsTuesday => _kCalsTuesday;
  ValueNotifier<int> get kCalsWednesday => _kCalsWednesday;
  ValueNotifier<int> get kCalsThursday => _kCalsThursday;
  ValueNotifier<int> get kCalsFriday => _kCalsFriday;
  ValueNotifier<int> get kCalsSaturday => _kCalsSaturday;
  ValueNotifier<int> get kCalsSunday => _kCalsSunday;

  void _dayKCalsChanged() {
    _kCalsTargetDaily.value =
        ((_kCalsMonday.value +
                    _kCalsTuesday.value +
                    _kCalsWednesday.value +
                    _kCalsThursday.value +
                    _kCalsFriday.value +
                    _kCalsSaturday.value +
                    _kCalsSunday.value) /
                7)
            .round();
  }

  @override
  void dispose() {
    _kCalsTargetDaily.dispose();
    _kCalsMonday.dispose();
    _kCalsTuesday.dispose();
    _kCalsWednesday.dispose();
    _kCalsThursday.dispose();
    _kCalsFriday.dispose();
    _kCalsSaturday.dispose();
    _kCalsSunday.dispose();

    super.dispose();
  }
}

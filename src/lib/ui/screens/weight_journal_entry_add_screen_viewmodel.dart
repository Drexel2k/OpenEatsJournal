import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class WeightJournalEntryAddScreenViewModel extends ChangeNotifier {
  WeightJournalEntryAddScreenViewModel({required double initialWeight, required ConvertValidate convert})
    : _lastValidWeightKg = initialWeight,
      _weightDisplay = ValueNotifier(convert.getDisplayWeightKg(weightKg: initialWeight)),
      _convert = convert {
    _weightDisplay.addListener(_weightChangedInternal);
  }

  final ConvertValidate _convert;

  final ValueNotifier<double?> _weightDisplay;
  double _lastValidWeightKg;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);

  final Debouncer _weightDebouncer = Debouncer();
  VoidCallback? _weightChanged;

  set weightChanged(VoidCallback value) {
    _weightChanged = value;
  }

  ValueNotifier<double?> get weightDisplay => _weightDisplay;
  double get lastValidWeightDisplay => _convert.getDisplayWeightKg(weightKg: _lastValidWeightKg);
  double get lastValidWeightKg => _lastValidWeightKg;
  ValueNotifier<bool> get weightValid => _weightValid;

  void _weightChangedInternal() {
    if (_convert.weightValid(displayWeight: _weightDisplay.value)) {
      _weightValid.value = true;

      _weightDebouncer.run(
        callback: () async {
          _lastValidWeightKg = _convert.getWeightKg(displayWeight: _weightDisplay.value!);
          if (_weightChanged != null) {
            _weightChanged!();
          }
        },
      );
    } else {
      _weightDebouncer.cancel();
      _weightValid.value = false;
    }
  }

  @override
  void dispose() {
    _weightDisplay.dispose();
    _weightValid.dispose();

    super.dispose();
  }
}

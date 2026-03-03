import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class WeightJournalEntryAddScreenViewModel extends ChangeNotifier {
  WeightJournalEntryAddScreenViewModel({required double initialWeight, required ConvertValidate convert})
    : _lastValidWeight = initialWeight,
      _weight = ValueNotifier(convert.getDisplayWeightKg(weightKg: initialWeight)),
      _convert = convert {
    _weight.addListener(_weightChangedInternal);
  }

  final ConvertValidate _convert;

  final ValueNotifier<double?> _weight;
  double _lastValidWeight;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);

  final Debouncer _weightDebouncer = Debouncer();
  VoidCallback? _weightChanged;

  set weightChanged(VoidCallback value) {
    _weightChanged = value;
  }

  ValueNotifier<double?> get weight => _weight;
  double get lastValidWeightDisplay => _convert.getDisplayWeightKg(weightKg: _lastValidWeight);
  double get lastValidWeight => _lastValidWeight;
  ValueNotifier<bool> get weightValid => _weightValid;

  void _weightChangedInternal() {
    if (_convert.weightValid(displayWeight: _weight.value)) {
      _weightValid.value = true;

      _weightDebouncer.run(
        callback: () async {
          _lastValidWeight = _convert.getWeightKg(displayWeight: _weight.value!);
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
    _weight.dispose();
    _weightValid.dispose();

    super.dispose();
  }
}

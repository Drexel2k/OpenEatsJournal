import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class WeightJournalEntryAddScreenViewModel extends ChangeNotifier {
  WeightJournalEntryAddScreenViewModel({required double initialWeight})
    : _lastValidWeight = initialWeight,
      _weight = ValueNotifier(ConvertValidate.getDisplayWeightKg(weightKg: initialWeight)) {
    _weight.addListener(_weightChangedInternal);
  }

  final ValueNotifier<double?> _weight;
  double _lastValidWeight;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);

  final Debouncer _weightDebouncer = Debouncer();
  VoidCallback? _weightChanged;

  set weightChanged(VoidCallback value) {
    _weightChanged = value;
  }

  ValueNotifier<double?> get weight => _weight;
  double get lastValidWeightDisplay => ConvertValidate.getDisplayWeightKg(weightKg: _lastValidWeight);
  double get lastValidWeight => _lastValidWeight;
  ValueNotifier<bool> get weightValid => _weightValid;

  void _weightChangedInternal() {
    if (ConvertValidate.weightValid(displayWeight: _weight.value)) {
      _weightValid.value = true;

      _weightDebouncer.run(
        callback: () async {
          _lastValidWeight = ConvertValidate.getWeightKg(displayWeight: _weight.value!);
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

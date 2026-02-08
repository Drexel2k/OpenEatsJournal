import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class WeightRowViewModel extends ChangeNotifier {
  WeightRowViewModel({required double weight, required DateTime date, required Function({required DateTime date, required double weight}) onWeightChange})
    : _weight = ValueNotifier(ConvertValidate.getDisplayWeightKg(weightKg: weight)),
      _date = date,
      _onWeightChange = onWeightChange,
      _lastValidWeight = weight {
    _weight.addListener(_weightChangedInternal);
  }

  final ValueNotifier<double?> _weight;
  final DateTime _date;
  final Function({required DateTime date, required double weight}) _onWeightChange;

  double _lastValidWeight;
  final ValueNotifier<bool> _weightValid = ValueNotifier(true);

  final Debouncer _weightDebouncer = Debouncer();

  ValueNotifier<double?> get weight => _weight;
  DateTime get date => _date;
  double get lastValidWeightDisplay => ConvertValidate.getDisplayWeightKg(weightKg: _lastValidWeight);
  ValueNotifier<bool> get weightValid => _weightValid;

  void _weightChangedInternal() {
    if (_weight.value != null && _weight.value! > 0 && _weight.value! < 1000) {
      _weightValid.value = true;

      _weightDebouncer.run(
        callback: () async {
          _lastValidWeight = ConvertValidate.getWeightKg(displayWeight: _weight.value!);
          _onWeightChange(date: _date, weight: _lastValidWeight);
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

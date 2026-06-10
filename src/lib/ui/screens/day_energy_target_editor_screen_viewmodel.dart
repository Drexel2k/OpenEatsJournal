import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class DayEnergyTargetEditorScreenViewModel extends ChangeNotifier {
  DayEnergyTargetEditorScreenViewModel({required double initialEnergyTargetKJoule, required ConvertValidate convert})
    : _lastValidEnergyTargetKJoule = initialEnergyTargetKJoule,
      _energyTargetDisplay = ValueNotifier(convert.getDisplayEnergy(energyKJ: initialEnergyTargetKJoule)),
      _convert = convert {
    _energyTargetDisplay.addListener(_energyTargetChangedInternal);
  }

  final ConvertValidate _convert;

  final ValueNotifier<int?> _energyTargetDisplay;
  double _lastValidEnergyTargetKJoule;
  final ValueNotifier<bool> _energyTargetValid = ValueNotifier(true);

  final Debouncer _energyDebouncer = Debouncer();
  VoidCallback? _energyChanged;

  set energyChanged(VoidCallback value) {
    _energyChanged = value;
  }

  ValueNotifier<int?> get energyTargetDisplay => _energyTargetDisplay;
  int get lastValidEnergyTargetDisplay => _convert.getDisplayEnergy(energyKJ: _lastValidEnergyTargetKJoule);
  double get lastValidEnergyTargetKJoule => _lastValidEnergyTargetKJoule;
  ValueNotifier<bool> get energyTargetValid => _energyTargetValid;

  void _energyTargetChangedInternal() {
    if (_convert.dailyEnergyValid(displayEnergy: _energyTargetDisplay.value)) {
      _energyTargetValid.value = true;

      _energyDebouncer.run(
        callback: () async {
          _lastValidEnergyTargetKJoule = _convert.getEnergyKJ(displayEnergy: _energyTargetDisplay.value!);
          if (_energyChanged != null) {
            _energyChanged!();
          }
        },
      );
    } else {
      _energyDebouncer.cancel();
      _energyTargetValid.value = false;
    }
  }

  @override
  void dispose() {
    _energyTargetDisplay.dispose();
    _energyTargetValid.dispose();

    super.dispose();
  }
}

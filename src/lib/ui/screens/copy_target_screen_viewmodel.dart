import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/meal.dart";

class CopyTargetScreenViewModel extends ChangeNotifier {
  CopyTargetScreenViewModel({required DateTime currentDate, required Meal? currentMeal})
    : _targetDate = ValueNotifier(currentDate),
      _targetMeal = ValueNotifier(currentMeal != null ? currentMeal.value : -1),
      _originalMeal = currentMeal;

  final ValueNotifier<DateTime> _targetDate;
  final ValueNotifier<int> _targetMeal;
  final Meal? _originalMeal;

  ValueNotifier<DateTime> get targetDate => _targetDate;
  ValueNotifier<int> get targetMeal => _targetMeal;
  Meal? get originalMeal => _originalMeal;

  @override
  void dispose() {
    _targetDate.dispose();
    _targetMeal.dispose();

    super.dispose();
  }
}

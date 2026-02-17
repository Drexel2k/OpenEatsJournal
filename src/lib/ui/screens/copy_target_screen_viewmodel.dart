import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/meal.dart";

class CopyTargetScreenViewModel extends ChangeNotifier {
  CopyTargetScreenViewModel({required DateTime currentDate, required Meal? currentMeal})
    : _currentDate = ValueNotifier(currentDate),
      _currentMeal = ValueNotifier(currentMeal != null ? currentMeal.value : -1),
      _originalMeal = currentMeal;

  final ValueNotifier<DateTime> _currentDate;
  final ValueNotifier<int> _currentMeal;
  final Meal? _originalMeal;

  ValueNotifier<DateTime> get currentDate => _currentDate;
  ValueNotifier<int> get currentMeal => _currentMeal;
  Meal? get originalMeal => _originalMeal;

  @override
  void dispose() {
    _currentDate.dispose();
    _currentMeal.dispose();

    super.dispose();
  }
}

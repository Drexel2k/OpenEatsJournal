import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/nutritions.dart';

class FoodRepositoryGetDayDataResult {
  const FoodRepositoryGetDayDataResult({Nutritions? dayNutritionTargets, Map<Meal, Nutritions>? nutritionSumsPerMeal})
    : _dayNutritionTargets = dayNutritionTargets,
      _nutritionSumsPerMeal = nutritionSumsPerMeal;

  final Nutritions? _dayNutritionTargets;
  final Map<Meal, Nutritions>? _nutritionSumsPerMeal;

  Nutritions? get dayNutritionTargets => _dayNutritionTargets;
  Map<Meal, Nutritions>? get nutritionSumsPerMeal => _nutritionSumsPerMeal;
}

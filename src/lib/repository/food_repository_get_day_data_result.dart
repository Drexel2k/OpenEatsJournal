import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/nutritions.dart';

class FoodRepositoryGetDayMealSumsResult {
  const FoodRepositoryGetDayMealSumsResult({Nutritions? dayNutritionTargets, Map<Meal, Nutritions>? mealNutritionSums})
    : _dayNutritionTargets = dayNutritionTargets,
      _mealNutritionSums = mealNutritionSums;

  final Nutritions? _dayNutritionTargets;
  final Map<Meal, Nutritions>? _mealNutritionSums;

  Nutritions? get dayNutritionTargets => _dayNutritionTargets;
  Map<Meal, Nutritions>? get mealNutritionSums => _mealNutritionSums;
}

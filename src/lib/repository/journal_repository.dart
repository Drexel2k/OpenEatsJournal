import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";

class JournalRepository {
  JournalRepository._singleton();
  static final JournalRepository instance = JournalRepository._singleton();

  late OpenEatsJournalDatabaseService _oejDatabase;

  //must be called once before the singleton is used
  void init({required OpenEatsJournalDatabaseService oejDatabase}) {
    _oejDatabase = oejDatabase;
  }

  Future<void> saveOnceDayNutritionTarget({required DateTime entryDate, required int dayTargetKJoule}) async {
    await _oejDatabase.insertOnceDayNutritionTarget(entryDate, dayTargetKJoule);
  }

  Future<void> addEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _oejDatabase.insertEatsJournalEntry(eatsJournalEntry);
  }

  Future<void> addWeightJournalEntry({required DateTime date, required double weight}) async {
    await _oejDatabase.insertWeightJournalEntry(date, weight);
  }

  Future<FoodRepositoryGetDayDataResult> getDayData({required DateTime date}) async {
    int? dayKJouleTarget = await _oejDatabase.getDayNutritionTargets(date);
    Map<Meal, Nutritions>? sumsPerMeal = await _oejDatabase.getDaySumsPerMeal(date);
    if ((dayKJouleTarget != null && sumsPerMeal != null) || (dayKJouleTarget == null && sumsPerMeal == null)) {
      if (dayKJouleTarget != null) {
        return FoodRepositoryGetDayDataResult(
          dayNutritionTargets: Nutritions(
            kJoule: dayKJouleTarget,
            carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget),
            protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget),
            fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget),
          ),
          nutritionSumsPerMeal: sumsPerMeal,
        );
      } else {
        return FoodRepositoryGetDayDataResult();
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }
}

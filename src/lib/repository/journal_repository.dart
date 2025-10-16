import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository_get_sums_result.dart";
import "package:openeatsjournal/domain/nutrition_sums_result.dart";
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
    await _oejDatabase.insertOnceDayNutritionTarget(day: entryDate, dayTargetKJoule: dayTargetKJoule);
  }

  Future<void> addEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _oejDatabase.insertEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  }

  Future<void> addWeightJournalEntry({required DateTime date, required double weight}) async {
    await _oejDatabase.insertWeightJournalEntry(day: date, weight: weight);
  }

  Future<FoodRepositoryGetDayMealSumsResult> getDayMealSums({required DateTime date}) async {
    Map<String, int>? dayKJouleTarget = await _oejDatabase.getGroupedKJouleTargets(from: date, until: date, groupBy: OpenEatsJournalStrings.dbColumnEntryDate);
    Map<Meal, Nutritions>? sumsPerMeal = await _oejDatabase.getDayNutritionSumsPerMeal(day: date);
    if ((dayKJouleTarget != null && sumsPerMeal != null) || (dayKJouleTarget == null && sumsPerMeal == null)) {
      if (dayKJouleTarget != null) {
        return FoodRepositoryGetDayMealSumsResult(
          dayNutritionTargets: Nutritions(
            kJoule: dayKJouleTarget.entries.first.value,
            carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget.entries.first.value),
            protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget.entries.first.value),
            fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTarget.entries.first.value),
          ),
          mealNutritionSums: sumsPerMeal,
        );
      } else {
        return FoodRepositoryGetDayMealSumsResult();
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  //current day and last month
  Future<JournalRepositoryGetSumsResult> getDaySumsForLast32Days() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    DateTime before31days = today.subtract(Duration(days: 31));

    Map<String, int>? dayKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnEntryDate,
    );
    Map<String, NutritionSums>? nutritionSumsPerDay = await _oejDatabase.getGroupedNutritionSums(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnEntryDate,
    );
    if ((dayKJouleTargets != null && nutritionSumsPerDay != null) || (dayKJouleTargets == null && nutritionSumsPerDay == null)) {
      if (dayKJouleTargets != null) {
        JournalRepositoryGetSumsResult result = JournalRepositoryGetSumsResult(
          groupNutritionSums: nutritionSumsPerDay,
          groupNutritionTargets: {},
          from: before31days,
          until: today,
        );

        for (MapEntry<String, NutritionSums> dayNutrionSum in nutritionSumsPerDay!.entries) {
          if (dayKJouleTargets.containsKey(dayNutrionSum.key)) {
            result.groupNutritionTargets![dayNutrionSum.key] = Nutritions(
              kJoule: dayKJouleTargets[dayNutrionSum.key]!,
              carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTargets[dayNutrionSum.key]!),
              protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTargets[dayNutrionSum.key]!),
              fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: dayKJouleTargets[dayNutrionSum.key]!),
            );
          } else {
            throw StateError("Day data and day targets must both exist or both not exist.");
          }
        }

        return result;
      } else {
        return JournalRepositoryGetSumsResult(from: before31days, until: today);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  //current week and last 14 weeks, data of last 3 months. Last 30 months can have 31+30+31=92 days, 92/7=31,14, so we need 14 weeks + current week.
  Future<JournalRepositoryGetSumsResult> getWeekSumsForLast15Weeks() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    //14*7-1 (-1c because to get the current week, we need so substract 6 days from today. Then weh have Wednesday to Tuesday e.g.)
    DateTime before14weeks = today.subtract(Duration(days: 97));
    if (before14weeks.day == 1) {
      before14weeks.subtract(Duration(days: before14weeks.day - 7));
    } else {
      before14weeks.subtract(Duration(days: before14weeks.day - (before14weeks.day - 1)));
    }

    Map<String, int>? weekKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before14weeks,
      until: today,
      groupBy: OpenEatsJournalStrings.dbResultWeekOfYear,
    );
    Map<String, NutritionSums>? nutritionSumsPerWeek = await _oejDatabase.getGroupedNutritionSums(
      from: before14weeks,
      until: today,
      groupBy: OpenEatsJournalStrings.dbResultWeekOfYear,
    );
    if ((weekKJouleTargets != null && nutritionSumsPerWeek != null) || (weekKJouleTargets == null && nutritionSumsPerWeek == null)) {
      if (weekKJouleTargets != null) {
        JournalRepositoryGetSumsResult result = JournalRepositoryGetSumsResult(
          groupNutritionSums: nutritionSumsPerWeek,
          groupNutritionTargets: {},
          from: before14weeks,
          until: today,
        );

        for (MapEntry<String, NutritionSums> dayNutrionSum in nutritionSumsPerWeek!.entries) {
          if (weekKJouleTargets.containsKey(dayNutrionSum.key)) {
            result.groupNutritionTargets![dayNutrionSum.key] = Nutritions(
              kJoule: weekKJouleTargets[dayNutrionSum.key]!,
              carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
              protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
              fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
            );
          } else {
            throw StateError("Day data and day targets must both exist or both not exist.");
          }
        }

        return result;
      } else {
        return JournalRepositoryGetSumsResult(from: before14weeks, until: today);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  //current month and last 12 months
  Future<JournalRepositoryGetSumsResult> getMonthSumsForLast13Months() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    DateTime before12months = DateTime(today.year - 1, today.month, 1);

    Map<String, int>? weekKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbResultMonthOfYear,
    );
    Map<String, NutritionSums>? nutritionSumsPerWeek = await _oejDatabase.getGroupedNutritionSums(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbResultMonthOfYear,
    );
    if ((weekKJouleTargets != null && nutritionSumsPerWeek != null) || (weekKJouleTargets == null && nutritionSumsPerWeek == null)) {
      if (weekKJouleTargets != null) {
        JournalRepositoryGetSumsResult result = JournalRepositoryGetSumsResult(
          groupNutritionSums: nutritionSumsPerWeek,
          groupNutritionTargets: {},
          from: before12months,
          until: today,
        );

        for (MapEntry<String, NutritionSums> dayNutrionSum in nutritionSumsPerWeek!.entries) {
          if (weekKJouleTargets.containsKey(dayNutrionSum.key)) {
            result.groupNutritionTargets![dayNutrionSum.key] = Nutritions(
              kJoule: weekKJouleTargets[dayNutrionSum.key]!,
              carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
              protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
              fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: weekKJouleTargets[dayNutrionSum.key]!),
            );
          } else {
            throw StateError("Day data and day targets must both exist or both not exist.");
          }
        }

        return result;
      } else {
        return JournalRepositoryGetSumsResult(from: before12months, until: today);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }
}

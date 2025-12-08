import "package:collection/collection.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/domain/nutrition_sums.dart";
import "package:openeatsjournal/repository/journal_repository_get_weight_max_result.dart";
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
    await _oejDatabase.insertOnceDaDateInfo(date: entryDate);
    await _oejDatabase.insertOnceDayNutritionTarget(day: entryDate, dayTargetKJoule: dayTargetKJoule);
  }

  Future<void> addEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _oejDatabase.insertOnceDaDateInfo(date: eatsJournalEntry.entryDate);
    await _oejDatabase.insertEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  }

  Future<FoodRepositoryGetDayMealSumsResult> getDayMealSums({required DateTime date}) async {
    Map<DateTime, int>? dayKJouleTarget = await _oejDatabase.getGroupedKJouleTargets(from: date, until: date, groupBy: OpenEatsJournalStrings.dbColumnDate);
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
  Future<JournalRepositoryGetNutritionSumsResult> getNutritionDaySumsForLast32Days() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    
    DateTime before31days = today.subtract(Duration(days: 31));

    Map<DateTime, int>? dayKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnDate,
    );

    Map<DateTime, NutritionSums>? nutritionSumsPerDay = await _oejDatabase.getGroupedNutritionSums(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnDate,
    );

    if ((dayKJouleTargets != null && nutritionSumsPerDay != null) || (dayKJouleTargets == null && nutritionSumsPerDay == null)) {
      if (dayKJouleTargets != null) {
        JournalRepositoryGetNutritionSumsResult result = JournalRepositoryGetNutritionSumsResult(
          groupNutritionSums: nutritionSumsPerDay,
          groupNutritionTargets: {},
          from: before31days,
          until: today,
        );

        for (MapEntry<DateTime, NutritionSums> dayNutrionSum in nutritionSumsPerDay!.entries) {
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
        return JournalRepositoryGetNutritionSumsResult(from: before31days, until: today);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  //current week and last 14 weeks, data of last 3 months. Last 3 months can have 31+30+31=92 days, 92/7=13.14, so we need 14 weeks + current week.
  Future<JournalRepositoryGetNutritionSumsResult> getNutritionWeekSumsForLast15Weeks() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime thisWeekStartDate = ConvertValidate.getWeekStartDate(today);
    DateTime before14weeksStartDate = thisWeekStartDate.subtract(Duration(days: 98));

    before14weeksStartDate = thisWeekStartDate.subtract(Duration(days: 98));

    Map<DateTime, int>? weekKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before14weeksStartDate,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    Map<DateTime, NutritionSums>? nutritionSumsPerWeek = await _oejDatabase.getGroupedNutritionSums(
      from: before14weeksStartDate,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    if ((weekKJouleTargets != null && nutritionSumsPerWeek != null) || (weekKJouleTargets == null && nutritionSumsPerWeek == null)) {
      if (weekKJouleTargets != null) {
        JournalRepositoryGetNutritionSumsResult result = JournalRepositoryGetNutritionSumsResult(
          groupNutritionSums: nutritionSumsPerWeek,
          groupNutritionTargets: {},
          from: before14weeksStartDate,
          until: thisWeekStartDate,
        );

        for (MapEntry<DateTime, NutritionSums> dayNutrionSum in nutritionSumsPerWeek!.entries) {
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
        return JournalRepositoryGetNutritionSumsResult(from: before14weeksStartDate, until: thisWeekStartDate);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  //current month and last 12 months
  Future<JournalRepositoryGetNutritionSumsResult> getNutritionMonthSumsForLast13Months() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime thisMonthStartDate = DateTime(today.year, today.month, today.day);

    int nextMonthYear = thisMonthStartDate.year;
    int nextMonth = thisMonthStartDate.month + 1;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextMonthYear = nextMonthYear + 1;
    }

    DateTime before12months = DateTime(today.year - 1, today.month, 1);

    Map<DateTime, int>? weekKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    Map<DateTime, NutritionSums>? nutritionSumsPerWeek = await _oejDatabase.getGroupedNutritionSums(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    if ((weekKJouleTargets != null && nutritionSumsPerWeek != null) || (weekKJouleTargets == null && nutritionSumsPerWeek == null)) {
      if (weekKJouleTargets != null) {
        JournalRepositoryGetNutritionSumsResult result = JournalRepositoryGetNutritionSumsResult(
          groupNutritionSums: nutritionSumsPerWeek,
          groupNutritionTargets: {},
          from: before12months,
          until: thisMonthStartDate,
        );

        for (MapEntry<DateTime, NutritionSums> dayNutrionSum in nutritionSumsPerWeek!.entries) {
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
        return JournalRepositoryGetNutritionSumsResult(from: before12months, until: thisMonthStartDate);
      }
    } else {
      throw StateError("Day data and day targets must both exist or both not exist.");
    }
  }

  Future<void> setWeightJournalEntry({required DateTime date, required double weight}) async {
    await _oejDatabase.insertOnceDaDateInfo(date: date);
    await _oejDatabase.setWeightJournalEntry(day: date, weight: weight);
  }

  Future<bool> deleteWeightJournalEntry(DateTime date) async {
    return await _oejDatabase.deleteWeightJournalEntry(date: date);
  }

  Future<WeightJournalEntry?> getWeightJournalEntryFor(DateTime date) async {
    return await _oejDatabase.getMaxWeightJournalEntryFor(date: date, maxOf: OpenEatsJournalStrings.dbColumnDate);
  }

  Future<double> getLastWeightJournalEntry() async {
    return await _oejDatabase.getLastWeightJournalEntry();
  }

  Future<List<WeightJournalEntry>?> get10WeightJournalEntries({required int startIndex}) async {
    return await _oejDatabase.get10WeightJournalEntries(startIndex: startIndex);
  }

  //current day and last month
  Future<JournalRepositoryGetWeightMaxResult>? getWeightPerDayForLast32Days() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime before31days = today.subtract(Duration(days: 31));

    Map<DateTime, double>? weightPerDay = await _oejDatabase.getWeightMax(from: before31days, until: today, maxOf: OpenEatsJournalStrings.dbColumnEntryDate);

    if (weightPerDay == null || !weightPerDay.containsKey(before31days)) {
      WeightJournalEntry? weightBeforeInterval = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before31days.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnDate,
      );
      if (weightBeforeInterval != null) {
        weightPerDay ??= {};
        weightPerDay[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightPerDay != null && !weightPerDay.containsKey(today)) {
      WeightJournalEntry? weightAfterInterval = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: today.add(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnDate,
      );
      if (weightAfterInterval != null) {
        weightPerDay[weightAfterInterval.date] = weightAfterInterval.weight;
      } else {
        weightPerDay[today] = weightPerDay[weightPerDay.keys.max]!;
      }
    }

    if (weightPerDay != null) {
      JournalRepositoryGetWeightMaxResult result = JournalRepositoryGetWeightMaxResult(groupMaxWeights: weightPerDay, from: before31days, until: today);

      return result;
    } else {
      return JournalRepositoryGetWeightMaxResult(from: before31days, until: today);
    }
  }

  //current week and last 14 weeks, data of last 3 months. Last 3 months can have 31+30+31=92 days, 92/7=13.14, so we need 14 weeks + current week.
  Future<JournalRepositoryGetWeightMaxResult>? getMaxWeightPerWeekForLast15Weeks() async {
    //set start of week (monday) on before14weeks
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime thisWeekStartDate = ConvertValidate.getWeekStartDate(today);
    DateTime before14weeksStartDate = thisWeekStartDate.subtract(Duration(days: 98));

    Map<DateTime, double>? weightMaxPerWeek = await _oejDatabase.getWeightMax(
      from: before14weeksStartDate,
      until: today,
      maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    if (weightMaxPerWeek == null || !weightMaxPerWeek.containsKey(before14weeksStartDate)) {
      WeightJournalEntry? weightBeforeInterval = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before14weeksStartDate.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
      );
      if (weightBeforeInterval != null) {
        weightMaxPerWeek ??= {};
        weightMaxPerWeek[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightMaxPerWeek != null && !weightMaxPerWeek.containsKey(thisWeekStartDate)) {
      WeightJournalEntry? weightAfterInterval = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: thisWeekStartDate.add(Duration(days: 7)),
        maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
      );
      if (weightAfterInterval != null) {
        weightMaxPerWeek[weightAfterInterval.date] = weightAfterInterval.weight;
      } else {
        weightMaxPerWeek[thisWeekStartDate] = weightMaxPerWeek[weightMaxPerWeek.keys.max]!;
      }
    }

    if (weightMaxPerWeek != null) {
      JournalRepositoryGetWeightMaxResult result = JournalRepositoryGetWeightMaxResult(
        groupMaxWeights: weightMaxPerWeek,
        from: before14weeksStartDate,
        until: thisWeekStartDate,
      );
      return result;
    } else {
      return JournalRepositoryGetWeightMaxResult(from: before14weeksStartDate, until: thisWeekStartDate);
    }
  }

  //current month and last 12 months
  Future<JournalRepositoryGetWeightMaxResult>? getMaxWeightPerMonthForLast13Months() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime thisMonthStartDate = DateTime(today.year, today.month, 1);

    int nextMonthYear = thisMonthStartDate.year;
    int nextMonth = thisMonthStartDate.month + 1;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextMonthYear = nextMonthYear + 1;
    }

    DateTime before12monthsStartDate = DateTime(today.year - 1, today.month, 1);

    Map<DateTime, double>? weightMaxPerMonth = await _oejDatabase.getWeightMax(
      from: before12monthsStartDate,
      until: today,
      maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    if (weightMaxPerMonth == null || !weightMaxPerMonth.containsKey(before12monthsStartDate)) {
      WeightJournalEntry? weightBeforeInterval = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before12monthsStartDate.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
      );
      if (weightBeforeInterval != null) {
        weightMaxPerMonth ??= {};
        weightMaxPerMonth[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightMaxPerMonth != null && !weightMaxPerMonth.containsKey(thisMonthStartDate)) {
      WeightJournalEntry? weightAfterInterval = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: DateTime(nextMonthYear, nextMonth, 1),
        maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
      );
      if (weightAfterInterval != null) {
        weightMaxPerMonth[weightAfterInterval.date] = weightAfterInterval.weight;
      } else {
        weightMaxPerMonth[thisMonthStartDate] = weightMaxPerMonth[weightMaxPerMonth.keys.max]!;
      }
    }

    if (weightMaxPerMonth != null) {
      JournalRepositoryGetWeightMaxResult result = JournalRepositoryGetWeightMaxResult(
        groupMaxWeights: weightMaxPerMonth,
        from: before12monthsStartDate,
        until: thisMonthStartDate,
      );
      return result;
    } else {
      return JournalRepositoryGetWeightMaxResult(from: before12monthsStartDate, until: thisMonthStartDate);
    }
  }
}

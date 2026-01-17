import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/repository/food_repository_get_day_data_result.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/domain/nutrition_sums.dart";
import "package:openeatsjournal/repository/journal_repository_get_weight_max_result.dart";
import "package:openeatsjournal/repository/convert.dart";
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

  Future<void> setEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _oejDatabase.insertOnceDaDateInfo(date: eatsJournalEntry.entryDate);
    await _oejDatabase.setEatsJournalEntry(
      eatsJournalEntryData: {
        OpenEatsJournalStrings.dbColumnFoodIdRef: eatsJournalEntry.food?.id,
        OpenEatsJournalStrings.dbColumnEntryDate: ConvertValidate.dateformatterDatabaseDateOnly.format(eatsJournalEntry.entryDate),
        OpenEatsJournalStrings.dbColumnName: eatsJournalEntry.name,
        OpenEatsJournalStrings.dbColumnAmount: eatsJournalEntry.amount,
        OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef: eatsJournalEntry.amountMeasurementUnit?.value,
        OpenEatsJournalStrings.dbColumnKiloJoule: eatsJournalEntry.kJoule,
        OpenEatsJournalStrings.dbColumnCarbohydrates: eatsJournalEntry.carbohydrates,
        OpenEatsJournalStrings.dbColumnSugar: eatsJournalEntry.sugar,
        OpenEatsJournalStrings.dbColumnFat: eatsJournalEntry.fat,
        OpenEatsJournalStrings.dbColumnSaturatedFat: eatsJournalEntry.saturatedFat,
        OpenEatsJournalStrings.dbColumnProtein: eatsJournalEntry.protein,
        OpenEatsJournalStrings.dbColumnSalt: eatsJournalEntry.salt,
        OpenEatsJournalStrings.dbColumnMealIdRef: eatsJournalEntry.meal.value,
      },
      id: eatsJournalEntry.id,
    );
  }

  Future<void> duplicateEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await setEatsJournalEntry(eatsJournalEntry: EatsJournalEntry.copyAsNew(eatsJournalEntry: eatsJournalEntry));
  }

  Future<List<EatsJournalEntry>?> getEatsJournalEntries({required DateTime date, Meal? meal}) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getEatsJournalEntries(date: date, mealValue: meal?.value);
    if (dbResult == null) {
      return null;
    }

    List<EatsJournalEntry> eatsJournalEntries = [];

    int currentRowEatsJournalEntryId = -1;
    int currentEatsJournalEntryId = -1;

    List<Map<String, Object?>> eatsJournalEntriesRows = [];
    for (Map<String, Object?> eatsJournalEntryRow in dbResult) {
      currentRowEatsJournalEntryId = eatsJournalEntryRow[OpenEatsJournalStrings.dbResultEatsJournalEntryId] as int;
      if (currentEatsJournalEntryId != currentRowEatsJournalEntryId) {
        if (currentEatsJournalEntryId != -1) {
          eatsJournalEntries.add(_getEatsJournalEntryFromDbResult(eatsJournalEntriesRows: eatsJournalEntriesRows));
          eatsJournalEntriesRows.clear();
        }

        currentEatsJournalEntryId = currentRowEatsJournalEntryId;
      }

      eatsJournalEntriesRows.add(eatsJournalEntryRow);
    }

    eatsJournalEntries.add(_getEatsJournalEntryFromDbResult(eatsJournalEntriesRows: eatsJournalEntriesRows));

    return eatsJournalEntries;
  }

  EatsJournalEntry _getEatsJournalEntryFromDbResult({required List<Map<String, Object?>> eatsJournalEntriesRows}) {
    if ((eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultFoodId] as int?) != null) {
      return EatsJournalEntry.fromData(
        id: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryId] as int,
        entryDate: ConvertValidate.dateformatterDatabaseDateOnly.parse(eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbColumnEntryDate] as String),
        name: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryName] as String,
        kJoule: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryKiloJoule] as int,
        meal: Meal.getByValue(eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbColumnMealIdRef] as int),
        food: Convert.getFoodFromDbResult(dbResult: eatsJournalEntriesRows),
        amount: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmount] as double,
        amountMeasurementUnit: MeasurementUnit.getByValue(
          eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmountMeasurementUnitIdRef] as int,
        ),
        carbohydrates: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryCarbohydrates] as double?,
        sugar: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySugar] as double?,
        fat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryFat] as double?,
        saturatedFat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySaturatedFat] as double?,
        protein: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryProtein] as double?,
        salt: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySalt] as double?,
      );
    } else {
      return EatsJournalEntry.fromData(
        id: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryId] as int,
        entryDate: ConvertValidate.dateformatterDatabaseDateOnly.parse(eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbColumnEntryDate] as String),
        name: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryName] as String,
        kJoule: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryKiloJoule] as int,
        meal: Meal.getByValue(eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbColumnMealIdRef] as int),
        amount: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmount] as double?,
        amountMeasurementUnit: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmountMeasurementUnitIdRef] != null
            ? MeasurementUnit.getByValue(eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmountMeasurementUnitIdRef] as int)
            : null,
        carbohydrates: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryCarbohydrates] as double?,
        sugar: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySugar] as double?,
        fat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryFat] as double?,
        saturatedFat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySaturatedFat] as double?,
        protein: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryProtein] as double?,
        salt: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySalt] as double?,
      );
    }
  }

  Future<bool> deleteEatsJournalEntry({required int id}) async {
    return await _oejDatabase.deleteEatsJournalEntry(id: id);
  }

  Future<FoodRepositoryGetDayMealSumsResult> getDayMealSums({required DateTime date}) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getGroupedKJouleTargets(from: date, until: date, groupBy: OpenEatsJournalStrings.dbColumnDate);

    Map<DateTime, int>? dayKJouleTarget;
    if (dbResult != null) {
      dayKJouleTarget = _getKJouleTargets(dbResult: dbResult);
    }

    List<Map<String, Object?>>? sumsPerMealResult = await _oejDatabase.getDayNutritionSumsPerMeal(day: date);

    Map<Meal, Nutritions>? sumsPerMeal;
    if (sumsPerMealResult != null) {
      sumsPerMeal = {};
      for (Map<String, Object?> row in sumsPerMealResult) {
        sumsPerMeal[Meal.getByValue((row[OpenEatsJournalStrings.dbColumnMealIdRef] as int))] = Nutritions(
          kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
          carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double?),
          sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double?),
          fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double?),
          saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double?),
          protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double?),
          salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double?),
        );
      }
    }

    if ((dayKJouleTarget != null && sumsPerMeal != null) ||
        (dayKJouleTarget == null && sumsPerMeal == null) ||
        (dayKJouleTarget != null && sumsPerMeal == null)) {
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
      throw StateError("If day data exists, day targets must exist.");
    }
  }

  //current day and last month
  Future<JournalRepositoryGetNutritionSumsResult> getNutritionDaySumsForLast32Days() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime before31days = today.subtract(Duration(days: 31));

    List<Map<String, Object?>>? dbResultKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnDate,
    );

    Map<DateTime, int>? dayKJouleTargets;
    if (dbResultKJouleTargets != null) {
      dayKJouleTargets = _getKJouleTargets(dbResult: dbResultKJouleTargets);
    }

    Map<DateTime, NutritionSums>? nutritionSumsPerDay;
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getGroupedNutritionSums(
      from: before31days,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnDate,
    );

    if (dbResult != null) {
      nutritionSumsPerDay = {};
      for (Map<String, Object?> row in dbResult) {
        nutritionSumsPerDay[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] = NutritionSums(
          entryCount: row[OpenEatsJournalStrings.dbResultDayCount] as int,
          nutritions: Nutritions(
            kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
            carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double?),
            sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double?),
            fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double?),
            saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double?),
            protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double?),
            salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double?),
          ),
        );
      }
    }

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

    List<Map<String, Object?>>? dbResultKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before14weeksStartDate,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    Map<DateTime, int>? weekKJouleTargets;
    if (dbResultKJouleTargets != null) {
      weekKJouleTargets = _getKJouleTargets(dbResult: dbResultKJouleTargets);
    }

    Map<DateTime, NutritionSums>? nutritionSumsPerWeek;
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getGroupedNutritionSums(
      from: before14weeksStartDate,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    if (dbResult != null) {
      nutritionSumsPerWeek = {};
      for (Map<String, Object?> row in dbResult) {
        nutritionSumsPerWeek[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] = NutritionSums(
          entryCount: row[OpenEatsJournalStrings.dbResultDayCount] as int,
          nutritions: Nutritions(
            kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
            carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double?),
            sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double?),
            fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double?),
            saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double?),
            protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double?),
            salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double?),
          ),
        );
      }
    }

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

    List<Map<String, Object?>>? dbResultKJouleTargets = await _oejDatabase.getGroupedKJouleTargets(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    Map<DateTime, int>? monthKJouleTargets;
    if (dbResultKJouleTargets != null) {
      monthKJouleTargets = _getKJouleTargets(dbResult: dbResultKJouleTargets);
    }

    Map<DateTime, NutritionSums>? nutritionSumsPerMonth;
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getGroupedNutritionSums(
      from: before12months,
      until: today,
      groupBy: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    if (dbResult != null) {
      nutritionSumsPerMonth = {};
      for (Map<String, Object?> row in dbResult) {
        nutritionSumsPerMonth[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] = NutritionSums(
          entryCount: row[OpenEatsJournalStrings.dbResultDayCount] as int,
          nutritions: Nutritions(
            kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
            carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double?),
            sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double?),
            fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double?),
            saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double?),
            protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double?),
            salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double?),
          ),
        );
      }
    }

    if ((monthKJouleTargets != null && nutritionSumsPerMonth != null) || (monthKJouleTargets == null && nutritionSumsPerMonth == null)) {
      if (monthKJouleTargets != null) {
        JournalRepositoryGetNutritionSumsResult result = JournalRepositoryGetNutritionSumsResult(
          groupNutritionSums: nutritionSumsPerMonth,
          groupNutritionTargets: {},
          from: before12months,
          until: thisMonthStartDate,
        );

        for (MapEntry<DateTime, NutritionSums> dayNutrionSum in nutritionSumsPerMonth!.entries) {
          if (monthKJouleTargets.containsKey(dayNutrionSum.key)) {
            result.groupNutritionTargets![dayNutrionSum.key] = Nutritions(
              kJoule: monthKJouleTargets[dayNutrionSum.key]!,
              carbohydrates: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: monthKJouleTargets[dayNutrionSum.key]!),
              protein: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: monthKJouleTargets[dayNutrionSum.key]!),
              fat: NutritionCalculator.calculateCarbohydrateDemandByKJoule(kJoule: monthKJouleTargets[dayNutrionSum.key]!),
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

  Future<bool> deleteWeightJournalEntry({required DateTime date}) async {
    return await _oejDatabase.deleteWeightJournalEntry(date: date);
  }

  Future<WeightJournalEntry?> getWeightJournalEntryFor(DateTime date) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabase.getMaxWeightJournalEntryFor(date: date, maxOf: OpenEatsJournalStrings.dbColumnDate);
    if (dbResult != null) {
      return WeightJournalEntry(
        date: ConvertValidate.dateformatterDatabaseDateOnly.parse(dbResult[0][OpenEatsJournalStrings.dbResultGroupColumn] as String),
        weight: dbResult[0][OpenEatsJournalStrings.dbResultWeightMax] as double,
      );
    }

    return null;
  }

  Future<double> getLastWeightJournalEntry() async {
    return await _oejDatabase.getLastWeightJournalEntry();
  }

  Future<List<WeightJournalEntry>?> get10WeightJournalEntries({required int startIndex}) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabase.get10WeightJournalEntries(startIndex: startIndex);

    List<WeightJournalEntry> result = [];
    if (dbResult != null) {
      for (Map<String, Object?> row in dbResult) {
        result.add(
          WeightJournalEntry(
            date: ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbColumnEntryDate] as String),
            weight: row[OpenEatsJournalStrings.dbColumnWeight] as double,
          ),
        );
      }
    }

    return result;
  }

  //current day and last month
  Future<JournalRepositoryGetWeightMaxResult>? getWeightPerDayForLast32Days() async {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime before31days = today.subtract(Duration(days: 31));

    List<Map<String, Object?>>? dbResultWeightMax = await _oejDatabase.getWeightMax(
      from: before31days,
      until: today,
      maxOf: OpenEatsJournalStrings.dbColumnEntryDate,
    );
    Map<DateTime, double>? weightPerDay;

    if (dbResultWeightMax != null) {
      weightPerDay = _getWeightMax(dbResult: dbResultWeightMax);
    }

    if (weightPerDay == null || !weightPerDay.containsKey(before31days)) {
      List<Map<String, Object?>>? dbResultFor = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before31days.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnDate,
      );

      WeightJournalEntry? weightBeforeInterval;
      if (dbResultFor != null) {
        weightBeforeInterval = _getWeightJournalEntryFromDbResult(dbResultFor);
      }

      if (weightBeforeInterval != null) {
        weightPerDay ??= {};
        weightPerDay[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightPerDay != null && !weightPerDay.containsKey(today)) {
      List<Map<String, Object?>>? dbResultAfter = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: today.add(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnDate,
      );

      WeightJournalEntry? weightAfterInterval;
      if (dbResultAfter != null) {
        weightAfterInterval = _getWeightJournalEntryFromDbResult(dbResultAfter);
      }

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

  WeightJournalEntry? _getWeightJournalEntryFromDbResult(List<Map<String, Object?>> dbResult) {
    return WeightJournalEntry(
      date: ConvertValidate.dateformatterDatabaseDateOnly.parse(dbResult[0][OpenEatsJournalStrings.dbResultGroupColumn] as String),
      weight: dbResult[0][OpenEatsJournalStrings.dbResultWeightMax] as double,
    );
  }

  //current week and last 14 weeks, data of last 3 months. Last 3 months can have 31+30+31=92 days, 92/7=13.14, so we need 14 weeks + current week.
  Future<JournalRepositoryGetWeightMaxResult>? getMaxWeightPerWeekForLast15Weeks() async {
    //set start of week (monday) on before14weeks
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime thisWeekStartDate = ConvertValidate.getWeekStartDate(today);
    DateTime before14weeksStartDate = thisWeekStartDate.subtract(Duration(days: 98));

    List<Map<String, Object?>>? dbResultWeightMax = await _oejDatabase.getWeightMax(
      from: before14weeksStartDate,
      until: today,
      maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
    );

    Map<DateTime, double>? weightMaxPerWeek;

    if (dbResultWeightMax != null) {
      weightMaxPerWeek = _getWeightMax(dbResult: dbResultWeightMax);
    }

    if (weightMaxPerWeek == null || !weightMaxPerWeek.containsKey(before14weeksStartDate)) {
      List<Map<String, Object?>>? dbResultFor = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before14weeksStartDate.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
      );

      WeightJournalEntry? weightBeforeInterval;
      if (dbResultFor != null) {
        weightBeforeInterval = _getWeightJournalEntryFromDbResult(dbResultFor);
      }

      if (weightBeforeInterval != null) {
        weightMaxPerWeek ??= {};
        weightMaxPerWeek[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightMaxPerWeek != null && !weightMaxPerWeek.containsKey(thisWeekStartDate)) {
      List<Map<String, Object?>>? dbResultAfter = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: thisWeekStartDate.add(Duration(days: 7)),
        maxOf: OpenEatsJournalStrings.dbColumnWeekStartDate,
      );

      WeightJournalEntry? weightAfterInterval;
      if (dbResultAfter != null) {
        weightAfterInterval = _getWeightJournalEntryFromDbResult(dbResultAfter);
      }

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

    List<Map<String, Object?>>? dbResultWeightMax = await _oejDatabase.getWeightMax(
      from: before12monthsStartDate,
      until: today,
      maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
    );

    Map<DateTime, double>? weightMaxPerMonth;
    if (dbResultWeightMax != null) {
      weightMaxPerMonth = _getWeightMax(dbResult: dbResultWeightMax);
    }

    if (weightMaxPerMonth == null || !weightMaxPerMonth.containsKey(before12monthsStartDate)) {
      List<Map<String, Object?>>? dbResultFor = await _oejDatabase.getMaxWeightJournalEntryFor(
        date: before12monthsStartDate.subtract(Duration(days: 1)),
        maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
      );

      WeightJournalEntry? weightBeforeInterval;
      if (dbResultFor != null) {
        weightBeforeInterval = _getWeightJournalEntryFromDbResult(dbResultFor);
      }

      if (weightBeforeInterval != null) {
        weightMaxPerMonth ??= {};
        weightMaxPerMonth[weightBeforeInterval.date] = weightBeforeInterval.weight;
      }
    }

    if (weightMaxPerMonth != null && !weightMaxPerMonth.containsKey(thisMonthStartDate)) {
      List<Map<String, Object?>>? dbResultAfter = await _oejDatabase.getMaxWeightJournalEntryAfter(
        date: DateTime(nextMonthYear, nextMonth, 1),
        maxOf: OpenEatsJournalStrings.dbColumnMonthStartDate,
      );

      WeightJournalEntry? weightAfterInterval;
      if (dbResultAfter != null) {
        weightAfterInterval = _getWeightJournalEntryFromDbResult(dbResultAfter);
      }

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

  Future<Map<int, bool>> getEatsJournalEntriesAvailableForLast8Days() async {
    Map<int, bool> result = {};

    DateTime today = DateUtils.dateOnly(DateTime.now());
    DateTime currentDay = today.subtract(Duration(days: 7));

    List<Map<String, Object?>>? dbResult = await _oejDatabase.getEatsJournalEntriesAvailable(from: currentDay, until: today);

    Map<DateTime, bool> dbData = {};
    if (dbResult != null) {
      for (Map<String, Object?> row in dbResult) {
        dbData[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbColumnEntryDate] as String)] =
            (row[OpenEatsJournalStrings.dbResultEntryCount] as int) > 0;
      }
    }

    for (int dayIndex = -7; dayIndex <= 0; dayIndex++) {
      result[dayIndex] = dbData.containsKey(currentDay);
      currentDay = currentDay.add(Duration(days: 1));
    }

    return result;
  }

  Map<DateTime, int> _getKJouleTargets({required List<Map<String, Object?>> dbResult}) {
    Map<DateTime, int> result = {};
    for (Map<String, Object?> row in dbResult) {
      result[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] =
          row[OpenEatsJournalStrings.dbResultKJouleSum] as int;
    }

    return result;
  }

  Map<DateTime, double> _getWeightMax({required List<Map<String, Object?>> dbResult}) {
    Map<DateTime, double> result = {};
    for (Map<String, Object?> row in dbResult) {
      result[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] =
          row[OpenEatsJournalStrings.dbResultWeightMax] as double;
    }

    return result;
  }
}

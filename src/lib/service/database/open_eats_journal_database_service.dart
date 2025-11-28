import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_type.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/nutrition_sums.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class OpenEatsJournalDatabaseService {
  OpenEatsJournalDatabaseService._singleton();
  static final OpenEatsJournalDatabaseService instance = OpenEatsJournalDatabaseService._singleton();

  static Database? _database;

  // final Map<int, String> _migrationScripts = {
  //   2: """SQL...
  //     """,
  // };

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "oej.db");

    return await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableSetting} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnSetting} TEXT,
        ${OpenEatsJournalStrings.dbColumnDartType} TEXT,
        ${OpenEatsJournalStrings.dbColumnvalue} TEXT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableWeightJournal} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnEntryDate} DATE,
        ${OpenEatsJournalStrings.dbColumnWeight} REAL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFood} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef} INT,
        ${OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef} TEXT,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} INT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} INT,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT,
        ${OpenEatsJournalStrings.dbColumnCarbohydrates} REAL,
        ${OpenEatsJournalStrings.dbColumnSugar} REAL,
        ${OpenEatsJournalStrings.dbColumnFat} REAL,
        ${OpenEatsJournalStrings.dbColumnSaturatedFat} REAL,
        ${OpenEatsJournalStrings.dbColumnProtein} REAL,
        ${OpenEatsJournalStrings.dbColumnSalt} REAL,
        ${OpenEatsJournalStrings.dbColumnQuantity} Text
      );""");
    batch.execute("""CREATE VIRTUAL TABLE ${OpenEatsJournalStrings.dbTableFoodTextSearch} USING fts4(
        content="${OpenEatsJournalStrings.dbTableFood}",
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodUnit} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnAmount} INT,
        ${OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnOrderNumber} INT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableEatsJournal} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnEntryDate} DATE NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnAmount} INT,
        ${OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnCarbohydrates} REAL,
        ${OpenEatsJournalStrings.dbColumnSugar} REAL,
        ${OpenEatsJournalStrings.dbColumnFat} REAL,
        ${OpenEatsJournalStrings.dbColumnSaturatedFat} REAL,
        ${OpenEatsJournalStrings.dbColumnProtein} REAL,
        ${OpenEatsJournalStrings.dbColumnSalt} REAL,
        ${OpenEatsJournalStrings.dbColumnMealIdRef} INT NOT NULL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableDailyNutritionTarget} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnEntryDate} DATE NOT NULL,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT NOT NULL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableDateInfo} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnDate} DATE NOT NULL,
        ${OpenEatsJournalStrings.dbColumnWeekOfYearNormalized} TEXT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnMonthOfYearNormalized} TEXT NOT NULL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodSource} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnDescription} TEXT,
        ${OpenEatsJournalStrings.dbColumnUrl} Text
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableMeal} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableMeasurementUnit} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodUnitType} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT
      );""");

    batch.execute("""CREATE UNIQUE INDEX ${OpenEatsJournalStrings.dbIndexDateIndexTableDailyNutritionTarget} ON
        ${OpenEatsJournalStrings.dbTableDailyNutritionTarget}(${OpenEatsJournalStrings.dbColumnEntryDate})
      ;""");
    batch.execute("""CREATE UNIQUE INDEX ${OpenEatsJournalStrings.dbIndexDateIndexTableDateInfo} ON
        ${OpenEatsJournalStrings.dbTableDateInfo}(${OpenEatsJournalStrings.dbColumnDate})
      ;""");

    batch.insert(OpenEatsJournalStrings.dbTableFoodSource, {
      OpenEatsJournalStrings.dbColumnId: 1,
      OpenEatsJournalStrings.dbColumnName: "Open Eats Journal Food Data",
      OpenEatsJournalStrings.dbColumnDescription: "Food data that comes with this app.",
    });
    batch.insert(OpenEatsJournalStrings.dbTableFoodSource, {
      OpenEatsJournalStrings.dbColumnId: 2,
      OpenEatsJournalStrings.dbColumnName: "User Food Data",
      OpenEatsJournalStrings.dbColumnDescription: "Food data created by the user.",
    });
    batch.insert(OpenEatsJournalStrings.dbTableFoodSource, {
      OpenEatsJournalStrings.dbColumnId: 3,
      OpenEatsJournalStrings.dbColumnName: "Open Food Facts",
      OpenEatsJournalStrings.dbColumnDescription:
          "Open Food Facts is a food products database made by everyone, for everyone. You can use it to make better food choices, and as it is open data, anyone can re-use it for any purpose. Open Food Facts is a non-profit project developed by thousands of volunteers from around the world. You can start contributing by adding a product from your kitchen with our app for iPhone or Android, and we have lots of exciting projects you can contribute to in many different ways.",
      "url": "https://world.openfoodfacts.org/",
    });

    batch.insert(OpenEatsJournalStrings.dbTableMeal, {OpenEatsJournalStrings.dbColumnId: 1, OpenEatsJournalStrings.dbColumnName: "breakfast"});
    batch.insert(OpenEatsJournalStrings.dbTableMeal, {OpenEatsJournalStrings.dbColumnId: 2, OpenEatsJournalStrings.dbColumnName: "lunch"});
    batch.insert(OpenEatsJournalStrings.dbTableMeal, {OpenEatsJournalStrings.dbColumnId: 3, OpenEatsJournalStrings.dbColumnName: "dinner"});
    batch.insert(OpenEatsJournalStrings.dbTableMeal, {OpenEatsJournalStrings.dbColumnId: 4, OpenEatsJournalStrings.dbColumnName: "snacks"});

    batch.insert(OpenEatsJournalStrings.dbTableMeasurementUnit, {OpenEatsJournalStrings.dbColumnId: 1, OpenEatsJournalStrings.dbColumnName: "g"});
    batch.insert(OpenEatsJournalStrings.dbTableMeasurementUnit, {OpenEatsJournalStrings.dbColumnId: 2, OpenEatsJournalStrings.dbColumnName: "ml"});

    batch.insert(OpenEatsJournalStrings.dbTableFoodUnitType, {OpenEatsJournalStrings.dbColumnId: 1, OpenEatsJournalStrings.dbColumnName: "piece"});
    batch.insert(OpenEatsJournalStrings.dbTableFoodUnitType, {OpenEatsJournalStrings.dbColumnId: 2, OpenEatsJournalStrings.dbColumnName: "serving"});

    await batch.commit();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // for (int i = oldVersion + 1; i <= newVersion; i++) {
    //   await db.execute(_migrationScripts[i]!);
    // }
  }

  Future<bool> _settingExists({required String setting}) async {
    Database db = await instance.db;
    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableSetting,
      columns: [OpenEatsJournalStrings.dbColumnSetting],
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting],
    );

    if (dbResult.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if (dbResult.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> _insertSetting({required Map<String, String> setting}) async {
    Database db = await instance.db;
    await db.insert(OpenEatsJournalStrings.dbTableSetting, setting);
  }

  Future<void> _updateSetting({required Map<String, String> setting}) async {
    Database db = await instance.db;
    await db.update(
      OpenEatsJournalStrings.dbTableSetting,
      {OpenEatsJournalStrings.dbColumnvalue: setting[OpenEatsJournalStrings.dbColumnvalue]},
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting[OpenEatsJournalStrings.dbColumnSetting]],
    );
  }

  //set...Setting methos create new settings if setting does not exist or updates the existing settings.
  Future<void> setStringSetting({required String setting, required String value}) async {
    if (await _settingExists(setting: setting)) {
      _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value});
    } else {
      await _insertSetting(
        setting: {
          OpenEatsJournalStrings.dbColumnSetting: setting,
          OpenEatsJournalStrings.dbColumnDartType: "String",
          OpenEatsJournalStrings.dbColumnvalue: value,
        },
      );
    }
  }

  Future<void> setIntSetting({required String setting, required int value}) async {
    if (await _settingExists(setting: setting)) {
      _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting(
        setting: {
          OpenEatsJournalStrings.dbColumnSetting: setting,
          OpenEatsJournalStrings.dbColumnDartType: "int",
          OpenEatsJournalStrings.dbColumnvalue: value.toString(),
        },
      );
    }
  }

  Future<void> setDoubleSetting({required String setting, required double value}) async {
    if (await _settingExists(setting: setting)) {
      _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting(
        setting: {
          OpenEatsJournalStrings.dbColumnSetting: setting,
          OpenEatsJournalStrings.dbColumnDartType: "double",
          OpenEatsJournalStrings.dbColumnvalue: value.toString(),
        },
      );
    }
  }

  Future<void> setBoolSetting({required String setting, required bool value}) async {
    if (await _settingExists(setting: setting)) {
      _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting(
        setting: {
          OpenEatsJournalStrings.dbColumnSetting: setting,
          OpenEatsJournalStrings.dbColumnDartType: "bool",
          OpenEatsJournalStrings.dbColumnvalue: value.toString(),
        },
      );
    }
  }

  Future<void> setDateTimeSetting({required String setting, required DateTime value}) async {
    final String formattedDate = ConvertValidate.dateFormatterDatabaseDateAndTime.format(value);

    if (await _settingExists(setting: setting)) {
      _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: formattedDate});
    } else {
      await _insertSetting(
        setting: {
          OpenEatsJournalStrings.dbColumnSetting: setting,
          OpenEatsJournalStrings.dbColumnDartType: "DateTime",
          OpenEatsJournalStrings.dbColumnvalue: formattedDate,
        },
      );
    }
  }

  Future<Object?> _getSetting({required String setting}) async {
    Database db = await instance.db;
    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableSetting,
      columns: [OpenEatsJournalStrings.dbColumnvalue],
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting],
    );

    if (dbResult.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if (dbResult.isEmpty) {
      return null;
    }

    return dbResult[0][OpenEatsJournalStrings.dbColumnvalue];
  }

  Future<void> setAllSettings({required AllSettings allSettings}) async {
    await setBoolSetting(setting: OpenEatsJournalStrings.settingDarkmode, value: allSettings.darkMode!);
    await setStringSetting(setting: OpenEatsJournalStrings.settingLanguageCode, value: allSettings.languageCode!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingGender, value: allSettings.gender!.value);
    await setDateTimeSetting(setting: OpenEatsJournalStrings.settingBirthday, value: allSettings.birthday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingHeight, value: allSettings.height!);
    await setDoubleSetting(setting: OpenEatsJournalStrings.settingActivityFactor, value: allSettings.activityFactor!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingWeightTarget, value: allSettings.weightTarget!.value);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleMonday, value: allSettings.kJouleMonday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleTuesday, value: allSettings.kJouleTuesday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleWednesday, value: allSettings.kJouleWednesday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleThursday, value: allSettings.kJouleThursday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleFriday, value: allSettings.kJouleFriday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleSaturday, value: allSettings.kJouleSaturday!);
    await setIntSetting(setting: OpenEatsJournalStrings.settingKJouleSunday, value: allSettings.kJouleSunday!);
    await setStringSetting(setting: OpenEatsJournalStrings.settingLanguageCode, value: allSettings.languageCode!);
  }

  Future<String?> getStringSetting({required String setting}) async {
    Object? result = await _getSetting(setting: setting);
    return result == null ? null : result as String;
  }

  Future<int?> getIntSetting({required String setting}) async {
    Object? result = await _getSetting(setting: setting);
    return result == null ? null : int.parse(result as String);
  }

  Future<double?> getDoubleSetting({required String setting}) async {
    Object? result = await _getSetting(setting: setting);
    return result == null ? null : double.parse(result as String);
  }

  Future<bool?> getBoolSetting({required String setting}) async {
    Object? result = await _getSetting(setting: setting);
    return result == null ? null : result == "true";
  }

  Future<DateTime?> getDateTimeSetting({required String setting}) async {
    Object? result = await _getSetting(setting: setting);
    if (result == null) {
      return null;
    }

    return ConvertValidate.dateFormatterDatabaseDateAndTime.parse(await _getSetting(setting: setting) as String);
  }

  Future<AllSettings> getAllSettings() async {
    int? gender = await getIntSetting(setting: OpenEatsJournalStrings.settingGender);
    int? weightTarget = await getIntSetting(setting: OpenEatsJournalStrings.settingWeightTarget);

    return AllSettings(
      darkMode: await getBoolSetting(setting: OpenEatsJournalStrings.settingDarkmode),
      languageCode: await getStringSetting(setting: OpenEatsJournalStrings.settingLanguageCode),
      gender: gender != null ? Gender.getByValue(gender) : null,
      birthday: await getDateTimeSetting(setting: OpenEatsJournalStrings.settingBirthday),
      height: await getIntSetting(setting: OpenEatsJournalStrings.settingHeight),
      activityFactor: await getDoubleSetting(setting: OpenEatsJournalStrings.settingActivityFactor),
      weightTarget: weightTarget != null ? WeightTarget.getByValue(weightTarget) : null,
      kJouleMonday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleMonday),
      kJouleTuesday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleTuesday),
      kJouleWednesday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleWednesday),
      kJouleThursday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleThursday),
      kJouleFriday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleFriday),
      kJouleSaturday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleSaturday),
      kJouleSunday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleSunday),
    );
  }

  Future<void> insertEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    Database db = await instance.db;

    if (eatsJournalEntry.food != null && eatsJournalEntry.food!.id == null) {
      throw StateError("Food for eats journal entry must have an id.");
    }

    final String entryDateString = ConvertValidate.dateformatterDatabaseDateOnly.format(eatsJournalEntry.entryDate);
    await db.insert(OpenEatsJournalStrings.dbTableEatsJournal, {
      OpenEatsJournalStrings.dbColumnFoodIdRef: eatsJournalEntry.food?.id,
      OpenEatsJournalStrings.dbColumnEntryDate: entryDateString,
      OpenEatsJournalStrings.dbColumnName: eatsJournalEntry.name,
      OpenEatsJournalStrings.dbColumnAmount: eatsJournalEntry.amount,
      OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef: eatsJournalEntry.amountMeasurementUnit?.value,
      OpenEatsJournalStrings.dbColumnKiloJoule: eatsJournalEntry.kJoule,
      OpenEatsJournalStrings.dbColumnCarbohydrates: eatsJournalEntry.carbohydrates,
      OpenEatsJournalStrings.dbColumnSugar: eatsJournalEntry.sugar,
      OpenEatsJournalStrings.dbColumnFat: eatsJournalEntry.fat,
      OpenEatsJournalStrings.dbColumnSaturatedFat: eatsJournalEntry.saturatedFat,
      OpenEatsJournalStrings.dbColumnProtein: eatsJournalEntry.protein,
      OpenEatsJournalStrings.dbColumnSalt: eatsJournalEntry.salt,
      OpenEatsJournalStrings.dbColumnMealIdRef: eatsJournalEntry.meal.value,
    });
  }

  //creates new food entry or updates an existing one.
  Future<void> setFoodByExternalId({required Food food}) async {
    Database db = await instance.db;
    if (food.foodSource == FoodSource.user) {
      throw ArgumentError("Food update by external id is only needed for foods of external data sources.");
    }

    if (food.foodSourceFoodId == null) {
      throw ArgumentError("Food update by external id required an external food source id.");
    }

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableFood,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = ? AND ${OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef} = ?",
      whereArgs: [food.foodSource.value, food.foodSourceFoodId],
    );

    if (dbResult.length > 1) {
      throw StateError(
        "Only one food entry may exist for a given external food id and food source, multiple entries found for ${food.foodSourceFoodId}, food source ${food.foodSource.name}.",
      );
    }

    if (food.id != null) {
      if (dbResult.isEmpty) {
        throw StateError("No record for a given external id and food source, food id was not null, a food entry should exist.");
      }
    }

    //If food comes from external API and is used for the first time in the food search result screen e.g. it has id null.
    //If we know already the food in the food table, the id from the food table is assigned here.
    if (food.id == null && dbResult.isNotEmpty) {
      food.id = dbResult[0][OpenEatsJournalStrings.dbColumnId] as int;
    }

    await _setFoodInternal(food: food);
  }

  Future<void> setFood({required Food food}) async {
    Database db = await instance.db;
    if (food.foodSource == FoodSource.standard) {
      throw ArgumentError("Food update of standard foods is not allowed.");
    }

    if (food.id != null) {
      final List<Map<String, Object?>> dbResult = await db.query(
        OpenEatsJournalStrings.dbTableFood,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [food.id],
      );

      if (dbResult.length > 1) {
        throw StateError("Only one food entry may exist for a given food id, multiple entries found for ${food.id}.");
      }

      if (dbResult.isEmpty) {
        throw StateError("No record for a given food id, food id was not null, a food entry should exist.");
      }
    }

    await _setFoodInternal(food: food);
  }

  Future<void> _setFoodInternal({required Food food}) async {
    Database db = await instance.db;

    Map<String, Object?> foodData = {
      OpenEatsJournalStrings.dbColumnFoodSourceIdRef: food.foodSource.value,
      OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef: food.originalFoodSource?.value,
      OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef: food.foodSourceFoodId,
      OpenEatsJournalStrings.dbColumnName: food.name.trim() != OpenEatsJournalStrings.emptyString ? food.name : null,
      OpenEatsJournalStrings.dbColumnBrands: (food.brands != null && food.brands!.isNotEmpty) ? food.brands!.join(",") : null,
      OpenEatsJournalStrings.dbColumnNutritionPerGramAmount: food.nutritionPerGramAmount,
      OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount: food.nutritionPerMilliliterAmount,
      OpenEatsJournalStrings.dbColumnKiloJoule: food.kJoule,
      OpenEatsJournalStrings.dbColumnCarbohydrates: food.carbohydrates,
      OpenEatsJournalStrings.dbColumnSugar: food.sugar,
      OpenEatsJournalStrings.dbColumnFat: food.fat,
      OpenEatsJournalStrings.dbColumnSaturatedFat: food.saturatedFat,
      OpenEatsJournalStrings.dbColumnProtein: food.protein,
      OpenEatsJournalStrings.dbColumnSalt: food.salt,
      OpenEatsJournalStrings.dbColumnQuantity: food.quantity,
    };

    if (food.id == null) {
      food.id = await db.insert(OpenEatsJournalStrings.dbTableFood, foodData);
    } else {
      //can't update in fts4 table, need to delete and insert
      await db.delete(OpenEatsJournalStrings.dbTableFoodTextSearch, where: "${OpenEatsJournalStrings.dbColumnRowId} = ?", whereArgs: [food.id]);

      await db.update(OpenEatsJournalStrings.dbTableFood, foodData, where: "${OpenEatsJournalStrings.dbColumnId} = ?", whereArgs: [food.id]);
    }

    //we must provide a rowid for contentless fts tables
    Map<String, Object?> foodTextSearchData = {
      OpenEatsJournalStrings.dbColumnRowId: food.id,
      OpenEatsJournalStrings.dbColumnName: food.name,
      OpenEatsJournalStrings.dbColumnBrands: (food.brands != null && food.brands!.isNotEmpty) ? food.brands!.join(",") : null,
    };

    await db.insert(OpenEatsJournalStrings.dbTableFoodTextSearch, foodTextSearchData);

    await _setFoodUnits(food: food);
  }

  Future<void> _setFoodUnits({required Food food}) async {
    Database db = await instance.db;
    if (food.foodUnitsWithOrder.isEmpty) {
      return;
    }

    if (food.foodSource == FoodSource.standard) {
      throw ArgumentError("Food units can't be set for standard foods.");
    }

    if (food.id == null) {
      throw StateError("Food for food units must have an id.");
    }

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object.foodUnitType != null) {
        List<Map<String, Object?>>? dbResult;

        dbResult = await db.query(
          OpenEatsJournalStrings.dbTableFoodUnit,
          columns: [OpenEatsJournalStrings.dbColumnId],
          where: "${OpenEatsJournalStrings.dbColumnFoodIdRef}= ? AND ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef} = ?",
          whereArgs: [food.id, foodUnitWithOrder.object.foodUnitType!.value],
        );

        if (dbResult.length > 1) {
          throw StateError(
            "Only one food unit entry of type ${foodUnitWithOrder.object.foodUnitType} may exist for a food, multiple entries found for food ${food.id} ${food.name}.",
          );
        }

        if (dbResult.isNotEmpty) {
          //If food comes from external API and the food unit is used for the first time in the food search result screen e.g. it has id null.
          //If we know already the food unit, the id is assigned here.
          foodUnitWithOrder.object.id ??= dbResult[0][OpenEatsJournalStrings.dbColumnId] as int;
        }
      }

      Map<String, Object?> foodUnitData = {
        OpenEatsJournalStrings.dbColumnFoodIdRef: food.id,
        OpenEatsJournalStrings.dbColumnName: foodUnitWithOrder.object.name,
        OpenEatsJournalStrings.dbColumnAmount: foodUnitWithOrder.object.amount,
        OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef: foodUnitWithOrder.object.amountMeasurementUnit.value,
        OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef: foodUnitWithOrder.object.foodUnitType?.value,
        OpenEatsJournalStrings.dbColumnOrderNumber: foodUnitWithOrder.order,
      };

      if (foodUnitWithOrder.object.id == null) {
        foodUnitWithOrder.object.id = await db.insert(OpenEatsJournalStrings.dbTableFoodUnit, foodUnitData);
      } else {
        await db.update(
          OpenEatsJournalStrings.dbTableFoodUnit,
          foodUnitData,
          where: "${OpenEatsJournalStrings.dbColumnId} = ?",
          whereArgs: [foodUnitWithOrder.object.id],
        );
      }
    }
  }

  Future<Food?> getFoodById(int id) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableFood,
      columns: [
        OpenEatsJournalStrings.dbColumnId,
        OpenEatsJournalStrings.dbColumnName,
        OpenEatsJournalStrings.dbColumnFoodSourceIdRef,
        OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef,
        OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef,
        OpenEatsJournalStrings.dbColumnName,
        OpenEatsJournalStrings.dbColumnBrands,
        OpenEatsJournalStrings.dbColumnNutritionPerGramAmount,
        OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount,
        OpenEatsJournalStrings.dbColumnKiloJoule,
        OpenEatsJournalStrings.dbColumnCarbohydrates,
        OpenEatsJournalStrings.dbColumnSugar,
        OpenEatsJournalStrings.dbColumnFat,
        OpenEatsJournalStrings.dbColumnSaturatedFat,
        OpenEatsJournalStrings.dbColumnProtein,
        OpenEatsJournalStrings.dbColumnSalt,
      ],
      where: "${OpenEatsJournalStrings.dbColumnId} = ?",
      whereArgs: [id],
    );

    if (dbResult.isEmpty) {
      return null;
    }

    return await _getFroodFromDbResult(dbRow: dbResult[0]);
  }

  Future<List<Food>?> getUserFoodBySearchtext(String searchText) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
        ${OpenEatsJournalStrings.dbColumnId},
        ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef},
        ${OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef},
        ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef},
        ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnName},
        ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnBrands},
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount},
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount},
        ${OpenEatsJournalStrings.dbColumnKiloJoule},
        ${OpenEatsJournalStrings.dbColumnCarbohydrates},
        ${OpenEatsJournalStrings.dbColumnSugar},
        ${OpenEatsJournalStrings.dbColumnFat},
        ${OpenEatsJournalStrings.dbColumnSaturatedFat},
        ${OpenEatsJournalStrings.dbColumnProtein},
        ${OpenEatsJournalStrings.dbColumnSalt},
        ${OpenEatsJournalStrings.dbColumnQuantity}
        FROM 
                ${OpenEatsJournalStrings.dbTableFood}
        WHERE ${OpenEatsJournalStrings.dbColumnId} IN (SELECT ${OpenEatsJournalStrings.dbColumnRowId} FROM ${OpenEatsJournalStrings.dbTableFoodTextSearch} WHERE ${OpenEatsJournalStrings.dbTableFoodTextSearch} MATCH ?)
        """,
      [searchText],
    );

    if (dbResult.isEmpty) {
      return null;
    }

    List<Food> foods = [];
    for (Map<String, Object?> row in dbResult) {
      foods.add(await _getFroodFromDbResult(dbRow: row));
    }

    return foods;
  }

  Future<Food> _getFroodFromDbResult({required Map<String, Object?> dbRow}) async {
    Database db = await instance.db;

    Food food = Food(
      id: dbRow[OpenEatsJournalStrings.dbColumnId] as int,
      name: dbRow[OpenEatsJournalStrings.dbColumnName] as String,
      foodSource: FoodSource.getByValue(dbRow[OpenEatsJournalStrings.dbColumnFoodSourceIdRef] as int),
      kJoule: dbRow[OpenEatsJournalStrings.dbColumnKiloJoule] as int,
      originalFoodSource: dbRow[OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] != null
          ? FoodSource.getByValue(dbRow[OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] as int)
          : null,
      foodSourceFoodId: dbRow[OpenEatsJournalStrings.dbColumndbColumnFoodSourceFoodIdRef] as String?,
      brands: dbRow[OpenEatsJournalStrings.dbColumnBrands] != null
          ? (dbRow[OpenEatsJournalStrings.dbColumnBrands] as String).split(",").map((String brand) => brand.trim()).toList()
          : null,
      nutritionPerGramAmount: dbRow[OpenEatsJournalStrings.dbColumnNutritionPerGramAmount] as int?,
      nutritionPerMilliliterAmount: dbRow[OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount] as int?,
      carbohydrates: dbRow[OpenEatsJournalStrings.dbColumnCarbohydrates] as double?,
      sugar: dbRow[OpenEatsJournalStrings.dbColumnSugar] as double?,
      fat: dbRow[OpenEatsJournalStrings.dbColumnFat] as double?,
      saturatedFat: dbRow[OpenEatsJournalStrings.dbColumnSaturatedFat] as double?,
      protein: dbRow[OpenEatsJournalStrings.dbColumnProtein] as double?,
      salt: dbRow[OpenEatsJournalStrings.dbColumnSalt] as double?,
      quantity: dbRow[OpenEatsJournalStrings.dbColumnQuantity] as String?,
    );

    final List<Map<String, Object?>> dbResultFoodUnit = await db.query(
      OpenEatsJournalStrings.dbTableFoodUnit,
      columns: [
        OpenEatsJournalStrings.dbColumnId,
        OpenEatsJournalStrings.dbColumnName,
        OpenEatsJournalStrings.dbColumnAmount,
        OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef,
        OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef,
        OpenEatsJournalStrings.dbColumnOrderNumber,
      ],
      where: "${OpenEatsJournalStrings.dbColumnFoodIdRef} = ?",
      whereArgs: [food.id],
    );

    for (Map<String, Object?> row in dbResultFoodUnit) {
      ObjectWithOrder<FoodUnit> foodUnitWithOrder = ObjectWithOrder(
        object: FoodUnit(
          id: row[OpenEatsJournalStrings.dbColumnId] as int,
          name: row[OpenEatsJournalStrings.dbColumnName] as String,
          amount: row[OpenEatsJournalStrings.dbColumnAmount] as int,
          amountMeasurementUnit: MeasurementUnit.getByValue(row[OpenEatsJournalStrings.dbColumnamountMeasurementUnitIdRef] as int),
          foodUnitType: row[OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef] != null
              ? FoodUnitType.getByValue(row[OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef] as int)
              : null,
        ),
        order: row[OpenEatsJournalStrings.dbColumnOrderNumber] as int,
      );

      food.addFoodUnitWithOrder(foodUnitWithOrder: foodUnitWithOrder);
    }

    return food;
  }

  Future<void> insertOnceDayNutritionTarget({required DateTime day, required int dayTargetKJoule}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(day);

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableDailyNutritionTarget,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (dbResult.length > 1) {
      throw StateError("An entry for date must exist only once in daily nutrition targets, mutiple instances on date $formattedDate found.");
    }

    if (dbResult.isEmpty) {
      await db.insert(OpenEatsJournalStrings.dbTableDailyNutritionTarget, {
        OpenEatsJournalStrings.dbColumnEntryDate: formattedDate,
        OpenEatsJournalStrings.dbColumnKiloJoule: dayTargetKJoule,
      });
    }
  }

  Future<void> insertOnceDaDateInfo({required DateTime date}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(date);

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableDateInfo,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnDate} = ?",
      whereArgs: [formattedDate],
    );

    if (dbResult.length > 1) {
      throw StateError("An entry for date must exist only once in date info, mutiple instances on date $formattedDate found.");
    }

    if (dbResult.isEmpty) {
      WeekOfYear weekOfYear = ConvertValidate.getweekNumber(date);

      await db.insert(OpenEatsJournalStrings.dbTableDateInfo, {
        OpenEatsJournalStrings.dbColumnDate: formattedDate,
        OpenEatsJournalStrings.dbColumnWeekOfYearNormalized: "${weekOfYear.year}-${weekOfYear.week.toString().padLeft(2, "0")}",
        OpenEatsJournalStrings.dbColumnMonthOfYearNormalized: "${date.year}-${date.month.toString().padLeft(2, "0")}",
      });
    }
  }

  Future<Map<Meal, Nutritions>?> getDayNutritionSumsPerMeal({required DateTime day}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(day);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      "SELECT ${OpenEatsJournalStrings.dbColumnMealIdRef}, SUM(${OpenEatsJournalStrings.dbColumnKiloJoule}) AS ${OpenEatsJournalStrings.dbResultKJouleSum}, SUM(${OpenEatsJournalStrings.dbColumnCarbohydrates}) AS ${OpenEatsJournalStrings.dbResultCarbohydratesSum}, SUM(${OpenEatsJournalStrings.dbColumnSugar}) AS ${OpenEatsJournalStrings.dbResultSugarSum}, SUM(${OpenEatsJournalStrings.dbColumnFat}) AS ${OpenEatsJournalStrings.dbResultFatSum}, SUM(${OpenEatsJournalStrings.dbColumnSaturatedFat}) AS ${OpenEatsJournalStrings.dbResultSaturatedFatSum}, SUM(${OpenEatsJournalStrings.dbColumnProtein}) AS ${OpenEatsJournalStrings.dbResultProteinSum}, SUM(${OpenEatsJournalStrings.dbColumnSalt}) AS ${OpenEatsJournalStrings.dbResultSaltSum} FROM ${OpenEatsJournalStrings.dbTableEatsJournal} WHERE ${OpenEatsJournalStrings.dbColumnEntryDate} = ? GROUP BY ${OpenEatsJournalStrings.dbColumnEntryDate}, ${OpenEatsJournalStrings.dbColumnMealIdRef}",
      [formattedDate],
    );

    if (dbResult.isNotEmpty) {
      Map<Meal, Nutritions> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[Meal.getByValue((row[OpenEatsJournalStrings.dbColumnMealIdRef] as int))] = Nutritions(
          kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
          carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double),
          sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double),
          fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double),
          saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double),
          protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double),
          salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double),
        );
      }

      return result;
    } else {
      return null;
    }
  }

  Future<Map<String, int>?> getGroupedKJouleTargets({required DateTime from, required DateTime until, required String groupBy}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    List<Map<String, Object?>> dbResult;
    if (groupBy == OpenEatsJournalStrings.dbColumnEntryDate) {
      dbResult = await db.rawQuery(
        """SELECT
        ${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn},
        ${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultKJouleSum}
        FROM
                ${OpenEatsJournalStrings.dbTableDailyNutritionTarget}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?""",
        [fromFormatted, untilFormatted],
      );
    } else {
      dbResult = await db.rawQuery(
        """SELECT
        $groupBy                                         AS ${OpenEatsJournalStrings.dbResultGroupColumn},
        SUM(${OpenEatsJournalStrings.dbColumnKiloJoule}) AS ${OpenEatsJournalStrings.dbResultKJouleSum}
        FROM
                ${OpenEatsJournalStrings.dbTableDailyNutritionTarget}
        LEFT JOIN
                ${OpenEatsJournalStrings.dbTableDateInfo}
        ON
                ${OpenEatsJournalStrings.dbTableDailyNutritionTarget}.${OpenEatsJournalStrings.dbColumnEntryDate} = ${OpenEatsJournalStrings.dbTableDateInfo}.${OpenEatsJournalStrings.dbColumnDate}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?
        GROUP BY
                $groupBy""",
        [fromFormatted, untilFormatted],
      );
    }

    if (dbResult.isNotEmpty) {
      Map<String, int> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[row[OpenEatsJournalStrings.dbResultGroupColumn] as String] = row[OpenEatsJournalStrings.dbResultKJouleSum] as int;
      }

      return result;
    } else {
      return null;
    }
  }

  Future<Map<String, NutritionSums>?> getGroupedNutritionSums({required DateTime from, required DateTime until, required String groupBy}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
        $groupBy                                                                                          AS ${OpenEatsJournalStrings.dbResultGroupColumn}     ,
        COUNT(DISTINCT ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnId}) AS ${OpenEatsJournalStrings.dbResultDayCount}        ,
        SUM(${OpenEatsJournalStrings.dbColumnKiloJoule})                                                  AS ${OpenEatsJournalStrings.dbResultKJouleSum}       ,
        SUM(${OpenEatsJournalStrings.dbColumnCarbohydrates})                                              AS ${OpenEatsJournalStrings.dbResultCarbohydratesSum},
        SUM(${OpenEatsJournalStrings.dbColumnSugar})                                                      AS ${OpenEatsJournalStrings.dbResultSugarSum}        ,
        SUM(${OpenEatsJournalStrings.dbColumnFat})                                                        AS ${OpenEatsJournalStrings.dbResultFatSum}          ,
        SUM(${OpenEatsJournalStrings.dbColumnSaturatedFat})                                               AS ${OpenEatsJournalStrings.dbResultSaturatedFatSum} ,
        SUM(${OpenEatsJournalStrings.dbColumnProtein})                                                    AS ${OpenEatsJournalStrings.dbResultProteinSum}      ,
        SUM(${OpenEatsJournalStrings.dbColumnSalt})                                                       AS ${OpenEatsJournalStrings.dbResultSaltSum}
        FROM
                ${OpenEatsJournalStrings.dbTableEatsJournal}
        LEFT JOIN
                ${OpenEatsJournalStrings.dbTableDateInfo}
        ON
                ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnEntryDate} = ${OpenEatsJournalStrings.dbTableDateInfo}.${OpenEatsJournalStrings.dbColumnDate}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?
        GROUP BY
        $groupBy""",
      [fromFormatted, untilFormatted],
    );

    if (dbResult.isNotEmpty) {
      Map<String, NutritionSums> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[row[OpenEatsJournalStrings.dbResultGroupColumn] as String] = NutritionSums(
          entryCount: row[OpenEatsJournalStrings.dbResultDayCount] as int,
          nutritions: Nutritions(
            kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
            carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double),
            sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double),
            fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double),
            saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double),
            protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double),
            salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double),
          ),
        );
      }

      return result;
    } else {
      return null;
    }
  }

  Future<void> setWeightJournalEntry({required DateTime day, required double weight}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(day);

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (dbResult.length > 1) {
      throw StateError("Only one weight journal entry may exist for a given date, multiple entries found for $formattedDate.");
    }

    if (dbResult.isEmpty) {
      await db.insert(OpenEatsJournalStrings.dbTableWeightJournal, {
        OpenEatsJournalStrings.dbColumnEntryDate: formattedDate,
        OpenEatsJournalStrings.dbColumnWeight: weight,
      });
    } else {
      await db.update(
        OpenEatsJournalStrings.dbTableWeightJournal,
        {OpenEatsJournalStrings.dbColumnEntryDate: formattedDate, OpenEatsJournalStrings.dbColumnWeight: weight},
        where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
        whereArgs: [formattedDate],
      );
    }
  }

  Future<bool> deleteWeightJournalEntry({required DateTime date}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(date);

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (dbResult.length > 1) {
      throw StateError("Only one weight journal entry may exist for a given date, multiple entries found for $formattedDate.");
    }

    if (dbResult.isEmpty) {
      return false;
    }

    db.delete(OpenEatsJournalStrings.dbTableWeightJournal, where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?", whereArgs: [formattedDate]);
    return true;
  }

  Future<WeightJournalEntry?> getWeightJournalEntryFor({required DateTime date}) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnEntryDate, OpenEatsJournalStrings.dbColumnWeight],
      orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} DESC",
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} <= ?",
      limit: 1,
      whereArgs: [ConvertValidate.dateformatterDatabaseDateOnly.format(date)],
    );

    if (dbResult.isNotEmpty) {
      return WeightJournalEntry(
        date: ConvertValidate.dateformatterDatabaseDateOnly.parse(dbResult[0][OpenEatsJournalStrings.dbColumnEntryDate] as String),
        weight: dbResult[0][OpenEatsJournalStrings.dbColumnWeight] as double,
      );
    }

    return null;
  }

  Future<double> getLastWeightJournalEntry() async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnEntryDate, OpenEatsJournalStrings.dbColumnWeight],
      orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} DESC",
      limit: 1,
    );

    return dbResult[0][OpenEatsJournalStrings.dbColumnWeight] as double;
  }

  Future<List<WeightJournalEntry>?> get10WeightJournalEntries({required int startIndex}) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnEntryDate, OpenEatsJournalStrings.dbColumnWeight],
      orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} DESC",
      limit: 10,
      offset: startIndex * 10,
    );

    if (dbResult.isNotEmpty) {
      List<WeightJournalEntry> result = [];
      for (Map<String, Object?> row in dbResult) {
        result.add(
          WeightJournalEntry(
            date: ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbColumnEntryDate] as String),
            weight: row[OpenEatsJournalStrings.dbColumnWeight] as double,
          ),
        );
      }

      return result;
    }

    return null;
  }
}

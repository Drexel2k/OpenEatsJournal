import "package:intl/intl.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/nutritions.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
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
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodCache} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumndbColumnFoodSourceIdExternalRef} TEXT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT,
        ${OpenEatsJournalStrings.dbColumnSearchText} TEXT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} INT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} INT,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT,
        ${OpenEatsJournalStrings.dbColumnCarbohydrates} REAL,
        ${OpenEatsJournalStrings.dbColumnSugar} REAL,
        ${OpenEatsJournalStrings.dbColumnFat} REAL,
        ${OpenEatsJournalStrings.dbColumnSaturatedFat} REAL,
        ${OpenEatsJournalStrings.dbColumnProtein} REAL,
        ${OpenEatsJournalStrings.dbColumnSalt} REAL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodUser} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT,
        ${OpenEatsJournalStrings.dbColumnSearchText} TEXT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} INT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} INT,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT,
        ${OpenEatsJournalStrings.dbColumnCarbohydrates} REAL,
        ${OpenEatsJournalStrings.dbColumnSugar} REAL,
        ${OpenEatsJournalStrings.dbColumnFat} REAL,
        ${OpenEatsJournalStrings.dbColumnSaturatedFat} REAL,
        ${OpenEatsJournalStrings.dbColumnProtein} REAL,
        ${OpenEatsJournalStrings.dbColumnSalt} REAL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodStandard} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT,
        ${OpenEatsJournalStrings.dbColumnSearchText} TEXT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} INT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} INT,
        ${OpenEatsJournalStrings.dbColumnKiloJoule} INT,
        ${OpenEatsJournalStrings.dbColumnCarbohydrates} REAL,
        ${OpenEatsJournalStrings.dbColumnSugar} REAL,
        ${OpenEatsJournalStrings.dbColumnFat} REAL,
        ${OpenEatsJournalStrings.dbColumnSaturatedFat} REAL,
        ${OpenEatsJournalStrings.dbColumnProtein} REAL,
        ${OpenEatsJournalStrings.dbColumnSalt}  REAL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodUnit} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnFoodSourceTableIdRef}  INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnAmount} INT,
        ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnOrderNumber} INT
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableEatsJournal} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnFoodSourceTableIdRef} INT,
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

  Future<bool> _settingExists(String setting) async {
    Database db = await instance.db;
    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableSetting,
      columns: [OpenEatsJournalStrings.dbColumnSetting],
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting],
    );

    if (result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if (result.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> _insertSetting(Map<String, String> setting) async {
    Database db = await instance.db;
    await db.insert(OpenEatsJournalStrings.dbTableSetting, setting);
  }

  Future<void> _updateSetting(Map<String, String> setting) async {
    Database db = await instance.db;
    await db.update(
      OpenEatsJournalStrings.dbTableSetting,
      {OpenEatsJournalStrings.dbColumnvalue: setting[OpenEatsJournalStrings.dbColumnvalue]},
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting[OpenEatsJournalStrings.dbColumnSetting]],
    );
  }

  //set...Setting methos create new settings if setting does not exist or updates the existing settings.
  Future<void> setStringSetting(String setting, String value) async {
    if (await _settingExists(setting)) {
      _updateSetting({OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value});
    } else {
      await _insertSetting({
        OpenEatsJournalStrings.dbColumnSetting: setting,
        OpenEatsJournalStrings.dbColumnDartType: "String",
        OpenEatsJournalStrings.dbColumnvalue: value,
      });
    }
  }

  Future<void> setIntSetting(String setting, int value) async {
    if (await _settingExists(setting)) {
      _updateSetting({OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting({
        OpenEatsJournalStrings.dbColumnSetting: setting,
        OpenEatsJournalStrings.dbColumnDartType: "int",
        OpenEatsJournalStrings.dbColumnvalue: value.toString(),
      });
    }
  }

  Future<void> setDoubleSetting(String setting, double value) async {
    if (await _settingExists(setting)) {
      _updateSetting({OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting({
        OpenEatsJournalStrings.dbColumnSetting: setting,
        OpenEatsJournalStrings.dbColumnDartType: "double",
        OpenEatsJournalStrings.dbColumnvalue: value.toString(),
      });
    }
  }

  Future<void> setBoolSetting(String setting, bool value) async {
    if (await _settingExists(setting)) {
      _updateSetting({OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
    } else {
      await _insertSetting({
        OpenEatsJournalStrings.dbColumnSetting: setting,
        OpenEatsJournalStrings.dbColumnDartType: "bool",
        OpenEatsJournalStrings.dbColumnvalue: value.toString(),
      });
    }
  }

  Future<void> setDateTimeSetting(String setting, DateTime value) async {
    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateAndTime);
    final String formattedDate = formatter.format(value);

    if (await _settingExists(setting)) {
      _updateSetting({OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: formattedDate});
    } else {
      await _insertSetting({
        OpenEatsJournalStrings.dbColumnSetting: setting,
        OpenEatsJournalStrings.dbColumnDartType: "DateTime",
        OpenEatsJournalStrings.dbColumnvalue: formattedDate,
      });
    }
  }

  Future<Object?> _getSetting(String setting) async {
    Database db = await instance.db;
    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableSetting,
      columns: [OpenEatsJournalStrings.dbColumnvalue],
      where: "${OpenEatsJournalStrings.dbColumnSetting} = ?",
      whereArgs: [setting],
    );

    if (result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if (result.isEmpty) {
      return null;
    }

    return result[0][OpenEatsJournalStrings.dbColumnvalue];
  }

  Future<void> setAllSettings(AllSettings allSettings) async {
    await setBoolSetting(OpenEatsJournalStrings.settingDarkmode, allSettings.darkMode!);
    await setStringSetting(OpenEatsJournalStrings.settingLanguageCode, allSettings.languageCode!);
    await setIntSetting(OpenEatsJournalStrings.settingGender, allSettings.gender!.value);
    await setDateTimeSetting(OpenEatsJournalStrings.settingBirthday, allSettings.birthday!);
    await setIntSetting(OpenEatsJournalStrings.settingHeight, allSettings.height!);
    await setDoubleSetting(OpenEatsJournalStrings.settingWeight, allSettings.weight!);
    await setDoubleSetting(OpenEatsJournalStrings.settingActivityFactor, allSettings.activityFactor!);
    await setIntSetting(OpenEatsJournalStrings.settingWeightTarget, allSettings.weightTarget!.value);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleMonday, allSettings.kJouleMonday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleTuesday, allSettings.kJouleTuesday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleWednesday, allSettings.kJouleWednesday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleThursday, allSettings.kJouleThursday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleFriday, allSettings.kJouleFriday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleSaturday, allSettings.kJouleSaturday!);
    await setIntSetting(OpenEatsJournalStrings.settingKJouleSunday, allSettings.kJouleSunday!);
    await setStringSetting(OpenEatsJournalStrings.settingLanguageCode, allSettings.languageCode!);
  }

  Future<String?> getStringSetting(String setting) async {
    Object? result = await _getSetting(setting);
    return result == null ? null : result as String;
  }

  Future<int?> getIntSetting(String setting) async {
    Object? result = await _getSetting(setting);
    return result == null ? null : int.parse(result as String);
  }

  Future<double?> getDoubleSetting(String setting) async {
    Object? result = await _getSetting(setting);
    return result == null ? null : double.parse(result as String);
  }

  Future<bool?> getBoolSetting(String setting) async {
    Object? result = await _getSetting(setting);
    return result == null ? null : result == "true";
  }

  Future<DateTime?> getDateTimeSetting(String setting) async {
    Object? result = await _getSetting(setting);
    if (result == null) {
      return null;
    }

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateAndTime);
    DateTime resultDate = formatter.parse(await _getSetting(setting) as String);

    return resultDate;
  }

  Future<AllSettings> getAllSettings() async {
    int? gender = await getIntSetting(OpenEatsJournalStrings.settingGender);
    int? weightTarget = await getIntSetting(OpenEatsJournalStrings.settingWeightTarget);

    return AllSettings(
      darkMode: await getBoolSetting(OpenEatsJournalStrings.settingDarkmode),
      languageCode: await getStringSetting(OpenEatsJournalStrings.settingLanguageCode),
      gender: gender != null ? Gender.getByValue(gender) : null,
      birthday: await getDateTimeSetting(OpenEatsJournalStrings.settingBirthday),
      height: await getIntSetting(OpenEatsJournalStrings.settingHeight),
      weight: await getDoubleSetting(OpenEatsJournalStrings.settingWeight),
      activityFactor: await getDoubleSetting(OpenEatsJournalStrings.settingActivityFactor),
      weightTarget: weightTarget != null ? WeightTarget.getByValue(weightTarget) : null,
      kJouleMonday: await getIntSetting(OpenEatsJournalStrings.settingKJouleMonday),
      kJouleTuesday: await getIntSetting(OpenEatsJournalStrings.settingKJouleTuesday),
      kJouleWednesday: await getIntSetting(OpenEatsJournalStrings.settingKJouleWednesday),
      kJouleThursday: await getIntSetting(OpenEatsJournalStrings.settingKJouleThursday),
      kJouleFriday: await getIntSetting(OpenEatsJournalStrings.settingKJouleFriday),
      kJouleSaturday: await getIntSetting(OpenEatsJournalStrings.settingKJouleSaturday),
      kJouleSunday: await getIntSetting(OpenEatsJournalStrings.settingKJouleSunday),
    );
  }

  Future<void> insertWeightJournalEntry(DateTime entryDate, double weight) async {
    Database db = await instance.db;

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
    final String formattedDate = formatter.format(entryDate);

    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (result.length > 1) {
      throw StateError("Only one weight journal entry may exist for a given date, multiple entries found for $formattedDate.");
    }

    if (result.isEmpty) {
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

  Future<void> insertEatsJournalEntry(EatsJournalEntry eatsJournalEntry) async {
    Database db = await instance.db;

    if (eatsJournalEntry.food != null && eatsJournalEntry.food!.id == null) {
      throw StateError("Food for eats journal entry must have an id.");
    }

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
    final String entryDateString = formatter.format(eatsJournalEntry.entryDate);
    await db.insert(OpenEatsJournalStrings.dbTableEatsJournal, {
      OpenEatsJournalStrings.dbColumnFoodSourceIdRef: eatsJournalEntry.foodSource?.value,
      OpenEatsJournalStrings.dbColumnFoodSourceTableIdRef: eatsJournalEntry.food?.id,
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

  //creates new cache entry or updates existing one.
  Future<void> setFoodCache(Food food) async {
    Database db = await instance.db;
    if (food.foodSource == FoodSource.user && food.foodSource == FoodSource.standard) {
      throw ArgumentError("Food cache is only needed for foods of external data sources.");
    }

    if (food.foodSourceIdExternal == null) {
      throw ArgumentError("Food cache required an external food source id.");
    }

    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableFoodCache,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = ? AND ${OpenEatsJournalStrings.dbColumndbColumnFoodSourceIdExternalRef} = ?",
      whereArgs: [food.foodSource.value, food.foodSourceIdExternal],
    );

    if (result.length > 1) {
      throw StateError(
        "Only one food cache entry may exist for a given external id and food source, multiple entries found for ${food.foodSourceIdExternal}, food source ${food.foodSource.name}.",
      );
    }

    if (food.id != null) {
      if (result.isEmpty) {
        throw StateError("No record for a given external id and food source, food id was not null, a food cache entry should exist.");
      }
    }

    Map<String, Object?> foodData = {
      OpenEatsJournalStrings.dbColumnFoodSourceIdRef: food.foodSource.value,
      OpenEatsJournalStrings.dbColumndbColumnFoodSourceIdExternalRef: food.foodSourceIdExternal,
      OpenEatsJournalStrings.dbColumnName: food.name.trim() != OpenEatsJournalStrings.emptyString ? food.name : null,
      OpenEatsJournalStrings.dbColumnBrands: (food.brands != null && food.brands!.isNotEmpty) ? food.brands!.join(",") : null,
      OpenEatsJournalStrings.dbColumnSearchText: "${food.name}${food.brands != null ? " " : ""}${food.brands?.join("")}",
      OpenEatsJournalStrings.dbColumnNutritionPerGramAmount: food.nutritionPerGramAmount,
      OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount: food.nutritionPerMilliliterAmount,
      OpenEatsJournalStrings.dbColumnKiloJoule: food.kJoule,
      OpenEatsJournalStrings.dbColumnCarbohydrates: food.carbohydrates,
      OpenEatsJournalStrings.dbColumnSugar: food.sugar,
      OpenEatsJournalStrings.dbColumnFat: food.fat,
      OpenEatsJournalStrings.dbColumnSaturatedFat: food.saturatedFat,
      OpenEatsJournalStrings.dbColumnProtein: food.protein,
      OpenEatsJournalStrings.dbColumnSalt: food.salt,
    };

    if (result.isEmpty) {
      food.id = await db.insert(OpenEatsJournalStrings.dbTableFoodCache, foodData);
    } else {
      await db.update(
        OpenEatsJournalStrings.dbTableFoodCache,
        foodData,
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [result[0][OpenEatsJournalStrings.dbColumnId]],
      );

      //If food comes from external API and is used for the first time in the food search result screen e.g. it has id null.
      //If we know already the food in the cache, the id from the cache is assigned here.
      food.id ??= result[0][OpenEatsJournalStrings.dbColumnId] as int;
    }

    await _setFoodUnits(food);
  }

  Future<void> _setFoodUnits(Food food) async {
    Database db = await instance.db;
    if (food.foodUnits.isEmpty) {
      return;
    }

    if (food.foodSource == FoodSource.standard) {
      throw ArgumentError("Food units can't be set for standard foods.");
    }

    if (food.id == null) {
      throw StateError("Food for food units must have an id.");
    }

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnits) {
      if (foodUnitWithOrder.object.foodUnitType != null) {
        List<Map<String, Object?>>? result;

        result = await db.query(
          OpenEatsJournalStrings.dbTableFoodUnit,
          columns: [OpenEatsJournalStrings.dbColumnId],
          where:
              "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef}= ? AND ${OpenEatsJournalStrings.dbColumnFoodSourceTableIdRef} = ? and ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef} = ?",
          whereArgs: [food.foodSource.value, food.id, foodUnitWithOrder.object.foodUnitType!.value],
        );

        if (result.length > 1) {
          throw StateError(
            "Only one food unit entry of type ${foodUnitWithOrder.object.foodUnitType} may exist for a food, multiple entries found for food ${food.id} ${food.name}.",
          );
        }

        if (result.isNotEmpty) {
          //If food comes from external API the food unit and is used for the first time in the food search result screen e.g. it has id null.
          //If we know already the food unit, the id is assigned here.
          foodUnitWithOrder.object.id ??= result[0][OpenEatsJournalStrings.dbColumnId] as int;
        }
      }

      Map<String, Object?> foodUnitData = {
        OpenEatsJournalStrings.dbColumnFoodSourceIdRef: food.foodSource.value,
        OpenEatsJournalStrings.dbColumnFoodSourceTableIdRef: food.id,
        OpenEatsJournalStrings.dbColumnName: foodUnitWithOrder.object.name,
        OpenEatsJournalStrings.dbColumnAmount: foodUnitWithOrder.object.amount,
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

  Future<void> insertOnceDayNutritionTarget(DateTime day, int dayTargetKJoule) async {
    Database db = await instance.db;

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
    final String formattedDate = formatter.format(day);

    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableDailyNutritionTarget,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (result.length > 1) {
      throw StateError("An entry for ate must exist only once in daily nutrition targets, mutiple instances on date $formattedDate found.");
    }

    if (result.isEmpty) {
      await db.insert(OpenEatsJournalStrings.dbTableDailyNutritionTarget, {
        OpenEatsJournalStrings.dbColumnEntryDate: formattedDate,
        OpenEatsJournalStrings.dbColumnKiloJoule: dayTargetKJoule,
      });
    }
  }

  Future<Map<Meal, Nutritions>?> getDaySumsPerMeal(DateTime entryDate) async {
    Database db = await instance.db;

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
    final String formattedDate = formatter.format(entryDate);

    final kJouleSum = "kilo_joule_sum";
    final carbohydratesSum = "carbohydrates_sum";
    final sugarSum = "sugar_sum";
    final fatSum = "fat_sum";
    final saturatedFatSum = "saturated_fat_sum";
    final proteinSum = "protein_sum";
    final saltSum = "salt_sum";

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      "SELECT ${OpenEatsJournalStrings.dbColumnMealIdRef}, SUM(${OpenEatsJournalStrings.dbColumnKiloJoule}) AS $kJouleSum, SUM(${OpenEatsJournalStrings.dbColumnCarbohydrates}) AS $carbohydratesSum, SUM(${OpenEatsJournalStrings.dbColumnSugar}) AS $sugarSum, SUM(${OpenEatsJournalStrings.dbColumnFat}) AS $fatSum, SUM(${OpenEatsJournalStrings.dbColumnSaturatedFat}) AS $saturatedFatSum, SUM(${OpenEatsJournalStrings.dbColumnProtein}) AS $proteinSum, SUM(${OpenEatsJournalStrings.dbColumnSalt}) AS $saltSum FROM ${OpenEatsJournalStrings.dbTableEatsJournal} WHERE ${OpenEatsJournalStrings.dbColumnEntryDate} = ? GROUP BY ${OpenEatsJournalStrings.dbColumnEntryDate}, ${OpenEatsJournalStrings.dbColumnMealIdRef}",
      [formattedDate],
    );

    if (dbResult.isNotEmpty) {
      Map<Meal, Nutritions> result = <Meal, Nutritions>{};
      for (Map<String, Object?> row in dbResult) {
        result[Meal.getByValue((row[OpenEatsJournalStrings.dbColumnMealIdRef] as int))] = Nutritions(
          kJoule: (row[kJouleSum] as int),
          carbohydrates: (row[carbohydratesSum] as double),
          sugar: (row[sugarSum] as double),
          fat: (row[fatSum] as double),
          saturatedFat: (row[saturatedFatSum] as double),
          protein: (row[proteinSum] as double),
          salt: (row[saltSum] as double),
        );
      }

      return result;
    } else {
      return null;
    }
  }

  Future<int?> getDayNutritionTargets(DateTime day) async {
    Database db = await instance.db;

    final DateFormat formatter = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
    final String formattedDate = formatter.format(day);

    final List<Map<String, Object?>> result = await db.query(
      OpenEatsJournalStrings.dbTableDailyNutritionTarget,
      columns: [OpenEatsJournalStrings.dbColumnKiloJoule],
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} = ?",
      whereArgs: [formattedDate],
    );

    if (result.length > 1) {
      throw StateError("An entry for ate must exist only once in daily nutrition targets, mutiple instances on date $formattedDate found.");
    }

    if (result.isNotEmpty) {
      return (result[0][OpenEatsJournalStrings.dbColumnKiloJoule] as int);
    } else {
      return null;
    }
  }
}

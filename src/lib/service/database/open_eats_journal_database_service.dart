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
import "package:openeatsjournal/domain/ordered_default_food_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
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
        ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef} TEXT,
        ${OpenEatsJournalStrings.dbColumnBarcode} INT,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnBrands} TEXT,
        ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} REAL,
        ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} REAL,
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
        ${OpenEatsJournalStrings.dbColumnAmount} REAL NOT NULL,
        ${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnOrderNumber} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnIsDefault} BOOLEAN NOT NULL
      );""");
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableEatsJournal} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodIdRef} INT,
        ${OpenEatsJournalStrings.dbColumnEntryDate} DATE NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnAmount} REAL,
        ${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} INT,
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
        ${OpenEatsJournalStrings.dbColumnMonthStartDate} DATE NOT NULL,
        ${OpenEatsJournalStrings.dbColumnWeekStartDate} DATE NOT NULL
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

    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexSettingTableSetting} ON
        ${OpenEatsJournalStrings.dbTableSetting}(${OpenEatsJournalStrings.dbColumnSetting})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexFoodSourceIdRefTableFood} ON
        ${OpenEatsJournalStrings.dbTableFood}(${OpenEatsJournalStrings.dbColumnFoodSourceIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexOriginalFoodSourceIdRefTableFood} ON
        ${OpenEatsJournalStrings.dbTableFood}(${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexOriginalFoodSourceFoodIdRefTableFood} ON
        ${OpenEatsJournalStrings.dbTableFood}(${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexBarcodeTableFood} ON
        ${OpenEatsJournalStrings.dbTableFood}(${OpenEatsJournalStrings.dbColumnBarcode})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexFoodIdRefTableFoodUnit} ON
        ${OpenEatsJournalStrings.dbTableFoodUnit}(${OpenEatsJournalStrings.dbColumnFoodIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexAmountMeasurementUnitIdRefTableFoodUnit} ON
        ${OpenEatsJournalStrings.dbTableFoodUnit}(${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexFoodUnitTypeIdRefTableFoodUnit} ON
        ${OpenEatsJournalStrings.dbTableFoodUnit}(${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexFoodIdRefTableEatsJournal} ON
        ${OpenEatsJournalStrings.dbTableEatsJournal}(${OpenEatsJournalStrings.dbColumnFoodIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexEntryDateTableEatsJournal} ON
        ${OpenEatsJournalStrings.dbTableEatsJournal}(${OpenEatsJournalStrings.dbColumnEntryDate})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexAmountMeasurementUnitIdRefTableEatsJournal} ON
        ${OpenEatsJournalStrings.dbTableEatsJournal}(${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef})
      ;""");
    batch.execute("""CREATE INDEX ${OpenEatsJournalStrings.dbIndexMealIdRefTableEatsJournal} ON
        ${OpenEatsJournalStrings.dbTableEatsJournal}(${OpenEatsJournalStrings.dbColumnMealIdRef})
      ;""");

    batch.execute("""CREATE UNIQUE INDEX ${OpenEatsJournalStrings.dbIndexDateTableDailyNutritionTarget} ON
        ${OpenEatsJournalStrings.dbTableDailyNutritionTarget}(${OpenEatsJournalStrings.dbColumnEntryDate})
      ;""");
    batch.execute("""CREATE UNIQUE INDEX ${OpenEatsJournalStrings.dbIndexDateTableDateInfo} ON
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

  Future<void> setEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    Database db = await instance.db;

    if (eatsJournalEntry.food != null && eatsJournalEntry.food!.id == null) {
      throw StateError("Food for eats journal entry must have an id.");
    }

    if (eatsJournalEntry.id != null) {
      final List<Map<String, Object?>> dbResult = await db.query(
        OpenEatsJournalStrings.dbTableEatsJournal,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [eatsJournalEntry.id],
      );

      if (dbResult.length > 1) {
        throw StateError("Only one eats journal entry may exist for a given  eats journal id, multiple entries found for ${eatsJournalEntry.id}.");
      }

      if (dbResult.isEmpty) {
        throw StateError("No record for a given  eats journal id,  eats journal id was not null, a food entry should exist.");
      }
    }

    Map<String, Object?> eatsJournalEntryData = {
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
    };

    if (eatsJournalEntry.id == null) {
      eatsJournalEntry.id = await db.insert(OpenEatsJournalStrings.dbTableEatsJournal, eatsJournalEntryData);
    } else {
      await db.update(
        OpenEatsJournalStrings.dbTableEatsJournal,
        eatsJournalEntryData,
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [eatsJournalEntry.id],
      );
    }
  }

  Future<List<EatsJournalEntry>?> getEatsJournalEntries({required DateTime date, Meal? meal}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(date);
    String where = "WHERE ${OpenEatsJournalStrings.dbColumnEntryDate} = ?";
    List<Object?> arguments = [formattedDate];

    if (meal != null) {
      where = "$where AND  ${OpenEatsJournalStrings.dbColumnMealIdRef} = ?";
      arguments.add(meal.value);
    }

    //first block of columns from dbTableEatsJournal, second from dbTableFood, third from dbTableFoodUnit
    final List<Map<String, Object?>> dbResult = await db.rawQuery("""SELECT
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryId},
              ${OpenEatsJournalStrings.dbColumnEntryDate},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryName},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnAmount} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryAmount},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryAmountMeasurementUnitIdRef},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryKiloJoule},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnCarbohydrates} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryCarbohydrates},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnSugar} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntrySugar},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnFat} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryFat},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnSaturatedFat} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntrySaturatedFat},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnProtein} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntryProtein},
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnSalt} AS ${OpenEatsJournalStrings.dbResultEatsJournalEntrySalt},
              ${OpenEatsJournalStrings.dbColumnMealIdRef},

              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodId},
              ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodName},
              ${OpenEatsJournalStrings.dbColumnBrands},
              ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount},
              ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultFoodKiloJoule},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnCarbohydrates} AS ${OpenEatsJournalStrings.dbResultFoodCarbohydrates},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSugar} AS ${OpenEatsJournalStrings.dbResultFoodSugar},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnFat} AS ${OpenEatsJournalStrings.dbResultFoodFat},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSaturatedFat} AS ${OpenEatsJournalStrings.dbResultFoodSaturatedFat},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnProtein} AS ${OpenEatsJournalStrings.dbResultFoodProtein},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSalt} AS ${OpenEatsJournalStrings.dbResultFoodSalt},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnQuantity},

              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodUnitId},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodUnitName},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnAmount} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmount},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef},
              ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef},
              ${OpenEatsJournalStrings.dbColumnOrderNumber},
              ${OpenEatsJournalStrings.dbColumnIsDefault}
        FROM
              ${OpenEatsJournalStrings.dbTableEatsJournal}
        LEFT JOIN
              ${OpenEatsJournalStrings.dbTableFood}
        ON
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnFoodIdRef} = ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId}
        LEFT JOIN
              ${OpenEatsJournalStrings.dbTableFoodUnit}
        ON
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} = ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnFoodIdRef}
        $where
        ORDER BY
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnId} ASC,
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} ASC,
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} ASC
        """, arguments);

    if (dbResult.isEmpty) {
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
        food: _getFoodFromDbResult(dbResult: eatsJournalEntriesRows),
        amount: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmount] as double,
        amountMeasurementUnit: MeasurementUnit.getByValue(
          eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryAmountMeasurementUnitIdRef] as int,
        ),
        carbohydrates: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryCarbohydrates] as double?,
        sugar: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySugar] as double?,
        fat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryFat] as double?,
        satureatedFat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySaturatedFat] as double?,
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
        satureatedFat: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySaturatedFat] as double?,
        protein: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntryProtein] as double?,
        salt: eatsJournalEntriesRows[0][OpenEatsJournalStrings.dbResultEatsJournalEntrySalt] as double?,
      );
    }
  }

  Future<bool> deleteEatsJournalEntry({required int id}) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableEatsJournal,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnId} = ?",
      whereArgs: [id],
    );

    if (dbResult.isEmpty) {
      return false;
    }

    db.delete(OpenEatsJournalStrings.dbTableEatsJournal, where: "${OpenEatsJournalStrings.dbColumnId} = ?", whereArgs: [id]);
    return true;
  }

  //creates new food entry or updates an existing one.
  Future<void> setFoodByExternalId({required Food food}) async {
    Database db = await instance.db;
    if (food.foodSource == FoodSource.user) {
      throw ArgumentError("Food update by external id is only needed for foods of external data sources.");
    }

    if (food.originalFoodSourceFoodId == null) {
      throw ArgumentError("Food update by external id required an external food source id.");
    }

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableFood,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = ? AND ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef} = ?",
      whereArgs: [food.foodSource.value, food.originalFoodSourceFoodId],
    );

    if (dbResult.length > 1) {
      throw StateError(
        "Only one food entry may exist for a given external food id and food source, multiple entries found for ${food.originalFoodSourceFoodId}, food source ${food.foodSource.name}.",
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
      OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef: food.originalFoodSourceFoodId,
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
        OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef: foodUnitWithOrder.object.amountMeasurementUnit.value,
        OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef: foodUnitWithOrder.object.foodUnitType?.value,
        OpenEatsJournalStrings.dbColumnOrderNumber: foodUnitWithOrder.order,
        OpenEatsJournalStrings.dbColumnIsDefault: foodUnitWithOrder.object == food.defaultFoodUnit,
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

    //first block of columns from dbTableFood, second from dbTableFoodUnit
    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodId},
              ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnName}  AS ${OpenEatsJournalStrings.dbResultFoodName},
              ${OpenEatsJournalStrings.dbColumnBrands},
              ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount},
              ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount},
              ${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultFoodKiloJoule},
              ${OpenEatsJournalStrings.dbColumnCarbohydrates} AS ${OpenEatsJournalStrings.dbResultFoodCarbohydrates},
              ${OpenEatsJournalStrings.dbColumnSugar} AS ${OpenEatsJournalStrings.dbResultFoodSugar},
              ${OpenEatsJournalStrings.dbColumnFat} AS ${OpenEatsJournalStrings.dbResultFoodFat},
              ${OpenEatsJournalStrings.dbColumnSaturatedFat} AS ${OpenEatsJournalStrings.dbResultFoodSaturatedFat},
              ${OpenEatsJournalStrings.dbColumnProtein} AS ${OpenEatsJournalStrings.dbResultFoodProtein},
              ${OpenEatsJournalStrings.dbColumnSalt} AS ${OpenEatsJournalStrings.dbResultFoodSalt},
              ${OpenEatsJournalStrings.dbColumnQuantity},

              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodUnitId},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodUnitName},
              ${OpenEatsJournalStrings.dbColumnAmount} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmount},
              ${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef},
              ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef},
              ${OpenEatsJournalStrings.dbColumnOrderNumber},
              ${OpenEatsJournalStrings.dbColumnIsDefault}
        FROM 
              ${OpenEatsJournalStrings.dbTableFood}
        LEFT JOIN 
              ${OpenEatsJournalStrings.dbTableFoodUnit}
        ON
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} = ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnFoodIdRef}
        WHERE 
              ${OpenEatsJournalStrings.dbColumnId} = ?
        """,
      [id],
    );

    if (dbResult.isEmpty) {
      return null;
    }

    return _getFoodFromDbResult(dbResult: dbResult);
  }

  Future<List<Food>?> getUserFoodBySearchtext(String searchText) async {
    Database db = await instance.db;

    //first block of columns from dbTableFood, second from dbTableFoodUnit
    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodId},
              ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodName},
              ${OpenEatsJournalStrings.dbColumnBrands},
              ${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount},
              ${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount},
              ${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultFoodKiloJoule},
              ${OpenEatsJournalStrings.dbColumnCarbohydrates} AS ${OpenEatsJournalStrings.dbResultFoodCarbohydrates},
              ${OpenEatsJournalStrings.dbColumnSugar} AS ${OpenEatsJournalStrings.dbResultFoodSugar},
              ${OpenEatsJournalStrings.dbColumnFat} AS ${OpenEatsJournalStrings.dbResultFoodFat},
              ${OpenEatsJournalStrings.dbColumnSaturatedFat} AS ${OpenEatsJournalStrings.dbResultFoodSaturatedFat},
              ${OpenEatsJournalStrings.dbColumnProtein} AS ${OpenEatsJournalStrings.dbResultFoodProtein},
              ${OpenEatsJournalStrings.dbColumnSalt} AS ${OpenEatsJournalStrings.dbResultFoodSalt},
              ${OpenEatsJournalStrings.dbColumnQuantity},

              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodUnitId},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodUnitName},
              ${OpenEatsJournalStrings.dbColumnAmount} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmount},
              ${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef},
              ${OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef},
              ${OpenEatsJournalStrings.dbColumnOrderNumber},
              ${OpenEatsJournalStrings.dbColumnIsDefault}
        FROM 
              ${OpenEatsJournalStrings.dbTableFood}
        LEFT JOIN 
              ${OpenEatsJournalStrings.dbTableFoodUnit}
        ON
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} = ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnFoodIdRef}
        WHERE 
              ${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = 1 AND
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} IN (SELECT ${OpenEatsJournalStrings.dbColumnRowId} FROM ${OpenEatsJournalStrings.dbTableFoodTextSearch} WHERE ${OpenEatsJournalStrings.dbTableFoodTextSearch} MATCH ?)
        """,
      [searchText],
    );

    if (dbResult.isEmpty) {
      return null;
    }

    List<Food> foods = [];

    List<Map<String, Object?>> foodRows = [];
    int currentFoodId = -1;
    int currentRowFoodId;
    for (Map<String, Object?> row in dbResult) {
      currentRowFoodId = row[OpenEatsJournalStrings.dbResultFoodId] as int;
      if (currentRowFoodId != currentFoodId) {
        if (currentFoodId != -1) {
          foods.add(_getFoodFromDbResult(dbResult: foodRows));
          foodRows.clear();
        }

        currentFoodId = currentRowFoodId;
      }

      foodRows.add(row);
    }

    foods.add(_getFoodFromDbResult(dbResult: foodRows));

    return foods;
  }

  Food _getFoodFromDbResult({required List<Map<String, Object?>> dbResult}) {
    if (dbResult.isEmpty) {
      throw ArgumentError("Food result must not be empty.");
    }

    List<OrderedDefaultFoodUnit> orderedDefaultFoodUnits = [];

    int currentRowFoodUnitId = -1;
    int currentFoodUnitId = -1;

    Map<String, Object?>? foodUnitRow;
    OrderedDefaultFoodUnit? orderedDefaultFoodUnit;
    for (Map<String, Object?> foodUnitRowInternal in dbResult) {
      currentRowFoodUnitId = foodUnitRowInternal[OpenEatsJournalStrings.dbResultFoodUnitId] as int;
      if (currentFoodUnitId != currentRowFoodUnitId) {
        if (currentFoodUnitId != -1) {
          orderedDefaultFoodUnit = _getOrderedDefaultFoodUnit(foodUnitRow: foodUnitRow!);
          if (orderedDefaultFoodUnit != null) {
            orderedDefaultFoodUnits.add(orderedDefaultFoodUnit);
          }
        }

        currentFoodUnitId = currentRowFoodUnitId;
      }

      foodUnitRow = foodUnitRowInternal;
    }

    orderedDefaultFoodUnit = _getOrderedDefaultFoodUnit(foodUnitRow: foodUnitRow!);
    if (orderedDefaultFoodUnit != null) {
      orderedDefaultFoodUnits.add(orderedDefaultFoodUnit);
    }

    Food food = Food.fromData(
      id: dbResult[0][OpenEatsJournalStrings.dbResultFoodId] as int,
      name: dbResult[0][OpenEatsJournalStrings.dbResultFoodName] as String,
      foodSource: FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbColumnFoodSourceIdRef] as int),
      kJoule: dbResult[0][OpenEatsJournalStrings.dbResultFoodKiloJoule] as int,
      originalFoodSource: dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] != null
          ? FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] as int)
          : null,
      originalFoodSourceFoodId: dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef] as String?,
      brands: dbResult[0][OpenEatsJournalStrings.dbColumnBrands] != null
          ? (dbResult[0][OpenEatsJournalStrings.dbColumnBrands] as String).split(",").map((String brand) => brand.trim()).toList()
          : null,
      nutritionPerGramAmount: dbResult[0][OpenEatsJournalStrings.dbColumnNutritionPerGramAmount] as double?,
      nutritionPerMilliliterAmount: dbResult[0][OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount] as double?,
      carbohydrates: dbResult[0][OpenEatsJournalStrings.dbResultFoodCarbohydrates] as double?,
      sugar: dbResult[0][OpenEatsJournalStrings.dbResultFoodSugar] as double?,
      fat: dbResult[0][OpenEatsJournalStrings.dbResultFoodFat] as double?,
      saturatedFat: dbResult[0][OpenEatsJournalStrings.dbResultFoodSaturatedFat] as double?,
      protein: dbResult[0][OpenEatsJournalStrings.dbResultFoodProtein] as double?,
      salt: dbResult[0][OpenEatsJournalStrings.dbResultFoodSalt] as double?,
      quantity: dbResult[0][OpenEatsJournalStrings.dbColumnQuantity] as String?,
      orderedDefaultFoodUnits: orderedDefaultFoodUnits.isNotEmpty ? orderedDefaultFoodUnits : null,
    );

    return food;
  }

  OrderedDefaultFoodUnit? _getOrderedDefaultFoodUnit({required Map<String, Object?> foodUnitRow}) {
    if ((foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitId] as int?) != null) {
      return OrderedDefaultFoodUnit(
        foodUnitWithOrder: ObjectWithOrder<FoodUnit>(
          object: FoodUnit(
            id: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitId] as int,
            name: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitName] as String,
            amount: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitAmount] as double,
            amountMeasurementUnit: MeasurementUnit.getByValue(foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef] as int),
            foodUnitType: foodUnitRow[OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef] != null
                ? FoodUnitType.getByValue(foodUnitRow[OpenEatsJournalStrings.dbColumnFoodUnitTypeIdRef] as int)
                : null,
          ),
          order: foodUnitRow[OpenEatsJournalStrings.dbColumnOrderNumber] as int,
        ),
        isDefault: (foodUnitRow[OpenEatsJournalStrings.dbColumnIsDefault] as int) == 1,
      );
    }

    return null;
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
      DateTime weekOfYearStartDate = ConvertValidate.getWeekStartDate(date);

      await db.insert(OpenEatsJournalStrings.dbTableDateInfo, {
        OpenEatsJournalStrings.dbColumnDate: formattedDate,
        OpenEatsJournalStrings.dbColumnMonthStartDate: ConvertValidate.dateformatterDatabaseDateOnly.format(DateTime(date.year, date.month, 1)),
        OpenEatsJournalStrings.dbColumnWeekStartDate: ConvertValidate.dateformatterDatabaseDateOnly.format(weekOfYearStartDate),
      });
    }
  }

  Future<Map<Meal, Nutritions>?> getDayNutritionSumsPerMeal({required DateTime day}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(day);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
              ${OpenEatsJournalStrings.dbColumnMealIdRef}                                                               ,
              SUM(${OpenEatsJournalStrings.dbColumnKiloJoule})     AS ${OpenEatsJournalStrings.dbResultKJouleSum}       ,
              SUM(${OpenEatsJournalStrings.dbColumnCarbohydrates}) AS ${OpenEatsJournalStrings.dbResultCarbohydratesSum},
              SUM(${OpenEatsJournalStrings.dbColumnSugar})         AS ${OpenEatsJournalStrings.dbResultSugarSum}        ,
              SUM(${OpenEatsJournalStrings.dbColumnFat})           AS ${OpenEatsJournalStrings.dbResultFatSum}          ,
              SUM(${OpenEatsJournalStrings.dbColumnSaturatedFat})  AS ${OpenEatsJournalStrings.dbResultSaturatedFatSum} ,
              SUM(${OpenEatsJournalStrings.dbColumnProtein})       AS ${OpenEatsJournalStrings.dbResultProteinSum}      ,
              SUM(${OpenEatsJournalStrings.dbColumnSalt})          AS ${OpenEatsJournalStrings.dbResultSaltSum}
      FROM
              ${OpenEatsJournalStrings.dbTableEatsJournal}
      WHERE
              ${OpenEatsJournalStrings.dbColumnEntryDate} = ?
      GROUP BY
              ${OpenEatsJournalStrings.dbColumnEntryDate},
              ${OpenEatsJournalStrings.dbColumnMealIdRef}""",
      [formattedDate],
    );

    if (dbResult.isNotEmpty) {
      Map<Meal, Nutritions> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[Meal.getByValue((row[OpenEatsJournalStrings.dbColumnMealIdRef] as int))] = Nutritions(
          kJoule: (row[OpenEatsJournalStrings.dbResultKJouleSum] as int),
          carbohydrates: (row[OpenEatsJournalStrings.dbResultCarbohydratesSum] as double?),
          sugar: (row[OpenEatsJournalStrings.dbResultSugarSum] as double?),
          fat: (row[OpenEatsJournalStrings.dbResultFatSum] as double?),
          saturatedFat: (row[OpenEatsJournalStrings.dbResultSaturatedFatSum] as double?),
          protein: (row[OpenEatsJournalStrings.dbResultProteinSum] as double?),
          salt: (row[OpenEatsJournalStrings.dbResultSaltSum] as double?),
        );
      }

      return result;
    } else {
      return null;
    }
  }

  Future<Map<DateTime, int>?> getGroupedKJouleTargets({required DateTime from, required DateTime until, required String groupBy}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    List<Map<String, Object?>> dbResult;
    if (groupBy == OpenEatsJournalStrings.dbColumnDate) {
      dbResult = await db.query(
        OpenEatsJournalStrings.dbTableDailyNutritionTarget,
        columns: [
          "${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn}",
          "${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultKJouleSum}",
        ],

        where: "${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?",

        whereArgs: [fromFormatted, untilFormatted],
        orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} ASC",
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
                $groupBy
        ORDER BY
                $groupBy ASC""",
        [fromFormatted, untilFormatted],
      );
    }

    if (dbResult.isNotEmpty) {
      Map<DateTime, int> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] =
            row[OpenEatsJournalStrings.dbResultKJouleSum] as int;
      }

      return result;
    } else {
      return null;
    }
  }

  Future<Map<DateTime, NutritionSums>?> getGroupedNutritionSums({required DateTime from, required DateTime until, required String groupBy}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """SELECT
        $groupBy                                                                                          AS ${OpenEatsJournalStrings.dbResultGroupColumn}     ,
        COUNT(DISTINCT ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnEntryDate}) AS ${OpenEatsJournalStrings.dbResultDayCount}        ,
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
        $groupBy
        ORDER BY
                $groupBy ASC""",
      [fromFormatted, untilFormatted],
    );

    if (dbResult.isNotEmpty) {
      Map<DateTime, NutritionSums> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] = NutritionSums(
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

  Future<WeightJournalEntry?> getMaxWeightJournalEntryFor({required DateTime date, required String maxOf}) async {
    Database db = await instance.db;

    List<Map<String, Object?>> dbResult;
    if (maxOf == OpenEatsJournalStrings.dbColumnDate) {
      dbResult = await db.query(
        OpenEatsJournalStrings.dbTableWeightJournal,
        columns: [
          "${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn}",
          "${OpenEatsJournalStrings.dbColumnWeight} AS ${OpenEatsJournalStrings.dbResultWeightMax}",
        ],
        orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} DESC",
        where: "${OpenEatsJournalStrings.dbColumnEntryDate} <= ?",
        limit: 1,
        whereArgs: [ConvertValidate.dateformatterDatabaseDateOnly.format(date)],
      );
    } else {
      dbResult = await db.rawQuery(
        """SELECT
        $maxOf                                                                 AS ${OpenEatsJournalStrings.dbResultGroupColumn}     ,
        MAX(${OpenEatsJournalStrings.dbColumnWeight})                          AS ${OpenEatsJournalStrings.dbResultWeightMax}
        FROM
                ${OpenEatsJournalStrings.dbTableWeightJournal}
        LEFT JOIN
                ${OpenEatsJournalStrings.dbTableDateInfo}
        ON
                ${OpenEatsJournalStrings.dbTableWeightJournal}.${OpenEatsJournalStrings.dbColumnEntryDate} = ${OpenEatsJournalStrings.dbTableDateInfo}.${OpenEatsJournalStrings.dbColumnDate}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} <= ?
        GROUP BY
                $maxOf
        ORDER BY
                $maxOf DESC
        LIMIT 1""",
        [ConvertValidate.dateformatterDatabaseDateOnly.format(date)],
      );
    }

    if (dbResult.isNotEmpty) {
      return WeightJournalEntry(
        date: ConvertValidate.dateformatterDatabaseDateOnly.parse(dbResult[0][OpenEatsJournalStrings.dbResultGroupColumn] as String),
        weight: dbResult[0][OpenEatsJournalStrings.dbResultWeightMax] as double,
      );
    }

    return null;
  }

  Future<WeightJournalEntry?> getMaxWeightJournalEntryAfter({required DateTime date, required String maxOf}) async {
    Database db = await instance.db;

    List<Map<String, Object?>> dbResult;
    if (maxOf == OpenEatsJournalStrings.dbColumnDate) {
      dbResult = await db.query(
        OpenEatsJournalStrings.dbTableWeightJournal,
        columns: [
          "${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn}",
          "${OpenEatsJournalStrings.dbColumnWeight} AS ${OpenEatsJournalStrings.dbResultWeightMax}",
        ],
        orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} ASC",
        where: "${OpenEatsJournalStrings.dbColumnEntryDate} >= ?",
        limit: 1,
        whereArgs: [ConvertValidate.dateformatterDatabaseDateOnly.format(date)],
      );
    } else {
      dbResult = await db.rawQuery(
        """SELECT
        $maxOf                                                                   AS ${OpenEatsJournalStrings.dbResultGroupColumn}     ,
        MAX(${OpenEatsJournalStrings.dbColumnWeight})                            AS ${OpenEatsJournalStrings.dbResultWeightMax}
        FROM
                ${OpenEatsJournalStrings.dbTableWeightJournal}
        LEFT JOIN
                ${OpenEatsJournalStrings.dbTableDateInfo}
        ON
                ${OpenEatsJournalStrings.dbTableWeightJournal}.${OpenEatsJournalStrings.dbColumnEntryDate} = ${OpenEatsJournalStrings.dbTableDateInfo}.${OpenEatsJournalStrings.dbColumnDate}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} >= ?
        GROUP BY
                $maxOf
        ORDER BY
                $maxOf ASC
        LIMIT 1""",
        [ConvertValidate.dateformatterDatabaseDateOnly.format(date)],
      );
    }

    if (dbResult.isNotEmpty) {
      return WeightJournalEntry(
        date: ConvertValidate.dateformatterDatabaseDateOnly.parse(dbResult[0][OpenEatsJournalStrings.dbResultGroupColumn] as String),
        weight: dbResult[0][OpenEatsJournalStrings.dbResultWeightMax] as double,
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

  Future<Map<DateTime, double>?> getWeightMax({required DateTime from, required DateTime until, required String maxOf}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    List<Map<String, Object?>> dbResult;
    if (maxOf == OpenEatsJournalStrings.dbColumnEntryDate) {
      dbResult = await db.rawQuery(
        """SELECT
        ${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn},
        ${OpenEatsJournalStrings.dbColumnEntryDate} AS ${OpenEatsJournalStrings.dbResultGroupColumn},
        ${OpenEatsJournalStrings.dbColumnWeight} AS ${OpenEatsJournalStrings.dbResultWeightMax}
        FROM
                ${OpenEatsJournalStrings.dbTableWeightJournal}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?
        ORDER BY
                ${OpenEatsJournalStrings.dbColumnEntryDate} ASC""",
        [fromFormatted, untilFormatted],
      );
    } else {
      dbResult = await db.rawQuery(
        """SELECT
        $maxOf                                                                                          AS ${OpenEatsJournalStrings.dbResultGroupColumn}     ,
        MAX(${OpenEatsJournalStrings.dbColumnWeight})                                                  AS ${OpenEatsJournalStrings.dbResultWeightMax}
        FROM
                ${OpenEatsJournalStrings.dbTableWeightJournal}
        LEFT JOIN
                ${OpenEatsJournalStrings.dbTableDateInfo}
        ON
                ${OpenEatsJournalStrings.dbTableWeightJournal}.${OpenEatsJournalStrings.dbColumnEntryDate} = ${OpenEatsJournalStrings.dbTableDateInfo}.${OpenEatsJournalStrings.dbColumnDate}
        WHERE
                ${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?
        GROUP BY
                $maxOf
        ORDER BY
                $maxOf ASC""",
        [fromFormatted, untilFormatted],
      );
    }

    if (dbResult.isNotEmpty) {
      Map<DateTime, double> result = {};
      for (Map<String, Object?> row in dbResult) {
        result[ConvertValidate.dateformatterDatabaseDateOnly.parse(row[OpenEatsJournalStrings.dbResultGroupColumn] as String)] =
            row[OpenEatsJournalStrings.dbResultWeightMax] as double;
      }

      return result;
    } else {
      return null;
    }
  }
}

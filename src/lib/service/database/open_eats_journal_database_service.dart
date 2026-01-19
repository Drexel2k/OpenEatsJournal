import "dart:io";

import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

class OpenEatsJournalDatabaseService {
  OpenEatsJournalDatabaseService._singleton();
  static final OpenEatsJournalDatabaseService instance = OpenEatsJournalDatabaseService._singleton();

  static Database? _database;
  static final String _databaseFileName = "oej.db";
  static late String _databaseFile;
  static late String _databaseDirectory;

  static final String _sqlFoodColumns =
      """
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodId},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} AS ${OpenEatsJournalStrings.dbResultFoodFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef} AS ${OpenEatsJournalStrings.dbResultFoodOriginalFoodSourceIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef} AS ${OpenEatsJournalStrings.dbResultFoodOriginalFoodSourceFoodIdRef},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnBarcode} AS ${OpenEatsJournalStrings.dbResultFoodBarcode},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodName},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnBrands} AS ${OpenEatsJournalStrings.dbResultFoodBrands},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnNutritionPerGramAmount} AS ${OpenEatsJournalStrings.dbResultFoodNutritionPerGramAmount},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount} AS ${OpenEatsJournalStrings.dbResultFoodNutritionPerMilliliterAmount},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnKiloJoule} AS ${OpenEatsJournalStrings.dbResultFoodKiloJoule},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnCarbohydrates} AS ${OpenEatsJournalStrings.dbResultFoodCarbohydrates},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSugar} AS ${OpenEatsJournalStrings.dbResultFoodSugar},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnFat} AS ${OpenEatsJournalStrings.dbResultFoodFat},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSaturatedFat} AS ${OpenEatsJournalStrings.dbResultFoodSaturatedFat},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnProtein} AS ${OpenEatsJournalStrings.dbResultFoodProtein},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSalt} AS ${OpenEatsJournalStrings.dbResultFoodSalt},
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnQuantity} AS ${OpenEatsJournalStrings.dbResultFoodQuantity},

              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} AS ${OpenEatsJournalStrings.dbResultFoodUnitId},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnName} AS ${OpenEatsJournalStrings.dbResultFoodUnitName},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnAmount} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmount},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} AS ${OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef} AS ${OpenEatsJournalStrings.dbResultFoodUnitOriginalFoodSourceFoodUnitIdRef},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnOrderNumber} AS ${OpenEatsJournalStrings.dbResultFoodUnitOrderNumber},
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnIsDefault}  AS ${OpenEatsJournalStrings.dbResultFoodUnitIsDefault}
        """;

  static final String _sqlFoodUnitJoin =
      """
        LEFT JOIN 
              ${OpenEatsJournalStrings.dbTableFoodUnit}
        ON
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} = ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnFoodIdRef}
      """;

  // final Map<int, String> _migrationScripts = {
  //   2: """SQL...
  //     """,
  // };

  bool _fileTransfering = false;

  Future<Database> get db async {
    if (_fileTransfering) {
      throw StateError("Can't access database during exports or imports.");
    }

    if (_database != null) {
      return _database!;
    }

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    _databaseDirectory = await getDatabasesPath();
    _databaseFile = join(_databaseDirectory, _databaseFileName);
    return await openDatabase(_databaseFile, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
        ${OpenEatsJournalStrings.dbColumnQuantity} Text,
        ${OpenEatsJournalStrings.dbColumnSearchText} Text
      );""");
    //removed fts4 table, as fts4 can only search in the beginning of words, not if a word contains a search text.
    //fts5 would be able to search within words, but is not available on Android...
    batch.execute("""CREATE TABLE ${OpenEatsJournalStrings.dbTableFoodUnit} (
        ${OpenEatsJournalStrings.dbColumnId} INTEGER PRIMARY KEY,
        ${OpenEatsJournalStrings.dbColumnFoodIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnName} TEXT,
        ${OpenEatsJournalStrings.dbColumnAmount} REAL NOT NULL,
        ${OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef} INT NOT NULL,
        ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef} TEXT,
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

    await batch.commit();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // for (int i = oldVersion + 1; i <= newVersion; i++) {
    //   await db.execute(_migrationScripts[i]!);
    // }
  }

  Future<void> exportDatabase() async {
    _fileTransfering = true;
    await _database!.close();
    Directory exportDirectory = Directory(join((await getApplicationDocumentsDirectory()).path, OpenEatsJournalStrings.export));
    await exportDirectory.create(recursive: true);

    String targetFile = join(exportDirectory.path, _databaseFileName);
    File sourceFile = File(_databaseFile);
    await sourceFile.copy(targetFile);
    _database = await _initDb();
    _fileTransfering = false;
  }

  Future<bool> importDatabase() async {
    bool result = false;
    File sourceFile = File(join((await getApplicationDocumentsDirectory()).path, OpenEatsJournalStrings.import, _databaseFileName));
    if (sourceFile.existsSync()) {
      _fileTransfering = true;
      await _database!.close();

      Directory targetDirectory = Directory(_databaseDirectory);
      await targetDirectory.delete(recursive: true);
      await targetDirectory.create(recursive: true);

      await sourceFile.copy(_databaseFile);
      result = true;
    }

    _database = await _initDb();
    _fileTransfering = false;

    //reload settings
    return result;
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
      await _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value});
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
      await _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
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
      await _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
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
      await _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: value.toString()});
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
      await _updateSetting(setting: {OpenEatsJournalStrings.dbColumnSetting: setting, OpenEatsJournalStrings.dbColumnvalue: formattedDate});
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

  Future<void> setSettings({required Map<String, Object> allSettings}) async {
    for (MapEntry<String, Object> setting in allSettings.entries) {
      if (setting.value is bool) {
        await setBoolSetting(setting: setting.key, value: setting.value as bool);
      }

      if (setting.value is String) {
        await setStringSetting(setting: setting.key, value: setting.value as String);
      }

      if (setting.value is int) {
        await setIntSetting(setting: setting.key, value: setting.value as int);
      }

      if (setting.value is double) {
        await setDoubleSetting(setting: setting.key, value: setting.value as double);
      }

      if (setting.value is DateTime) {
        await setDateTimeSetting(setting: setting.key, value: setting.value as DateTime);
      }
    }
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

  Future<Map<String, Object?>> getAllSettings() async {
    return {
      OpenEatsJournalStrings.settingDarkmode: await getBoolSetting(setting: OpenEatsJournalStrings.settingDarkmode),
      OpenEatsJournalStrings.settingLanguageCode: await getStringSetting(setting: OpenEatsJournalStrings.settingLanguageCode),
      OpenEatsJournalStrings.settingGender: await getIntSetting(setting: OpenEatsJournalStrings.settingGender),
      OpenEatsJournalStrings.settingBirthday: await getDateTimeSetting(setting: OpenEatsJournalStrings.settingBirthday),
      OpenEatsJournalStrings.settingHeight: await getIntSetting(setting: OpenEatsJournalStrings.settingHeight),
      OpenEatsJournalStrings.settingActivityFactor: await getDoubleSetting(setting: OpenEatsJournalStrings.settingActivityFactor),
      OpenEatsJournalStrings.settingWeightTarget: await getIntSetting(setting: OpenEatsJournalStrings.settingWeightTarget),
      OpenEatsJournalStrings.settingKJouleMonday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleMonday),
      OpenEatsJournalStrings.settingKJouleTuesday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleTuesday),
      OpenEatsJournalStrings.settingKJouleWednesday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleWednesday),
      OpenEatsJournalStrings.settingKJouleThursday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleThursday),
      OpenEatsJournalStrings.settingKJouleFriday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleFriday),
      OpenEatsJournalStrings.settingKJouleSaturday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleSaturday),
      OpenEatsJournalStrings.settingKJouleSunday: await getIntSetting(setting: OpenEatsJournalStrings.settingKJouleSunday),
      OpenEatsJournalStrings.settingLastProcessedStandardFoodDataChangeDate: await getDateTimeSetting(
        setting: OpenEatsJournalStrings.settingLastProcessedStandardFoodDataChangeDate,
      ),
    };
  }

  Future<int> setEatsJournalEntry({required Map<String, Object?> eatsJournalEntryData, int? id}) async {
    Database db = await instance.db;
    //quick entries don't have food id reference.
    // if (eatsJournalEntryData[OpenEatsJournalStrings.dbColumnFoodIdRef] == null) {
    //   throw StateError("Food for eats journal entry must have an id.");
    // }

    if (id != null) {
      final List<Map<String, Object?>> dbResult = await db.query(
        OpenEatsJournalStrings.dbTableEatsJournal,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [id],
      );

      if (dbResult.length > 1) {
        throw StateError("Only one eats journal entry may exist for a given  eats journal id, multiple entries found for $id.");
      }

      if (dbResult.isEmpty) {
        throw StateError("No record for a given  eats journal id,  eats journal id was not null, a food entry should exist.");
      }
    }

    if (id == null) {
      id = await db.insert(OpenEatsJournalStrings.dbTableEatsJournal, eatsJournalEntryData);
    } else {
      await db.update(OpenEatsJournalStrings.dbTableEatsJournal, eatsJournalEntryData, where: "${OpenEatsJournalStrings.dbColumnId} = ?", whereArgs: [id]);
    }

    return id;
  }

  Future<List<Map<String, Object?>>?> getEatsJournalEntries({required DateTime date, int? mealValue}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(date);
    String where = "WHERE ${OpenEatsJournalStrings.dbColumnEntryDate} = ?";
    List<Object?> whereArgs = [formattedDate];

    if (mealValue != null) {
      where = "$where AND  ${OpenEatsJournalStrings.dbColumnMealIdRef} = ?";
      whereArgs.add(mealValue);
    }

    //first block of columns from dbTableEatsJournal, second from dbTableFood, third from dbTableFoodUnit
    final List<Map<String, Object?>> dbResult = await db.rawQuery("""
        SELECT
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

              $_sqlFoodColumns
        FROM
              ${OpenEatsJournalStrings.dbTableEatsJournal}
        LEFT JOIN
              ${OpenEatsJournalStrings.dbTableFood}
        ON
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnFoodIdRef} = ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId}
        $_sqlFoodUnitJoin
        $where
        ORDER BY
              ${OpenEatsJournalStrings.dbTableEatsJournal}.${OpenEatsJournalStrings.dbColumnId} ASC,
              ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId} ASC,
              ${OpenEatsJournalStrings.dbTableFoodUnit}.${OpenEatsJournalStrings.dbColumnId} ASC
        """, whereArgs);

    if (dbResult.isEmpty) {
      return null;
    }

    return dbResult;
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
  Future<int> setFoodByExternalId({required Map<String, Object?> foodData, int? id}) async {
    Database db = await instance.db;
    if (foodData[OpenEatsJournalStrings.dbColumnFoodSourceIdRef] == 1) {
      //FoodSource.user
      throw ArgumentError("Food update by external id is only needed for foods of external data sources.");
    }

    if (foodData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef] == null) {
      throw ArgumentError("Food update by external id required an external food source id.");
    }

    final List<Map<String, Object?>> dbResultExternalId = await db.query(
      OpenEatsJournalStrings.dbTableFood,
      columns: [OpenEatsJournalStrings.dbColumnId],
      where: "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = ? AND ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef} = ?",
      whereArgs: [foodData[OpenEatsJournalStrings.dbColumnFoodSourceIdRef], foodData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef]],
    );

    if (dbResultExternalId.length > 1) {
      throw StateError(
        "Only one food entry may exist for a given external food id and food source, multiple entries found for ${foodData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef]}, food source ${foodData[OpenEatsJournalStrings.dbColumnFoodSourceIdRef]}.",
      );
    }

    if (id != null) {
      if (dbResultExternalId.isEmpty) {
        throw StateError("No record for a given external id and food source, food id was not null, a food entry should exist.");
      }
    }

    if (id != null) {
      final List<Map<String, Object?>> dbResultId = await db.query(
        OpenEatsJournalStrings.dbTableFood,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [id],
      );

      if (dbResultId.length > 1) {
        throw StateError("Only one food entry may exist for a given food id, multiple entries found for $id.");
      }

      if (dbResultId.isEmpty) {
        throw StateError("No record for a given food id, food id was not null, a food entry should exist.");
      }
    } else {
      //If food comes from external API and is used for the first time in the food search result screen e.g. it has id null.
      //If we know already the food in the food table, the id from the food table is assigned here.
      if (dbResultExternalId.isNotEmpty) {
        id = dbResultExternalId[0][OpenEatsJournalStrings.dbColumnId] as int;
      }
    }

    id = await _setFoodInternal(foodData: foodData, id: id);

    return id;
  }

  //todo: maybe merge setFood and setFoodByExternalId as done in setFoodUnit
  Future<int> setFood({required Map<String, Object?> foodData, int? id}) async {
    Database db = await instance.db;
    if (foodData[OpenEatsJournalStrings.dbColumnFoodSourceIdRef] == 2) {
      //FoodSource.standard
      throw ArgumentError("Food update of standard foods is not allowed.");
    }

    if (id != null) {
      final List<Map<String, Object?>> dbResult = await db.query(
        OpenEatsJournalStrings.dbTableFood,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnId} = ?",
        whereArgs: [id],
      );

      if (dbResult.length > 1) {
        throw StateError("Only one food entry may exist for a given food id, multiple entries found for $id.");
      }

      if (dbResult.isEmpty) {
        throw StateError("No record for a given food id, food id was not null, a food entry should exist.");
      }
    }

    return await _setFoodInternal(foodData: foodData, id: id);
  }

  Future<int> _setFoodInternal({required Map<String, Object?> foodData, int? id}) async {
    Database db = await instance.db;

    if (id == null) {
      id = await db.insert(OpenEatsJournalStrings.dbTableFood, foodData);
    } else {
      await db.update(OpenEatsJournalStrings.dbTableFood, foodData, where: "${OpenEatsJournalStrings.dbColumnId} = ?", whereArgs: [id]);
    }

    return id;
  }

  Future<int> setFoodUnit({required Map<String, Object?> foodUnitData, int? id}) async {
    Database db = await instance.db;

    if (foodUnitData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef] != null) {
      List<Map<String, Object?>>? dbResult;

      dbResult = await db.query(
        OpenEatsJournalStrings.dbTableFoodUnit,
        columns: [OpenEatsJournalStrings.dbColumnId],
        where: "${OpenEatsJournalStrings.dbColumnFoodIdRef}= ? AND ${OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef} = ?",
        whereArgs: [foodUnitData[OpenEatsJournalStrings.dbColumnFoodIdRef], foodUnitData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef]],
      );

      if (dbResult.length > 1) {
        throw StateError(
          "Only one food unit entry with original food source food unit id ${foodUnitData[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef]} may exist for a food, multiple entries found for food ${foodUnitData[OpenEatsJournalStrings.dbColumnFoodIdRef]}.",
        );
      }

      if (dbResult.isNotEmpty) {
        //If food comes from external API and the food unit is used for the first time in the food search result screen e.g. it has id null.
        //If we know already the food unit, the id is assigned here.
        int dbId = dbResult[0][OpenEatsJournalStrings.dbColumnId] as int;
        if (id == null) {
          id = dbId;
        } else {
          if (id != dbId) {
            throw StateError("Data base id $dbId of food unit with orignal food source food unit it is different from argument id $id.");
          }
        }
      }
    }

    if (id == null) {
      id = await db.insert(OpenEatsJournalStrings.dbTableFoodUnit, foodUnitData);
    } else {
      await db.update(OpenEatsJournalStrings.dbTableFoodUnit, foodUnitData, where: "${OpenEatsJournalStrings.dbColumnId} = ?", whereArgs: [id]);
    }

    return id;
  }

  Future<List<Map<String, Object?>>?> getFoodsBySearchtext({required String searchText, required List<int> foodSourceIds}) async {
    searchText = searchText.trim();

    List<Object?> whereArgs = [];
    String foodSourceWhereSql = OpenEatsJournalStrings.emptyString;

    if (foodSourceIds.isNotEmpty) {
      String placeholders = "?, " * foodSourceIds.length;
      placeholders = placeholders.substring(0, placeholders.length - 2);
      foodSourceWhereSql = "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} IN ($placeholders) AND ";
      whereArgs.addAll(foodSourceIds);
    }

    List<String> searchWords = _getSearchWord(searchText: searchText);

    String searchTextWhereSql = OpenEatsJournalStrings.emptyString;
    if (searchWords.isNotEmpty) {
      for (String word in searchWords) {
        searchTextWhereSql = "${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnSearchText} LIKE ? AND ";
        whereArgs.add("%$word%");
      }

      searchTextWhereSql = searchTextWhereSql.substring(0, searchTextWhereSql.length - 5);
    } else {
      if (foodSourceIds.isNotEmpty) {
        foodSourceWhereSql = foodSourceWhereSql.substring(0, foodSourceWhereSql.length - 5);
      }
    }

    return _getFoods(
      whereSql:
          """              
              $foodSourceWhereSql
              $searchTextWhereSql
              """,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, Object?>>?> getFoodsByBarcode({required int barcode, List<int>? foodSourceIds}) async {
    List<Object?> arguments = [];
    String foodSourceWhereSql = OpenEatsJournalStrings.emptyString;

    if (foodSourceIds != null) {
      String placeholders = "?, " * foodSourceIds.length;
      placeholders = placeholders.substring(0, placeholders.length - 2);
      foodSourceWhereSql = "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} IN ($placeholders) AND ";
      arguments.addAll(foodSourceIds);
    }

    arguments.add(barcode);

    return _getFoods(
      whereSql:
          """
              $foodSourceWhereSql
              ${OpenEatsJournalStrings.dbColumnBarcode} = ?""",
      whereArgs: arguments,
    );
  }

  Future<List<Map<String, Object?>>?> _getFoods({required String whereSql, required List<Object?> whereArgs}) async {
    Database db = await instance.db;

    //first block of columns from dbTableFood, second from dbTableFoodUnit
    final List<Map<String, Object?>> dbResult = await db.rawQuery("""
        SELECT
              $_sqlFoodColumns
        FROM 
              ${OpenEatsJournalStrings.dbTableFood}
        $_sqlFoodUnitJoin
        WHERE 
              $whereSql
        """, whereArgs);

    if (dbResult.isEmpty) {
      return null;
    }

    return dbResult;
  }

  Future<List<Map<String, Object?>>?> getFoodsBySearchtextByUsage({required String searchText, required List<int> foodSourceIds, required int days}) async {
    List<Object?> arguments = [];
    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(DateTime.now().subtract(Duration(days: days)));
    arguments.add(formattedDate);

    List<String> wheres = [];
    if (foodSourceIds.isNotEmpty) {
      String placeholders = "?, " * foodSourceIds.length;
      placeholders = placeholders.substring(0, placeholders.length - 2);
      wheres.add("${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} IN ($placeholders)");
      arguments.addAll(foodSourceIds);
    }

    List<String> searchWords = _getSearchWord(searchText: searchText);

    if (searchWords.isNotEmpty) {
      for (String word in searchWords) {
        wheres.add("${OpenEatsJournalStrings.dbColumnSearchText} LIKE ?");
        arguments.add("%$word%");
      }
    }

    List<Map<String, Object?>> dbResult = await _getFoodIdsByBarcodeByUsageInternal(wheres: wheres, arguments: arguments);

    if (dbResult.isEmpty) {
      return null;
    }

    return dbResult;
  }

  Future<List<Map<String, Object?>>?> getFoodsByBarcodeByUsage({required int barcode, required List<int> foodSourceIds, required int days}) async {
    List<Object?> arguments = [];
    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(DateTime.now().subtract(Duration(days: days)));
    arguments.add(formattedDate);

    List<String> wheres = [];
    if (foodSourceIds.isNotEmpty) {
      String placeholders = "?, " * foodSourceIds.length;
      placeholders = placeholders.substring(0, placeholders.length - 2);
      wheres.add("${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} IN ($placeholders)");
      arguments.addAll(foodSourceIds);
    }

    wheres.add("${OpenEatsJournalStrings.dbColumnBarcode} = ?");
    arguments.add(barcode);

    List<Map<String, Object?>> dbResult = await _getFoodIdsByBarcodeByUsageInternal(wheres: wheres, arguments: arguments);

    if (dbResult.isEmpty) {
      return null;
    }

    return dbResult;
  }

  Future<List<Map<String, Object?>>> _getFoodIdsByBarcodeByUsageInternal({required List<String> wheres, required List<Object?> arguments}) async {
    Database db = await instance.db;
    return db.rawQuery("""
        SELECT
                $_sqlFoodColumns
        FROM
                (
                      SELECT
                              ${OpenEatsJournalStrings.dbColumnFoodIdRef},
                              COUNT(${OpenEatsJournalStrings.dbColumnId}) AS ${OpenEatsJournalStrings.dbResultEntryCount}
                      FROM
                              ${OpenEatsJournalStrings.dbTableEatsJournal}
                      WHERE
                              ${OpenEatsJournalStrings.dbColumnEntryDate} >= ? AND ${OpenEatsJournalStrings.dbColumnFoodIdRef} IS NOT NULL
                      GROUP BY
                              ${OpenEatsJournalStrings.dbColumnFoodIdRef}
                ) AS ${OpenEatsJournalStrings.dbTableFoodByUsage}
        JOIN 
                ${OpenEatsJournalStrings.dbTableFood}
        ON
                ${OpenEatsJournalStrings.dbTableFoodByUsage}.${OpenEatsJournalStrings.dbColumnFoodIdRef} = ${OpenEatsJournalStrings.dbTableFood}.${OpenEatsJournalStrings.dbColumnId}
                $_sqlFoodUnitJoin
        WHERE 
                ${wheres.join(" AND ")}
        ORDER BY
                ${OpenEatsJournalStrings.dbResultEntryCount} DESC
        """, arguments);
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

  Future<List<Map<String, Object?>>?> getDayNutritionSumsPerMeal({required DateTime day}) async {
    Database db = await instance.db;

    final String formattedDate = ConvertValidate.dateformatterDatabaseDateOnly.format(day);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """
      SELECT
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
      return dbResult;
    }

    return null;
  }

  Future<List<Map<String, Object?>>?> getGroupedKJouleTargets({required DateTime from, required DateTime until, required String groupBy}) async {
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
        """
        SELECT
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
      return dbResult;
    }

    return null;
  }

  Future<List<Map<String, Object?>>?> getGroupedNutritionSums({required DateTime from, required DateTime until, required String groupBy}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    final List<Map<String, Object?>> dbResult = await db.rawQuery(
      """
          SELECT
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
      return dbResult;
    }

    return null;
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

  Future<List<Map<String, Object?>>?> getMaxWeightJournalEntryFor({required DateTime date, required String maxOf}) async {
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
        """
        SELECT
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
      return dbResult;
    }

    return null;
  }

  Future<List<Map<String, Object?>>?> getMaxWeightJournalEntryAfter({required DateTime date, required String maxOf}) async {
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
        """
        SELECT
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
      return dbResult;
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

  Future<List<Map<String, Object?>>?> get10WeightJournalEntries({required int startIndex}) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableWeightJournal,
      columns: [OpenEatsJournalStrings.dbColumnEntryDate, OpenEatsJournalStrings.dbColumnWeight],
      orderBy: "${OpenEatsJournalStrings.dbColumnEntryDate} DESC",
      limit: 10,
      offset: startIndex * 10,
    );

    if (dbResult.isNotEmpty) {
      return dbResult;
    }

    return null;
  }

  Future<List<Map<String, Object?>>?> getWeightMax({required DateTime from, required DateTime until, required String maxOf}) async {
    Database db = await instance.db;

    final String fromFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(from);
    final String untilFormatted = ConvertValidate.dateformatterDatabaseDateOnly.format(until);

    List<Map<String, Object?>> dbResult;
    if (maxOf == OpenEatsJournalStrings.dbColumnEntryDate) {
      dbResult = await db.rawQuery(
        """
        SELECT
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
        """
        SELECT
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
      return dbResult;
    }

    return null;
  }

  Future<List<Map<String, Object?>>?> getEatsJournalEntriesAvailable({required DateTime from, required DateTime until}) async {
    Database db = await instance.db;

    final List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableEatsJournal,
      columns: [OpenEatsJournalStrings.dbColumnEntryDate, "COUNT(${OpenEatsJournalStrings.dbColumnId}) AS ${OpenEatsJournalStrings.dbResultEntryCount}"],
      groupBy: OpenEatsJournalStrings.dbColumnEntryDate,
      where: "${OpenEatsJournalStrings.dbColumnEntryDate} BETWEEN ? AND ?",
      whereArgs: [ConvertValidate.dateformatterDatabaseDateOnly.format(from), ConvertValidate.dateformatterDatabaseDateOnly.format(until)],
    );

    return dbResult;
  }

  Future<void> deleteFoodUnits({required int foodId, required List<int> exceptIds}) async {
    Database db = await instance.db;

    List<String> wheres = [];
    List<Object> whereArgs = [];
    wheres.add("${OpenEatsJournalStrings.dbColumnFoodIdRef} = ?");
    whereArgs.add(foodId);

    if (exceptIds.isNotEmpty) {
      String placeholders = "?, " * exceptIds.length;
      placeholders = placeholders.substring(0, placeholders.length - 2);
      wheres.add("${OpenEatsJournalStrings.dbColumnId} NOT IN ($placeholders)");
      whereArgs.addAll(exceptIds);
    }

    await db.delete(OpenEatsJournalStrings.dbTableFoodUnit, where: wheres.join(" AND "), whereArgs: whereArgs);
  }

  List<String> _getSearchWord({required String searchText}) {
    return searchText.split(" ").map((word) => word.trim()).toList();
  }
}

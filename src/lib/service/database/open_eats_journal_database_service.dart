import "package:intl/intl.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class OpenEatsJournalDatabaseService {
  OpenEatsJournalDatabaseService._singleton();
  static final OpenEatsJournalDatabaseService instance = OpenEatsJournalDatabaseService._singleton();

  static Database? _database;

  final Map<int, String> _migrationScripts = {
    2: """CREATE TABLE users (
              id INTEGER PRIMARY KEY,
              first_name TEXT)
              """,
  };

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
    batch.execute("""CREATE TABLE t_setting (
        id INTEGER PRIMARY KEY,
        setting TEXT,
        dart_type TEXT,
        value TEXT
      );""");
    batch.execute("""CREATE TABLE t_weight_journal (
        id INTEGER PRIMARY KEY,
        entry_date DATE,
        weight REAL
      );""");

    await batch.commit();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await db.execute(_migrationScripts[i]!);
    }
  }

  Future<bool> _settingExists(String setting) async {
    Database db = await instance.db;
    final result = await db.query("t_setting", columns: ["setting"], where: "setting = ?", whereArgs: [setting]);

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
    await db.insert("t_setting", setting);
  }

  Future<void> _updateSetting(Map<String, String> setting) async {
    Database db = await instance.db;
    await db.update("t_setting", {"value": setting["value"]}, where: "setting = ?", whereArgs: [setting["setting"]]);
  }

  Future<void> setStringSetting(String setting, String value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value});
    } else {
      await _insertSetting({"setting": setting, "dart_type": "String", "value": value});
    }
  }

  Future<void> setIntSetting(String setting, int value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value.toString()});
    } else {
      await _insertSetting({"setting": setting, "dart_type": "String", "value": value.toString()});
    }
  }

  Future<void> setDoubleSetting(String setting, double value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value.toString()});
    } else {
      await _insertSetting({"setting": setting, "dart_type": "String", "value": value.toString()});
    }
  }

  Future<void> setBoolSetting(String setting, bool value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value.toString()});
    } else {
      await _insertSetting({"setting": setting, "dart_type": "bool", "value": value.toString()});
    }
  }

  Future<void> setDateTimeSetting(String setting, DateTime value) async {
    final DateFormat formatter = DateFormat("y-M-d H:m:s:S");
    final String formatted = formatter.format(value);

    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": formatted});
    } else {
      await _insertSetting({"setting": setting, "dart_type": "DateTime", "value": formatted});
    }
  }

  Future<Object?> _getSetting(String setting) async {
    Database db = await instance.db;
    final List<Map<String, Object?>> result = await db.query(
      "t_setting",
      columns: ["value"],
      where: "setting = ?",
      whereArgs: [setting],
    );

    if (result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if (result.isEmpty) {
      return null;
    }

    return result[0]["value"];
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

    final DateFormat formatter = DateFormat("y-M-d H:m:s:S");
    DateTime resultDate = formatter.parse(await _getSetting(setting) as String);

    return resultDate;
  }

  Future<void> insertWeight(DateTime date, double weight) async {
    final DateFormat formatter = DateFormat("y-M-d");
    final String formatted = formatter.format(date);

    Database db = await instance.db;
    await db.insert("t_weight_journal", {"entry_date": formatted, "weight": weight});
  }
}

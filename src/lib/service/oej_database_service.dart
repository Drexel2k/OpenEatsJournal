import "package:intl/intl.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class OejDatabaseService {
  static final OejDatabaseService instance = OejDatabaseService._singleton();
  static Database? _database;

  final Map<int, String> _migrationScripts = {
    2: """CREATE TABLE users (
              id INTEGER PRIMARY KEY,
              first_name TEXT)
              """
  };

  OejDatabaseService._singleton();

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
    batch.execute(
      """CREATE TABLE t_setting (
        id INTEGER PRIMARY KEY,
        setting TEXT,
        dart_type TEXT,
        value TEXT
      );"""
    );
    batch.execute(
      """CREATE TABLE t_weight_journal (
        id INTEGER PRIMARY KEY,
        entry_date DATE,
        weight REAL
      );"""
    );
    
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

    if(result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if(result.isEmpty) {
      return false;
    }
    else {
      return true;
    }
  }

  Future<void> _insertSetting(Map<String, String> setting) async {
    Database db = await instance.db;
    await db.insert("t_setting",  setting);
  }

  Future<void> _updateSetting(Map<String, String> setting) async {
    Database db = await instance.db;
    await db.update("t_setting", {"value": setting["value"]}, where: "setting = ?", whereArgs: [setting["setting"]]);
  }

  Future<void> setStringSetting(String setting, String value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value});
    }
    else {
      await _insertSetting({"setting":setting, "dart_type":"String", "value":value });
    }
  }

  Future<void> setIntSetting(String setting, int value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value.toString()});
    }
    else {
      await _insertSetting({"setting":setting, "dart_type":"String", "value":value.toString() });
    }
  }

  Future<void> setDoubleSetting(String setting, double value) async {
    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": value.toString()});
    }
    else {
      await _insertSetting({"setting":setting, "dart_type":"String", "value":value.toString() });
    }
  }

  Future<void> setDateTimeSetting(String setting, DateTime value) async {
    final DateFormat formatter = DateFormat("y-M-d H:m:s:S");
    final String formatted = formatter.format(value);

    if (await _settingExists(setting)) {
      _updateSetting({"setting": setting, "value": formatted});
    }
    else {
      await _insertSetting({"setting":setting, "dart_type":"DateTime", "value":formatted });
    }
  }

  Future<String?> getStringSetting(String setting) async {
    Database db = await instance.db;
    final result = await db.query("setting", columns: ["value"], where: "setting = ?", whereArgs: [setting]);

    if(result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if(result.isEmpty) {
      return null;
    }

    return result[0]["value"] as String;
  }

  Future<int?> getIntSetting(String setting) async {
    Database db = await instance.db;
    final result = await db.query("setting", columns: ["value"], where: "setting = ?", whereArgs: [setting]);

    if(result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if(result.isEmpty) {
      return null;
    }

    return result[0]["value"] as int;
  }

  Future<double?> getDoubleSetting(String setting) async {
    Database db = await instance.db;
    final result = await db.query("setting", columns: ["value"], where: "setting = ?", whereArgs: [setting]);

    if(result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if(result.isEmpty) {
      return null;
    }

    return result[0]["value"] as double;
  }

  Future<DateTime?> getDateTimeSetting(String setting) async {
    Database db = await instance.db;
    final result = await db.query("t_setting", columns: ["value"], where: "setting = ?", whereArgs: [setting]);

    if(result.length > 1) {
      throw StateError("A setting must exist only once, mutiple instances of $setting found.");
    }

    if(result.isEmpty) {
      return null;
    }

    final DateFormat formatter = DateFormat("y-M-d H:m:s:S");
    DateTime resultDate = formatter.parse(result[0]["value"] as String);

    return resultDate;
  }

  Future<void> insertWeight(DateTime date, double weight) async {
    final DateFormat formatter = DateFormat("y-M-d");
    final String formatted = formatter.format(date);

    Database db = await instance.db;
    await db.insert("t_weight_journal",  {"entry_date":formatted, "weight":weight});
  }
}
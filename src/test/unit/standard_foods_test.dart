import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:path/path.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "../mocks.mocks.dart";

OpenEatsJournalDatabaseService? _database;

void main() async {
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    //oej_onboarded_with_data.db contains eats journal entries from 2026-01-16 until 2026-02-11
    String dataBaseFileName = "oej_empty.db";
    _database = OpenEatsJournalDatabaseService(databaseFileName: dataBaseFileName);
  });

  tearDown(() async {
    File databaseFileName = File(join(await _database!.getDatabasePath(), _database!.databaseFileName));

    if (databaseFileName.existsSync()) {
      await _database!.close();
      databaseFileName.deleteSync();
    }

    _database = null;
  });

  Future<List<Object>> generalSetup() async {
    WidgetsFlutterBinding.ensureInitialized();

    List<Object> result = [];
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!);
    result.add(settingsRepository);

    OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService();

    var getCallback = MockCallbacks().get;

    OpenFoodFactsService openFoodFactsService = OpenFoodFactsService(
      httpGet: getCallback,
      appName: settingsRepository.appName,
      appVersion: settingsRepository.appVersion,
      appContactMail: settingsRepository.appContactMail!,
    );

    result.add(
      FoodRepository(
        settingsRepository: settingsRepository,
        openFoodFactsService: openFoodFactsService,
        oejDatabaseService: _database!,
        oejAssetsService: openEatsJournalAssetsService,
      ),
    );

    result.add(JournalRepository(oejDatabase: _database!));

    //required for database initialization
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), settingsRepository.initSettings()]);
    return result;
  }

  test("Initialize standard foods", () async {
    List<Object> repositories = await generalSetup();
    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;

    await settingsRepository.initSettings();

    await expectLater(
      foodRepository.initializeStandardFoodData(
        languageCode: OpenEatsJournalStrings.en,
        lastProcessedStandardFoodDataChangeDate: settingsRepository.lastProcessedStandardFoodDataChangeDate,
      ),
      completes,
    );

    List<File> files = [];
    for (FileSystemEntity fileSystemEntity in Directory(join(Directory.current.path, "assets")).listSync()) {
      if (fileSystemEntity is File) {
        if (fileSystemEntity.path.contains("standard_food_data")) {
          files.add(fileSystemEntity);
        }
      }
    }

    files.sort((file1, file2) => file1.path.compareTo(file2.path));

    int foodCount = 0;
    for (int fileIndex = 0; fileIndex < files.length; fileIndex++) {
      List<String> lines = files[fileIndex].readAsLinesSync();

      List<String> parts;
      for (String line in lines) {
        parts = line.split(",");
        if (parts[0] == "\"${OpenEatsJournalStrings.csvFood}\"") {
          foodCount++;
        }
      }
    }

    Database db = await _database!.database;
    List<Map<String, Object?>> dbResult = await db.query(
      OpenEatsJournalStrings.dbTableFood,
      columns: ["COUNT(${OpenEatsJournalStrings.dbColumnId}) AS id_count"],
      where: "${OpenEatsJournalStrings.dbColumnFoodSourceIdRef} = ?",
      whereArgs: ["2"],
    );

    expect(dbResult[0]["id_count"], foodCount);
  });
}

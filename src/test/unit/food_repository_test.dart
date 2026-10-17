import "dart:io";
import "dart:typed_data";
import "package:csv/csv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mockito/mockito.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
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
    String dataBaseFileName = "oej_onboarded_with_data.db";
    _database = OpenEatsJournalDatabaseService(databaseFileName: dataBaseFileName);

    File dbSourceFile = File(join(Directory.current.path, r"test\data\oej_onboarded_with_data.db"));
    Directory(await _database!.getDatabasePath()).createSync(recursive: true);
    dbSourceFile.copySync(join(await _database!.getDatabasePath(), _database!.databaseFileName));
  });

  tearDown(() async {
    File databaseFileName = File(join(await _database!.getDatabasePath(), _database!.databaseFileName));

    if (databaseFileName.existsSync()) {
      await _database!.close();
      databaseFileName.deleteSync();
    }

    _database = null;
  });

  Future<List<Object>> testSetup({required bool apiv1, DateTime? today}) async {
    List<Object> result = [];
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!, today: today);
    result.add(settingsRepository);

    //required for database initialization
    await Future.wait([initializeDateFormatting(), settingsRepository.initSettings()]);

    var localCsvResponses = [
      csv
          .decode(await File(join(Directory.current.path, r"test\data\standard_food_data.1.csv")).readAsString())
          .map<List<String>>((first) => first.map<String>((second) => second as String).toList())
          .toList(),
    ];

    MockOpenEatsJournalAssetsService openEatsJournalAssetsService = MockOpenEatsJournalAssetsService();
    when(openEatsJournalAssetsService.getStandardFoodFiles()).thenAnswer((_) => Future(() async => ["1.csv"]));
    when(openEatsJournalAssetsService.getCsvContent(path: anyNamed("path"))).thenAnswer((_) => Future(() async => localCsvResponses[0]));

    List<Uint8List> openFoodFactsResponses = [await File(join(Directory.current.path, r"test\data\open_food_facts_response_apiv1_page_1.json")).readAsBytes()];
    openFoodFactsResponses = apiv1
        ? [await File(join(Directory.current.path, r"test\data\open_food_facts_response_apiv1_page_1.json")).readAsBytes()]
        : [
            await File(join(Directory.current.path, r"test\data\open_food_facts_response_apiv3_4071800000763.json")).readAsBytes(),
            await File(join(Directory.current.path, r"test\data\open_food_facts_response_apiv3_4250241203524.json")).readAsBytes(),
            await File(join(Directory.current.path, r"test\data\open_food_facts_response_apiv3_5000112546415.json")).readAsBytes(),
          ];

    var getCallback = MockFunctions().httpGet;
    when(
      getCallback(any, headers: anyNamed("headers")),
    ).thenAnswer((_) async => Response.bytes(openFoodFactsResponses.removeAt(0), 200, headers: {"content-type": "application/json; charset=utf-8"}));

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

    return result;
  }

  test("Receive open food facts data v1", () async {
    List<Object> repositories = await testSetup(apiv1: true);
    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;

    FoodRepositoryResult foodRepositoryResult = await foodRepository.getFoodsBySearchTextOpenFoodFactsApiV1(
      searchText: "",
      languageCode: settingsRepository.languageCode.value,
      page: 3,
    );

    Food food = foodRepositoryResult.foods![0];

    expect(food.name, "Burger 1 nutr per 100g some null");
    expect(food.foodSource, FoodSource.openFoodFacts);
    expect(food.kJoule, 1004.0);
    expect(food.fromDb, false);
    expect(food.id, isNull);

    expect(food.originalFoodSource, isNull);
    expect(food.originalFoodSourceFoodId, "8722700125174");
    expect(food.originalFoodSourceFoodVariantId, isNull);
    expect(food.barcode, 8722700125174);
    expect(food.brands, ["Brand 1 nutr per 100g some null"]);
    expect(food.nutritionPerGramAmount, 100.0);
    expect(food.nutritionPerMilliliterAmount, isNull);
    expect(food.carbohydrates, isNull);
    expect(food.sugar, isNull);
    expect(food.fat, 21.0);
    expect(food.saturatedFat, 1.7);
    expect(food.protein, 1.1);
    expect(food.salt, 1.3);
    expect(food.quantity, isNull);
  });

  test("Receive open food facts data v3", () async {
    List<Object> repositories = await testSetup(apiv1: false);
    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;

    FoodRepositoryResult foodRepositoryResult = await foodRepository.getFoodByBarcodeOpenFoodFacts(
      barcode: 4071800000763,
      languageCode: settingsRepository.languageCode.value,
    );

    Food food = foodRepositoryResult.foods![0];

    expect(food.name, "Das volle Korn mit Keim und Randschicht, Katen");
    expect(food.foodSource, FoodSource.openFoodFacts);
    expect(food.kJoule, 886.0);
    expect(food.fromDb, false);
    expect(food.id, isNull);

    expect(food.originalFoodSource, isNull);
    expect(food.originalFoodSourceFoodId, "4071800000763");
    expect(food.originalFoodSourceFoodVariantId, isNull);
    expect(food.barcode, 4071800000763);
    expect(food.brands, ["Harry"]);
    expect(food.nutritionPerGramAmount, 100.0);
    expect(food.nutritionPerMilliliterAmount, isNull);
    expect(food.fat, 1.8);
    expect(food.saturatedFat, 0.3);
    expect(food.carbohydrates, 38.0);
    expect(food.sugar, 3.7);
    expect(food.protein, 5.8);
    expect(food.salt, 1.1);
    expect(food.quantity, "500 g");

    expect(food.foodUnitsWithOrder.length, 3);
    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.serving && foodUnitWithOrder.object.amount == 63,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.piece && foodUnitWithOrder.object.amount == 500,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.name == "100g" && foodUnitWithOrder.object.amount == 100)
          .toList()
          .length,
      1,
    );

    foodRepositoryResult = await foodRepository.getFoodByBarcodeOpenFoodFacts(barcode: 4071800000763, languageCode: settingsRepository.languageCode.value);
    expect(foodRepositoryResult.foods!.length, 2);

    food = foodRepositoryResult.foods![0];

    expect(food.name, "15 Fischstäbchen");
    expect(food.foodSource, FoodSource.openFoodFacts);
    expect(food.kJoule, 835.0);
    expect(food.fromDb, false);
    expect(food.id, isNull);

    expect(food.originalFoodSource, isNull);
    expect(food.originalFoodSourceFoodId, "4250241203524");
    expect(food.originalFoodSourceFoodVariantId, isNull);
    expect(food.barcode, 4250241203524);
    expect(food.brands, ["IGLO"]);
    expect(food.nutritionPerGramAmount, 100.0);
    expect(food.nutritionPerMilliliterAmount, isNull);
    expect(food.fat, 8.6);
    expect(food.saturatedFat, 0.7);
    expect(food.carbohydrates, 17.0);
    expect(food.sugar, 0.8);
    expect(food.protein, 13.0);
    expect(food.salt, 0.79);
    expect(food.quantity, "450g (15x30g)");

    expect(food.foodUnitsWithOrder.length, 3);
    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.serving && foodUnitWithOrder.object.amount == 150,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.piece && foodUnitWithOrder.object.amount == 450,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.name == "100g" && foodUnitWithOrder.object.amount == 100)
          .toList()
          .length,
      1,
    );

    food = foodRepositoryResult.foods![1];

    expect(food.name, "15 Fischstäbchen (prepared)");
    expect(food.foodSource, FoodSource.openFoodFacts);
    expect(food.kJoule, 1290.0);
    expect(food.fromDb, false);
    expect(food.id, isNull);

    expect(food.originalFoodSource, isNull);
    expect(food.originalFoodSourceFoodId, "4250241203524");
    expect(food.originalFoodSourceFoodVariantId, "prepared");
    expect(food.barcode, 4250241203524);
    expect(food.brands, ["IGLO"]);
    expect(food.nutritionPerGramAmount, 150.0);
    expect(food.nutritionPerMilliliterAmount, isNull);
    expect(food.fat, 13.0);
    expect(food.saturatedFat, 1.0);
    expect(food.carbohydrates, 27.0);
    expect(food.sugar, 1.3);
    expect(food.protein, 20.0);
    expect(food.salt, 1.1);
    expect(food.quantity, "450g (15x30g)");

    expect(food.foodUnitsWithOrder.length, 2);
    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.serving && foodUnitWithOrder.object.amount == 150,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.piece && foodUnitWithOrder.object.amount == 450,
          )
          .toList()
          .length,
      1,
    );

    foodRepositoryResult = await foodRepository.getFoodByBarcodeOpenFoodFacts(barcode: 4071800000763, languageCode: settingsRepository.languageCode.value);
    expect(foodRepositoryResult.foods!.length, 1);

    food = foodRepositoryResult.foods![0];

    expect(food.name, "Coca-Cola Original");
    expect(food.foodSource, FoodSource.openFoodFacts);
    expect(food.kJoule, 179.0);
    expect(food.fromDb, false);
    expect(food.id, isNull);

    expect(food.originalFoodSource, isNull);
    expect(food.originalFoodSourceFoodId, "5000112546415");
    expect(food.originalFoodSourceFoodVariantId, isNull);
    expect(food.barcode, 5000112546415);
    expect(food.brands, ["Coca-Cola", "Coca-Cola Company"]);
    expect(food.nutritionPerGramAmount, 100.0);
    expect(food.nutritionPerMilliliterAmount, 99.44444444444444);
    expect(food.fat, isNull);
    expect(food.saturatedFat, isNull);
    expect(food.carbohydrates, 10.6);
    expect(food.sugar, 10.6);
    expect(food.protein, isNull);
    expect(food.salt, isNull);
    expect(food.quantity, "1.2533l");

    expect(food.foodUnitsWithOrder.length, 5);
    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.serving && foodUnitWithOrder.object.amount == 333.3,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where(
            (ObjectWithOrder<FoodUnit> foodUnitWithOrder) =>
                foodUnitWithOrder.object.name == OpenEatsJournalStrings.piece && foodUnitWithOrder.object.amount == 1253.3,
          )
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.name == "100g" && foodUnitWithOrder.object.amount == 100)
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.name == "100ml" && foodUnitWithOrder.object.amount == 100)
          .toList()
          .length,
      1,
    );

    expect(
      food.foodUnitsWithOrder
          .where((ObjectWithOrder<FoodUnit> foodUnitWithOrder) => foodUnitWithOrder.object.name == "1l" && foodUnitWithOrder.object.amount == 1000)
          .toList()
          .length,
      1,
    );
  });
}

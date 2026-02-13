import "dart:io";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mockito/mockito.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:path/path.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "../callbacks.mocks.dart";

late Repositories _repositories;
late double _addedKJoule;
late double? _addedFat;
late double? _addedSaturatedFat;
late double? _addedCarbohydrates;
late double? _addedSugar;
late double? _addedProtein;
late double? _addedSalt;

late double _orignalKJouleDay;
late double? _orignalFatDay;
late double? _orignalSaturatedFatDay;
late double? _orignalCarbohydratesDay;
late double? _orignalSugarDay;
late double? _orignalProteinDay;
late double? _orignalSaltDay;

late double _orignalKJouleWeek;
late double? _orignalFatWeek;
late double? _orignalSaturatedFatWeek;
late double? _orignalCarbohydratesWeek;
late double? _orignalSugarWeek;
late double? _orignalProteinWeek;
late double? _orignalSaltWeek;

late double _orignalKJouleMonth;
late double? _orignalFatMonth;
late double? _orignalSaturatedFatMonth;
late double? _orignalCarbohydratesMonth;
late double? _orignalSugarMonth;
late double? _orignalProteinMonth;
late double? _orignalSaltMonth;

void main() async {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final OpenEatsJournalDatabaseService oejDatabase = OpenEatsJournalDatabaseService.instance;
    OpenEatsJournalDatabaseService.databaseFileName = "oej_onboarded_with_data.db";
    File dbSourceFile = File(join(Directory.current.path, r"test\data\oej_onboarded_with_data.db"));
    dbSourceFile.copySync(join(await oejDatabase.getDatabasePath(), OpenEatsJournalDatabaseService.databaseFileName));

    final OpenFoodFactsService openFoodFactsService = OpenFoodFactsService.instance;
    final OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService.instance;

    _repositories = Repositories(
      settingsRepository: SettingsRepository.instance,
      foodRepository: FoodRepository.instance,
      journalRepository: JournalRepository.instance,
    );

    _repositories.settingsRepository.init(oejDatabase: oejDatabase);

    var responses = [
      Future(() async => Response.bytes((await File(join(Directory.current.path, r"test\data\open_food_facts_response_page_1.json")).readAsBytes()), 200)),
    ];

    var getCallback = MockCallbacks().get;
    when(getCallback(any, headers: anyNamed("headers"))).thenAnswer((_) => Future(() async => responses.removeAt(0)));

    openFoodFactsService.init(
      httpGet: getCallback,
      appName: _repositories.settingsRepository.appName,
      appVersion: _repositories.settingsRepository.appVersion,
      appContactMail: _repositories.settingsRepository.appContactMail!,
      useStaging: _repositories.settingsRepository.useStagingServices,
    );

    _repositories.journalRepository.init(oejDatabase: oejDatabase);
    _repositories.foodRepository.init(
      openFoodFactsService: openFoodFactsService,
      oejDatabaseService: oejDatabase,
      oejAssetsService: openEatsJournalAssetsService,
    );

    //required for database initialization
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), _repositories.settingsRepository.initSettings()]);

    ConvertValidate.init(
      languageCode: _repositories.settingsRepository.languageCode.value,
      energyUnit: _repositories.settingsRepository.energyUnit,
      heightUnit: _repositories.settingsRepository.heightUnit,
      weightUnit: _repositories.settingsRepository.weightUnit,
      volumeUnit: _repositories.settingsRepository.volumeUnit,
    );
  });

  tearDownAll(() async {
    File dbTargetFile = File(join(await OpenEatsJournalDatabaseService.instance.getDatabasePath(), OpenEatsJournalDatabaseService.databaseFileName));

    if (dbTargetFile.existsSync()) {
      OpenEatsJournalDatabaseService.instance.close();
      dbTargetFile.deleteSync();
    }
  });

  test("Check statistic data", () async {
    DateTime today = DateTime(2026, 2, 11);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultDays = await _repositories.journalRepository
        .getNutritionDaySumsForLast32Days(today: today);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultWeeks = await _repositories.journalRepository
        .getNutritionWeekSumsForLast15Weeks(today: today);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultMonths = await _repositories.journalRepository
        .getNutritionMonthSumsForLast13Months(today: today);

    DateTime y2026m1d16 = DateTime(2026, 1, 16);
    DateTime y2026m2d11 = DateTime(2026, 2, 11);
    DateTime y2026m2d12 = DateTime(2026, 1, 12);
    DateTime y2026m2d9 = DateTime(2026, 2, 9);
    DateTime y2026m1d1 = DateTime(2026, 1, 1);
    DateTime y2026m2d1 = DateTime(2026, 2, 1);
    DateTime y2026m2d10 = DateTime(2026, 2, 10);

    expect(journalRepositoryGetNutritionSumsResultDays.from, today.subtract(Duration(days: 31)));
    expect(journalRepositoryGetNutritionSumsResultDays.until, today);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums!.entries.length, 27);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.entryCount, 1);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.kJoule, 7998.0);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.fat, 86.679);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.saturatedFat, 42.377);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.carbohydrates, 197.745);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.sugar, 72.493);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.protein, 70.716);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m1d16]?.nutritions.salt, 6.7540000000000004);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.entryCount, 1);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.kJoule, 6159.0);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.fat, 63.737);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.saturatedFat, 33.509);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.carbohydrates, 156.925);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.sugar, 58.894000000000005);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.protein, 55.144999999999996);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d11]?.nutritions.salt, 5.2419);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets!.entries.length, 27);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.kJoule, 8368.0);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.fat, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.carbohydrates, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.protein, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m1d16]?.salt, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.kJoule, 8368.0);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.fat, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.carbohydrates, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.protein, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d11]?.salt, null);

    expect(journalRepositoryGetNutritionSumsResultWeeks.from, ConvertValidate.getWeekStartDate(today).subtract(Duration(days: 98)));
    expect(journalRepositoryGetNutritionSumsResultWeeks.until, ConvertValidate.getWeekStartDate(today));
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums!.entries.length, 5);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.entryCount, 3);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.kJoule, 27441.0);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.fat, 211.012);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.saturatedFat, 87.38);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.carbohydrates, 573.149);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.sugar, 230.26600000000002);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.protein, 176.72);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.nutritions.salt, 21.0722);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.entryCount, 3);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.kJoule, 21851.0);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.fat, 235.3439999523163);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.saturatedFat, 124.75399995231629);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.carbohydrates, 548.868);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.sugar, 184.78599980926515);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.protein, 191.43700009536744);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.salt, 15.9262);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets!.entries.length, 5);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.kJoule, 29498.0);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.fat, 954.3470588235296);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.carbohydrates, 954.3470588235296);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.protein, 954.3470588235296);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d12]?.salt, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.kJoule, 25104.0);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.fat, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.carbohydrates, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.protein, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.salt, null);

    expect(journalRepositoryGetNutritionSumsResultMonths.from, DateTime(today.year - 1, today.month, 1));
    expect(journalRepositoryGetNutritionSumsResultMonths.until, DateTime(today.year, today.month, 1));
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums!.entries.length, 2);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.entryCount, 16);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.kJoule, 141777.0);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.fat, 1320.9145263157895);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.saturatedFat, 541.0874736842105);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.carbohydrates, 3382.489315789474);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.sugar, 1331.5993157894736);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.protein, 1289.5074736842105);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m1d1]?.nutritions.salt, 124.61271921052632);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.entryCount, 11);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.kJoule, 96664.0);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.fat, 793.189420814213);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.saturatedFat, 357.2959471300025);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.carbohydrates, 2017.437894736842);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.sugar, 763.7218937831678);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.protein, 683.3634215294687);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.salt, 75.18767763157895);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets!.entries.length, 2);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.kJoule, 144873.0);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.fat, 4687.067647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.carbohydrates, 4687.067647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.protein, 4687.067647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m1d1]?.salt, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.kJoule, 98639.0);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.fat, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.carbohydrates, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.protein, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.salt, null);

    _orignalKJouleDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.kJoule;
    _orignalFatDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.fat;
    _orignalSaturatedFatDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.saturatedFat;
    _orignalCarbohydratesDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.carbohydrates;
    _orignalSugarDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.sugar;
    _orignalProteinDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.protein;
    _orignalSaltDay = journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]!.nutritions.salt;

    _orignalKJouleWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.kJoule;
    _orignalFatWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.fat;
    _orignalSaturatedFatWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.saturatedFat;
    _orignalCarbohydratesWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.carbohydrates;
    _orignalSugarWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.sugar;
    _orignalProteinWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.protein;
    _orignalSaltWeek = journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]!.nutritions.salt;

    _orignalKJouleMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.kJoule;
    _orignalFatMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.fat;
    _orignalSaturatedFatMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.saturatedFat;
    _orignalCarbohydratesMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.carbohydrates;
    _orignalSugarMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.sugar;
    _orignalProteinMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.protein;
    _orignalSaltMonth = journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]!.nutritions.salt;
  });

  test("Receive open food facts data and add food entry", () async {
    FoodRepositoryResult foodRepositoryResult = await _repositories.foodRepository.getOpenFoodFactsFoodBySearchTextApiV1(
      searchText: "",
      languageCode: _repositories.settingsRepository.languageCode.value,
      page: 3,
    );

    DateTime entryDate = DateTime(2026, 2, 10);
    EatsJournalEntry eatsJournalEntry = EatsJournalEntry.fromFood(entryDate: entryDate, food: foodRepositoryResult.foods![0], meal: Meal.lunch);
    eatsJournalEntry.amount = 500;
    _addedKJoule = eatsJournalEntry.kJoule;
    _addedFat = eatsJournalEntry.fat;
    _addedSaturatedFat = eatsJournalEntry.saturatedFat;
    _addedCarbohydrates = eatsJournalEntry.carbohydrates;
    _addedSugar = eatsJournalEntry.sugar;
    _addedProtein = eatsJournalEntry.protein;
    _addedSalt = eatsJournalEntry.salt;

    await _repositories.journalRepository.setEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  });

  test("Check result in statistics after added food entry", () async {
    DateTime today = DateTime(2026, 2, 11);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultDays = await _repositories.journalRepository
        .getNutritionDaySumsForLast32Days(today: today);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultWeeks = await _repositories.journalRepository
        .getNutritionWeekSumsForLast15Weeks(today: today);
    JournalRepositoryGetNutritionSumsResult journalRepositoryGetNutritionSumsResultMonths = await _repositories.journalRepository
        .getNutritionMonthSumsForLast13Months(today: today);

    DateTime y2026m2d10 = DateTime(2026, 2, 10);
    DateTime y2026m2d12 = DateTime(2026, 1, 12);
    DateTime y2026m2d9 = DateTime(2026, 2, 9);
    DateTime y2026m2d1 = DateTime(2026, 2, 1);

    expect(journalRepositoryGetNutritionSumsResultDays.from, today.subtract(Duration(days: 31)));
    expect(journalRepositoryGetNutritionSumsResultDays.until, today);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums!.entries.length, 27);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.entryCount, 1);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.kJoule, _orignalKJouleDay + _addedKJoule);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.fat, _orignalFatDay! + (_addedFat ?? 0));
    expect(
      journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.saturatedFat,
      _orignalSaturatedFatDay! + (_addedSaturatedFat ?? 0),
    );
    expect(
      journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.carbohydrates,
      _orignalCarbohydratesDay! + (_addedCarbohydrates ?? 0),
    );
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.sugar, _orignalSugarDay! + (_addedSugar ?? 0));
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.protein, _orignalProteinDay! + (_addedProtein ?? 0));
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionSums![y2026m2d10]?.nutritions.salt, _orignalSaltDay! + (_addedSalt ?? 0));
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets!.entries.length, 27);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.kJoule, 8368.0);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.fat, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.carbohydrates, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.protein, 270.7294117647059);
    expect(journalRepositoryGetNutritionSumsResultDays.groupNutritionTargets![y2026m2d10]?.salt, null);

    expect(journalRepositoryGetNutritionSumsResultWeeks.from, ConvertValidate.getWeekStartDate(today).subtract(Duration(days: 98)));
    expect(journalRepositoryGetNutritionSumsResultWeeks.until, ConvertValidate.getWeekStartDate(today));
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums!.entries.length, 5);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d12]?.entryCount, 3);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.kJoule, _orignalKJouleWeek + _addedKJoule);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.fat, _orignalFatWeek! + (_addedFat ?? 0));
    expect(
      journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.saturatedFat,
      _orignalSaturatedFatWeek! + (_addedSaturatedFat ?? 0),
    );
    expect(
      journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.carbohydrates,
      _orignalCarbohydratesWeek! + (_addedCarbohydrates ?? 0),
    );
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.sugar, _orignalSugarWeek! + (_addedSugar ?? 0));
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.protein, _orignalProteinWeek! + (_addedProtein ?? 0));
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionSums![y2026m2d9]?.nutritions.salt, _orignalSaltWeek! + (_addedSalt ?? 0));
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.kJoule, 25104.0);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.fat, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.carbohydrates, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.protein, 812.1882352941177);
    expect(journalRepositoryGetNutritionSumsResultWeeks.groupNutritionTargets![y2026m2d9]?.salt, null);

    expect(journalRepositoryGetNutritionSumsResultMonths.from, DateTime(today.year - 1, today.month, 1));
    expect(journalRepositoryGetNutritionSumsResultMonths.until, DateTime(today.year, today.month, 1));
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums!.entries.length, 2);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.entryCount, 11);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.kJoule, _orignalKJouleMonth + _addedKJoule);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.fat, _orignalFatMonth! + (_addedFat ?? 0));
    expect(
      journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.saturatedFat,
      _orignalSaturatedFatMonth! + (_addedSaturatedFat ?? 0),
    );
    expect(
      journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.carbohydrates,
      _orignalCarbohydratesMonth! + (_addedCarbohydrates ?? 0),
    );
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.sugar, _orignalSugarMonth! + (_addedSugar ?? 0));
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.protein, _orignalProteinMonth! + (_addedProtein ?? 0));
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionSums![y2026m2d1]?.nutritions.salt, _orignalSaltMonth! + (_addedSalt ?? 0));
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.kJoule, 98639.0);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.fat, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.saturatedFat, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.carbohydrates, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.sugar, null);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.protein, 3191.2617647058823);
    expect(journalRepositoryGetNutritionSumsResultMonths.groupNutritionTargets![y2026m2d1]?.salt, null);
  });
}

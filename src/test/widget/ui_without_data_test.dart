import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_app_viewmodel.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:path/path.dart";
import "package:provider/provider.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

import "../mocks.mocks.dart";

OpenEatsJournalDatabaseService? _database;

void main() async {
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    //oej_onboarded_with_data.db contains eats journal entries from 2026-01-16 until 2026-02-11
    _database = OpenEatsJournalDatabaseService(databaseFileName: "oej_test.db");
    await _database!.open();
  });

  tearDown(() async {
    File databaseFileName = File(join(await _database!.getDatabasePath(), _database!.databaseFileName));

    if (databaseFileName.existsSync()) {
      await _database!.close();
      databaseFileName.deleteSync();
    }

    _database = null;
  });

  Future<List<Object>> setupWithSpecificTodayDate({required DateTime today}) async {
    List<Object> result = List.empty(growable: true);
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!, today: today);
    result.add(settingsRepository);

    OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService();

    OpenFoodFactsService openFoodFactsService = OpenFoodFactsService(
      httpGet: MockCallbacks().get,
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

    await initializeDateFormatting(OpenEatsJournalStrings.en);
    return result;
  }

  testWidgets("Onboarding test", (tester) async {
    DateTime today = DateTime(2026, 3, 31);
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;
    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;

    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(settingsRepository.onboarded.value, false);

    //page1
    expect(find.textContaining("Welcome"), findsOneWidget);
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    expect(find.textContaining("You must agree"), findsOneWidget);

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    expect(find.textContaining("You must agree"), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    //page2
    expect(find.textContaining("Stay healthy"), findsOneWidget);
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    expect(find.textContaining("You must confirm"), findsOneWidget);

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    expect(find.textContaining("You must confirm"), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    //page3
    expect(find.textContaining("gender"), findsOneWidget);
    await tester.ensureVisible(find.text("Proceed"));
    await tester.tap(find.text("Proceed"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Please select"), findsOneWidget);

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Please select"), findsNothing);

    await tester.ensureVisible(find.text("male"));
    await tester.tap(find.text("male"));

    FinderResult<Element> textFields = find.byType(SettingsTextField).evaluate();
    SettingsTextField settingsTextField;

    int textFieldIndex = 0;
    for (Element element in textFields) {
      settingsTextField = element.widget as SettingsTextField;

      //birthday
      if (textFieldIndex == 0) {
        await tester.tap(find.byWidgetPredicate((widgetInternal) => widgetInternal == settingsTextField));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pump();

        await tester.enterText(find.descendant(of: find.byType(Dialog), matching: find.byType(TextField)), "7/1/1980");
        await tester.tap(find.text("OK"));
      }

      //height cm
      if (textFieldIndex == 1) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == settingsTextField), "185");
      }

      //weight kg
      if (textFieldIndex == 2) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == settingsTextField), "90");
      }

      textFieldIndex++;
    }

    await tester.tap(find.text("Low"));

    await tester.ensureVisible(find.textContaining("Proceed"));
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    //page4
    expect(find.textContaining("weight target"), findsOneWidget);
    await tester.ensureVisible(find.text("Proceed"));
    await tester.tap(find.text("Proceed"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Please select"), findsOneWidget);

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("-0.5"));
    await tester.pump();

    expect(find.text("2,571"), findsOneWidget);
    expect(find.text("2,071"), findsOneWidget);

    await tester.tap(find.text("Proceed"));
    await tester.pumpAndSettle();

    //page5
    expect(find.textContaining("contribute", findRichText: true), findsOneWidget);
    await tester.tap(find.text("Finish"));
    await tester.pumpAndSettle();

    //check eats journal screen display
    expect(find.textContaining("2,071"), findsExactly(2)); //space in beginning
    expect(find.textContaining("70.2"), findsOneWidget);
    expect(find.textContaining("280.3"), findsOneWidget);
    expect(find.textContaining("76.4"), findsOneWidget);

    expect(find.text("breakfast"), findsExactly(2)); //one in the meal selection dropdown
    expect(find.text("lunch"), findsOneWidget);
    expect(find.text("dinner"), findsOneWidget);
    expect(find.text("snacks"), findsOneWidget);
    expect(find.text("weight"), findsOneWidget);

    //"restart" the app
    List<Object> repositoriesRestart = (await tester.runAsync<List<Object>>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;

    SettingsRepository settingsRepositoryRestart = repositoriesRestart[0] as SettingsRepository;
    FoodRepository foodRepositoryRestart = repositoriesRestart[1] as FoodRepository;
    JournalRepository journalRepositoryRestart = repositoriesRestart[2] as JournalRepository;

    //UniqueKey ensures provider resets when restarting the widget/pumping it again
    Widget widgetRestart = MultiProvider(
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepositoryRestart),
        Provider<FoodRepository>.value(value: foodRepositoryRestart),
        Provider<JournalRepository>.value(value: journalRepositoryRestart),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepositoryRestart, foodRepository: foodRepositoryRestart),
        ),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widgetRestart);
    await tester.pumpAndSettle();

    expect(settingsRepositoryRestart.onboarded.value, true);

    //check eats journal home screen for correct values
    //check eats journal screen display
    expect(find.textContaining("2,071"), findsExactly(2)); //space in beginning
    expect(find.textContaining("70.2"), findsOneWidget);
    expect(find.textContaining("280.3"), findsOneWidget);
    expect(find.textContaining("76.4"), findsOneWidget);

    expect(find.text("breakfast"), findsExactly(2)); //one in the meal selection dropdown
    expect(find.text("lunch"), findsOneWidget);
    expect(find.text("dinner"), findsOneWidget);
    expect(find.text("snacks"), findsOneWidget);
    expect(find.text("weight"), findsOneWidget);

    //check if data was persisted with new settings repository...
    expect(settingsRepositoryRestart.darkMode.value, false);
    expect(settingsRepositoryRestart.languageCode.value, OpenEatsJournalStrings.en);
    expect(settingsRepositoryRestart.gender, Gender.male);
    expect(settingsRepositoryRestart.birthday, DateTime(1980, 7, 1));
    expect(settingsRepositoryRestart.height, 185);
    expect(settingsRepositoryRestart.activityFactor, 1.4);
    expect(settingsRepositoryRestart.weightTarget, WeightTarget.lose05);
    expect(settingsRepositoryRestart.kJouleMonday, 8664.018);
    expect(settingsRepositoryRestart.kJouleTuesday, 8664.018);
    expect(settingsRepositoryRestart.kJouleWednesday, 8664.018);
    expect(settingsRepositoryRestart.kJouleThursday, 8664.018);
    expect(settingsRepositoryRestart.kJouleFriday, 8664.018);
    expect(settingsRepositoryRestart.kJouleSaturday, 8664.018);
    expect(settingsRepositoryRestart.kJouleSunday, 8664.018);
    expect(settingsRepositoryRestart.lastProcessedStandardFoodDataChangeDate, DateTime(2026, 03, 04));
    expect(settingsRepositoryRestart.energyUnit, EnergyUnit.kcal);
    expect(settingsRepositoryRestart.heightUnit, HeightUnit.cm);
    expect(settingsRepositoryRestart.weightUnit, WeightUnit.g);
    expect(settingsRepositoryRestart.volumeUnit, VolumeUnit.ml);
  });
}

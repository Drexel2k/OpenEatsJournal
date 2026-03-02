import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
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
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:path/path.dart";
import "package:provider/provider.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "../callbacks.mocks.dart";

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

  Future<Repositories> setupWithSpecificTodayDate({required DateTime today}) async {
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!, today: today);
    OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService();

    OpenFoodFactsService openFoodFactsService = OpenFoodFactsService(
      httpGet: MockCallbacks().get,
      appName: settingsRepository.appName,
      appVersion: settingsRepository.appVersion,
      appContactMail: settingsRepository.appContactMail!,
    );

    Repositories repositories = Repositories(
      settingsRepository: settingsRepository,
      foodRepository: FoodRepository(
        settingsRepository: settingsRepository,
        openFoodFactsService: openFoodFactsService,
        oejDatabaseService: _database!,
        oejAssetsService: openEatsJournalAssetsService,
      ),
      journalRepository: JournalRepository(oejDatabase: _database!),
    );

    //required for database initialization
    //await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), repositories.settingsRepository.initSettings()]);
    // ConvertValidate.init(
    //   languageCode: OpenEatsJournalStrings.en,
    //   energyUnit: EnergyUnit.kcal,
    //   heightUnit: HeightUnit.cm,
    //   weightUnit: WeightUnit.g,
    //   volumeUnit: VolumeUnit.ml,
    // );

    return repositories;
  }

  testWidgets("Onboarding test", (tester) async {
    DateTime today = DateTime(2026, 3, 31);
    //without runAsync openDatabase will hang.
    Repositories repositories = (await tester.runAsync<Repositories>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;

    Widget widget = Provider<Repositories>.value(
      value: repositories,
      child: ChangeNotifierProvider(
        create: (context) => OpenEatsJournalAppViewModel(settingsRepository: repositories.settingsRepository, foodRepository: repositories.foodRepository),
        child: OpenEatsJournalApp(),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(repositories.settingsRepository.onboarded.value, false);

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
    await tester.dragUntilVisible(find.text("Proceed"), find.byType(SingleChildScrollView), Offset(0, -10));
    await tester.tap(find.text("Proceed"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Please select"), findsOneWidget);

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Please select"), findsNothing);

    await tester.dragUntilVisible(find.text("male"), find.byType(SingleChildScrollView), Offset(0, 10));
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

    await tester.dragUntilVisible(find.text("Proceed"), find.byType(SingleChildScrollView), Offset(0, -10));
    await tester.tap(find.textContaining("Proceed"));
    await tester.pumpAndSettle();

    //page4
    expect(find.textContaining("weight target"), findsOneWidget);
    await tester.dragUntilVisible(find.text("Proceed"), find.byType(SingleChildScrollView), Offset(0, -10));
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
    Repositories repositoriesRestart = (await tester.runAsync<Repositories>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;

    //UniqueKey ensures provider resets when restarting the widget/pumping it again
    Widget widgetRestart = Provider<Repositories>.value(
      key: UniqueKey(),
      value: repositoriesRestart,
      child: ChangeNotifierProvider.value(
        value: OpenEatsJournalAppViewModel(settingsRepository: repositoriesRestart.settingsRepository, foodRepository: repositoriesRestart.foodRepository),
        child: OpenEatsJournalApp(),
      ),
    );

    await tester.pumpWidget(widgetRestart);
    await tester.pumpAndSettle();

    expect(repositoriesRestart.settingsRepository.onboarded.value, true);

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
    expect(repositoriesRestart.settingsRepository.darkMode.value, false);
    expect(repositoriesRestart.settingsRepository.languageCode.value, OpenEatsJournalStrings.en);
    expect(repositoriesRestart.settingsRepository.gender, Gender.male);
    expect(repositoriesRestart.settingsRepository.birthday, DateTime(1980, 7, 1));
    expect(repositoriesRestart.settingsRepository.height, 185);
    expect(repositoriesRestart.settingsRepository.activityFactor, 1.4);
    expect(repositoriesRestart.settingsRepository.weightTarget, WeightTarget.lose05);
    expect(repositoriesRestart.settingsRepository.kJouleMonday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleTuesday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleWednesday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleThursday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleFriday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleSaturday, 8664.018);
    expect(repositoriesRestart.settingsRepository.kJouleSunday, 8664.018);
    expect(repositoriesRestart.settingsRepository.lastProcessedStandardFoodDataChangeDate, DateTime(2026, 02, 28, 1));
    expect(repositoriesRestart.settingsRepository.energyUnit, EnergyUnit.kcal);
    expect(repositoriesRestart.settingsRepository.heightUnit, HeightUnit.cm);
    expect(repositoriesRestart.settingsRepository.weightUnit, WeightUnit.g);
    expect(repositoriesRestart.settingsRepository.volumeUnit, VolumeUnit.ml);
  });
}

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/statistics_screen.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
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
    _database = OpenEatsJournalDatabaseService(databaseFileName: "oej_onboarded_with_data.db");

    File dbSourceFile = File(join(Directory.current.path, r"test\data\oej_onboarded_with_data.db"));
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

  Future<Repositories> generalSetup() async {
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!);
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
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), repositories.settingsRepository.initSettings()]);

    ConvertValidate.init(
      languageCode: repositories.settingsRepository.languageCode.value,
      energyUnit: repositories.settingsRepository.energyUnit,
      heightUnit: repositories.settingsRepository.heightUnit,
      weightUnit: repositories.settingsRepository.weightUnit,
      volumeUnit: repositories.settingsRepository.volumeUnit,
    );

    return repositories;
  }

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
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), repositories.settingsRepository.initSettings()]);

    ConvertValidate.init(
      languageCode: repositories.settingsRepository.languageCode.value,
      energyUnit: repositories.settingsRepository.energyUnit,
      heightUnit: repositories.settingsRepository.heightUnit,
      weightUnit: repositories.settingsRepository.weightUnit,
      volumeUnit: repositories.settingsRepository.volumeUnit,
    );

    return repositories;
  }

  testWidgets("Adding and loading quick entry", (tester) async {
    //without runAsync openDatabase will hang.
    Repositories repositories = (await tester.runAsync<Repositories>(() async {
      return await generalSetup();
    }))!;
    //Adding entry
    DateTime entryDateValue = DateTime(2026, 02, 12);
    String nameValue = "Quick Entry 1";
    int kCalValue = 150;
    Meal mealValue = Meal.dinner;
    double amountValue = 100;
    MeasurementUnit amountMeasurementUnitValue = MeasurementUnit.milliliter;
    double fatValue = 90;
    double saturatedFatValue = 80;
    double carbohydratesValue = 70;
    double sugarValue = 60;
    double proteinValue = 50;
    double saltValue = 40;

    EatsJournalEntry quickEntry = EatsJournalEntry.quick(
      entryDate: entryDateValue,
      name: nameValue,
      kJoule: ConvertValidate.getEnergyKJ(displayEnergy: kCalValue),
      meal: mealValue,
    );
    quickEntry.amount = amountValue;
    quickEntry.amountMeasurementUnit = amountMeasurementUnitValue;
    quickEntry.fat = fatValue;
    quickEntry.saturatedFat = saturatedFatValue;
    quickEntry.carbohydrates = carbohydratesValue;
    quickEntry.sugar = sugarValue;
    quickEntry.protein = proteinValue;
    quickEntry.salt = saltValue;

    Widget widget = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(repositories.settingsRepository.languageCode.value),
      navigatorKey: AppGlobal.navigatorKey,
      home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
        create: (context) => EatsJournalQuickEntryEditScreenViewModel(
          quickEntry: quickEntry,
          journalRepository: repositories.journalRepository,
          settingsRepository: repositories.settingsRepository,
        ),
        child: EatsJournalQuickEntryEditScreen(),
      ),
    );

    await tester.pumpWidget(widget);

    Finder createButton = find.byIcon(Icons.add_circle_outline);
    await tester.tap(createButton);
    await tester.pump();

    expect(quickEntry.id, isNotNull);

    //Loading entry
    List<EatsJournalEntry>? entries = await repositories.journalRepository.getEatsJournalEntries(date: entryDateValue, meal: mealValue);

    expect(entries, isNotNull);
    expect(entries!.length, 1);
    expect(entries[0].entryDate, entryDateValue);
    expect(entries[0].name, nameValue);
    expect(entries[0].kJoule, ConvertValidate.getEnergyKJ(displayEnergy: kCalValue));
    expect(entries[0].amount, amountValue);
    expect(entries[0].amountMeasurementUnit, amountMeasurementUnitValue);
    expect(entries[0].fat, fatValue);
    expect(entries[0].saturatedFat, saturatedFatValue);
    expect(entries[0].carbohydrates, carbohydratesValue);
    expect(entries[0].sugar, sugarValue);
    expect(entries[0].protein, proteinValue);
    expect(entries[0].salt, saltValue);

    //Check if everything is displayed
    widget = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(repositories.settingsRepository.languageCode.value),
      navigatorKey: AppGlobal.navigatorKey,
      home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
        create: (context) => EatsJournalQuickEntryEditScreenViewModel(
          quickEntry: entries[0],
          journalRepository: repositories.journalRepository,
          settingsRepository: repositories.settingsRepository,
        ),
        child: EatsJournalQuickEntryEditScreen(),
      ),
    );

    await tester.pumpWidget(widget);

    FinderResult<Element> textFields = find.byType(OpenEatsJournalTextField).evaluate();
    OpenEatsJournalTextField openEatsJournalTextField;

    int textFieldIndex = 0;
    for (Element element in textFields) {
      openEatsJournalTextField = element.widget as OpenEatsJournalTextField;
      if (textFieldIndex == 0) {
        expect(openEatsJournalTextField.controller!.text, nameValue);
      }

      if (textFieldIndex == 1) {
        expect(openEatsJournalTextField.controller!.text, "$kCalValue");
      }

      if (textFieldIndex == 2) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: amountValue));
      }

      if (textFieldIndex == 3) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: carbohydratesValue));
      }

      if (textFieldIndex == 4) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: sugarValue));
      }

      if (textFieldIndex == 5) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: fatValue));
      }

      if (textFieldIndex == 6) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: saturatedFatValue));
      }

      if (textFieldIndex == 7) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: proteinValue));
      }

      if (textFieldIndex == 8) {
        expect(openEatsJournalTextField.controller!.text, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: saltValue));
      }

      textFieldIndex++;
    }

    expect(find.text("dinner"), findsOneWidget);
    expect(find.text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(entryDateValue)), findsOneWidget);
    expect(find.text("ml"), findsOneWidget);

    //let timer end, otherwise the test will fail/throw an internal exception.
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets("Check statistic data with nutritions null values", (tester) async {
    DateTime today = DateTime(2026, 3, 18);
    //without runAsync openDatabase will hang.
    Repositories repositories = (await tester.runAsync<Repositories>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;

    EatsJournalEntry eatsJournalEntry = EatsJournalEntry.quick(entryDate: today, name: "Test Entry", kJoule: 400, meal: Meal.breakfast);
    await repositories.journalRepository.saveOnceDayNutritionTarget(
      entryDate: eatsJournalEntry.entryDate,
      dayTargetKJoule: repositories.settingsRepository.getTargetKJouleForDay(day: eatsJournalEntry.entryDate),
    );
    await repositories.journalRepository.setEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);

    Widget widget = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(repositories.settingsRepository.languageCode.value),
      navigatorKey: AppGlobal.navigatorKey,
      home: ChangeNotifierProvider<StatisticsScreenViewModel>(
        create: (context) => StatisticsScreenViewModel(settingsRepository: repositories.settingsRepository, journalRepository: repositories.journalRepository),
        child: StatisticsScreen(),
      ),
    );

    await tester.pumpWidget(widget);

    Finder dropdownFinder = find.byType(OpenEatsJournalDropdownMenu<int>);
    Finder dropdownSelectedValueFinder = find.text('Energy');
    expect(dropdownSelectedValueFinder, findsOneWidget);

    //just test if the result is displayed without execetpions because of the null values.
    List<String> nutritons = ["Fat", "Saturated fat", "Carbohydrates", "Sugar", "Protein", "Salt"];
    Finder dropdownItem;
    for (String untrition in nutritons) {
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      dropdownItem = find.text(untrition).first;
      await tester.tap(dropdownItem);
      await tester.pumpAndSettle();
      dropdownSelectedValueFinder = find.text(untrition);
      expect(dropdownSelectedValueFinder, findsOneWidget);
    }
  });
}

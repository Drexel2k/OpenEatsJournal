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
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:path/path.dart";
import "package:provider/provider.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "../callbacks.mocks.dart";

late Repositories _repositories;

void main() async {
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final OpenEatsJournalDatabaseService oejDatabase = OpenEatsJournalDatabaseService.instance;
    OpenEatsJournalDatabaseService.databaseFileName = "oej_onboarded_with_data.db";
    File dbSourceFile = File(join(Directory.current.path, r"test\data\oej_onboarded_with_data.db"));

    String targetDirectoryPath = await oejDatabase.getDatabasePath();
    Directory targetDirectory = Directory(targetDirectoryPath);
    await targetDirectory.create(recursive: true);

    dbSourceFile.copySync(join(await oejDatabase.getDatabasePath(), OpenEatsJournalDatabaseService.databaseFileName));

    final OpenFoodFactsService openFoodFactsService = OpenFoodFactsService.instance;
    final OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService.instance;

    _repositories = Repositories(
      settingsRepository: SettingsRepository.instance,
      foodRepository: FoodRepository.instance,
      journalRepository: JournalRepository.instance,
    );

    _repositories.settingsRepository.init(oejDatabase: oejDatabase);

    openFoodFactsService.init(
      httpGet: MockCallbacks().get,
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

  tearDown(() async {
    File dbTargetFile = File(join(await OpenEatsJournalDatabaseService.instance.getDatabasePath(), OpenEatsJournalDatabaseService.databaseFileName));

    if (dbTargetFile.existsSync()) {
      await OpenEatsJournalDatabaseService.instance.close();
      dbTargetFile.deleteSync();
    }
  });

  testWidgets("Adding and loading quick entry", (tester) async {
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
      locale: Locale(_repositories.settingsRepository.languageCode.value),
      navigatorKey: AppGlobal.navigatorKey,
      home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
        create: (context) => EatsJournalQuickEntryEditScreenViewModel(
          quickEntry: quickEntry,
          journalRepository: _repositories.journalRepository,
          settingsRepository: _repositories.settingsRepository,
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
    List<EatsJournalEntry>? entries = await _repositories.journalRepository.getEatsJournalEntries(date: entryDateValue, meal: mealValue);

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
      locale: Locale(_repositories.settingsRepository.languageCode.value),
      navigatorKey: AppGlobal.navigatorKey,
      home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
        create: (context) => EatsJournalQuickEntryEditScreenViewModel(
          quickEntry: entries[0],
          journalRepository: _repositories.journalRepository,
          settingsRepository: _repositories.settingsRepository,
        ),
        child: EatsJournalQuickEntryEditScreen(),
      ),
    );

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
}

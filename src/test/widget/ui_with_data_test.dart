import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
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
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/food_edit_screen.dart";
import "package:openeatsjournal/ui/screens/food_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/statistics_screen.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_colors.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
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

  Future<List<Object>> generalSetup() async {
    List<Object> result = List.empty(growable: true);
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!);
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

    //required for database initialization
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), settingsRepository.initSettings()]);

    ConvertValidate convert = ConvertValidate(
      languageCode: settingsRepository.languageCode.value,
      energyUnit: settingsRepository.energyUnit,
      heightUnit: settingsRepository.heightUnit,
      weightUnit: settingsRepository.weightUnit,
      volumeUnit: settingsRepository.volumeUnit,
    );

    result.add(convert);

    return result;
  }

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

    //required for database initialization
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), settingsRepository.initSettings()]);

    ConvertValidate convert = ConvertValidate(
      languageCode: settingsRepository.languageCode.value,
      energyUnit: settingsRepository.energyUnit,
      heightUnit: settingsRepository.heightUnit,
      weightUnit: settingsRepository.weightUnit,
      volumeUnit: settingsRepository.volumeUnit,
    );

    result.add(convert);

    return result;
  }

  testWidgets("Adding and loading quick entry", (tester) async {
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await generalSetup();
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    ConvertValidate convert = repositories[3] as ConvertValidate;

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
      kJoule: convert.getEnergyKJ(displayEnergy: kCalValue),
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

    OverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        Provider.value(value: convert),
        Provider.value(value: overlayDisplay),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settingsRepository.languageCode.value),
        navigatorKey: AppGlobal.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
          extensions: const <ThemeExtension<dynamic>>[
            OpenEatsJournalColors(
              userFoodColor: Color.fromARGB(255, 26, 65, 255),
              standardFoodColor: Color.fromARGB(255, 5, 112, 89),
              openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
              quickEntryColor: Color.fromARGB(255, 255, 0, 233),
              cacheFoodColor: Color.fromARGB(255, 83, 83, 83),
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
        home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
          create: (context) => EatsJournalQuickEntryEditScreenViewModel(
            quickEntry: quickEntry,
            journalRepository: journalRepository,
            settingsRepository: settingsRepository,
            convert: convert,
          ),
          child: EatsJournalQuickEntryEditScreen(),
        ),
      ),
    );

    await tester.pumpWidget(widget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(quickEntry.id, isNotNull);

    //Loading entry
    List<EatsJournalEntry>? entries = await journalRepository.getEatsJournalEntries(date: entryDateValue, meal: mealValue);

    expect(entries, isNotNull);
    expect(entries!.length, 1);
    expect(entries[0].entryDate, entryDateValue);
    expect(entries[0].name, nameValue);
    expect(entries[0].kJoule, convert.getEnergyKJ(displayEnergy: kCalValue));
    expect(entries[0].amount, amountValue);
    expect(entries[0].amountMeasurementUnit, amountMeasurementUnitValue);
    expect(entries[0].fat, fatValue);
    expect(entries[0].saturatedFat, saturatedFatValue);
    expect(entries[0].carbohydrates, carbohydratesValue);
    expect(entries[0].sugar, sugarValue);
    expect(entries[0].protein, proteinValue);
    expect(entries[0].salt, saltValue);

    //Check if everything is displayed
    widget = MultiProvider(
      providers: [
        Provider.value(value: convert),
        Provider.value(value: overlayDisplay),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settingsRepository.languageCode.value),
        navigatorKey: AppGlobal.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
          extensions: const <ThemeExtension<dynamic>>[
            OpenEatsJournalColors(
              userFoodColor: Color.fromARGB(255, 26, 65, 255),
              standardFoodColor: Color.fromARGB(255, 5, 112, 89),
              openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
              quickEntryColor: Color.fromARGB(255, 255, 0, 233),
              cacheFoodColor: Color.fromARGB(255, 83, 83, 83),
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
        home: ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
          create: (context) => EatsJournalQuickEntryEditScreenViewModel(
            quickEntry: entries[0],
            journalRepository: journalRepository,
            settingsRepository: settingsRepository,
            convert: convert,
          ),
          child: EatsJournalQuickEntryEditScreen(),
        ),
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
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: amountValue));
      }

      if (textFieldIndex == 3) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: carbohydratesValue));
      }

      if (textFieldIndex == 4) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: sugarValue));
      }

      if (textFieldIndex == 5) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: fatValue));
      }

      if (textFieldIndex == 6) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: saturatedFatValue));
      }

      if (textFieldIndex == 7) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: proteinValue));
      }

      if (textFieldIndex == 8) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: saltValue));
      }

      textFieldIndex++;
    }

    expect(find.text("dinner"), findsOneWidget);
    expect(find.text(convert.dateFormatterDisplayLongDateOnly.format(entryDateValue)), findsOneWidget);
    expect(find.text("ml"), findsOneWidget);
  });

  testWidgets("Check statistic data with nutritions null values", (tester) async {
    DateTime today = DateTime(2026, 3, 18);
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await setupWithSpecificTodayDate(today: today);
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    ConvertValidate convert = repositories[3] as ConvertValidate;

    EatsJournalEntry eatsJournalEntry = EatsJournalEntry.quick(entryDate: today, name: "Test Entry", kJoule: 400, meal: Meal.breakfast);
    await journalRepository.saveOnceDayNutritionTarget(
      entryDate: eatsJournalEntry.entryDate,
      dayTargetKJoule: settingsRepository.getTargetKJouleForDay(day: eatsJournalEntry.entryDate),
    );
    await journalRepository.setEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);

    Widget widget = Provider.value(
      value: convert,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settingsRepository.languageCode.value),
        navigatorKey: AppGlobal.navigatorKey,
        home: ChangeNotifierProvider<StatisticsScreenViewModel>(
          create: (context) => StatisticsScreenViewModel(settingsRepository: settingsRepository, journalRepository: journalRepository),
          child: StatisticsScreen(),
        ),
      ),
    );

    await tester.pumpWidget(widget);

    Finder dropdownFinder = find.byType(OpenEatsJournalDropdownMenu<int>);
    Finder dropdownSelectedValueFinder = find.text('Energy');
    expect(dropdownSelectedValueFinder, findsOneWidget);

    //just test if the result is displayed without exceptions because of the null values.
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

  testWidgets("Adding new food from existing food", (tester) async {
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await generalSetup();
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    ConvertValidate convert = repositories[3] as ConvertValidate;

    String nameValue = "Dinner rolls, wheat";
    int brandsLength = 0;
    FoodSource foodSourceValue = FoodSource.user;
    FoodSource originalFoodSourceValue = FoodSource.standard;
    String originalFoodSourceFoodIdValue = "5";
    bool fromDbValue = true;
    int kCalValue = 273;
    int nutritionPerGramAmountValue = 100;
    double fatValue = 6.3;
    double saturatedFatValue = 1.5;
    double carbohydratesValue = 46;
    double sugarValue = 1.6;
    double proteinValue = 8.6;
    double saltValue = 0.9;
    String quantityValue = OpenEatsJournalStrings.emptyString;
    int foodUnitsLength = 2;
    String defaultFoodUnitNameValue = "Roll";

    Food food = (await foodRepository.getFoodsBySearchText(
      searchText: "roll",
      languageCode: OpenEatsJournalStrings.en,
      searchMode: SearchMode.offline,
    ))[1].foods![0];

    int originalFoodId = food.id!;
    List<int> originalfoodUnitIds = food.foodUnitsWithOrder.map((foodunit) => foodunit.object.id!).toList();

    Food newFood = Food.copyAsNewUserFood(food: food);

    OverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        Provider.value(value: convert),
        Provider.value(value: overlayDisplay),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settingsRepository.languageCode.value),
        navigatorKey: AppGlobal.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
          extensions: const <ThemeExtension<dynamic>>[
            OpenEatsJournalColors(
              userFoodColor: Color.fromARGB(255, 26, 65, 255),
              standardFoodColor: Color.fromARGB(255, 5, 112, 89),
              openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
              quickEntryColor: Color.fromARGB(255, 255, 0, 233),
              cacheFoodColor: Color.fromARGB(255, 83, 83, 83),
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
        home: ChangeNotifierProvider<FoodEditScreenViewModel>(
          create: (context) => FoodEditScreenViewModel(food: newFood, foodRepository: foodRepository, convert: convert),
          child: FoodEditScreen(),
        ),
      ),
    );

    await tester.pumpWidget(widget);

    await tester.ensureVisible(find.text("Create"));
    await tester.tap(find.text("Create"));
    await tester.pump();

    expect(newFood.id, isNotNull);

    //Loading food
    Food loadedFood = (await foodRepository.getFoodsBySearchText(
      searchText: "roll",
      languageCode: OpenEatsJournalStrings.en,
      searchMode: SearchMode.offline,
    ))[0].foods![0];

    //check if ids are new
    expect(loadedFood.id != originalFoodId, true);
    List<int> loadedFoodUnitIds = loadedFood.foodUnitsWithOrder.map((foodunit) => foodunit.object.id!).toList();
    for (int loadedFoodUnitId in loadedFoodUnitIds) {
      expect(originalfoodUnitIds.contains(loadedFoodUnitId), false);
    }

    //check if values are the same
    expect(loadedFood, isNotNull);
    expect(loadedFood.name, nameValue);
    expect(loadedFood.brands.length, brandsLength);
    expect(loadedFood.foodSource, foodSourceValue);
    expect(loadedFood.originalFoodSource, originalFoodSourceValue);
    expect(loadedFood.originalFoodSourceFoodId, originalFoodSourceFoodIdValue);
    expect(loadedFood.fromDb, fromDbValue);
    expect(loadedFood.barcode, null);
    expect(loadedFood.kJoule, convert.getEnergyKJ(displayEnergy: kCalValue));
    expect(loadedFood.nutritionPerGramAmount, nutritionPerGramAmountValue);
    expect(loadedFood.nutritionPerMilliliterAmount, null);
    expect(loadedFood.fat, fatValue);
    expect(loadedFood.saturatedFat, saturatedFatValue);
    expect(loadedFood.carbohydrates, carbohydratesValue);
    expect(loadedFood.sugar, sugarValue);
    expect(loadedFood.protein, proteinValue);
    expect(loadedFood.salt, saltValue);
    expect(loadedFood.quantity, quantityValue);
    expect(loadedFood.foodUnitsWithOrder.length, foodUnitsLength);
    expect(loadedFood.defaultFoodUnit!.name, defaultFoodUnitNameValue);

    //Check if everything is displayed
    widget = MultiProvider(
      providers: [
        Provider.value(value: convert),
        Provider.value(value: overlayDisplay),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(settingsRepository.languageCode.value),
        navigatorKey: AppGlobal.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
          extensions: const <ThemeExtension<dynamic>>[
            OpenEatsJournalColors(
              userFoodColor: Color.fromARGB(255, 26, 65, 255),
              standardFoodColor: Color.fromARGB(255, 5, 112, 89),
              openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
              quickEntryColor: Color.fromARGB(255, 255, 0, 233),
              cacheFoodColor: Color.fromARGB(255, 83, 83, 83),
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
        home: ChangeNotifierProvider<FoodEditScreenViewModel>(
          create: (context) => FoodEditScreenViewModel(food: loadedFood, foodRepository: foodRepository, convert: convert),
          child: FoodEditScreen(),
        ),
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
        expect(openEatsJournalTextField.controller!.text, OpenEatsJournalStrings.emptyString);
      }

      if (textFieldIndex == 2) {
        expect(openEatsJournalTextField.controller!.text, OpenEatsJournalStrings.emptyString);
      }

      if (textFieldIndex == 3) {
        expect(openEatsJournalTextField.controller!.text, convert.numberFomatterInt.format(nutritionPerGramAmountValue));
      }

      if (textFieldIndex == 4) {
        expect(openEatsJournalTextField.controller!.text, OpenEatsJournalStrings.emptyString);
      }

      if (textFieldIndex == 5) {
        expect(openEatsJournalTextField.controller!.text, "$kCalValue");
      }

      if (textFieldIndex == 6) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: carbohydratesValue));
      }

      if (textFieldIndex == 7) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: sugarValue));
      }

      if (textFieldIndex == 8) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: fatValue));
      }

      if (textFieldIndex == 9) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: saturatedFatValue));
      }

      if (textFieldIndex == 10) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: proteinValue));
      }

      if (textFieldIndex == 11) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: saltValue));
      }

      if (textFieldIndex == 12) {
        expect(openEatsJournalTextField.controller!.text, "Roll");
      }

      if (textFieldIndex == 13) {
        expect(openEatsJournalTextField.controller!.text, "80");
      }

      if (textFieldIndex == 14) {
        expect(openEatsJournalTextField.controller!.text, "Slice");
      }

      if (textFieldIndex == 15) {
        expect(openEatsJournalTextField.controller!.text, "50");
      }

      textFieldIndex++;
    }
  });
}

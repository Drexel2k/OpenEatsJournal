import "dart:io";
import "package:csv/csv.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mockito/mockito.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_app_viewmodel.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
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

  Future<List<Object>> testSetup({
    DateTime? today,
    Food Function()? getFoodFunction,
    String? barcodeScannerResult,
    EatsJournalEntry Function()? getEatsJournalEntryFunction,
  }) async {
    List<Object> result = [];
    SettingsRepository settingsRepository = SettingsRepository(oejDatabase: _database!, today: today);
    result.add(settingsRepository);

    //required for database initialization
    await Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), settingsRepository.initSettings()]);

    MockOpenEatsJournalAssetsService openEatsJournalAssetsService = MockOpenEatsJournalAssetsService();
    when(openEatsJournalAssetsService.getStandardFoodFiles()).thenAnswer((_) => Future(() async => ["1.csv"]));
    when(openEatsJournalAssetsService.getCsvContent(path: anyNamed("path"))).thenAnswer(
      (_) => Future(() async {
        return CsvToListConverter(
          shouldParseNumbers: false,
        ).convert(File(join(Directory.current.path, r"test\data\standard_food_data.1.csv")).readAsStringSync());
      }),
    );

    OpenFoodFactsService openFoodFactsService = OpenFoodFactsService(
      httpGet: MockFunctions().httpGet,
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
        getNewFood: getFoodFunction,
        barcodeScannerResult: barcodeScannerResult,
      ),
    );

    result.add(JournalRepository(oejDatabase: _database!, getNewQuickEntry: getEatsJournalEntryFunction));

    result.add(
      ConvertValidate(
        languageCode: settingsRepository.languageCode.value,
        energyUnit: settingsRepository.energyUnit,
        heightUnit: settingsRepository.heightUnit,
        weightUnit: settingsRepository.weightUnit,
        volumeUnit: settingsRepository.volumeUnit,
      ),
    );

    return result;
  }

  testWidgets("Adding and loading quick entry", (tester) async {
    DateTime entryDateValue = DateTime.utc(2026, 02, 12);
    Meal mealValue = Meal.dinner;

    EatsJournalEntry quickEntry = EatsJournalEntry.quick(
      entryDate: entryDateValue,
      name: OpenEatsJournalStrings.emptyString,
      kJoule: NutritionCalculator.kJouleForOnekCal,
      meal: mealValue,
    );

    var responses = [quickEntry];

    var getEatsJournalEntryFunction = MockFunctions().getEatsJournalEntry;
    when(getEatsJournalEntryFunction()).thenAnswer((_) => responses.removeAt(0));

    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await testSetup(today: entryDateValue, getEatsJournalEntryFunction: getEatsJournalEntryFunction);
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    ConvertValidate convert = repositories[3] as ConvertValidate;

    //Adding entry
    String nameValue = "Quick Entry 1";
    int kCalValue = 150;
    double amountValue = 100;
    double fatValue = 90;
    double saturatedFatValue = 80;
    double carbohydratesValue = 70;
    double sugarValue = 60;
    double proteinValue = 50;
    double saltValue = 40;

    OverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
        Provider.value(value: overlayDisplay),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    FinderResult<Element> fabs = find.byType(FloatingActionButton).evaluate();
    FloatingActionButton fab;

    for (Element element in fabs) {
      fab = element.widget as FloatingActionButton;
      if (fab.heroTag == "2") {
        await tester.tap(find.byWidgetPredicate((widgetInternal) => widgetInternal == fab));
      }
    }

    await tester.pumpAndSettle();

    FinderResult<Element> textFields = find.byType(OpenEatsJournalTextField).evaluate();
    OpenEatsJournalTextField openEatsJournalTextField;

    int textFieldIndex = 0;
    for (Element textFieldElement in textFields) {
      openEatsJournalTextField = textFieldElement.widget as OpenEatsJournalTextField;

      //name
      if (textFieldIndex == 0) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), nameValue);
      }

      //kCal
      if (textFieldIndex == 1) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$kCalValue");
      }

      //amount
      if (textFieldIndex == 2) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$amountValue");
      }

      //fat
      if (textFieldIndex == 3) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$fatValue");
      }

      //sat fat
      if (textFieldIndex == 4) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$saturatedFatValue");
      }

      //carbos
      if (textFieldIndex == 5) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$carbohydratesValue");
      }

      //sugar
      if (textFieldIndex == 6) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$sugarValue");
      }

      //protein
      if (textFieldIndex == 7) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$proteinValue");
      }

      //salt
      if (textFieldIndex == 8) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$saltValue");
      }

      textFieldIndex++;
    }

    await tester.tap(find.text("g"));

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(quickEntry.id, isNotNull);

    //Loading entry
    //Icon is behind button because of stack layout, so it is missed
    await tester.tap(find.byIcon(Icons.restaurant), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text("QCK"));
    await tester.pumpAndSettle();

    textFields = find.byType(OpenEatsJournalTextField).evaluate();
    textFieldIndex = 0;
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
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: fatValue));
      }

      if (textFieldIndex == 4) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: saturatedFatValue));
      }

      if (textFieldIndex == 5) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: carbohydratesValue));
      }

      if (textFieldIndex == 6) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString1DecimalDigit(doubleValue: sugarValue));
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
    DateTime today = DateTime.utc(2026, 3, 18);
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await testSetup(today: today);
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
    Finder dropdownSelectedValueFinder = find.text("Energy");
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
      return await testSetup();
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
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: fatValue));
      }

      if (textFieldIndex == 7) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: saturatedFatValue));
      }

      if (textFieldIndex == 8) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: carbohydratesValue));
      }

      if (textFieldIndex == 9) {
        expect(openEatsJournalTextField.controller!.text, convert.getCleanDoubleString3DecimalDigits(doubleValue: sugarValue));
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

  testWidgets("Display units and language change", (tester) async {
    DateTime today = DateTime.utc(2026, 2, 11);
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await testSetup(today: today);
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    MockOverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
        Provider<OverlayDisplay>.value(value: overlayDisplay),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text("kCal"), findsAny);
    expect(find.textContaining("kg"), findsAny);
    expect(find.text("kJoule"), findsNothing);
    expect(find.textContaining("lb"), findsNothing);

    //Icon is behind button because of stack layout, so it is missed
    await tester.tap(find.byIcon(Icons.restaurant), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r"^\d+\.?\d*ml$")), findsAny);
    expect(find.textContaining(RegExp(r"^\d+\.?\d*g$")), findsAny);
    expect(find.textContaining(RegExp(r"^\d+\.?\d*fl oz (GB)$")), findsNothing);
    expect(find.textContaining(RegExp(r"^\d+\.?\d*oz$")), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text("App"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("German"));
    await tester.pumpAndSettle();

    //on home screen again after translation, settings dialog closed
    //continue with unit values in German
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text("App"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("kJoule"));
    await tester.ensureVisible(find.text("Daten exportieren"));
    await tester.tap(find.text("Zoll"));
    await tester.tap(find.text("Oz"));
    await tester.tap(find.text("Fl Oz (GB)"));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text("kCal"), findsNothing);
    expect(find.textContaining("kg"), findsNothing);
    expect(find.text("kJoule"), findsAny);
    expect(find.textContaining("lb"), findsAny);

    //Icon is behind button because of stack layout, so it is missed
    await tester.tap(find.byIcon(Icons.restaurant), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r"^\d+,?\d*ml$")), findsNothing);
    expect(find.textContaining(RegExp(r"^\d+,?\d*g$")), findsNothing);
    expect(find.textContaining(RegExp(r"^\d+,?\d*Fl Oz \(GB\)$")), findsAny);
    expect(find.textContaining(RegExp(r"^\d+,?\d*Oz$")), findsAny);
  });

  testWidgets("Add and load food", (tester) async {
    Food food = Food(
      name: OpenEatsJournalStrings.emptyString,
      foodSource: FoodSource.user,
      fromDb: true,
      kJoule: NutritionCalculator.kJouleForOnekCal,
      nutritionPerGramAmount: 100,
    );

    var responses = [food];

    var getFoodFunction = MockFunctions().getFood;
    when(getFoodFunction()).thenAnswer((_) => responses.removeAt(0));

    String barcodeScannerResult = "1234567890123";
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await testSetup(getFoodFunction: getFoodFunction, barcodeScannerResult: barcodeScannerResult);
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    ConvertValidate convert = repositories[3] as ConvertValidate;

    //Adding food
    String nameValue = "Food 1";
    String brandsValue = "Brand 1, Brand 2";
    int kCalValue = 150;
    double fatValue = 90;
    double saturatedFatValue = 80;
    double carbohydratesValue = 70;
    double sugarValue = 60;
    double proteinValue = 50;
    double saltValue = 40;

    OverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
        Provider.value(value: overlayDisplay),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    FinderResult<Element> fabs = find.byType(FloatingActionButton).evaluate();
    FloatingActionButton fab;

    for (Element element in fabs) {
      fab = element.widget as FloatingActionButton;
      if (fab.heroTag == "3") {
        await tester.tap(find.byWidgetPredicate((widgetInternal) => widgetInternal == fab));
      }
    }

    await tester.pumpAndSettle();

    FinderResult<Element> textFields = find.byType(OpenEatsJournalTextField).evaluate();
    OpenEatsJournalTextField openEatsJournalTextField;

    int textFieldIndex = 0;
    for (Element textFieldElement in textFields) {
      openEatsJournalTextField = textFieldElement.widget as OpenEatsJournalTextField;

      //name
      if (textFieldIndex == 0) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), nameValue);
      }

      //brands
      if (textFieldIndex == 2) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), brandsValue);
      }

      //kCal
      if (textFieldIndex == 5) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$kCalValue");
      }

      //fat
      if (textFieldIndex == 6) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$fatValue");
      }

      //sat fat
      if (textFieldIndex == 7) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$saturatedFatValue");
      }

      //carbos
      if (textFieldIndex == 8) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$carbohydratesValue");
      }

      //sugar
      if (textFieldIndex == 9) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$sugarValue");
      }

      //protein
      if (textFieldIndex == 10) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$proteinValue");
      }

      //salt
      if (textFieldIndex == 11) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "$saltValue");
      }

      textFieldIndex++;
    }

    await tester.ensureVisible(find.byIcon(Icons.qr_code_scanner));
    await tester.tap(find.byIcon(Icons.qr_code_scanner));

    expect((textFields.elementAt(1).widget as OpenEatsJournalTextField).controller!.text, barcodeScannerResult);

    await tester.ensureVisible(find.text("Create"));
    await tester.tap(find.text("Create"));

    await tester.pumpAndSettle();

    expect(food.id, isNotNull);

    //Loading food
    await tester.tap(find.byIcon(Icons.lunch_dining));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Offline"));
    await tester.pumpAndSettle();

    textFields = find.byType(OpenEatsJournalTextField).evaluate();
    openEatsJournalTextField = textFields.elementAt(0).widget as OpenEatsJournalTextField;

    await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), nameValue);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Edit"));
    await tester.pumpAndSettle();

    textFields = find.byType(OpenEatsJournalTextField).evaluate();
    textFieldIndex = 0;
    for (Element textFieldElement in textFields) {
      openEatsJournalTextField = textFieldElement.widget as OpenEatsJournalTextField;

      //name
      if (textFieldIndex == 0) {
        expect(openEatsJournalTextField.controller!.text, nameValue);
      }

      //brands
      if (textFieldIndex == 2) {
        expect(openEatsJournalTextField.controller!.text, brandsValue);
      }

      //kCal
      if (textFieldIndex == 5) {
        expect(openEatsJournalTextField.controller!.text, "$kCalValue");
      }

      //fat
      if (textFieldIndex == 6) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: fatValue),
        );
      }

      //sat fat
      if (textFieldIndex == 7) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: saturatedFatValue),
        );
      }

      //carbos
      if (textFieldIndex == 8) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: carbohydratesValue),
        );
      }

      //sugar
      if (textFieldIndex == 9) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: sugarValue),
        );
      }

      //protein
      if (textFieldIndex == 10) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: proteinValue),
        );
      }

      //salt
      if (textFieldIndex == 11) {
        await tester.enterText(
          find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField),
          convert.getCleanDoubleString3DecimalDigits(doubleValue: saltValue),
        );
      }

      textFieldIndex++;
    }
  });

  testWidgets("Daily calories editor", (tester) async {
    DateTime today = DateTime.utc(2026, 2, 11);
    //without runAsync openDatabase will hang.
    List<Object> repositories = (await tester.runAsync<List<Object>>(() async {
      return await testSetup(today: today);
    }))!;

    SettingsRepository settingsRepository = repositories[0] as SettingsRepository;
    FoodRepository foodRepository = repositories[1] as FoodRepository;
    JournalRepository journalRepository = repositories[2] as JournalRepository;
    MockOverlayDisplay overlayDisplay = MockOverlayDisplay();

    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
        Provider<OverlayDisplay>.value(value: overlayDisplay),
      ],
      child: OpenEatsJournalApp(),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    //existing average daily target
    expect(find.text("2,150kCal"), findsAny);

    FinderResult<Element> textFields = find.byType(OpenEatsJournalTextField).evaluate();
    OpenEatsJournalTextField openEatsJournalTextField;

    int textFieldIndex = 0;

    textFieldIndex = 0;
    for (Element textFieldElement in textFields) {
      openEatsJournalTextField = textFieldElement.widget as OpenEatsJournalTextField;

      //monday target
      if (textFieldIndex == 3) {
        await tester.enterText(find.byWidgetPredicate((widgetInternal) => widgetInternal == openEatsJournalTextField), "2100");
      }

      textFieldIndex++;
    }

    await tester.pump();

    //new average daily target
    expect(find.text("2,164kCal"), findsAny);

    //wait for the debouncer timer to end, otherwise we get a pending timers exception at the end..
    await tester.pump(const Duration(milliseconds: 550));
  });
}

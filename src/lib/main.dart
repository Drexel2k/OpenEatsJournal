import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart" as http show get;
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_app_viewmodel.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";

//for debugPaintSizeEnabled=true;
//import "package:flutter/rendering.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:provider/provider.dart";

void main() async {
  //required for database initialization
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(OpenEatsJournalStrings.en);

  ErrorWidget.builder = ErrorHandlers.errorWidget;
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.presentError(details);
    ErrorHandlers.showException(error: details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandlers.showException(error: error, stackTrace: stack);
    return true;
  };

  OpenEatsJournalDatabaseService openEatsJournalDatabaseService = OpenEatsJournalDatabaseService();
  SettingsRepository settingsRepository = SettingsRepository(oejDatabase: openEatsJournalDatabaseService);
  OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService();
  OpenFoodFactsService openFoodFactsService = OpenFoodFactsService(
    httpGet: http.get,
    appName: settingsRepository.appName,
    appVersion: settingsRepository.appVersion,
    appContactMail: settingsRepository.appContactMail!,
  );

  FoodRepository foodRepository = FoodRepository(
    settingsRepository: settingsRepository,
    openFoodFactsService: openFoodFactsService,
    oejDatabaseService: openEatsJournalDatabaseService,
    oejAssetsService: openEatsJournalAssetsService,
  );

  JournalRepository journalRepository = JournalRepository(oejDatabase: openEatsJournalDatabaseService);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //debugPaintSizeEnabled=true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>.value(value: settingsRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<JournalRepository>.value(value: journalRepository),
        ChangeNotifierProvider(
          create: (context) => OpenEatsJournalAppViewModel(settingsRepository: settingsRepository, foodRepository: foodRepository),
        ),
      ],
      child: OpenEatsJournalApp(),
    ),
  );
}

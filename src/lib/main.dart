import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart" as http show get;
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
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:provider/provider.dart";

void main() {
  //required for database initialization
  WidgetsFlutterBinding.ensureInitialized();

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

  final Repositories repositories = Repositories(
    settingsRepository: settingsRepository,
    foodRepository: FoodRepository(
      settingsRepository: settingsRepository,
      openFoodFactsService: openFoodFactsService,
      oejDatabaseService: openEatsJournalDatabaseService,
      oejAssetsService: openEatsJournalAssetsService,
    ),
    journalRepository: JournalRepository(oejDatabase: openEatsJournalDatabaseService),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //debugPaintSizeEnabled=true;

  runApp(
    Provider<Repositories>(
      create: (context) => repositories,
      child: OpenEatsJournalApp(
        openEatsJournalAppViewModel: OpenEatsJournalAppViewModel(
          settingsRepository: repositories.settingsRepository,
          foodRepository: repositories.foodRepository,
        ),
        repositories: repositories,
      ),
    ),
  );
}

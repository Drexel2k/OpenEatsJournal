import "dart:ui";
import "package:flutter/material.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
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

void main() {
  ErrorWidget.builder = ErrorHandlers.errorWidget;

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandlers.showException(error: error, stackTrace: stack);
    return true;
  };

  final OpenEatsJournalDatabaseService oejDatabase = OpenEatsJournalDatabaseService.instance;
  final OpenFoodFactsService openFoodFactsService = OpenFoodFactsService.instance;
  final OpenEatsJournalAssetsService openEatsJournalAssetsService = OpenEatsJournalAssetsService.instance;

  final Repositories repositories = Repositories(
    settingsRepository: SettingsRepository.instance,
    foodRepository: FoodRepository.instance,
    journalRepository: JournalRepository.instance,
  );

  repositories.settingsRepository.init(oejDatabase: oejDatabase);

  openFoodFactsService.init(
    appName: repositories.settingsRepository.appName,
    appVersion: repositories.settingsRepository.appVersion,
    appContactMail: repositories.settingsRepository.appContactMail!,
    useStaging: repositories.settingsRepository.useStagingServices,
  );

  repositories.journalRepository.init(oejDatabase: oejDatabase);
  repositories.foodRepository.init(openFoodFactsService: openFoodFactsService, oejDatabaseService: oejDatabase, oejAssetsService: openEatsJournalAssetsService);

  //required for database initialization
  WidgetsFlutterBinding.ensureInitialized();

  //debugPaintSizeEnabled=true;

  runApp(
    OpenEatsJournalApp(
      openEatsJournalAppViewModel: OpenEatsJournalAppViewModel(
        settingsRepository: repositories.settingsRepository,
        foodRepository: repositories.foodRepository,
      ),
      repositories: repositories,
    ),
  );
}

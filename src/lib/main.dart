import "dart:ui";

import "package:flutter/material.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";

//for debugPaintSizeEnabled=true;
//import "package:flutter/rendering.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";

Future<void> main() async {
  ErrorWidget.builder = ErrorHandlers.errorWidget;
  PlatformDispatcher.instance.onError = (error, stack) {
    throw error;
  };

  final OpenEatsJournalDatabaseService oejDatabase = OpenEatsJournalDatabaseService.instance;
  final OpenFoodFactsService openFoodFactsService = OpenFoodFactsService.instance;

  final Repositories repositories = Repositories(
    settingsRepository: SettingsRepository.instance,
    weightRepository: JournalRepository.instance,
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

  repositories.weightRepository.init(oejDatabase: oejDatabase);
  repositories.foodRepository.init(openFoodFactsService: openFoodFactsService, oejDatabase: oejDatabase);

  WidgetsFlutterBinding.ensureInitialized();
  await repositories.settingsRepository.initSettings();

  //debugPaintSizeEnabled=true;

  runApp(
    OpenEatsJournalApp(
      openEatsJournalAppViewModel: OpenEatsJournalAppViewModel(settingsRepository: repositories.settingsRepository),
      repositories: repositories,
    ),
  );
}

import "dart:ui";

import "package:flutter/material.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/service/database/oej_database_service.dart";
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

  final OejDatabaseService oejDatabase = OejDatabaseService.instance;
  final OpenFoodFactsService openFoodFactsService = OpenFoodFactsService.instance;

  final Repositories repositories = Repositories(
    settingsRepository: SettingsRepository.instance,
    weightRepository: WeightRepository.instance,
    foodRepository: FoodRepository.instance,
  );

  repositories.settingsRepository.init(oejDatabase: oejDatabase);

  openFoodFactsService.init(
    appName: repositories.settingsRepository.appName,
    appVersion: repositories.settingsRepository.appVersion,
    appContactMail: repositories.settingsRepository.appContactMail!,
    useStaging: repositories.settingsRepository.useStagingServices,
  );

  repositories.weightRepository.init(oejDatabase: oejDatabase);
  repositories.foodRepository.init(openFoodFactsService: openFoodFactsService);

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

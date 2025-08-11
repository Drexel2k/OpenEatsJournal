import "package:flutter/material.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/service/oej_database_service.dart";

//for debugPaintSizeEnabled=true;
//import "package:flutter/rendering.dart";
import "package:openeatsjournal/ui/repositories.dart";

Future<void> main() async {
  final OejDatabaseService oejDatabase = OejDatabaseService.instance;
  final Repositories repositories = Repositories(
    settingsRepository: SettingsRepository.instance,
    weightRepository: WeightRepository.instance);

  repositories.settingsRepository.setOejDatabase(oejDatabase);
  repositories.weightRepository.setOejDatabase(oejDatabase);

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
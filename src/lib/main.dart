import "package:flutter/material.dart";
import "package:openeatsjournal/open_eats_journal_app.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/service/oej_database_service.dart";

Future<void> main() async {
  final OejDatabaseService oejDatabase = OejDatabaseService.instance;
  final SettingsRepositoy settingsRepositoy = SettingsRepositoy.instance;
  final WeightRepositoy weightRepository = WeightRepositoy.instance;

  settingsRepositoy.setOejDatabase(oejDatabase);
  weightRepository.setOejDatabase(oejDatabase);

  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled=true;
  await settingsRepositoy.initSettings();

  runApp(
    OpenEatsJournalApp(
      openEatsJournalAppViewModel: OpenEatsJournalAppViewModel(settingsRepository: settingsRepositoy),
      settingsRepositoy: settingsRepositoy,
      weightRepository: weightRepository
    ),
  );
}
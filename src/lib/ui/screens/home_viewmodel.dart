import "package:flutter/foundation.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required SettingsRepository settingsRepository}) : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  String get languageCode => _settingsRepository.languageCode.value;
}

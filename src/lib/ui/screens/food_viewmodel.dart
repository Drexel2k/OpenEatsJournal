import "package:flutter/foundation.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class FoodViewModel extends ChangeNotifier {
  FoodViewModel({required SettingsRepository settingsRepository}) : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  String get appName => _settingsRepository.appName;
  String get appVersion => _settingsRepository.appVersion;
  String get appContactMail => _settingsRepository.appContactMail;
}

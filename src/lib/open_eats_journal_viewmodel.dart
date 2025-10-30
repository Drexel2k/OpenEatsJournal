import "package:flutter/material.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository {
    _settingsRepository.darkMode.addListener(_settingsDarkModeChanged);
    _settingsRepository.languageCode.addListener(_settingsLanguageCodeChanged);
  }

  final SettingsRepository _settingsRepository;
  final ExternalTriggerChangedNotifier _darkModeOrLanguageCodeChanged =  ExternalTriggerChangedNotifier();

  set darkMode(bool value) => _settingsRepository.darkMode.value = value;
  set languageCode(String value) => _settingsRepository.languageCode.value = value;

  bool get initialized => _settingsRepository.initialized.value;
  bool get darkMode => _settingsRepository.darkMode.value;
  String get languageCode => _settingsRepository.languageCode.value;
  ExternalTriggerChangedNotifier get darkModeOrLanguageCodeChanged => _darkModeOrLanguageCodeChanged;

  void _settingsDarkModeChanged() {
    _darkModeOrLanguageCodeChanged.notify();
  }

  void _settingsLanguageCodeChanged() {
    _darkModeOrLanguageCodeChanged.notify();
  }

  @override
  void dispose() {
    _darkModeOrLanguageCodeChanged.dispose();

    super.dispose();
  }
}

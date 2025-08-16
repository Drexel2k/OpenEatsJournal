import "package:flutter/material.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({
      required SettingsRepository settingsRepository
    }) :
    _settingsRepository = settingsRepository,
    _darkModeOrLanguageCodeChanged = DarkModeOrLanguageCodeChangedNotifier() {
      _settingsRepository.darkMode.addListener(_settingsDarkModeChanged);
      _settingsRepository.languageCode.addListener(_settingsLanguageCodeChanged);
  }

  final SettingsRepository _settingsRepository;
  final DarkModeOrLanguageCodeChangedNotifier _darkModeOrLanguageCodeChanged;

  set darkMode(bool value) => _settingsRepository.darkMode.value = value;
  set languageCode(String value) => _settingsRepository.languageCode.value = value;

  bool get initialized => _settingsRepository.initialized.value;
  bool get darkMode => _settingsRepository.darkMode.value;
  String get languageCode => _settingsRepository.languageCode.value;
  DarkModeOrLanguageCodeChangedNotifier get darkModeOrLanguageCodeChanged => _darkModeOrLanguageCodeChanged;

  _settingsDarkModeChanged() {
    _darkModeOrLanguageCodeChanged.notify();
  }

  _settingsLanguageCodeChanged() {
    _darkModeOrLanguageCodeChanged.notify();
  }

  @override
  void dispose() {
    _darkModeOrLanguageCodeChanged.dispose();

    super.dispose();
  }
}

class DarkModeOrLanguageCodeChangedNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
import "package:flutter/material.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({
      required SettingsRepository settingsRepository
    }) :
    _settingsRepository = settingsRepository,
    _initialized = ValueNotifier(settingsRepository.initialized.value),
    _darkMode = ValueNotifier(settingsRepository.darkMode.value),
    _languageCode = ValueNotifier(settingsRepository.languageCode.value) {
      _settingsRepository.initialized.addListener(_initializedChanged);

      _settingsRepository.darkMode.addListener(_settinbsDarkModeChanged);
      _settingsRepository.languageCode.addListener(_settingsLanguageCodeChanged);
      _languageCode.addListener(_languageCodeChanged);
  }

  final SettingsRepository _settingsRepository;
  final ValueNotifier<bool> _initialized;
  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<String> _languageCode;

  ValueNotifier<bool> get initialized => _initialized;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;


  void _initializedChanged() {
    _initialized.value = _settingsRepository.initialized.value;
  }

  _settinbsDarkModeChanged() {
    _darkMode.value = _settingsRepository.darkMode.value;
  }

  _settingsLanguageCodeChanged() {
    _languageCode.value = _settingsRepository.languageCode.value;
  }

  _languageCodeChanged() {
    _settingsRepository.languageCode.value = _languageCode.value;
  }

  @override
  void dispose() {
    _darkMode.dispose();

    super.dispose();
  }
}
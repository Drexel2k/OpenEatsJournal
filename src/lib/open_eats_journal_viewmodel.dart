import "package:flutter/material.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({
      required SettingsRepositoy settingsRepository
    }) :
    _settingsRepository = settingsRepository,
    _initialized = ValueNotifier(settingsRepository.initialized.value),
    _darkMode = ValueNotifier(settingsRepository.darkMode.value),
    _scaffoldTitle = ValueNotifier("") {
      _settingsRepository.initialized.addListener(_initializedChanged);
      _settingsRepository.scaffoldTitle.addListener(_scaffoldTitleChanged);
      _settingsRepository.darkMode.addListener(_darkModeChanged);
  }

  final SettingsRepositoy _settingsRepository;
  final ValueNotifier<bool> _initialized;
  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<String> _scaffoldTitle;

  ValueNotifier<bool> get initialized => _initialized;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get scaffoldTitle => _scaffoldTitle;
  bool get showScaffoldLeadingAction => _settingsRepository.showScaffoldLeadingAction;
  Function()? get scaffoldLeadingAction => _settingsRepository.scaffoldLeadingAction;

  void _initializedChanged() {
    _initialized.value = _settingsRepository.initialized.value;
  }

  _darkModeChanged() {
    _darkMode.value = _settingsRepository.darkMode.value;
  }

  void _scaffoldTitleChanged() {
    _scaffoldTitle.value = _settingsRepository.scaffoldTitle.value;
  }

  @override
  void dispose() {
    _darkMode.dispose();
    _scaffoldTitle.dispose();

    super.dispose();
  }
}
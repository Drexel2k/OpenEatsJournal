import "package:flutter/material.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({required SettingsRepository settingsRepository, required FoodRepository foodRepository})
    : _settingsRepository = settingsRepository,
      _foodRepository = foodRepository,
      _settingsLoaded = settingsRepository.initSettings() {
    _settingsRepository.darkMode.addListener(_settingsDarkModeChanged);
    _settingsRepository.languageCode.addListener(_settingsLanguageCodeChanged);
  }

  final SettingsRepository _settingsRepository;
  final FoodRepository _foodRepository;
  final ExternalTriggerChangedNotifier _darkModeOrLanguageCodeChanged = ExternalTriggerChangedNotifier();
  final Future<void> _settingsLoaded;
  Future<DateTime>? _dataInitialized;

  set darkMode(bool value) => _settingsRepository.darkMode.value = value;
  set languageCode(String value) => _settingsRepository.languageCode.value = value;

  bool get onboarded => _settingsRepository.onboarded.value;
  bool get darkMode => _settingsRepository.darkMode.value;
  String get languageCode => _settingsRepository.languageCode.value;
  ExternalTriggerChangedNotifier get darkModeOrLanguageCodeChanged => _darkModeOrLanguageCodeChanged;
  Future<void> get settingsLoaded => _settingsLoaded;
  Future<DateTime>? get dataInitialized => _dataInitialized;

  void _settingsDarkModeChanged() {
    _darkModeOrLanguageCodeChanged.notify();
  }

  void _settingsLanguageCodeChanged() {
    _dataInitialized = _foodRepository.initializeStandardFoodDataChangeDate(languageCode: _settingsRepository.languageCode.value);
    _darkModeOrLanguageCodeChanged.notify();
  }

  Future<void> initStandardFoodData() async {
    _dataInitialized ??= _foodRepository.initializeStandardFoodDataChangeDate(
      languageCode: _settingsRepository.languageCode.value,
      lastProcessedStandardFoodDataChangeDate: _settingsRepository.lastProcessedStandardFoodDataChangeDate,
    );
  }

  Future<void> saveLastProcessedStandardFoodDataDate(DateTime date) async {
    await _settingsRepository.saveLastProcessedStandardFoodDataChangeDate(date: date);
  }

  @override
  void dispose() {
    _darkModeOrLanguageCodeChanged.dispose();

    super.dispose();
  }
}

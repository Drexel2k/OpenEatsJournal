import "package:flutter/material.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class OpenEatsJournalAppViewModel extends ChangeNotifier {
  OpenEatsJournalAppViewModel({required SettingsRepository settingsRepository, required FoodRepository foodRepository})
    : _settingsRepository = settingsRepository,
      _foodRepository = foodRepository,
      //need to call initializeDateFormatting before first time calling ConvertValidate.init()
      _settingsLoaded = Future.wait([initializeDateFormatting(OpenEatsJournalStrings.en), settingsRepository.initSettings()]);

  final SettingsRepository _settingsRepository;
  final FoodRepository _foodRepository;
  //for everything which changes MaterialApp property
  final ExternalTriggerChangedNotifier _appWideSettingChanged = ExternalTriggerChangedNotifier();
  final Future<void> _settingsLoaded;
  Future<DateTime>? _dataInitialized;

  set darkMode(bool value) => _settingsRepository.darkMode.value = value;
  set languageCode(String value) => _settingsRepository.languageCode.value = value;

  bool get onboarded => _settingsRepository.onboarded.value;
  bool get darkMode => _settingsRepository.darkMode.value;
  String get languageCode => _settingsRepository.languageCode.value;
  ExternalTriggerChangedNotifier get appWideSettingChanged => _appWideSettingChanged;
  Future<void> get settingsLoaded => _settingsLoaded;
  Future<DateTime>? get dataInitialized => _dataInitialized;

  EnergyUnit get energyUnit => _settingsRepository.energyUnit;
  HeightUnit get heightUnit => _settingsRepository.heightUnit;
  WeightUnit get weightUnit => _settingsRepository.weightUnit;
  VolumeUnit get volumeUnit => _settingsRepository.volumeUnit;

  //During app startup listeners can't be set always, on first app startup they must be regesitered after onboarding, otherwise there may be timing issues
  //during navigation from onboarding to the home screen. Changing darkmode e.g. triggers rebuild of the main widget and the context and state of the
  //navigatorKey may be null, that that will fail the navigation.
  void startListening() {
    _settingsRepository.darkMode.addListener(_notifyAppWideSettingChanged);
    _settingsRepository.languageCode.addListener(_settingsLanguageCodeChanged);
  }

  void _settingsLanguageCodeChanged() {
    _dataInitialized = _foodRepository.initializeStandardFoodData(languageCode: _settingsRepository.languageCode.value);
    ConvertValidate.init(
      languageCode: _settingsRepository.languageCode.value,
      energyUnit: _settingsRepository.energyUnit,
      heightUnit: _settingsRepository.heightUnit,
      weightUnit: _settingsRepository.weightUnit,
      volumeUnit: _settingsRepository.volumeUnit,
    );

    _appWideSettingChanged.notify();
  }

  Future<void> initStandardFoodData({required String languageCode}) async {
    _dataInitialized ??= _foodRepository.initializeStandardFoodData(
      languageCode: languageCode,
      lastProcessedStandardFoodDataChangeDate: _settingsRepository.lastProcessedStandardFoodDataChangeDate,
    );
  }

  void _notifyAppWideSettingChanged() {
    _appWideSettingChanged.notify();
  }

  Future<void> saveLastProcessedStandardFoodDataDate(DateTime date) async {
    await _settingsRepository.saveLastProcessedStandardFoodDataChangeDate(date: date);
  }

  @override
  void dispose() {
    _appWideSettingChanged.dispose();

    super.dispose();
  }
}

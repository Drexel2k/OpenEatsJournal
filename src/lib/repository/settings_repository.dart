import "package:flutter/material.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class SettingsRepository extends ChangeNotifier {
  SettingsRepository._singleton();

  static final SettingsRepository instance = SettingsRepository._singleton();

  late OpenEatsJournalDatabaseService _oejDatabase;

  //persistant settings
  final ValueNotifier<bool> _darkMode = ValueNotifier(false);
  final ValueNotifier<String> _languageCode = ValueNotifier(OpenEatsJournalStrings.en);
  late Gender _gender;
  late DateTime _birthday;
  late double _height;
  late double _activityFactor;
  late WeightTarget _weightTarget;
  late int _kJouleMonday;
  late int _kJouleTuesday;
  late int _kJouleWednesday;
  late int _kJouleThursday;
  late int _kJouleFriday;
  late int _kJouleSaturday;
  late int _kJouleSunday;
  DateTime? _lastProcessedStandardFoodDataChangeDate;
  late HeightUnit _heightUnit;
  late WeightUnit _weightUnit;
  late VolumeUnit _volumeUnit;
  late EnergyUnit _energyUnit;

  set gender(Gender value) {
    _gender = value;
    _saveGender(gender: value);
  }

  set birthday(DateTime value) {
    _birthday = value;
    _saveBirthday(birthday: value);
  }

  set height(double value) {
    _height = value;
    _saveHeight(height: value);
  }

  set activityFactor(double value) {
    _activityFactor = value;
    _saveActivityFactor(activityFactor: value);
  }

  set weightTarget(WeightTarget value) {
    _weightTarget = value;
    _saveWeightTarget(weightTarget: value);
  }

  set energyUnit(EnergyUnit value) {
    _energyUnit = value;
    _saveEnergyUnit(energyUnit: value);
  }

  set heightUnit(HeightUnit value) {
    _heightUnit = value;
    _saveHeightUnit(heightUnit: value);
  }

  set weightUnit(WeightUnit value) {
    _weightUnit = value;
    _saveWeightUnit(weightUnit: value);
  }

  set volumeUnit(VolumeUnit value) {
    _volumeUnit = value;
    _saveVolumeUnit(volumeUnit: value);
  }

  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  Gender get gender => _gender;
  DateTime get birthday => _birthday;
  double get height => _height;
  double get activityFactor => _activityFactor;
  WeightTarget get weightTarget => _weightTarget;
  int get kJouleMonday => _kJouleMonday;
  int get kJouleTuesday => _kJouleTuesday;
  int get kJouleWednesday => _kJouleWednesday;
  int get kJouleThursday => _kJouleThursday;
  int get kJouleFriday => _kJouleFriday;
  int get kJouleSaturday => _kJouleSaturday;
  int get kJouleSunday => _kJouleSunday;
  DateTime? get lastProcessedStandardFoodDataChangeDate => _lastProcessedStandardFoodDataChangeDate;
  EnergyUnit get energyUnit => _energyUnit;
  HeightUnit get heightUnit => _heightUnit;
  WeightUnit get weightUnit => _weightUnit;
  VolumeUnit get volumeUnit => _volumeUnit;

  //non persistand app wide settings
  final ValueNotifier<bool> _onboarded = ValueNotifier(false);
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateUtils.dateOnly(DateTime.now()));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  ValueNotifier<bool> get onboarded => _onboarded;
  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  String get appName => "OpenEatsJournal";
  String get appVersion => "1.0 RC4";
  bool get useStagingServices => true;
  //Data required, but shall not be in the repo...
  String? get appContactMail => null;
  String? get contactData => null;

  //must be called once before the singleton is used
  void init({required OpenEatsJournalDatabaseService oejDatabase}) {
    _oejDatabase = oejDatabase;
  }

  Future<void> initSettings() async {
    Map<String, Object?> settingData = await _oejDatabase.getAllSettings();

    int? gender = settingData[OpenEatsJournalStrings.settingGender] as int?;
    int? weightTarget = settingData[OpenEatsJournalStrings.settingWeightTarget] as int?;
    int? energyUnit = settingData[OpenEatsJournalStrings.settingEnergyUnit] as int?;
    int? heightUnit = settingData[OpenEatsJournalStrings.settingHeightUnit] as int?;
    int? weightUnit = settingData[OpenEatsJournalStrings.settingWeightUnit] as int?;
    int? volumeUnit = settingData[OpenEatsJournalStrings.settingVolumeUnit] as int?;

    AllSettings allSettings = AllSettings(
      darkMode: settingData[OpenEatsJournalStrings.settingDarkmode] as bool?,
      languageCode: settingData[OpenEatsJournalStrings.settingLanguageCode] as String?,
      gender: gender != null ? Gender.getByValue(gender) : null,
      birthday: settingData[OpenEatsJournalStrings.settingBirthday] as DateTime?,
      height: settingData[OpenEatsJournalStrings.settingHeight] as double?,
      activityFactor: settingData[OpenEatsJournalStrings.settingActivityFactor] as double?,
      weightTarget: weightTarget != null ? WeightTarget.getByValue(weightTarget) : null,
      kJouleMonday: settingData[OpenEatsJournalStrings.settingKJouleMonday] as int?,
      kJouleTuesday: settingData[OpenEatsJournalStrings.settingKJouleTuesday] as int?,
      kJouleWednesday: settingData[OpenEatsJournalStrings.settingKJouleWednesday] as int?,
      kJouleThursday: settingData[OpenEatsJournalStrings.settingKJouleThursday] as int?,
      kJouleFriday: settingData[OpenEatsJournalStrings.settingKJouleFriday] as int?,
      kJouleSaturday: settingData[OpenEatsJournalStrings.settingKJouleSaturday] as int?,
      kJouleSunday: settingData[OpenEatsJournalStrings.settingKJouleSunday] as int?,
      lastProcessedStandardFoodDataChangeDate: settingData[OpenEatsJournalStrings.settingLastProcessedStandardFoodDataChangeDate] as DateTime?,
      energyUnit: energyUnit != null ? EnergyUnit.getByValue(energyUnit) : null,
      heightUnit: heightUnit != null ? HeightUnit.getByValue(heightUnit) : null,
      weightUnit: weightUnit != null ? WeightUnit.getByValue(weightUnit) : null,
      volumeUnit: volumeUnit != null ? VolumeUnit.getByValue(volumeUnit) : null,
    );

    if (allSettings.darkMode != null &&
        allSettings.languageCode != null &&
        allSettings.gender != null &&
        allSettings.birthday != null &&
        allSettings.height != null &&
        allSettings.activityFactor != null &&
        allSettings.weightTarget != null &&
        allSettings.kJouleMonday != null &&
        allSettings.kJouleTuesday != null &&
        allSettings.kJouleWednesday != null &&
        allSettings.kJouleThursday != null &&
        allSettings.kJouleFriday != null &&
        allSettings.kJouleSaturday != null &&
        allSettings.kJouleSunday != null &&
        allSettings.energyUnit != null &&
        allSettings.heightUnit != null &&
        allSettings.weightUnit != null &&
        allSettings.volumeUnit != null) {
      _onboarded.value = true;
      _darkMode.value = allSettings.darkMode!;
      _languageCode.value = allSettings.languageCode!;
      _gender = allSettings.gender!;
      _birthday = allSettings.birthday!;
      _height = allSettings.height!;
      _activityFactor = allSettings.activityFactor!;
      _weightTarget = allSettings.weightTarget!;
      _kJouleMonday = allSettings.kJouleMonday!;
      _kJouleTuesday = allSettings.kJouleTuesday!;
      _kJouleWednesday = allSettings.kJouleWednesday!;
      _kJouleThursday = allSettings.kJouleThursday!;
      _kJouleFriday = allSettings.kJouleFriday!;
      _kJouleSaturday = allSettings.kJouleSaturday!;
      _kJouleSunday = allSettings.kJouleSunday!;
      _lastProcessedStandardFoodDataChangeDate = allSettings.lastProcessedStandardFoodDataChangeDate;
      _energyUnit = allSettings.energyUnit!;
      _heightUnit = allSettings.heightUnit!;
      _weightUnit = allSettings.weightUnit!;
      _volumeUnit = allSettings.volumeUnit!;

      //don't need to save when settings were just loaded, there listeners are set only now
      //need saving only when onboarded
      _addListeners();
    }
  }

  //listeners save the value, as the settings edit screen has no save button
  void _addListeners() {
    _darkMode.addListener(_darkModeChanged);
    _languageCode.addListener(_languageCodeChanged);
  }

  Future<void> saveAllOnboardingSettings({required AllSettings settings}) async {
    Map<String, Object> settingData = {
      OpenEatsJournalStrings.settingDarkmode: settings.darkMode!,
      OpenEatsJournalStrings.settingLanguageCode: settings.languageCode!,
      OpenEatsJournalStrings.settingGender: settings.gender!.value,
      OpenEatsJournalStrings.settingBirthday: settings.birthday!,
      OpenEatsJournalStrings.settingHeight: settings.height!,
      OpenEatsJournalStrings.settingActivityFactor: settings.activityFactor!,
      OpenEatsJournalStrings.settingWeightTarget: settings.weightTarget!.value,
      OpenEatsJournalStrings.settingKJouleMonday: settings.kJouleMonday!,
      OpenEatsJournalStrings.settingKJouleTuesday: settings.kJouleTuesday!,
      OpenEatsJournalStrings.settingKJouleWednesday: settings.kJouleWednesday!,
      OpenEatsJournalStrings.settingKJouleThursday: settings.kJouleThursday!,
      OpenEatsJournalStrings.settingKJouleFriday: settings.kJouleFriday!,
      OpenEatsJournalStrings.settingKJouleSaturday: settings.kJouleSaturday!,
      OpenEatsJournalStrings.settingKJouleSunday: settings.kJouleSunday!,
      OpenEatsJournalStrings.settingEnergyUnit: settings.energyUnit!.value,
      OpenEatsJournalStrings.settingHeightUnit: settings.heightUnit!.value,
      OpenEatsJournalStrings.settingWeightUnit: settings.weightUnit!.value,
      OpenEatsJournalStrings.settingVolumeUnit: settings.volumeUnit!.value,
    };

    await _oejDatabase.setSettings(allSettings: settingData);

    _onboarded.value = true;
    _darkMode.value = settings.darkMode!;
    _languageCode.value = settings.languageCode!;
    _gender = settings.gender!;
    _birthday = settings.birthday!;
    _height = settings.height!;
    _activityFactor = settings.activityFactor!;
    _weightTarget = settings.weightTarget!;
    _kJouleMonday = settings.kJouleMonday!;
    _kJouleTuesday = settings.kJouleTuesday!;
    _kJouleWednesday = settings.kJouleWednesday!;
    _kJouleThursday = settings.kJouleThursday!;
    _kJouleFriday = settings.kJouleFriday!;
    _kJouleSaturday = settings.kJouleSaturday!;
    _kJouleSunday = settings.kJouleSunday!;
    _energyUnit = settings.energyUnit!;
    _heightUnit = settings.heightUnit!;
    _weightUnit = settings.weightUnit!;
    _volumeUnit = settings.volumeUnit!;

    //add listeners when onboarding finished
    //need saving only when onboarded
    _addListeners();
  }

  Future<void> _darkModeChanged() async {
    await _oejDatabase.setBoolSetting(setting: OpenEatsJournalStrings.settingDarkmode, value: _darkMode.value);
  }

  Future<void> _languageCodeChanged() async {
    await _oejDatabase.setStringSetting(setting: OpenEatsJournalStrings.settingLanguageCode, value: _languageCode.value);
  }

  Future<void> _saveGender({required Gender gender}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingGender, value: gender.value);
  }

  Future<void> _saveBirthday({required DateTime birthday}) async {
    await _oejDatabase.setDateTimeSetting(setting: OpenEatsJournalStrings.settingBirthday, value: birthday);
  }

  Future<void> _saveHeight({required double height}) async {
    await _oejDatabase.setDoubleSetting(setting: OpenEatsJournalStrings.settingHeight, value: height);
  }

  Future<void> _saveActivityFactor({required double activityFactor}) async {
    await _oejDatabase.setDoubleSetting(setting: OpenEatsJournalStrings.settingActivityFactor, value: activityFactor);
  }

  Future<void> _saveWeightTarget({required WeightTarget weightTarget}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingWeightTarget, value: weightTarget.value);
  }

  Future<void> _saveEnergyUnit({required EnergyUnit energyUnit}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingEnergyUnit, value: energyUnit.value);
  }

  Future<void> _saveHeightUnit({required HeightUnit heightUnit}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingHeightUnit, value: heightUnit.value);
  }

  Future<void> _saveWeightUnit({required WeightUnit weightUnit}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingWeightUnit, value: weightUnit.value);
  }

  Future<void> _saveVolumeUnit({required VolumeUnit volumeUnit}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingVolumeUnit, value: volumeUnit.value);
  }

  Future<void> saveKJouleMonday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleMonday, value: kJoule);
    _kJouleMonday = kJoule;
  }

  Future<void> saveKJouleTuesday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleTuesday, value: kJoule);
    _kJouleTuesday = kJoule;
  }

  Future<void> saveKJouleWednesday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleWednesday, value: kJoule);
    _kJouleWednesday = kJoule;
  }

  Future<void> saveKJouleThursday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleThursday, value: kJoule);
    _kJouleThursday = kJoule;
  }

  Future<void> saveKJouleFriday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleFriday, value: kJoule);
    _kJouleFriday = kJoule;
  }

  Future<void> saveKJouleSaturday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleSaturday, value: kJoule);
    _kJouleSaturday = kJoule;
  }

  Future<void> saveKJouleSunday({required int kJoule}) async {
    await _oejDatabase.setIntSetting(setting: OpenEatsJournalStrings.settingKJouleSunday, value: kJoule);
    _kJouleSunday = kJoule;
  }

  Future<void> saveDailyKJouleTargetsSame({required int dailyTargetKJoule}) async {
    await saveKJouleMonday(kJoule: dailyTargetKJoule);
    await saveKJouleTuesday(kJoule: dailyTargetKJoule);
    await saveKJouleWednesday(kJoule: dailyTargetKJoule);
    await saveKJouleThursday(kJoule: dailyTargetKJoule);
    await saveKJouleFriday(kJoule: dailyTargetKJoule);
    await saveKJouleSaturday(kJoule: dailyTargetKJoule);
    await saveKJouleSunday(kJoule: dailyTargetKJoule);
  }

  Future<void> saveLastProcessedStandardFoodDataChangeDate({required DateTime date}) async {
    await _oejDatabase.setDateTimeSetting(setting: OpenEatsJournalStrings.settingLastProcessedStandardFoodDataChangeDate, value: date);
    _lastProcessedStandardFoodDataChangeDate = date;
  }

  int getCurrentJournalDayTargetKJoule() {
    return getTargetKJouleForDay(day: currentJournalDate.value);
  }

  int getTargetKJouleForDay({required DateTime day}) {
    int dayTargetKJoule = 0;
    switch (day.weekday) {
      case 1:
        dayTargetKJoule = _kJouleMonday;
      case 2:
        dayTargetKJoule = _kJouleTuesday;
      case 3:
        dayTargetKJoule = _kJouleWednesday;
      case 4:
        dayTargetKJoule = _kJouleThursday;
      case 5:
        dayTargetKJoule = _kJouleFriday;
      case 6:
        dayTargetKJoule = _kJouleSaturday;
      case 7:
        dayTargetKJoule = _kJouleSunday;
      default:
        throw StateError("Unknown weekday ${currentJournalDate.value.weekday}.");
    }

    return dayTargetKJoule;
  }

  Future<bool> exportDatabase() async {
    return await _oejDatabase.exportDatabase();
  }

  Future<bool> importDatabase() async {
    return await _oejDatabase.importDatabase();
  }

  @override
  void dispose() {
    _darkMode.dispose();
    _languageCode.dispose();

    super.dispose();
  }
}

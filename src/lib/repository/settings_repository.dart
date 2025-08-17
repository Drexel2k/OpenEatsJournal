import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/service/oej_database_service.dart";

class SettingsRepository extends ChangeNotifier {
  SettingsRepository._singleton();

  static final SettingsRepository instance = SettingsRepository._singleton();

  late OejDatabaseService _oejDatabase;

  //persistant settings
  final ValueNotifier<bool> _darkMode = ValueNotifier(false);
  final ValueNotifier<String> _languageCode = ValueNotifier("en");
  late Gender _gender;
  late DateTime _birthday;
  late int _height;
  late double _weight;
  late double _activityFactor;
  late WeightTarget _weightTarget;
  late int _kCalsMonday;
  late int _kCalsTuesday;
  late int _kCalsWednesday;
  late int _kCalsThursday;
  late int _kCalsFriday;
  late int _kCalsSaturday;
  late int _kCalsSunday;

  set gender(Gender value) {
    _gender = value;
    _saveGender(value);
  }

  set birthday(value) {
    _birthday = value;
    _saveBirthday(value);
  }

  set height(value)  {
    _height = value;
    _saveHeight(value);
  }

  set weight(value)  {
    _weight = value;
    _saveWeight(value);
  }

  set activityFactor(value)  {
    _activityFactor = value;
    _saveActivityFactor(value);
  }

  set weightTarget(value)  {
    _weightTarget = value;
    _saveWeightTarget(value);
  }

  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get languageCode => _languageCode;
  Gender get gender => _gender;
  DateTime get birthday => _birthday;
  int get height => _height;
  double get weight => _weight;
  double get activityFactor => _activityFactor;
  WeightTarget get weightTarget => _weightTarget;
  int get kCalsMonday => _kCalsMonday;
  int get kCalsTuesday => _kCalsTuesday;
  int get kCalsWednesday => _kCalsWednesday;
  int get kCalsThursday => _kCalsThursday;
  int get kCalsFriday => _kCalsFriday;
  int get kCalsSaturday => _kCalsSaturday;
  int get kCalsSunday => _kCalsSunday;

  //non persistand app wide settings
  final ValueNotifier<bool> _initialized = ValueNotifier(false);

  ValueNotifier<bool> get initialized => _initialized;


  //must be called once before the singleton is used
  void setOejDatabase(OejDatabaseService oejDataBase) {
    _oejDatabase = oejDataBase;
  }

  Future<void> initSettings() async {
    bool? darkModeSetting = await _oejDatabase.getBoolSetting("darkmode");
    if (darkModeSetting != null) {
      _initialized.value = true;
      _darkMode.value = darkModeSetting;
      _languageCode.value = (await _oejDatabase.getStringSetting("language_code"))!;
      _gender = Gender.getByValue((await _oejDatabase.getIntSetting("gender"))!);
      _birthday = (await _oejDatabase.getDateTimeSetting("birthday"))!;
      _height = (await _oejDatabase.getIntSetting("height"))!;
      _weight = (await _oejDatabase.getDoubleSetting("weight"))!;
      _activityFactor = (await _oejDatabase.getDoubleSetting("activity_factor"))!;
      _weightTarget = WeightTarget.getByValue((await _oejDatabase.getIntSetting("weight_target"))!);
      _kCalsMonday = (await _oejDatabase.getIntSetting("kcals_monday"))!;
      _kCalsTuesday = (await _oejDatabase.getIntSetting("kcals_tuesday"))!;
      _kCalsWednesday = (await _oejDatabase.getIntSetting("kcals_wednesday"))!;
      _kCalsThursday = (await _oejDatabase.getIntSetting("kcals_thursday"))!;
      _kCalsFriday = (await _oejDatabase.getIntSetting("kcals_friday"))!;
      _kCalsSaturday = (await _oejDatabase.getIntSetting("kcals_saturday"))!;
      _kCalsSunday = (await _oejDatabase.getIntSetting("kcals_sunday"))!;
    }

    _darkMode.addListener(_darkModeChanged);
    _languageCode.addListener(_languageCodeChanged);
  }

  Future<void> saveAllSettings(AllSettings settings) async {
    await _saveDarkmode(settings.darkMode);
    await _saveLanguageCode(settings.languageCode);
    await _saveGender(settings.gender);
    await _saveBirthday(settings.birthday);
    await _saveHeight(settings.height);
    await _saveWeight(settings.weight);
    await _saveActivityFactor(settings.activityFactor);
    await _saveWeightTarget(settings.weightTarget);
    await _saveKCalsMonday(settings.kCalsMonday);
    await _saveKCalsTuesday(settings.kCalsTuesday);
    await _saveKCalsWednesday(settings.kCalsWednesday);
    await _saveKCalsThursday(settings.kCalsThursday);
    await _saveKCalsFriday(settings.kCalsFriday);
    await _saveKCalsSaturday(settings.kCalsSaturday);
    await _saveKCalsSunday(settings.kCalsSunday);

    _initialized.value = true;
    _darkMode.value = settings.darkMode;
    _gender = settings.gender;
    _birthday = settings.birthday;
    _height = settings.height;
    _weight = settings.weight;
    _activityFactor = settings.activityFactor;
    _weightTarget = settings.weightTarget;
    _kCalsMonday = settings.kCalsMonday;
    _kCalsTuesday = settings.kCalsTuesday;
    _kCalsWednesday = settings.kCalsWednesday;
    _kCalsThursday = settings.kCalsThursday;
    _kCalsFriday = settings.kCalsFriday;
    _kCalsSaturday = settings.kCalsSaturday;
    _kCalsSunday = settings.kCalsSunday;
    _languageCode.value = settings.languageCode;
  }

  Future<void> _saveDarkmode(bool darkMode) async {
    await _oejDatabase.setBoolSetting("darkmode", darkMode);
  }

  Future<void> _saveLanguageCode(String languageCode) async {
    await _oejDatabase.setStringSetting("language_code", languageCode);
  }

  Future<void> _saveGender(Gender gender) async {
    await _oejDatabase.setIntSetting("gender", gender.value);
  }

  Future<void> _saveBirthday(DateTime birthday) async {
    await _oejDatabase.setDateTimeSetting("birthday", birthday);
  }

  Future<void> _saveHeight(int height) async {
    await _oejDatabase.setIntSetting("height", height);
  }

  Future<void> _saveWeight(double weight) async {
    await _oejDatabase.setDoubleSetting("weight", weight);
  }

  Future<void> _saveActivityFactor(double activityFactor) async {
    await _oejDatabase.setDoubleSetting("activity_factor", activityFactor);
  }

  Future<void> _saveWeightTarget(WeightTarget weightTarget) async {
    await _oejDatabase.setIntSetting("weight_target", weightTarget.value);
  }

  Future<void> _saveKCalsMonday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_monday", kCals);
    _kCalsMonday = kCals;
  }

  Future<void> _saveKCalsTuesday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_tuesday", kCals);
    _kCalsTuesday = kCals;
  }

  Future<void> _saveKCalsWednesday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_wednesday", kCals);
    _kCalsWednesday = kCals;
  }

  Future<void> _saveKCalsThursday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_thursday", kCals);
    _kCalsThursday = kCals;
  }

  Future<void> _saveKCalsFriday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_friday", kCals);
    _kCalsFriday = kCals;
  }

  Future<void> _saveKCalsSaturday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_saturday", kCals);
    _kCalsSaturday = kCals;
  }

  Future<void> _saveKCalsSunday(int kCals) async {
    await _oejDatabase.setIntSetting("kcals_sunday", kCals);
    _kCalsSunday = kCals;
  }

  Future<void> _darkModeChanged() async {
    await _oejDatabase.setBoolSetting("darkmode", _darkMode.value);
  }

  Future<void> _languageCodeChanged() async {
    await _oejDatabase.setStringSetting("language_code", _languageCode.value);
  }

  Future<void> saveDailyCaloriesTargetsSame(int dailyTargetCalories) async {
    await _saveKCalsMonday(dailyTargetCalories);
    await _saveKCalsTuesday(dailyTargetCalories);
    await _saveKCalsWednesday(dailyTargetCalories);
    await _saveKCalsThursday(dailyTargetCalories);
    await _saveKCalsFriday(dailyTargetCalories);
    await _saveKCalsSaturday(dailyTargetCalories);
    await _saveKCalsSunday(dailyTargetCalories);
  }

  Future<void> saveDailyCaloriesTargetsSameIndividual(KCalSettings kCalSettings) async {
    await _saveKCalsMonday(kCalSettings.kCalsMonday);
    await _saveKCalsTuesday(kCalSettings.kCalsTuesday);
    await _saveKCalsWednesday(kCalSettings.kCalsWednesday);
    await _saveKCalsThursday(kCalSettings.kCalsThursday);
    await _saveKCalsFriday(kCalSettings.kCalsFriday);
    await _saveKCalsSaturday(kCalSettings.kCalsSaturday);
    await _saveKCalsSunday(kCalSettings.kCalsSunday);
  }

  @override
  void dispose() {
    _darkMode.dispose();
    _languageCode.dispose();

    super.dispose();
  }
}
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/all_settings.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";

class SettingsRepository extends ChangeNotifier {
  SettingsRepository._singleton();

  static final SettingsRepository instance = SettingsRepository._singleton();

  late OpenEatsJournalDatabaseService _oejDatabase;

  //persistant settings
  final ValueNotifier<bool> _darkMode = ValueNotifier(false);
  final ValueNotifier<String> _languageCode = ValueNotifier(OpenEatsJournalStrings.en);
  late Gender _gender;
  late DateTime _birthday;
  late int _height;
  late double _weight;
  late double _activityFactor;
  late WeightTarget _weightTarget;
  late int _kJouleMonday;
  late int _kJouleTuesday;
  late int _kJouleWednesday;
  late int _kJouleThursday;
  late int _kJouleFriday;
  late int _kJouleSaturday;
  late int _kJouleSunday;

  set gender(Gender value) {
    _gender = value;
    _saveGender(value);
  }

  set birthday(value) {
    _birthday = value;
    _saveBirthday(value);
  }

  set height(value) {
    _height = value;
    _saveHeight(value);
  }

  set weight(value) {
    _weight = value;
    _saveWeight(value);
  }

  set activityFactor(value) {
    _activityFactor = value;
    _saveActivityFactor(value);
  }

  set weightTarget(value) {
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
  int get kJouleMonday => _kJouleMonday;
  int get kJouleTuesday => _kJouleTuesday;
  int get kJouleWednesday => _kJouleWednesday;
  int get kJouleThursday => _kJouleThursday;
  int get kJouleFriday => _kJouleFriday;
  int get kJouleSaturday => _kJouleSaturday;
  int get kJouleSunday => _kJouleSunday;

  //non persistand app wide settings
  final ValueNotifier<bool> _initialized = ValueNotifier(false);
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateUtils.dateOnly(DateTime.now()));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  ValueNotifier<bool> get initialized => _initialized;
  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  //Needs to be set for Open Food Facts Api, but shall not be in the repo...
  String? get appContactMail => null;
  String get appName => "OpenEatsJournal";
  String get appVersion => "0.1";
  bool get useStagingServices => true;

  //must be called once before the singleton is used
  void init({required OpenEatsJournalDatabaseService oejDatabase}) {
    _oejDatabase = oejDatabase;
  }

  Future<void> initSettings() async {
    AllSettings allSettings = await _oejDatabase.getAllSettings();

    if (allSettings.darkMode != null &&
        allSettings.languageCode != null &&
        allSettings.gender != null &&
        allSettings.birthday != null &&
        allSettings.height != null &&
        allSettings.weight != null &&
        allSettings.activityFactor != null &&
        allSettings.weightTarget != null &&
        allSettings.kJouleMonday != null &&
        allSettings.kJouleTuesday != null &&
        allSettings.kJouleWednesday != null &&
        allSettings.kJouleThursday != null &&
        allSettings.kJouleFriday != null &&
        allSettings.kJouleSaturday != null &&
        allSettings.kJouleSunday != null) {
      _initialized.value = true;
      _darkMode.value = allSettings.darkMode!;
      _languageCode.value = allSettings.languageCode!;
      _gender = allSettings.gender!;
      _birthday = allSettings.birthday!;
      _height = allSettings.height!;
      _weight = allSettings.weight!;
      _activityFactor = allSettings.activityFactor!;
      _weightTarget = allSettings.weightTarget!;
      _kJouleMonday = allSettings.kJouleMonday!;
      _kJouleTuesday = allSettings.kJouleTuesday!;
      _kJouleWednesday = allSettings.kJouleWednesday!;
      _kJouleThursday = allSettings.kJouleThursday!;
      _kJouleFriday = allSettings.kJouleFriday!;
      _kJouleSaturday = allSettings.kJouleSaturday!;
      _kJouleSunday = allSettings.kJouleSunday!;
    }

    _darkMode.addListener(_darkModeChanged);
    _languageCode.addListener(_languageCodeChanged);
  }

  Future<void> saveAllSettings(AllSettings settings) async {
    await _oejDatabase.setAllSettings(settings);

    _initialized.value = true;
    _darkMode.value = settings.darkMode!;
    _gender = settings.gender!;
    _birthday = settings.birthday!;
    _height = settings.height!;
    _weight = settings.weight!;
    _activityFactor = settings.activityFactor!;
    _weightTarget = settings.weightTarget!;
    _kJouleMonday = settings.kJouleMonday!;
    _kJouleTuesday = settings.kJouleTuesday!;
    _kJouleWednesday = settings.kJouleWednesday!;
    _kJouleThursday = settings.kJouleThursday!;
    _kJouleFriday = settings.kJouleFriday!;
    _kJouleSaturday = settings.kJouleSaturday!;
    _kJouleSunday = settings.kJouleSunday!;
    _languageCode.value = settings.languageCode!;
  }

  Future<void> _darkModeChanged() async {
    await _oejDatabase.setBoolSetting("darkmode", _darkMode.value);
  }

  Future<void> _languageCodeChanged() async {
    await _oejDatabase.setStringSetting("language_code", _languageCode.value);
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

  Future<void> _saveKJouleMonday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleMonday, kJoule);
    _kJouleMonday = kJoule;
  }

  Future<void> _saveKJouleTuesday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleTuesday, kJoule);
    _kJouleTuesday = kJoule;
  }

  Future<void> _saveKJouleWednesday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleWednesday, kJoule);
    _kJouleWednesday = kJoule;
  }

  Future<void> _saveKJouleThursday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleThursday, kJoule);
    _kJouleThursday = kJoule;
  }

  Future<void> _saveKJouleFriday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleFriday, kJoule);
    _kJouleFriday = kJoule;
  }

  Future<void> _saveKJouleSaturday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleSaturday, kJoule);
    _kJouleSaturday = kJoule;
  }

  Future<void> _saveKJouleSunday(int kJoule) async {
    await _oejDatabase.setIntSetting(OpenEatsJournalStrings.settingKJouleSunday, kJoule);
    _kJouleSunday = kJoule;
  }

  Future<void> saveDailyKJouleTargetsSame(int dailyTargetKJoule) async {
    await _saveKJouleMonday(dailyTargetKJoule);
    await _saveKJouleTuesday(dailyTargetKJoule);
    await _saveKJouleWednesday(dailyTargetKJoule);
    await _saveKJouleThursday(dailyTargetKJoule);
    await _saveKJouleFriday(dailyTargetKJoule);
    await _saveKJouleSaturday(dailyTargetKJoule);
    await _saveKJouleSunday(dailyTargetKJoule);
  }

  Future<void> saveDailyKJouleTargetsSameIndividual(KJoulePerDay kJouleSettings) async {
    await _saveKJouleMonday(kJouleSettings.kJouleMonday);
    await _saveKJouleTuesday(kJouleSettings.kJouleTuesday);
    await _saveKJouleWednesday(kJouleSettings.kJouleWednesday);
    await _saveKJouleThursday(kJouleSettings.kJouleThursday);
    await _saveKJouleFriday(kJouleSettings.kJouleFriday);
    await _saveKJouleSaturday(kJouleSettings.kJouleSaturday);
    await _saveKJouleSunday(kJouleSettings.kJouleSunday);
  }

  int getCurrentJournalDayTargetKJoule() {
    int dayTargetKJoule = 0;
    switch (currentJournalDate.value.weekday) {
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

  @override
  void dispose() {
    _darkMode.dispose();
    _languageCode.dispose();

    super.dispose();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:openeatsjournal/domain/settings.dart';
import 'package:openeatsjournal/service/oej_database_service.dart';

class SettingsRepositoy {
  static final SettingsRepositoy instance = SettingsRepositoy._singleton();
  late OejDatabaseService _oejDatabase;

  SettingsRepositoy._singleton();

  late ValueNotifier<bool> darkMode;

  void setOejDatabase(OejDatabaseService oejDataBase) {
    _oejDatabase = oejDataBase;
  }

  Future<bool> initSettings() async {
    bool? darkModeSetting = await _getDarkModeSetting();
    if (darkModeSetting == null) {
      return false;
    }

    darkMode = ValueNotifier(darkModeSetting);
    return true;    
  }

  Future<void> setSettings(Settings settings) async {
    await _oejDatabase.setBoolSetting("darkmode", settings.darkMode);
    await _oejDatabase.setIntSetting("gender", settings.gender.value);
    await _oejDatabase.setDateTimeSetting("birthday", settings.birthday);
    await _oejDatabase.setIntSetting("height", settings.height);
    await _oejDatabase.setDoubleSetting("weight", settings.weight);
    await _oejDatabase.setDoubleSetting("activity_factor", settings.activityFactor);
    await _oejDatabase.setIntSetting("weight_target", settings.weightTarget.value);
    await _oejDatabase.setDoubleSetting("kcals_monday", settings.kCalsMonday);
    await _oejDatabase.setDoubleSetting("kcals_tuesday", settings.kCalsTuesday);
    await _oejDatabase.setDoubleSetting("kcals_wednesday", settings.kCalsWednesday);
    await _oejDatabase.setDoubleSetting("kcals_thursday", settings.kCalsThursday);
    await _oejDatabase.setDoubleSetting("kcals_friday", settings.kCalsFriday);
    await _oejDatabase.setDoubleSetting("kcals_saturday", settings.kCalsSaturday);
    await _oejDatabase.setDoubleSetting("kcals_sunday", settings.kCalsSunday);
  }

  Future<bool?> _getDarkModeSetting() async {
    return await _oejDatabase.getBoolSetting("darkmode");
  }
}
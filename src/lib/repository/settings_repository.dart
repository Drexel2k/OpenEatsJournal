import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/settings.dart";
import "package:openeatsjournal/service/oej_database_service.dart";

class SettingsRepositoy extends ChangeNotifier{
  SettingsRepositoy._singleton() :
    _scaffoldTitle = ValueNotifier("") {
      _scaffoldLeadingAction = _emptyLeadingAction;
  }
    
  static final SettingsRepositoy instance = SettingsRepositoy._singleton();

  late OejDatabaseService _oejDatabase;

  //persistand settings
  final ValueNotifier<bool> _darkMode = ValueNotifier(false);

  //non persistand app wide settings
  final ValueNotifier<bool> _initialized = ValueNotifier(false);
  final ValueNotifier<String> _scaffoldTitle;
  late Function() _scaffoldLeadingAction;

  set scaffoldLeadingAction(Function() action) => _scaffoldLeadingAction = action;

  ValueNotifier<bool> get initialized => _initialized;
  ValueNotifier<bool> get darkMode => _darkMode;
  ValueNotifier<String> get scaffoldTitle => _scaffoldTitle;
  bool get showScaffoldLeadingAction {
    if(_scaffoldLeadingAction == _emptyLeadingAction) {
      return false;
    }

    return true;
  }

  Function() get scaffoldLeadingAction => _scaffoldLeadingAction;

  //must be called once before the singleton is used
  void setOejDatabase(OejDatabaseService oejDataBase) {
    _oejDatabase = oejDataBase;
  }

  Future<void> initSettings() async {
    bool? darkModeSetting = await _getDarkModeSetting();
    if (darkModeSetting != null) {
      _initialized.value = true;
      _darkMode.value = darkModeSetting;
    }  
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

  _emptyLeadingAction(){}

  @override
  void dispose() {
    _darkMode.dispose();
    _scaffoldTitle.dispose();

    super.dispose();
  }
}
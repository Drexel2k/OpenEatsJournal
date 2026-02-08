import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/domain/weight_target.dart";

class AllSettings {
  AllSettings({
    bool? darkMode,
    String? languageCode,
    Gender? gender,
    DateTime? birthday,
    double? height,
    double? activityFactor,
    WeightTarget? weightTarget,
    int? kJouleMonday,
    int? kJouleTuesday,
    int? kJouleWednesday,
    int? kJouleThursday,
    int? kJouleFriday,
    int? kJouleSaturday,
    int? kJouleSunday,
    DateTime? lastProcessedStandardFoodDataChangeDate,
    EnergyUnit? energyUnit,
    HeightUnit? heightUnit,
    WeightUnit? weightUnit,
    VolumeUnit? volumeUnit,
  }) : _darkMode = darkMode,
       _languageCode = languageCode,
       _gender = gender,
       _birthday = birthday,
       _height = height,
       _activityFactor = activityFactor,
       _weightTarget = weightTarget,
       _kJouleMonday = kJouleMonday,
       _kJouleTuesday = kJouleTuesday,
       _kJouleWednesday = kJouleWednesday,
       _kJouleThursday = kJouleThursday,
       _kJouleFriday = kJouleFriday,
       _kJouleSaturday = kJouleSaturday,
       _kJouleSunday = kJouleSunday,
       _lastProcessedStandardFoodDataChangeDate = lastProcessedStandardFoodDataChangeDate,
       _energyUnit = energyUnit,
       _heightUnit = heightUnit,
       _weightUnit = weightUnit,
       _volumeUnit = volumeUnit;

  final bool? _darkMode;
  final String? _languageCode;
  final Gender? _gender;
  final DateTime? _birthday;
  final double? _height;
  final double? _activityFactor;
  final WeightTarget? _weightTarget;
  final int? _kJouleMonday;
  final int? _kJouleTuesday;
  final int? _kJouleWednesday;
  final int? _kJouleThursday;
  final int? _kJouleFriday;
  final int? _kJouleSaturday;
  final int? _kJouleSunday;
  final DateTime? _lastProcessedStandardFoodDataChangeDate;
  final EnergyUnit? _energyUnit;
  final HeightUnit? _heightUnit;
  final WeightUnit? _weightUnit;
  final VolumeUnit? _volumeUnit;

  bool? get darkMode => _darkMode;
  String? get languageCode => _languageCode;
  Gender? get gender => _gender;
  DateTime? get birthday => _birthday;
  double? get height => _height;
  double? get activityFactor => _activityFactor;
  WeightTarget? get weightTarget => _weightTarget;
  int? get kJouleMonday => _kJouleMonday;
  int? get kJouleTuesday => _kJouleTuesday;
  int? get kJouleWednesday => _kJouleWednesday;
  int? get kJouleThursday => _kJouleThursday;
  int? get kJouleFriday => _kJouleFriday;
  int? get kJouleSaturday => _kJouleSaturday;
  int? get kJouleSunday => _kJouleSunday;
  DateTime? get lastProcessedStandardFoodDataChangeDate => _lastProcessedStandardFoodDataChangeDate;
  EnergyUnit? get energyUnit => _energyUnit;
  HeightUnit? get heightUnit => _heightUnit;
  WeightUnit? get weightUnit => _weightUnit;
  VolumeUnit? get volumeUnit => _volumeUnit;
}

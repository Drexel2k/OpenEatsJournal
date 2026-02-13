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
    double? kJouleMonday,
    double? kJouleTuesday,
    double? kJouleWednesday,
    double? kJouleThursday,
    double? kJouleFriday,
    double? kJouleSaturday,
    double? kJouleSunday,
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
  final double? _kJouleMonday;
  final double? _kJouleTuesday;
  final double? _kJouleWednesday;
  final double? _kJouleThursday;
  final double? _kJouleFriday;
  final double? _kJouleSaturday;
  final double? _kJouleSunday;
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
  double? get kJouleMonday => _kJouleMonday;
  double? get kJouleTuesday => _kJouleTuesday;
  double? get kJouleWednesday => _kJouleWednesday;
  double? get kJouleThursday => _kJouleThursday;
  double? get kJouleFriday => _kJouleFriday;
  double? get kJouleSaturday => _kJouleSaturday;
  double? get kJouleSunday => _kJouleSunday;
  DateTime? get lastProcessedStandardFoodDataChangeDate => _lastProcessedStandardFoodDataChangeDate;
  EnergyUnit? get energyUnit => _energyUnit;
  HeightUnit? get heightUnit => _heightUnit;
  WeightUnit? get weightUnit => _weightUnit;
  VolumeUnit? get volumeUnit => _volumeUnit;
}

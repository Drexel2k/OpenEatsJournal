import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/weight_target.dart";

class AllSettings {
  AllSettings({
    bool? darkMode,
    String? languageCode,
    Gender? gender,
    DateTime? birthday,
    int? height,
    double? weight,
    double? activityFactor,
    WeightTarget? weightTarget,
    int? kJouleMonday,
    int? kJouleTuesday,
    int? kJouleWednesday,
    int? kJouleThursday,
    int? kJouleFriday,
    int? kJouleSaturday,
    int? kJouleSunday,
  }) : _darkMode = darkMode,
       _languageCode = languageCode,
       _gender = gender,
       _birthday = birthday,
       _height = height,
       _weight = weight,
       _activityFactor = activityFactor,
       _weightTarget = weightTarget,
       _kJouleMonday = kJouleMonday,
       _kJouleTuesday = kJouleTuesday,
       _kJouleWednesday = kJouleWednesday,
       _kJouleThursday = kJouleThursday,
       _kJouleFriday = kJouleFriday,
       _kJouleSaturday = kJouleSaturday,
       _kJouleSunday = kJouleSunday;

  final bool? _darkMode;
  final String? _languageCode;
  final Gender? _gender;
  final DateTime? _birthday;
  final int? _height;
  final double? _weight;
  final double? _activityFactor;
  final WeightTarget? _weightTarget;
  final int? _kJouleMonday;
  final int? _kJouleTuesday;
  final int? _kJouleWednesday;
  final int? _kJouleThursday;
  final int? _kJouleFriday;
  final int? _kJouleSaturday;
  final int? _kJouleSunday;

  bool? get darkMode => _darkMode;
  String? get languageCode => _languageCode;
  Gender? get gender => _gender;
  DateTime? get birthday => _birthday;
  int? get height => _height;
  double? get weight => _weight;
  double? get activityFactor => _activityFactor;
  WeightTarget? get weightTarget => _weightTarget;
  int? get kJouleMonday => _kJouleMonday;
  int? get kJouleTuesday => _kJouleTuesday;
  int? get kJouleWednesday => _kJouleWednesday;
  int? get kJouleThursday => _kJouleThursday;
  int? get kJouleFriday => _kJouleFriday;
  int? get kJouleSaturday => _kJouleSaturday;
  int? get kJouleSunday => _kJouleSunday;
}

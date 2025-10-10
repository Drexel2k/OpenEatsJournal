import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/weight_target.dart";

class AllSettings {
  AllSettings({
    this.darkMode,
    this.languageCode,
    this.gender,
    this.birthday,
    this.height,
    this.weight,
    this.activityFactor,
    this.weightTarget,
    this.kCalsMonday,
    this.kCalsTuesday,
    this.kCalsWednesday,
    this.kCalsThursday,
    this.kCalsFriday,
    this.kCalsSaturday,
    this.kCalsSunday,
  });

  final bool? darkMode;
  final String? languageCode;
  final Gender? gender;
  final DateTime? birthday;
  final int? height;
  final double? weight;
  final double? activityFactor;
  final WeightTarget? weightTarget;
  final int? kCalsMonday;
  final int? kCalsTuesday;
  final int? kCalsWednesday;
  final int? kCalsThursday;
  final int? kCalsFriday;
  final int? kCalsSaturday;
  final int? kCalsSunday;
}

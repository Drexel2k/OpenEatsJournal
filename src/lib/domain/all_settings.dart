import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/weight_target.dart";

class AllSettings {
  AllSettings({
    required this.darkMode,
    required this.languageCode,
    required this.gender,
    required this.birthday,
    required this.height,
    required this.weight,
    required this.activityFactor,
    required this.weightTarget,
    required this.kCalsMonday,
    required this.kCalsTuesday,
    required this.kCalsWednesday,
    required this.kCalsThursday,
    required this.kCalsFriday,
    required this.kCalsSaturday,
    required this.kCalsSunday
  });

  final bool darkMode;
  final String languageCode;
  final Gender gender;
  final DateTime birthday;
  final int height;
  final double weight;
  final double activityFactor;
  final WeightTarget weightTarget;
  final int kCalsMonday;
  final int kCalsTuesday;
  final int kCalsWednesday;
  final int kCalsThursday;
  final int kCalsFriday;
  final int kCalsSaturday;
  final int kCalsSunday;
}

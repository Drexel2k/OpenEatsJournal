import 'package:openeatsjournal/domain/gender.dart';
import 'package:openeatsjournal/domain/weight_target.dart';

class Settings {
  Settings({
    required this.darkMode,
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
    required this.kCalsSunday,
  });

  final bool darkMode;
  final Gender gender;
  final DateTime birthday;
  final int height;
  final double weight;
  final double activityFactor;
  final WeightTarget weightTarget;
  final double kCalsMonday;
  final double kCalsTuesday;
  final double kCalsWednesday;
  final double kCalsThursday;
  final double kCalsFriday;
  final double kCalsSaturday;
  final double kCalsSunday;
}

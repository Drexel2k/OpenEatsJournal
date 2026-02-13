class KJoulePerDay {
  KJoulePerDay({
    required double kJouleMonday,
    required double kJouleTuesday,
    required double kJouleWednesday,
    required double kJouleThursday,
    required double kJouleFriday,
    required double kJouleSaturday,
    required double kJouleSunday,
  }) : _kJouleMonday = kJouleMonday,
       _kJouleTuesday = kJouleTuesday,
       _kJouleWednesday = kJouleWednesday,
       _kJouleThursday = kJouleThursday,
       _kJouleFriday = kJouleFriday,
       _kJouleSaturday = kJouleSaturday,
       _kJouleSunday = kJouleSunday;

  double _kJouleMonday;
  double _kJouleTuesday;
  double _kJouleWednesday;
  double _kJouleThursday;
  double _kJouleFriday;
  double _kJouleSaturday;
  double _kJouleSunday;

  set kJouleMonday (double kJoule) => _kJouleMonday = kJoule;
  set kJouleTuesday (double kJoule) => _kJouleTuesday = kJoule;
  set kJouleWednesday (double kJoule) => _kJouleWednesday = kJoule;
  set kJouleThursday (double kJoule) => _kJouleThursday = kJoule;
  set kJouleFriday (double kJoule) => _kJouleFriday = kJoule;
  set kJouleSaturday (double kJoule) => _kJouleSaturday = kJoule;
  set kJouleSunday (double kJoule) => _kJouleSunday = kJoule;

  double get kJouleMonday => _kJouleMonday;
  double get kJouleTuesday => _kJouleTuesday;
  double get kJouleWednesday => _kJouleWednesday;
  double get kJouleThursday => _kJouleThursday;
  double get kJouleFriday => _kJouleFriday;
  double get kJouleSaturday => _kJouleSaturday;
  double get kJouleSunday => _kJouleSunday;
}

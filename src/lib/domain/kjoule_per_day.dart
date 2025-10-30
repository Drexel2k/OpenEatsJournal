class KJoulePerDay {
  KJoulePerDay({
    required int kJouleMonday,
    required int kJouleTuesday,
    required int kJouleWednesday,
    required int kJouleThursday,
    required int kJouleFriday,
    required int kJouleSaturday,
    required int kJouleSunday,
  }) : _kJouleMonday = kJouleMonday,
       _kJouleTuesday = kJouleTuesday,
       _kJouleWednesday = kJouleWednesday,
       _kJouleThursday = kJouleThursday,
       _kJouleFriday = kJouleFriday,
       _kJouleSaturday = kJouleSaturday,
       _kJouleSunday = kJouleSunday;

  int _kJouleMonday;
  int _kJouleTuesday;
  int _kJouleWednesday;
  int _kJouleThursday;
  int _kJouleFriday;
  int _kJouleSaturday;
  int _kJouleSunday;

  set kJouleMonday (int kJoule) => _kJouleMonday = kJoule;
  set kJouleTuesday (int kJoule) => _kJouleTuesday = kJoule;
  set kJouleWednesday (int kJoule) => _kJouleWednesday = kJoule;
  set kJouleThursday (int kJoule) => _kJouleThursday = kJoule;
  set kJouleFriday (int kJoule) => _kJouleFriday = kJoule;
  set kJouleSaturday (int kJoule) => _kJouleSaturday = kJoule;
  set kJouleSunday (int kJoule) => _kJouleSunday = kJoule;

  int get kJouleMonday => _kJouleMonday;
  int get kJouleTuesday => _kJouleTuesday;
  int get kJouleWednesday => _kJouleWednesday;
  int get kJouleThursday => _kJouleThursday;
  int get kJouleFriday => _kJouleFriday;
  int get kJouleSaturday => _kJouleSaturday;
  int get kJouleSunday => _kJouleSunday;
}

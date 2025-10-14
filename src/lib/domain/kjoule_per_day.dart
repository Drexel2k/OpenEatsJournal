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

  final int _kJouleMonday;
  final int _kJouleTuesday;
  final int _kJouleWednesday;
  final int _kJouleThursday;
  final int _kJouleFriday;
  final int _kJouleSaturday;
  final int _kJouleSunday;

  int get kJouleMonday => _kJouleMonday;
  int get kJouleTuesday => _kJouleTuesday;
  int get kJouleWednesday => _kJouleWednesday;
  int get kJouleThursday => _kJouleThursday;
  int get kJouleFriday => _kJouleFriday;
  int get kJouleSaturday => _kJouleSaturday;
  int get kJouleSunday => _kJouleSunday;
}

class WeightJournalEntry {
  WeightJournalEntry({required DateTime date, required double weight}) : _date = date, _weight = weight;

  final DateTime _date;
  final double _weight;

  DateTime get date => _date;
  double get weight => _weight;
}

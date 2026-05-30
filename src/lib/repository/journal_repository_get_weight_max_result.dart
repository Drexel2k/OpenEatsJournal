class JournalRepositoryGetWeightMaxResult {
  const JournalRepositoryGetWeightMaxResult({required DateTime from, required DateTime until, Map<DateTime, double>? groupMaxWeights})
    : _groupMaxWeights = groupMaxWeights,
      _from = from,
      _until = until;

  final DateTime _from;
  final DateTime _until;
  final Map<DateTime, double>? _groupMaxWeights;

  DateTime get from => _from;
  DateTime get until => _until;
  Map<DateTime, double>? get groupMaxWeights => _groupMaxWeights;
}

import 'package:openeatsjournal/domain/nutritions.dart';
import 'package:openeatsjournal/domain/nutrition_sums.dart';

class JournalRepositoryGetNutritionSumsResult {
  const JournalRepositoryGetNutritionSumsResult({ Map<DateTime, Nutritions>? groupNutritionTargets, Map<DateTime, NutritionSums>? groupNutritionSums, DateTime? from, DateTime? until})
    : _groupNutritionTargets = groupNutritionTargets,
      _groupNutritionSums = groupNutritionSums,
      _from=from,
      _until= until;

  final DateTime? _from;
  final DateTime? _until;
  final Map<DateTime, Nutritions>? _groupNutritionTargets;
  final Map<DateTime, NutritionSums>? _groupNutritionSums;

  DateTime? get from => _from;
  DateTime? get until => _until;
  Map<DateTime, Nutritions>? get groupNutritionTargets => _groupNutritionTargets;
  Map<DateTime, NutritionSums>? get groupNutritionSums => _groupNutritionSums;
}

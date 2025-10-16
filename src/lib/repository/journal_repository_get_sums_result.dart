import 'package:openeatsjournal/domain/nutritions.dart';
import 'package:openeatsjournal/domain/nutrition_sums_result.dart';

class JournalRepositoryGetSumsResult {
  const JournalRepositoryGetSumsResult({ Map<String, Nutritions>? groupNutritionTargets, Map<String, NutritionSums>? groupNutritionSums, DateTime? from, DateTime? until})
    : _groupNutritionTargets = groupNutritionTargets,
      _groupNutritionSums = groupNutritionSums,
      _from=from,
      _until= until;

  final DateTime? _from;
  final DateTime? _until;
  final Map<String, Nutritions>? _groupNutritionTargets;
  final Map<String, NutritionSums>? _groupNutritionSums;

  DateTime? get from => _from;
  DateTime? get until => _until;
  Map<String, Nutritions>? get groupNutritionTargets => _groupNutritionTargets;
  Map<String, NutritionSums>? get groupNutritionSums => _groupNutritionSums;
}

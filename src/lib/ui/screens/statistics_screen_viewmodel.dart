import "package:flutter/foundation.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/repository/journal_repository_get_weight_max_result.dart";

class StatisticsScreenViewModel extends ChangeNotifier {
  StatisticsScreenViewModel({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      _currentStatistic = ValueNotifier(StatisticType.energy) {
    _currentStatistic.addListener(_currentStatisticChanged);
    _currentStatisticChanged();
  }

  final JournalRepository _journalRepository;
  Future<JournalRepositoryGetNutritionSumsResult>? _last31daysNutritionData;
  Future<JournalRepositoryGetNutritionSumsResult>? _last15weeksNutritionData;
  Future<JournalRepositoryGetNutritionSumsResult>? _last13monthsNutritionData;
  Future<JournalRepositoryGetWeightMaxResult>? _last31daysWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? _last15weeksWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? _last13monthsWeightData;

  final ValueNotifier<StatisticType> _currentStatistic;

  Future<JournalRepositoryGetNutritionSumsResult>? get last31daysNutritionData => _last31daysNutritionData;
  Future<JournalRepositoryGetNutritionSumsResult>? get last15weeksNutritionData => _last15weeksNutritionData;
  Future<JournalRepositoryGetNutritionSumsResult>? get last13monthsNutritionData => _last13monthsNutritionData;
  Future<JournalRepositoryGetWeightMaxResult>? get last31daysWeightData => _last31daysWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? get last15weeksWeightData => _last15weeksWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? get last13monthsWeightData => _last13monthsWeightData;

  ValueNotifier<StatisticType> get currentStatistic => _currentStatistic;

  void _currentStatisticChanged() {
    if (_currentStatistic.value == StatisticType.energy && _last31daysNutritionData == null) {
      _last31daysNutritionData = _journalRepository.getNutritionDaySumsForLast32Days();
      _last15weeksNutritionData = _journalRepository.getNutritionWeekSumsForLast15Weeks();
      _last13monthsNutritionData = _journalRepository.getNutritionMonthSumsForLast13Months();
    }

    if (_currentStatistic.value == StatisticType.weight && _last31daysWeightData == null) {
      _last31daysWeightData = _journalRepository.getWeightPerDayForLast32Days();
      _last15weeksWeightData = _journalRepository.getMaxWeightPerWeekForLast15Weeks();
      _last13monthsWeightData = _journalRepository.getMaxWeightPerMonthForLast13Months();
    }
  }
}

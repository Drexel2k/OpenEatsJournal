import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/statistic.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/journal_repository_get_nutrition_sums_result.dart";
import "package:openeatsjournal/repository/journal_repository_get_weight_max_result.dart";

class StatisticsScreenViewModel extends ChangeNotifier {
  StatisticsScreenViewModel({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      _currentStatistic = ValueNotifier(Statistic.energy) {
    _currentStatistic.addListener(_currentStatisticChanged);
    _currentStatisticChanged();
  }

  final JournalRepository _journalRepository;
  Future<JournalRepositoryGetNutritionSumsResult>? _last31daysEnergyData;
  Future<JournalRepositoryGetNutritionSumsResult>? _last15weeksEnergyData;
  Future<JournalRepositoryGetNutritionSumsResult>? _last13monthsEnergyData;
  Future<JournalRepositoryGetWeightMaxResult>? _last31daysWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? _last15weeksWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? _last13monthsWeightData;

  final ValueNotifier<Statistic> _currentStatistic;

  Future<JournalRepositoryGetNutritionSumsResult>? get last31daysEnergyData => _last31daysEnergyData;
  Future<JournalRepositoryGetNutritionSumsResult>? get last15weeksEnergyData => _last15weeksEnergyData;
  Future<JournalRepositoryGetNutritionSumsResult>? get last13monthsEnergyData => _last13monthsEnergyData;
  Future<JournalRepositoryGetWeightMaxResult>? get last31daysWeightData => _last31daysWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? get last15weeksWeightData => _last15weeksWeightData;
  Future<JournalRepositoryGetWeightMaxResult>? get last13monthsWeightData => _last13monthsWeightData;

  ValueNotifier<Statistic> get currentStatistic => _currentStatistic;

  void _currentStatisticChanged() {
    if (_currentStatistic.value == Statistic.energy && _last31daysEnergyData == null) {
      _last31daysEnergyData = _journalRepository.getNutritionDaySumsForLast32Days();
      _last15weeksEnergyData = _journalRepository.getNutritionWeekSumsForLast15Weeks();
      _last13monthsEnergyData = _journalRepository.getNutritionMonthSumsForLast13Months();
    }

    if (_currentStatistic.value == Statistic.weight && _last31daysWeightData == null) {
      _last31daysWeightData = _journalRepository.getWeightPerDayForLast32Days();
      _last15weeksWeightData = _journalRepository.getMaxWeightPerWeekForLast15Weeks();
      _last13monthsWeightData = _journalRepository.getMaxWeightPerMonthForLast13Months();
    }
  }
}

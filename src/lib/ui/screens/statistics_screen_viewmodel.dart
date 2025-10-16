import "package:flutter/foundation.dart";
import "package:openeatsjournal/repository/journal_repository_get_sums_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";

class StatisticsScreenViewModel extends ChangeNotifier {
  StatisticsScreenViewModel({required JournalRepository journalRepository})
    : _last31daysData = journalRepository.getDaySumsForLast32Days(),
      _last15weeksData = journalRepository.getWeekSumsForLast15Weeks(),
      _last13monthsData  = journalRepository.getMonthSumsForLast13Months();

  final Future<JournalRepositoryGetSumsResult> _last31daysData;
  final Future<JournalRepositoryGetSumsResult> _last15weeksData;
  final Future<JournalRepositoryGetSumsResult> _last13monthsData;

  Future<JournalRepositoryGetSumsResult> get last31daysData => _last31daysData;
  Future<JournalRepositoryGetSumsResult> get last15weeksData => _last15weeksData;
  Future<JournalRepositoryGetSumsResult> get last13monthsData => _last13monthsData;
}

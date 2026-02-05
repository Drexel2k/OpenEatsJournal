import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/weight_journal_entry.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class WeightJournalEditScreenViewModel extends ChangeNotifier {
  WeightJournalEditScreenViewModel({required JournalRepository journalRepository}) : _journalRepository = journalRepository;

  final JournalRepository _journalRepository;

  final List<WeightJournalEntry> _weightEntriesResult = [];
  bool _hasMore = false;
  bool _isLoading = false;
  int _currentPage = 1;
  final ValueNotifier<bool> _showInitialLoading = ValueNotifier(false);

  final ExternalTriggerChangedNotifier _weightEntriesChanged = ExternalTriggerChangedNotifier();

  ExternalTriggerChangedNotifier get weightEntriesChanged => _weightEntriesChanged;

  List<WeightJournalEntry> get weightEntriesResult => _weightEntriesResult;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  ValueNotifier<bool> get showInitialLoading => _showInitialLoading;

  Future<void> getWeightJournalEntries() async {
    _initDataLoad();
    await _journalRepository.get10WeightJournalEntries(startIndex: _currentPage - 1).then((List<WeightJournalEntry>? result) {
      _searchFinished();

      if (result != null) {
        _weightEntriesResult.addAll(result);

        if (result.length >= 10) {
          _hasMore = true;
        }
      }
    });

    _weightEntriesChanged.notify();
  }

  Future<void> getWeightJournalEntriesLoadMore() async {
    _isLoading = true;
    _currentPage = _currentPage + 1;
    await _journalRepository.get10WeightJournalEntries(startIndex: _currentPage - 1).then((List<WeightJournalEntry>? result) {
      if (result != null) {
        _weightEntriesResult.addAll(result);
        if (result.length < 10) {
          _hasMore = false;
        }
      }

      _isLoading = false;
    });

    _weightEntriesChanged.notify();
  }

  void _initDataLoad() {
    _isLoading = true;
    _hasMore = false;
    _currentPage = 1;
    _weightEntriesResult.clear();
    _showInitialLoading.value = true;
    _weightEntriesChanged.notify();
  }

  void _searchFinished() {
    _isLoading = false;
    _showInitialLoading.value = false;
  }

  Future<void> setWeightJournalEntry({required DateTime date, required double weight}) async {
    await _journalRepository.setWeightJournalEntry(date: date, weight: weight);
  }

  Future<bool> deleteWeightJournalEntry({required DateTime date}) async {
    return await _journalRepository.deleteWeightJournalEntry(date: date);
  }

  @override
  void dispose() {
    _showInitialLoading.dispose();
    _weightEntriesChanged.dispose();

    super.dispose();
  }
}

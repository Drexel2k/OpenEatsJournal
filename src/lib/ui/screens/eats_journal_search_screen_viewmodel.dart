import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/eats_journal_entry_type.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";

class EatsJournalSearchScreenViewModel extends ChangeNotifier {
  EatsJournalSearchScreenViewModel({required JournalRepository journalRepository, DateTime? today})
    : _journalRepository = journalRepository,
      _dateFrom = ValueNotifier(_defaultDateFrom(today ?? DateTime.now())) {
    _searchQuery.addListener(_scheduleSearch);
    _dateFrom.addListener(_scheduleSearch);
    _selectedTypes.addListener(_scheduleSearch);

    _scheduleSearch();
  }

  final JournalRepository _journalRepository;
  final Debouncer _searchDebouncer = Debouncer();

  final ValueNotifier<String> _searchQuery = ValueNotifier("");
  final ValueNotifier<DateTime> _dateFrom;
  final ValueNotifier<Set<EatsJournalEntryType>> _selectedTypes = ValueNotifier({EatsJournalEntryType.quickEntry, EatsJournalEntryType.foodEntry});

  List<EatsJournalEntry> _searchResults = [];
  bool _isSearching = false;
  final ChangeNotifier searchResultsChanged = ChangeNotifier();

  ValueNotifier<String> get searchQuery => _searchQuery;
  ValueNotifier<DateTime> get dateFrom => _dateFrom;
  ValueNotifier<Set<EatsJournalEntryType>> get selectedTypes => _selectedTypes;
  List<EatsJournalEntry> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  static DateTime _defaultDateFrom(DateTime today) {
    int month = today.month - 3;
    int year = today.year;
    if (month <= 0) {
      month += 12;
      year -= 1;
    }
    return DateTime.utc(year, month, today.day);
  }

  void toggleType(EatsJournalEntryType type) {
    final Set<EatsJournalEntryType> updated = Set.of(_selectedTypes.value);
    if (updated.contains(type)) {
      //mindestens ein Typ muss aktiv bleiben
      if (updated.length > 1) {
        updated.remove(type);
      }
    } else {
      updated.add(type);
    }
    _selectedTypes.value = updated;
  }

  void _scheduleSearch() {
    _searchDebouncer.run(callback: _search);
  }

  Future<void> _search() async {
    _isSearching = true;
    searchResultsChanged.notifyListeners();

    _searchResults =
        //     await _journalRepository.searchEatsJournalEntries(
        //       from: _dateFrom.value,
        //       until: _dateUntil.value,
        //       nameQuery: _searchQuery.value,
        //       types: _selectedTypes.value,
        //     ) ??
        [];

    _isSearching = false;
    searchResultsChanged.notifyListeners();
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _dateFrom.dispose();
    _selectedTypes.dispose();
    searchResultsChanged.dispose();

    super.dispose();
  }
}

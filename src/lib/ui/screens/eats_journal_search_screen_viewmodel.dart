import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/eats_journal_entry_type.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_entry.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_status_code.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalSearchScreenViewModel extends ChangeNotifier {
  EatsJournalSearchScreenViewModel({required JournalRepository journalRepository, required SettingsRepository settingsRepository, required DateTime today})
    : _journalRepository = journalRepository,
      _settingsRepository = settingsRepository,
      _searchText = ValueNotifier(OpenEatsJournalStrings.emptyString),
      _searchFrom = ValueNotifier(_initDate(today: today));

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  final ValueNotifier<int?> _errorCode = ValueNotifier(null);
  final ValueNotifier<String> _searchText;
  final ValueNotifier<DateTime> _searchFrom;
  final ValueNotifier<bool> _quickEntrySelected = ValueNotifier(true);
  final ValueNotifier<bool> _foodEntrySelected = ValueNotifier(false);

  final int _pageSize = 50;
  final List<CancelableOperation> _searchOperations = [];
  int _currentPage = 1;
  final ExternalTriggerChangeNotifier _searchResultChanged = ExternalTriggerChangeNotifier();

  final List<EatsJournalEntrySearchResultEntry> _searchResult = [];

  ValueNotifier<int?> get errorCode => _errorCode;
  ValueNotifier<String> get searchText => _searchText;
  ValueNotifier<DateTime> get searchFrom => _searchFrom;
  ValueNotifier<bool> get quickEntrySelected => _quickEntrySelected;
  ValueNotifier<bool> get foodEntrySelected => _foodEntrySelected;

  ExternalTriggerChangeNotifier get searchResultChanged => _searchResultChanged;

  List<EatsJournalEntrySearchResultEntry> get searchResults => _searchResult;

  static DateTime _initDate({required DateTime today}) {
    int month = today.month - 3;
    int year = today.year;
    if (month <= 0) {
      month += 12;
      year -= 1;
    }
    return DateTime.utc(year, month, today.day);
  }

  Future<void> search() async {
    _cancelSearchOperations();
    _errorCode.value = null;
    _currentPage = 1;
    _searchResult.clear();

    if (_searchText.value.trim() == OpenEatsJournalStrings.emptyString) {
      _errorCode.value = 1;
      return;
    }

    _searchResult.add(
      EatsJournalEntrySearchResultEntry(eatsJournalEntrySearchResultStatusCode: EatsJournalEntrySearchResultStatusCode.offlineMoreResults, moreRequested: true),
    );
    _searchResultChanged.notify();

    if (_searchText.value.trim() != OpenEatsJournalStrings.emptyString && (_quickEntrySelected.value == true || _foodEntrySelected.value == true)) {
      EatsJournalEntryType? entryType;

      //if both are true we leave entryType = null, this means not filter
      if (!(_quickEntrySelected.value == true && _foodEntrySelected.value == true)) {
        if (_quickEntrySelected.value == true) {
          entryType = EatsJournalEntryType.quickEntry;
        }

        if (_foodEntrySelected.value == true) {
          entryType = EatsJournalEntryType.foodEntry;
        }
      }

      CancelableOperation searchOperation = CancelableOperation.fromFuture(
        _journalRepository.getEatsJournalEntriesBySearchText(
          from: _searchFrom.value,
          entryType: entryType,
          searchText: _searchText.value,
          limit: _pageSize,
          offset: 0,
        ),
      );
      _searchOperations.add(searchOperation);

      searchOperation.then((result) {
        _processResult(result: result);
      });
    }
  }

  Future<void> getMoreResults() async {
    EatsJournalEntryType? entryType;

    //if both are true we leave entryType = null, this means not filter
    if (!(_quickEntrySelected.value == true && _foodEntrySelected.value == true)) {
      if (_quickEntrySelected.value == true) {
        entryType = EatsJournalEntryType.quickEntry;
      }

      if (_foodEntrySelected.value == true) {
        entryType = EatsJournalEntryType.foodEntry;
      }
    }

    _currentPage++;

    CancelableOperation searchOperation = CancelableOperation.fromFuture(
      _journalRepository.getEatsJournalEntriesBySearchText(
        from: _searchFrom.value,
        entryType: entryType,
        searchText: _searchText.value,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      ),
    );
    _searchOperations.add(searchOperation);

    searchOperation.then((result) {
      _processResult(result: result);
    });
  }

  void _processResult({List<EatsJournalEntry>? result}) {
    if ((result == null || result.isEmpty) &&
        _searchResult.length == 1 &&
        _searchResult[0].eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.offlineMoreResults) {
      _searchResult.clear();
      _searchResult.add(EatsJournalEntrySearchResultEntry(eatsJournalEntrySearchResultStatusCode: EatsJournalEntrySearchResultStatusCode.offlineNoResult));
      _searchResultChanged.notify();
      return;
    }

    //_searchResult is not empty here, we had already results in previous pages
    _searchResult.removeWhere(
      (EatsJournalEntrySearchResultEntry eatsJournalEntrySearchResultEntry) =>
          eatsJournalEntrySearchResultEntry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.offlineMoreResults,
    );

    if ((result != null && result.isNotEmpty)) {
      _searchResult.addAll(
        result.map(
          (EatsJournalEntry entry) => EatsJournalEntrySearchResultEntry(
            eatsJournalEntrySearchResultStatusCode: EatsJournalEntrySearchResultStatusCode.searchResult,
            eatsJournalEntry: entry,
          ),
        ),
      );

      if (result.length >= _pageSize) {
        _searchResult.add(
          EatsJournalEntrySearchResultEntry(
            eatsJournalEntrySearchResultStatusCode: EatsJournalEntrySearchResultStatusCode.offlineMoreResults,
            moreRequested: false,
          ),
        );
      }
    }

    _searchResultChanged.notify();
  }

  void _cancelSearchOperations() {
    for (CancelableOperation searchOperation in _searchOperations) {
      searchOperation.cancel();
    }

    _searchOperations.clear();
  }

  Future<void> goTo({required DateTime date}) async {
    _settingsRepository.currentJournalDate.value = date;
    await Navigator.pushNamedAndRemoveUntil(
      AppGlobal.navigatorKey.currentContext!,
      OpenEatsJournalStrings.navigatorRouteEatsJournal,
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _errorCode.dispose();
    _foodEntrySelected.dispose();
    _quickEntrySelected.dispose();
    _searchFrom.dispose();
    _searchResultChanged.dispose();
    _searchText.dispose();

    super.dispose();
  }
}

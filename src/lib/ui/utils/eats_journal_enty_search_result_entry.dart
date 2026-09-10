import 'package:openeatsjournal/domain/eats_journal_entry.dart';
import 'package:openeatsjournal/ui/utils/eats_journal_enty_search_result_status_code.dart';

//Wrapper class for search result, can contain search results or control information for other information in result view
class EatsJournalEntrySearchResultEntry {
  EatsJournalEntrySearchResultEntry({
    required EatsJournalEntrySearchResultStatusCode eatsJournalEntrySearchResultStatusCode,
    EatsJournalEntry? eatsJournalEntry,
    bool? moreRequested,
  }) : _eatsJournalEntry = eatsJournalEntry,
       _eatsJournalEntrySearchResultStatusCode = eatsJournalEntrySearchResultStatusCode,
       _moreRequested = moreRequested;

  //0 = no more results, 1 more results available
  final EatsJournalEntrySearchResultStatusCode _eatsJournalEntrySearchResultStatusCode;
  //in combination with _eatsJournalEntrySearchResultStatusCode = offlineMoreResults, if more results available flag if more results are requested
  bool? _moreRequested;

  //Can be null on other FoodSearchResultStatusCode than 0
  final EatsJournalEntry? _eatsJournalEntry;

  set moreRequested(bool? value) => _moreRequested = value;

  EatsJournalEntrySearchResultStatusCode get eatsJournalEntrySearchResultStatusCode => _eatsJournalEntrySearchResultStatusCode;
  bool? get moreRequested => _moreRequested;
  EatsJournalEntry? get eatsJournalEntry => _eatsJournalEntry;
}

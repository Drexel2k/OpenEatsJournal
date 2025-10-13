import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";

class JournalRepository {
  JournalRepository._singleton();
  static final JournalRepository instance = JournalRepository._singleton();

  late OpenEatsJournalDatabaseService _oejDatabase;

  //must be called once before the singleton is used
  void init({required OpenEatsJournalDatabaseService oejDatabase}) {
    _oejDatabase = oejDatabase;
  }

  Future<void> saveOnceDailyNutritionTarget({required DateTime entryDate, required int dayTargetKJoule}) async {
    await _oejDatabase.insertOnceDailyNutritionTarget(entryDate, dayTargetKJoule);
  }

  Future<void> addEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _oejDatabase.insertEatsJournalEntry(eatsJournalEntry);
  }

  Future<void> addWeightJournalEntry({required DateTime date, required double weight}) async {
    await _oejDatabase.insertWeightJournalEntry(date, weight);
  }
}

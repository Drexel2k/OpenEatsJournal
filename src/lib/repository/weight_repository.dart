import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";

class WeightRepository {
  WeightRepository._singleton();
  static final WeightRepository instance = WeightRepository._singleton();

  late OpenEatsJournalDatabaseService _oejDatabase;

  //must be called once before the singleton is used
  void init({required OpenEatsJournalDatabaseService oejDatabase}) {
    _oejDatabase = oejDatabase;
  }

  Future<void> insertWeight(DateTime date, double weight) async {
    await _oejDatabase.insertWeight(date, weight);
  }
}

import "package:openeatsjournal/service/oej_database_service.dart";

class WeightRepositoy {
  WeightRepositoy._singleton();
  static final WeightRepositoy instance = WeightRepositoy._singleton();

  late OejDatabaseService _oejDatabase;

  //must be called once before the singleton is used
  void setOejDatabase(OejDatabaseService oejDataBase) {
    _oejDatabase = oejDataBase;
  }

  Future<void> insertWeight(DateTime date, double weight) async {
    await _oejDatabase.insertWeight(date, weight);
  }
}
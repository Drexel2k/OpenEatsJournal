import 'package:openeatsjournal/service/oej_database_service.dart';

class WeightRepositoy {
  static final WeightRepositoy instance = WeightRepositoy._singleton();
  late OejDatabaseService _oejDatabase;

  WeightRepositoy._singleton();

  void setOejDatabase(OejDatabaseService oejDataBase) {
    _oejDatabase = oejDataBase;
  }

  Future<void> insertWeight(DateTime date, double weight) async {
    await _oejDatabase.insertWeight(date, weight);
  }
}
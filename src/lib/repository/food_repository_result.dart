import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";

class FoodRepositoryResult {
  const FoodRepositoryResult({
    required List<FoodSource> foodSources,
    required bool fromDb,
    List<Food>? foods,
    bool? finished,
    int? errorCode,
    String? errorMessage,
  }) : _foodSources = foodSources,
       _fromDb = fromDb,
       _foods = foods,
       _finished = finished,
       _errorCode = errorCode,
       _errorMessage = errorMessage;

  final List<FoodSource> _foodSources;
  //to distinguish between data from objects from online services or cached versions which wer loaded from database
  final bool _fromDb;
  //null on error or if there was no food in valid response, on valid response list can be empty if food entries of response had not sufficient data from
  //online sources e.g.
  final List<Food>? _foods;
  final bool? _finished;
  final int? _errorCode;
  final String? _errorMessage;

  List<FoodSource> get foodSources => _foodSources;
  bool get fromDb => _fromDb;
  List<Food>? get foods => _foods;
  bool? get finished => _finished;
  int? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;
}

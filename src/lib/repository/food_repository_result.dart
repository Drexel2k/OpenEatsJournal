import "package:openeatsjournal/domain/food.dart";

class FoodRepositoryResult {
  const FoodRepositoryResult({List<Food>? foods, bool? finished, int? errorCode, String? errorMessage})
    : _foods = foods,
      _finished = finished,
      _errorCode = errorCode,
      _errorMessage = errorMessage;

  final List<Food>? _foods;
  final bool? _finished;
  final int? _errorCode;
  final String? _errorMessage;

  List<Food>? get foods => _foods;
  bool? get finished => _finished;
  int? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;
}

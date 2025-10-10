import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/repository/food_repository_response.dart';

class FoodRepositoryGetFoodBySearchTextResult extends FoodRepositoryResponse {
  const FoodRepositoryGetFoodBySearchTextResult({List<Food>? foods, bool? finished, super.errorCode, super.errorMessage})
    : _finished = finished,
      _foods = foods;

  final List<Food>? _foods;
  final bool? _finished;

  List<Food>? get foods => _foods;
  bool? get finished => _finished;
}

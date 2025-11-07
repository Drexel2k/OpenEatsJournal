import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/repository/food_repository_response.dart';

class FoodRepositoryGetFoodBySearchTextResult extends FoodRepositoryResponse {
  FoodRepositoryGetFoodBySearchTextResult({List<Food>? foods, bool? finished, super.errorCode, super.errorMessage}) : _finished = finished, _foods = foods;

  List<Food>? _foods;
  final bool? _finished;

  set foods(List<Food>? value) {
    _foods = value;
  }

  List<Food>? get foods => _foods;
  bool? get finished => _finished;
}

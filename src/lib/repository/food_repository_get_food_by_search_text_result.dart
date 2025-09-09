import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/repository/food_repository_response.dart';

class FoodRepositoryGetFoodBySearchTextResult extends FoodRepositoryResponse {
  const FoodRepositoryGetFoodBySearchTextResult({
    List<Food>? foods,
    int? page,
    int? pageCount,
    super.errorCode,
    super.errorMessage,
  }) : _foods = foods,
       _page = page,
       _pageCount = pageCount;

  final List<Food>? _foods;
  final int? _page;
  final int? _pageCount;

  List<Food>? get foods => _foods;
  int? get page => _page;
  int? get pageCount => _pageCount;
}

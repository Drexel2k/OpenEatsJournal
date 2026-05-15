import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/ui/utils/food_search_result_status_code.dart';

class FoodSearchResultEntry {
  FoodSearchResultEntry({required FoodSearchResultStatusCode foodSearchResultCode, Food? food}) : _food = food, _foodSearchResultCode = foodSearchResultCode;

  final FoodSearchResultStatusCode _foodSearchResultCode;
  final Food? _food;

  FoodSearchResultStatusCode get foodSearchResultCode => _foodSearchResultCode;
  Food? get food => _food;
}

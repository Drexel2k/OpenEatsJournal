import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/ui/utils/food_search_result_status_code.dart';

class FoodSearchResultEntry {
  FoodSearchResultEntry({required FoodSearchResultStatusCode foodSearchResultCode, Food? food, bool? moreRequested})
    : _food = food,
      _foodSearchResultCode = foodSearchResultCode,
      _moreRequested = moreRequested;

  final FoodSearchResultStatusCode _foodSearchResultCode;
  bool? _moreRequested;
  final Food? _food;

  set moreRequested(bool? value) => _moreRequested = value;

  FoodSearchResultStatusCode get foodSearchResultCode => _foodSearchResultCode;
  bool? get moreRequested => _moreRequested;
  Food? get food => _food;
}

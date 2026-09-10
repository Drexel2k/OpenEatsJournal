import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/ui/utils/food_search_result_status_code.dart';

//Wrapper class for search result, can contain search results or control information for other information in result view
class FoodSearchResultEntry {
  FoodSearchResultEntry({required FoodSearchResultStatusCode foodSearchResultCode, Food? food, bool? moreRequested})
    : _food = food,
      _foodSearchResultCode = foodSearchResultCode,
      _moreRequested = moreRequested;

  final FoodSearchResultStatusCode _foodSearchResultCode;
  //In combination with _foodSearchResultCode = openFoodFactsMoreResults, if more results availbel flag if more results are requested
  bool? _moreRequested;

  //Can be null on other FoodSearchResultStatusCode than searchResult
  final Food? _food;

  set moreRequested(bool? value) => _moreRequested = value;

  FoodSearchResultStatusCode get foodSearchResultCode => _foodSearchResultCode;
  bool? get moreRequested => _moreRequested;
  Food? get food => _food;
}

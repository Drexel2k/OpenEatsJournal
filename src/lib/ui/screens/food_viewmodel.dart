import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/repository/food_repository.dart";

class FoodViewModel extends ChangeNotifier {
  FoodViewModel({required FoodRepository foodRepository}) : _foodRepository = foodRepository;

  final FoodRepository _foodRepository;
  final List<Food> _foodSearchResult = [];
  final FoodSearchResultChangedNotifier _foodSearchResultChangedNotifier = FoodSearchResultChangedNotifier();

  List<Food> get foodSearchResult => _foodSearchResult;
  FoodSearchResultChangedNotifier get foodSearchResultChangedNotifier => _foodSearchResultChangedNotifier;

  Future<Food?> getFoodByBarcode({required String barcode, required String languageCode}) async {
    return await _foodRepository.getFoodByBarcode(barcode: barcode, languageCode: languageCode);
  }

  Future<List<Food>?> getFoodBySearchText({required String searchText, required String languageCode}) async {
    return await _foodRepository.getFoodBySearchText(searchText: searchText, languageCode: languageCode);
  }

  void setNewSearchResult(List<Food> foods) {
    _foodSearchResult.clear();
    _foodSearchResult.addAll(foods);
    _foodSearchResultChangedNotifier.notify();
  }
}

class FoodSearchResultChangedNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/food_repository_get_food_by_barcode_result.dart";
import "package:openeatsjournal/repository/food_repository_get_food_by_search_text_result.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";
import "package:openeatsjournal/ui/utils/object_with_order.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";

class FoodSearchScreenViewModel extends ChangeNotifier {
  FoodSearchScreenViewModel({required FoodRepository foodRepository, required SettingsRepository settingsRepository})
    : _foodRepository = foodRepository,
      _settingsRepository = settingsRepository {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
  }

  final FoodRepository _foodRepository;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  final List<ObjectWithOrder<Food>> _foodSearchResult = [];
  bool _hasMore = false;
  bool _isLoading = false;
  int _currentPage = 1;
  String _currentSearchText = OpenEatsJournalStrings.emptyString;
  String _currentLanguageCode = OpenEatsJournalStrings.emptyString;
  final ExternalTriggerChangedNotifier _foodSearchResultChangedNotifier = ExternalTriggerChangedNotifier();
  final ValueNotifier<bool> _showInitialLoading = ValueNotifier(false);
  final ValueNotifier<int?> _errorCode = ValueNotifier(null);
  String _errorMessage = OpenEatsJournalStrings.emptyString;
  final ValueNotifier<int?> _searchMessageCode = ValueNotifier(null);
  final ExternalTriggerChangedNotifier _sortButtonChanged = ExternalTriggerChangedNotifier();
  bool _sortButtonEnabled = true;
  SortOrder _sortOrder = SortOrder.name;

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;
  String get languageCode => _settingsRepository.languageCode.value;

  List<ObjectWithOrder<Food>> get foodSearchResult => _foodSearchResult;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  ExternalTriggerChangedNotifier get foodSearchResultChangedNotifier => _foodSearchResultChangedNotifier;
  ValueNotifier<bool> get showInitialLoading => _showInitialLoading;
  ValueNotifier<int?> get errorCode => _errorCode;
  String get errorMessage => _errorMessage;
  ValueNotifier<int?> get searchMessageCode => _searchMessageCode;
  ExternalTriggerChangedNotifier get sortButtonChanged => _sortButtonChanged;
  bool get sortButtonEnabled => _sortButtonEnabled;
  SortOrder get sortOrder => _sortOrder;

  _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  Future<void> getFoodByBarcode({required String barcode, required String languageCode, required Map<String, String> localizations}) async {
    _initSearch();
    _foodRepository.getFoodByBarcode(barcode: barcode, languageCode: languageCode).then((FoodRepositoryGetFoodByBarcodeResult result) {
      _searchFinished();

      if (result.errorCode == null) {
        if (result.food != null && result.food!.foodUnits.isNotEmpty) {
          for (FoodUnit unit in result.food!.foodUnits) {
            if (localizations.containsKey(unit.name)) {
              unit.name = localizations[unit.name]!;
            }
          }
        }

        _setNewSearchResult(result.food != null ? [ObjectWithOrder(object: result.food!, order: 0)] : null);
      } else {
        _errorCode.value = result.errorCode;
      }
    });
  }

  Future<void> getFoodBySearchText({required String searchText, required String languageCode, required Map<String, String> localizations}) async {
    _initSearch();
    _currentPage = 1;
    _currentSearchText = searchText;
    _currentLanguageCode = languageCode;
    _foodRepository.getFoodBySearchTextApiV1(searchText: searchText, languageCode: languageCode, page: _currentPage).then((
      FoodRepositoryGetFoodBySearchTextResult result,
    ) {
      _searchFinished();

      if (result.errorCode == null) {
        List<ObjectWithOrder<Food>>? foodsWithOrder;
        if (result.foods!.isNotEmpty) {
          int order = 0;
          foodsWithOrder = [];

          for (Food food in result.foods!) {
            if (food.foodUnits.isNotEmpty) {
              for (FoodUnit unit in food.foodUnits) {
                if (localizations.containsKey(unit.name)) {
                  unit.name = localizations[unit.name]!;
                }
              }
            }

            foodsWithOrder.add(ObjectWithOrder(object: food, order: order++));
          }

          if (result.pageCount! <= 1) {
            foodsWithOrder.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
            if (_sortButtonEnabled == false || _sortOrder != SortOrder.name) {
              _sortButtonEnabled = true;
              _sortOrder = SortOrder.name;
              _sortButtonChanged.notify();
            }
          } else {
            _searchMessageCode.value = 1;
            _hasMore = true;
            if (_sortButtonEnabled == true || _sortOrder != SortOrder.popularity) {
              _sortButtonEnabled = false;
              _sortOrder = SortOrder.popularity;
              _sortButtonChanged.notify();
            }
          }
        }

        _setNewSearchResult(foodsWithOrder);
      } else {
        _errorCode.value = result.errorCode;
      }
    });
  }

  void getFoodBySearchTextLoadMore() {
    _isLoading = true;
    _currentPage = _currentPage + 1;
    _foodRepository.getFoodBySearchTextApiV1(searchText: _currentSearchText, languageCode: _currentLanguageCode, page: _currentPage + 1).then((
      FoodRepositoryGetFoodBySearchTextResult result,
    ) {
      if (result.errorCode == null) {
        int order = 0;
        for (ObjectWithOrder<Food> food in _foodSearchResult) {
          if (food.order > order) {
            order = food.order;
          }
        }

        order++;

        List<ObjectWithOrder<Food>> foodsWithOrder = [];
        for (Food food in result.foods!) {
          foodsWithOrder.add(ObjectWithOrder(object: food, order: order++));
        }

        _addToSearchResult(foodsWithOrder);

        if (result.page! <= result.pageCount!) {
          _hasMore = true;
        } else {
          _hasMore = false;
        }

        _isLoading = false;
      } else {
        _isLoading = false;
        _hasMore = false;
        _clearSearchResult();
        _errorCode.value = result.errorCode;
      }
    });
  }

  void _initSearch() {
    _isLoading = true;
    _hasMore = false;
    _sortButtonEnabled = true;
    _errorMessage = OpenEatsJournalStrings.emptyString;
    _errorCode.value = null;
    _searchMessageCode.value = null;
    _sortButtonChanged.notify();
    _showInitialLoading.value = true;
  }

  _searchFinished() {
    _isLoading = false;
    _showInitialLoading.value = false;
  }

  void _setNewSearchResult(List<ObjectWithOrder<Food>>? foods) {
    _foodSearchResult.clear();
    if (foods != null) {
      _foodSearchResult.addAll(foods);
    }

    _foodSearchResultChangedNotifier.notify();
  }

  void _addToSearchResult(List<ObjectWithOrder<Food>> foods) {
    _foodSearchResult.addAll(foods);
    _foodSearchResultChangedNotifier.notify();
  }

  void _clearSearchResult() {
    _foodSearchResult.clear();
    _foodSearchResultChangedNotifier.notify();
  }

  void setSortOrder(SortOrder sortOrder) {
    _sortOrder = sortOrder;
    _sortButtonChanged.notify();

    if (_sortOrder == SortOrder.name) {
      _foodSearchResult.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
    } else if (_sortOrder == SortOrder.kcal) {
      _foodSearchResult.sort(
        (food1, food2) => food1.object.energyKjPer100Units == food2.object.energyKjPer100Units
            ? 0
            : food1.object.energyKjPer100Units > food2.object.energyKjPer100Units
            ? 1
            : -1,
      );
    } else if (_sortOrder == SortOrder.popularity) {
      _foodSearchResult.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
    }

    _foodSearchResultChangedNotifier.notify();
  }

  ObjectWithOrder toElement(Food e, int order) {
    return ObjectWithOrder(object: e, order: order);
  }

  @override
  void dispose() {
    _foodSearchResultChangedNotifier.dispose();
    _showInitialLoading.dispose();
    _errorCode.dispose();
    _searchMessageCode.dispose();
    _sortButtonChanged.dispose();

    super.dispose();
  }
}

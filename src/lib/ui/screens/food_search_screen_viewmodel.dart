import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";
import "package:openeatsjournal/ui/utils/sort_order.dart";

class FoodSearchScreenViewModel extends ChangeNotifier {
  FoodSearchScreenViewModel({
    required FoodRepository foodRepository,
    required JournalRepository journalRepository,
    required SettingsRepository settingsRepository,
  }) : _foodRepository = foodRepository,
       _journalRepository = journalRepository,
       _settingsRepository = settingsRepository {
    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
  }

  final FoodRepository _foodRepository;
  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);
  final ValueNotifier<bool> _floatincActionMenuElapsed = ValueNotifier(false);

  final List<ObjectWithOrder<Food>> _foodSearchResultUser = [];
  final List<ObjectWithOrder<Food>> _foodSearchResultStandard = [];
  final List<ObjectWithOrder<Food>> _foodSearchResultCache = [];
  final List<ObjectWithOrder<Food>> _foodSearchResultOpenFoodFacst = [];
  final List<ObjectWithOrder<Food>> _foodSearchResult = [];
  bool _hasMore = false;
  bool _isLoading = false;
  int _currentPage = 1;
  String _currentSearchText = OpenEatsJournalStrings.emptyString;
  final ExternalTriggerChangedNotifier _foodSearchResultChanged = ExternalTriggerChangedNotifier();
  final ValueNotifier<bool> _showInitialLoading = ValueNotifier(false);
  final ValueNotifier<int?> _errorCode = ValueNotifier(null);
  String _errorMessage = OpenEatsJournalStrings.emptyString;
  final ValueNotifier<int?> _searchMessageCode = ValueNotifier(null);
  final ExternalTriggerChangedNotifier _sortButtonChanged = ExternalTriggerChangedNotifier();
  bool _sortButtonEnabled = true;
  SortOrder _sortOrder = SortOrder.popularity;
  final ValueNotifier<bool> _sortDesc = ValueNotifier(true);

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;
  String get languageCode => _settingsRepository.languageCode.value;
  ValueNotifier<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;

  List<ObjectWithOrder<Food>> get foodSearchResult => _foodSearchResult;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  ExternalTriggerChangedNotifier get foodSearchResultChanged => _foodSearchResultChanged;
  ValueNotifier<bool> get showInitialLoading => _showInitialLoading;
  ValueNotifier<int?> get errorCode => _errorCode;
  String get errorMessage => _errorMessage;
  ValueNotifier<int?> get searchMessageCode => _searchMessageCode;
  ExternalTriggerChangedNotifier get sortButtonChanged => _sortButtonChanged;
  bool get sortButtonEnabled => _sortButtonEnabled;
  SortOrder get sortOrder => _sortOrder;
  ValueNotifier<bool> get sortDesc => _sortDesc;

  void _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  void _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  Future<void> getFoodByBarcode({required int barcode, required Map<String, String> localizations, required SearchMode searchMode}) async {
    _initSearch();

    await _foodRepository.getFoodsByBarcode(barcode: barcode, languageCode: languageCode, searchMode: searchMode).then((List<FoodRepositoryResult> result) {
      _processInitialResult(result: result, localizations: localizations);
    });
  }

  Future<void> getFoodBySearchText({required String searchText, required Map<String, String> localizations, required SearchMode searchMode}) async {
    _initSearch();
    _currentSearchText = searchText;

    await _foodRepository.getFoodsBySearchText(searchText: searchText, languageCode: languageCode, searchMode: searchMode).then((
      List<FoodRepositoryResult> result,
    ) {
      _processInitialResult(result: result, localizations: localizations);
    });
  }

  void _processInitialResult({required List<FoodRepositoryResult> result, required Map<String, String> localizations}) {
    _searchFinished();

    if (result.any((resultInternal) => resultInternal.foods != null && resultInternal.foods!.isNotEmpty)) {
      int order = 0;

      List<ObjectWithOrder<Food>>? foodsWithOrder = [];
      if (result[0].foods != null && result[0].foods!.isNotEmpty) {
        for (Food food in result[0].foods!) {
          if (food.foodUnitsWithOrder.isNotEmpty) {
            for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
              if (localizations.containsKey(unitWithOrder.object.name)) {
                unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
              }
            }
          }

          _foodSearchResultUser.add(ObjectWithOrder(object: food, order: order++));
        }

        foodsWithOrder.addAll(_foodSearchResultUser);
      }

      if (result[1].foods != null && result[1].foods!.isNotEmpty) {
        for (Food food in result[1].foods!) {
          if (food.foodUnitsWithOrder.isNotEmpty) {
            for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
              if (localizations.containsKey(unitWithOrder.object.name)) {
                unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
              }
            }
          }

          _foodSearchResultStandard.add(ObjectWithOrder(object: food, order: order++));
        }

        foodsWithOrder.addAll(_foodSearchResultStandard);
      }

      if (result[2].foods != null && result[2].foods!.isNotEmpty) {
        for (Food food in result[2].foods!) {
          if (food.foodUnitsWithOrder.isNotEmpty) {
            for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
              if (localizations.containsKey(unitWithOrder.object.name)) {
                unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
              }
            }
          }

          _foodSearchResultCache.add(ObjectWithOrder(object: food, order: order++));
        }

        foodsWithOrder.addAll(_foodSearchResultCache);
      }

      if (result[3].foods != null && result[3].foods!.isNotEmpty) {
        for (Food food in result[3].foods!) {
          if (food.foodUnitsWithOrder.isNotEmpty) {
            for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
              if (localizations.containsKey(unitWithOrder.object.name)) {
                unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
              }
            }
          }

          _foodSearchResultOpenFoodFacst.add(ObjectWithOrder(object: food, order: order++));
        }

        foodsWithOrder.addAll(_foodSearchResultOpenFoodFacst);
      }

      _addToSearchResult(foodsWithOrder);
    }

    if (_foodSearchResult.length > 500) {
      _searchMessageCode.value = 1;
      if (_sortButtonEnabled == true || _sortOrder != SortOrder.popularity) {
        _sortButtonEnabled = false;
        _sortOrder = SortOrder.popularity;
        _sortButtonChanged.notify();
      }
    }

    if (result[3].errorCode == null) {
      if (result[3].finished != null && !result[3].finished!) {
        _hasMore = true;
      }
    } else {
      _errorCode.value = result[3].errorCode;
      _errorMessage = result[3].errorMessage != null ? result[3].errorMessage! : OpenEatsJournalStrings.emptyString;
    }
  }

  Future<void> getFoodBySearchTextLoadMore() async {
    _isLoading = true;
    _currentPage = _currentPage + 1;
    await _foodRepository
        .getOpenFoodFactsFoodBySearchTextApiV1(searchText: _currentSearchText, languageCode: _settingsRepository.languageCode.value, page: _currentPage)
        .then((FoodRepositoryResult result) {
          if (result.errorCode == null) {
            List<ObjectWithOrder<Food>> foodsWithOrder = [];
            if (result.foods!.isNotEmpty) {
              int order = 0;
              for (ObjectWithOrder<Food> food in _foodSearchResult) {
                if (food.order > order) {
                  order = food.order;
                }
              }

              order++;

              for (Food food in result.foods!) {
                foodsWithOrder.add(ObjectWithOrder(object: food, order: order++));
              }
            }

            _addToSearchResult(foodsWithOrder);
            _hasMore = !result.finished!;
            _isLoading = false;
          } else {
            _isLoading = false;
            _hasMore = false;
            clearSearchResult();
            _errorCode.value = result.errorCode;
            _errorMessage = result.errorMessage != null ? result.errorMessage! : OpenEatsJournalStrings.emptyString;
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
    _currentPage = 1;
    _foodSearchResult.clear();
    _foodSearchResultUser.clear();
    _foodSearchResultStandard.clear();
    _foodSearchResultCache.clear();
    _foodSearchResultOpenFoodFacst.clear();
    _sortButtonChanged.notify();
    _showInitialLoading.value = true;
    _foodSearchResultChanged.notify();
  }

  void _searchFinished() {
    _isLoading = false;
    _showInitialLoading.value = false;
  }

  void _addToSearchResult(List<ObjectWithOrder<Food>>? foods) {
    if (foods != null) {
      _foodSearchResult.addAll(foods);
    }

    _foodSearchResultChanged.notify();
  }

  void clearSearchResult() {
    _foodSearchResult.clear();
    _foodSearchResultChanged.notify();
    _sortButtonChanged.notify();
  }

  void setSortOrder(SortOrder sortOrder) {
    _foodSearchResult.clear();
    _sortOrder = sortOrder;
    _sortButtonChanged.notify();

    if (_sortOrder == SortOrder.name) {
      _foodSearchResultUser.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultStandard.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultCache.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultOpenFoodFacst.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
    } else if (_sortOrder == SortOrder.kcal) {
      _foodSearchResultUser.sort((food1, food2) => food2.object.kJoule - food1.object.kJoule);
      _foodSearchResultStandard.sort((food1, food2) => food2.object.kJoule - food1.object.kJoule);
      _foodSearchResultCache.sort((food1, food2) => food2.object.kJoule - food1.object.kJoule);
      _foodSearchResultOpenFoodFacst.sort((food1, food2) => food2.object.kJoule - food1.object.kJoule);
    } else if (_sortOrder == SortOrder.popularity) {
      _foodSearchResultUser.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
      _foodSearchResultStandard.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
      _foodSearchResultCache.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
      _foodSearchResultOpenFoodFacst.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
    }

    if (_sortDesc.value) {
      _foodSearchResult.addAll(_foodSearchResultUser);
      _foodSearchResult.addAll(_foodSearchResultStandard);
      _foodSearchResult.addAll(_foodSearchResultCache);
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacst);
    } else {
      _foodSearchResult.addAll(_foodSearchResultUser.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultStandard.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultCache.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacst.reversed.toList());
    }

    _foodSearchResultChanged.notify();
  }

  void changeSortDirection() {
    _sortDesc.value = !_sortDesc.value;

    _foodSearchResult.clear();
    if (_sortDesc.value) {
      _foodSearchResult.addAll(_foodSearchResultUser);
      _foodSearchResult.addAll(_foodSearchResultStandard);
      _foodSearchResult.addAll(_foodSearchResultCache);
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacst);
    } else {
      _foodSearchResult.addAll(_foodSearchResultUser.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultStandard.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultCache.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacst.reversed.toList());
    }

    _foodSearchResultChanged.notify();
  }

  ObjectWithOrder toElement(Food e, int order) {
    return ObjectWithOrder(object: e, order: order);
  }

  Future<void> addEatsJournalEntry(EatsJournalEntry eatsJournalEntry) async {
    if (eatsJournalEntry.food != null && eatsJournalEntry.food!.isExternalFoodSource) {
      await _foodRepository.setFoodByExternalId(food: eatsJournalEntry.food!);
    }

    await _journalRepository.saveOnceDayNutritionTarget(
      entryDate: eatsJournalEntry.entryDate,
      dayTargetKJoule: _settingsRepository.getCurrentJournalDayTargetKJoule(),
    );
    await _journalRepository.setEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  }

  void toggleFloatingActionButtons() {
    _floatincActionMenuElapsed.value = !_floatincActionMenuElapsed.value;
  }

  Future<double> getLastWeightJournalEntry() async {
    return await _journalRepository.getLastWeightJournalEntry();
  }

  Future<void> setWeightJournalEntry({required DateTime date, required double weight}) async {
    await _journalRepository.setWeightJournalEntry(date: date, weight: weight);
  }

  @override
  void dispose() {
    _currentJournalDate.dispose();
    _currentMeal.dispose();
    _floatincActionMenuElapsed.dispose();
    _foodSearchResultChanged.dispose();
    _showInitialLoading.dispose();
    _errorCode.dispose();
    _searchMessageCode.dispose();
    _sortButtonChanged.dispose();
    _sortDesc.dispose();

    super.dispose();
  }
}

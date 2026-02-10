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
  final List<ObjectWithOrder<Food?>> _foodSearchResultOpenFoodFacts = [];
  final List<ObjectWithOrder<Food?>> _foodSearchResultAll = [];
  final List<ObjectWithOrder<Food?>> _foodSearchResult = [];

  bool _dontLoadMore = false;
  bool _hasMore = false;
  bool _isLoading = false;
  int _currentPage = 1;
  String _currentSearchText = OpenEatsJournalStrings.emptyString;
  final ExternalTriggerChangedNotifier _foodSearchResultChanged = ExternalTriggerChangedNotifier();
  final ValueNotifier<bool> _showInitialLoading = ValueNotifier(false);
  final ValueNotifier<int?> _errorCode = ValueNotifier(null);
  final ValueNotifier<bool> _showIsLoadingMessage = ValueNotifier(false);
  final ValueNotifier<bool> _showBarcodeNotFoundMessage = ValueNotifier(false);
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

  List<ObjectWithOrder<Food?>> get foodSearchResult => _foodSearchResult;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  ExternalTriggerChangedNotifier get foodSearchResultChanged => _foodSearchResultChanged;
  ValueNotifier<bool> get showInitialLoading => _showInitialLoading;
  ValueNotifier<int?> get errorCode => _errorCode;
  ValueNotifier<bool> get showIsLoadingMessage => _showIsLoadingMessage;
  ValueListenable<bool> get showBarcodeNotFoundMessage => _showBarcodeNotFoundMessage;
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

  Future<void> getFoodByBarcode({required Map<String, String> localizations, required SearchMode searchMode, int? barcode}) async {
    if (_checkIsLoading()) {
      return;
    }

    _initSearch();

    if (searchMode != SearchMode.recent) {
      if (barcode == null) {
        _initialSearchFinished();
        finishSearch();
        _isLoading = false;
        _errorCode.value = 4;
        return;
      }
    }

    if (barcode == null) {
      //searchmode must be recent
      //by text allows empty search to return all results, by barcode has no possibility to return all results
      await _foodRepository.getFoodsBySearchText(searchText: OpenEatsJournalStrings.emptyString, languageCode: languageCode, searchMode: searchMode).then((
        List<FoodRepositoryResult> result,
      ) {
        _processInitialResult(result: result, localizations: localizations, searchmode: searchMode);
      });
    } else {
      await _foodRepository.getFoodsByBarcode(barcode: barcode, languageCode: languageCode, searchMode: searchMode).then((List<FoodRepositoryResult> result) {
        _processInitialResult(result: result, localizations: localizations, searchmode: searchMode);
      });
    }
  }

  bool _checkIsLoading() {
    if (_isLoading) {
      _showIsLoadingMessage.value = true;
      return true;
    }

    _showIsLoadingMessage.value = false;
    return false;
  }

  Future<void> getFoodsBySearchText({required String searchText, required Map<String, String> localizations, required SearchMode searchMode}) async {
    if (_checkIsLoading()) {
      return;
    }

    _initSearch();
    _currentSearchText = searchText.trim();

    if (searchMode != SearchMode.recent && _currentSearchText == OpenEatsJournalStrings.emptyString) {
      _initialSearchFinished();
      finishSearch();
      _isLoading = false;
      _errorCode.value = 4;
      return;
    }

    await _foodRepository.getFoodsBySearchText(searchText: searchText, languageCode: languageCode, searchMode: searchMode).then((
      List<FoodRepositoryResult> result,
    ) {
      _processInitialResult(result: result, localizations: localizations, searchmode: searchMode);
    });
  }

  void _processInitialResult({required List<FoodRepositoryResult> result, required Map<String, String> localizations, required SearchMode searchmode}) {
    _initialSearchFinished();

    int order = 0;
    List<ObjectWithOrder<Food?>>? foodsWithOrder = [];

    if (searchmode == SearchMode.online && result[3].errorCode == null) {
      if (result[3].foods == null || result[3].foods!.isEmpty) {
        _showBarcodeNotFoundMessage.value = true;
      }
    }

    //Popularity in recent mode shall not be ordered by source first, but strictly after usage amount
    if (result[4].foods != null && result[4].foods!.isNotEmpty) {
      for (Food food in result[4].foods!) {
        if (food.foodUnitsWithOrder.isNotEmpty) {
          for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
            if (localizations.containsKey(unitWithOrder.object.name)) {
              unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
            }
          }
        }

        _foodSearchResultAll.add(ObjectWithOrder(object: food, order: order++));
      }

      if (searchmode == SearchMode.recent) {
        foodsWithOrder.addAll(_foodSearchResultAll);
      }
    }

    if (result[0].foods != null && result[0].foods!.isNotEmpty) {
      for (Food food in result[0].foods!) {
        _foodSearchResultUser.add(ObjectWithOrder(object: food, order: order++));
      }

      if (searchmode != SearchMode.recent) {
        foodsWithOrder.addAll(_foodSearchResultUser);
      }
    }

    if (result[1].foods != null && result[1].foods!.isNotEmpty) {
      for (Food food in result[1].foods!) {
        _foodSearchResultStandard.add(ObjectWithOrder(object: food, order: order++));
      }

      if (searchmode != SearchMode.recent) {
        foodsWithOrder.addAll(_foodSearchResultStandard);
      }
    }

    if (result[2].foods != null && result[2].foods!.isNotEmpty) {
      for (Food food in result[2].foods!) {
        _foodSearchResultCache.add(ObjectWithOrder(object: food, order: order++));
      }

      if (searchmode != SearchMode.recent) {
        foodsWithOrder.addAll(_foodSearchResultCache);
      }
    }

    if (result[3].errorCode == null) {
      if (result[3].foods != null && result[3].foods!.isNotEmpty) {
        for (Food food in result[3].foods!) {
          _foodSearchResultOpenFoodFacts.add(ObjectWithOrder(object: food, order: order++));
        }

        if (searchmode != SearchMode.recent) {
          foodsWithOrder.addAll(_foodSearchResultOpenFoodFacts);
        }
      } else {
        //If Open Food Facts return nothing, this null food will display the Open Food Facts contribution hint in the ui.
        if (searchmode == SearchMode.online) {
          _foodSearchResultOpenFoodFacts.add(ObjectWithOrder(object: null, order: order++));

          if (searchmode != SearchMode.recent) {
            foodsWithOrder.addAll(_foodSearchResultOpenFoodFacts);
          }
        }
      }
    }

    _addToSearchResult(foodsWithOrder);

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

    _isLoading = false;
  }

  Future<void> getFoodBySearchTextLoadMore() async {
    if (_checkIsLoading()) {
      return;
    }

    _isLoading = true;
    _currentPage = _currentPage + 1;
    await _foodRepository
        .getOpenFoodFactsFoodBySearchTextApiV1(searchText: _currentSearchText, languageCode: _settingsRepository.languageCode.value, page: _currentPage)
        .then((FoodRepositoryResult result) {
          if (result.errorCode == null) {
            List<ObjectWithOrder<Food>> foodsWithOrder = [];
            if (result.foods!.isNotEmpty) {
              int order = 0;
              for (ObjectWithOrder<Food?> food in _foodSearchResult) {
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

            if (!_dontLoadMore) {
              if (result.finished!) {
                finishSearch();
              }
            }
          } else {
            finishSearch();
            _errorCode.value = result.errorCode;
            _errorMessage = result.errorMessage != null ? result.errorMessage! : OpenEatsJournalStrings.emptyString;
          }

          _isLoading = false;
        });
  }

  void _initSearch() {
    _isLoading = true;
    _dontLoadMore = false;
    _hasMore = false;
    _sortOrder == SortOrder.popularity;
    _sortDesc.value = true;
    _sortButtonEnabled = true;
    _errorMessage = OpenEatsJournalStrings.emptyString;
    _errorCode.value = null;
    _searchMessageCode.value = null;
    _currentPage = 1;
    _clearAllSearchResults();
    _sortButtonChanged.notify();
    _showInitialLoading.value = true;
    _showBarcodeNotFoundMessage.value = false;
    _foodSearchResultChanged.notify();
  }

  void _initialSearchFinished() {
    _showInitialLoading.value = false;
  }

  void _addToSearchResult(List<ObjectWithOrder<Food?>>? foods) {
    if (foods != null) {
      _foodSearchResult.addAll(foods);
    }

    _foodSearchResultChanged.notify();
  }

  void setSortOrder({required SortOrder sortOrder, required SearchMode searchMode}) {
    _foodSearchResult.clear();
    _sortOrder = sortOrder;
    _sortButtonChanged.notify();

    if (_sortOrder == SortOrder.name) {
      _foodSearchResultUser.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultStandard.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultCache.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
      _foodSearchResultOpenFoodFacts.sort((food1, food2) => _compareNullFoodWithOrder(foodWithOrder1: food1, foodWithOrder2: food2, sortOrder: sortOrder));
    } else if (_sortOrder == SortOrder.kcal) {
      _foodSearchResultUser.sort((food1, food2) => food1.object.kJoule.compareTo(food2.object.kJoule));
      _foodSearchResultStandard.sort((food1, food2) => food1.object.kJoule.compareTo(food2.object.kJoule));
      _foodSearchResultCache.sort((food1, food2) => food1.object.kJoule.compareTo(food2.object.kJoule));
      _foodSearchResultOpenFoodFacts.sort((food1, food2) => _compareNullFoodWithOrder(foodWithOrder1: food1, foodWithOrder2: food2, sortOrder: sortOrder));
    } else if (_sortOrder == SortOrder.popularity) {
      if (searchMode != SearchMode.recent) {
        _foodSearchResultUser.sort((food1, food2) => food1.order.compareTo(food2.order));
        _foodSearchResultStandard.sort((food1, food2) => food1.order.compareTo(food2.order));
        _foodSearchResultCache.sort((food1, food2) => food1.order.compareTo(food2.order));
        _foodSearchResultOpenFoodFacts.sort((food1, food2) => food1.order.compareTo(food2.order));
      }
    }

    if (_sortDesc.value) {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultAll);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser);
        _foodSearchResult.addAll(_foodSearchResultStandard);
        _foodSearchResult.addAll(_foodSearchResultCache);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts);
      }
    } else {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultAll.reversed);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser.reversed);
        _foodSearchResult.addAll(_foodSearchResultStandard.reversed);
        _foodSearchResult.addAll(_foodSearchResultCache.reversed);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts.reversed);
      }
    }

    _foodSearchResultChanged.notify();
  }

  int _compareNullFoodWithOrder({
    required ObjectWithOrder<Food?> foodWithOrder1,
    required ObjectWithOrder<Food?> foodWithOrder2,
    required SortOrder sortOrder,
  }) {
    if (foodWithOrder1.object == null) {
      return -1;
    }

    if (foodWithOrder2.object == null) {
      return 1;
    }

    if (sortOrder == SortOrder.kcal) {
      return foodWithOrder1.object!.kJoule.compareTo(foodWithOrder2.object!.kJoule);
    } else {
      return foodWithOrder1.object!.name.compareTo(foodWithOrder2.object!.name);
    }
  }

  void changeSortDirection() {
    _sortDesc.value = !_sortDesc.value;

    _foodSearchResult.clear();
    if (_sortDesc.value) {
      _foodSearchResult.addAll(_foodSearchResultUser);
      _foodSearchResult.addAll(_foodSearchResultStandard);
      _foodSearchResult.addAll(_foodSearchResultCache);
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts);
    } else {
      _foodSearchResult.addAll(_foodSearchResultUser.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultStandard.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultCache.reversed.toList());
      _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts.reversed.toList());
    }

    _foodSearchResultChanged.notify();
  }

  ObjectWithOrder toElement(Food e, int order) {
    return ObjectWithOrder(object: e, order: order);
  }

  Future<void> addEatsJournalEntry(EatsJournalEntry eatsJournalEntry) async {
    await _foodRepository.setFoodByExternalIdIfNecessary(food: eatsJournalEntry.food!);

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

  void finishSearch() {
    _dontLoadMore = true;
    _hasMore = false;
  }

  void _clearAllSearchResults() {
    _foodSearchResult.clear();
    _foodSearchResultUser.clear();
    _foodSearchResultStandard.clear();
    _foodSearchResultCache.clear();
    _foodSearchResultOpenFoodFacts.clear();
    _foodSearchResultAll.clear();
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

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

  final List<ObjectWithOrder<Food>> _foodSearchResult = [];
  bool _hasMore = false;
  bool _isLoading = false;
  int _currentPage = 1;
  String _currentSearchText = OpenEatsJournalStrings.emptyString;
  String _currentLanguageCode = OpenEatsJournalStrings.emptyString;
  final ExternalTriggerChangedNotifier _foodSearchResultChanged = ExternalTriggerChangedNotifier();
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

  void _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  void _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  Future<void> getFoodByBarcode({required int barcode, required String languageCode, required Map<String, String> localizations}) async {
    _initSearch();
    await _foodRepository.getFoodByBarcode(barcode: barcode, languageCode: languageCode).then((FoodRepositoryResult result) {
      _searchFinished();

      if (result.errorCode == null) {
        List<ObjectWithOrder<Food>>? foodsWithOrder;
        if (result.foods != null) {
          foodsWithOrder = [];
          int order = 0;
          for (Food food in result.foods!) {
            if (food.isExternalFoodSource && food.foodUnitsWithOrder.isNotEmpty) {
              for (ObjectWithOrder<FoodUnit> unitWithOrder in result.foods![0].foodUnitsWithOrder) {
                if (localizations.containsKey(unitWithOrder.object.name)) {
                  unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
                }
              }
            }

            foodsWithOrder.add(ObjectWithOrder(object: food, order: order));
            order++;
          }
        }

        _addToSearchResult(foodsWithOrder);
      } else {
        _errorCode.value = result.errorCode;
      }
    });
  }

  Future<void> getFoodBySearchText({required String searchText, required String languageCode, required Map<String, String> localizations}) async {
    _initSearch();
    _currentSearchText = searchText;
    _currentLanguageCode = languageCode;
    await _foodRepository.getFoodBySearchText(searchText: searchText, languageCode: languageCode).then((FoodRepositoryResult result) {
      _searchFinished();

      if (result.errorCode == null) {
        List<ObjectWithOrder<Food>>? foodsWithOrder;
        if (result.foods!.isNotEmpty) {
          int order = 0;
          foodsWithOrder = [];

          for (Food food in result.foods!) {
            if (food.foodUnitsWithOrder.isNotEmpty) {
              for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
                if (localizations.containsKey(unitWithOrder.object.name)) {
                  unitWithOrder.object.name = localizations[unitWithOrder.object.name]!;
                }
              }
            }

            foodsWithOrder.add(ObjectWithOrder(object: food, order: order++));
          }

          if (result.finished!) {
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

        _addToSearchResult(foodsWithOrder);
      } else {
        _errorCode.value = result.errorCode;
      }
    });
  }

  Future<void> getFoodBySearchTextLoadMore() async {
    _isLoading = true;
    _currentPage = _currentPage + 1;
    await _foodRepository.getOpenFoodFactsFoodBySearchTextApiV1(searchText: _currentSearchText, languageCode: _currentLanguageCode, page: _currentPage).then((
      FoodRepositoryResult result,
    ) {
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
    _currentPage = 1;
    _foodSearchResult.clear();
    _sortButtonChanged.notify();
    _showInitialLoading.value = true;
    _foodSearchResultChanged.notify();
  }

  _searchFinished() {
    _isLoading = false;
    _showInitialLoading.value = false;
  }

  void _addToSearchResult(List<ObjectWithOrder<Food>>? foods) {
    if (foods != null) {
      _foodSearchResult.addAll(foods);
    }

    _foodSearchResultChanged.notify();
  }

  void _clearSearchResult() {
    _foodSearchResult.clear();
    _foodSearchResultChanged.notify();
    _sortButtonChanged.notify();
  }

  void setSortOrder(SortOrder sortOrder) {
    _sortOrder = sortOrder;
    _sortButtonChanged.notify();

    if (_sortOrder == SortOrder.name) {
      _foodSearchResult.sort((food1, food2) => food1.object.name.compareTo(food2.object.name));
    } else if (_sortOrder == SortOrder.kcal) {
      _foodSearchResult.sort((food1, food2) => food2.object.kJoule - food1.object.kJoule);
    } else if (_sortOrder == SortOrder.popularity) {
      _foodSearchResult.sort((food1, food2) => food1.order > food2.order ? 1 : -1);
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

    super.dispose();
  }
}

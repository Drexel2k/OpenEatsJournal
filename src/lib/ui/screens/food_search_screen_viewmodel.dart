import "package:async/async.dart";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/food_search_result_status_code.dart";
import "package:openeatsjournal/ui/utils/food_search_result_entry.dart";
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
  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime.utc(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);
  final ValueNotifier<bool> _floatincActionMenuElapsed = ValueNotifier(false);

  //in online and offline searches, local data is always shown first, therefor we need the buckets
  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResultUser = [];
  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResultStandard = [];
  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResultCache = [];
  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResultOpenFoodFacts = [];

  //only one bucket for recent search, as result is not shown in buckets but in selected order only
  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResultRecent = [];

  final List<ObjectWithOrder<FoodSearchResultEntry>> _foodSearchResult = [];

  final List<CancelableOperation> _searchOperations = [];

  int _currentPage = 1;
  String _currentSearchText = OpenEatsJournalStrings.emptyString;
  final ExternalTriggerChangedNotifier _foodSearchResultChanged = ExternalTriggerChangedNotifier();
  final ValueNotifier<int?> _errorCode = ValueNotifier(null);
  String _errorMessage = OpenEatsJournalStrings.emptyString;
  final ValueNotifier<int?> _searchMessageCode = ValueNotifier(null);
  final ExternalTriggerChangedNotifier _sortButtonChanged = ExternalTriggerChangedNotifier();
  bool _sortButtonEnabled = true;
  SortOrder _sortOrder = SortOrder.popularity;
  final ValueNotifier<bool> _sortDesc = ValueNotifier(true);

  bool _disposed = false;

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;
  String get languageCode => _settingsRepository.languageCode.value;
  ValueNotifier<bool> get floatingActionMenuElapsed => _floatincActionMenuElapsed;

  List<ObjectWithOrder<FoodSearchResultEntry>> get foodSearchResult => _foodSearchResult;
  ExternalTriggerChangedNotifier get foodSearchResultChanged => _foodSearchResultChanged;
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

  Future<void> getFoodByBarcode({required Map<String, String> foodUnitLocalizations, required SearchMode searchMode, int? barcode}) async {
    _initSearch(searchMode: searchMode);

    if (searchMode != SearchMode.recent) {
      if (barcode == null) {
        _errorCode.value = 4;
        return;
      }
    }

    //Make the searches cancelable, so that the user can start new searches while a search is still running
    CancelableOperation searchOperation;

    if (searchMode != SearchMode.recent) {
      if (searchMode == SearchMode.online) {
        searchOperation = CancelableOperation.fromFuture(_foodRepository.getFoodByBarcodeOpenFoodFacts(barcode: barcode!, languageCode: languageCode));
        _searchOperations.add(searchOperation);

        searchOperation.then((result) {
          _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
        });
      }

      searchOperation = CancelableOperation.fromFuture(_foodRepository.getFoodsByBarcodeDb(barcode: barcode!, languageCode: languageCode, includeCache: true));
      _searchOperations.add(searchOperation);

      searchOperation.then((result) {
        _processResult(result: result, foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
      });
    } else {
      if (barcode == null) {
        //On null barcode we want to return simply all results on recent search. FoodRepository by barcode has no possibility to return all results. Therefore
        //we take the workaround by text as this allows empty search to return all results,
        searchOperation = CancelableOperation.fromFuture(
          _foodRepository.getFoodsBySearchTextByUsageDb(searchText: OpenEatsJournalStrings.emptyString, languageCode: languageCode),
        );
        _searchOperations.add(searchOperation);

        searchOperation.then((result) {
          _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
        });
      } else {
        searchOperation = CancelableOperation.fromFuture(_foodRepository.getFoodsByBarcodeByUsageDb(barcode: barcode, languageCode: languageCode));
        _searchOperations.add(searchOperation);

        searchOperation.then((result) {
          _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
        });
      }
    }
  }

  Future<void> getFoodsBySearchText({required String searchText, required Map<String, String> foodUnitLocalizations, required SearchMode searchMode}) async {
    _initSearch(searchMode: searchMode);
    _currentSearchText = searchText.trim();

    if (searchMode != SearchMode.recent && _currentSearchText == OpenEatsJournalStrings.emptyString) {
      _errorCode.value = 4;
      return;
    }

    //Make the searches cancelable, so that the user can start new searches while a search is still running
    CancelableOperation searchOperation;
    if (searchMode != SearchMode.recent) {
      if (searchMode == SearchMode.online) {
        searchOperation = CancelableOperation.fromFuture(_foodRepository.getFoodsBySearchTextOpenFoodFacts(searchText: searchText, languageCode: languageCode));
        _searchOperations.add(searchOperation);

        searchOperation.then((result) {
          _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
        });
      }

      searchOperation = CancelableOperation.fromFuture(
        _foodRepository.getFoodsBySearchTextDb(searchText: searchText, languageCode: languageCode, includeCache: true),
      );
      _searchOperations.add(searchOperation);

      searchOperation.then((result) {
        _processResult(result: result, foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
      });
    } else {
      searchOperation = CancelableOperation.fromFuture(_foodRepository.getFoodsBySearchTextByUsageDb(searchText: searchText, languageCode: languageCode));
      _searchOperations.add(searchOperation);

      searchOperation.then((result) {
        _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: searchMode);
      });
    }
  }

  void _processResult({required List<FoodRepositoryResult> result, required Map<String, String> foodUnitLocalizations, required SearchMode searchmode}) {
    if (searchmode != SearchMode.recent) {
      //open food facts result is length 1, db result is length 3
      //open food facts result can call this code multiple times due to pagination, db result is only queried one time and therefore calls this code only once
      if (result.length > 1) {
        _getAndRemoveStatusOnResultEntries(resultEntries: _foodSearchResultUser, foodSearchResultStatusCode: FoodSearchResultStatusCode.offlineIsLoading);

        if (result.every((resultInternal) => resultInternal.foods == null || resultInternal.foods!.isEmpty)) {
          _foodSearchResultUser.add(ObjectWithOrder(object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.offlineNoResult), order: 0));
        }
      } else {
        _getAndRemoveStatusOnResultEntries(
          resultEntries: _foodSearchResultOpenFoodFacts,
          foodSearchResultStatusCode: FoodSearchResultStatusCode.openFoodFactsIsLoading,
        );

        _getAndRemoveStatusOnResultEntries(
          resultEntries: _foodSearchResultOpenFoodFacts,
          foodSearchResultStatusCode: FoodSearchResultStatusCode.openFoodFactsMoreResults,
        );

        if (result[0].errorCode == null && (result[0].foods == null || result[0].foods!.isEmpty)) {
          if (_foodSearchResultOpenFoodFacts.isEmpty && result[0].finished!) {
            _foodSearchResultOpenFoodFacts.add(
              ObjectWithOrder(object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.openFoodFactsNoResult), order: 0),
            );
          }
        }
      }

      for (FoodRepositoryResult foodRepositoryResult in result) {
        if (foodRepositoryResult.foodSources[0] == FoodSource.user) {
          if (foodRepositoryResult.foods != null && foodRepositoryResult.foods!.isNotEmpty) {
            int order = 0;
            for (Food food in foodRepositoryResult.foods!) {
              _foodSearchResultUser.add(
                ObjectWithOrder(
                  object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.searchResult, food: food),
                  order: order++,
                ),
              );
            }
          }
        }

        if (foodRepositoryResult.foodSources[0] == FoodSource.standard) {
          if (foodRepositoryResult.foods != null && foodRepositoryResult.foods!.isNotEmpty) {
            int order = 0;
            for (Food food in foodRepositoryResult.foods!) {
              _foodSearchResultStandard.add(
                ObjectWithOrder(
                  object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.searchResult, food: food),
                  order: order++,
                ),
              );
            }
          }
        }

        if (foodRepositoryResult.foodSources[0] == FoodSource.openFoodFacts) {
          if (foodRepositoryResult.errorCode == null) {
            if (foodRepositoryResult.foods != null && foodRepositoryResult.foods!.isNotEmpty) {
              ObjectWithOrder<FoodSearchResultEntry> foodSearchResultWithOrder;

              List<ObjectWithOrder<FoodSearchResultEntry>> foodSearchResult;
              if (foodRepositoryResult.fromDb) {
                foodSearchResult = _foodSearchResultCache;
              } else {
                foodSearchResult = _foodSearchResultOpenFoodFacts;
              }

              int order = 0;
              for (Food food in foodRepositoryResult.foods!) {
                _translateStandardFoodUnits(food, foodUnitLocalizations);
                foodSearchResultWithOrder = ObjectWithOrder(
                  object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.searchResult, food: food),
                  order: order++,
                );

                foodSearchResult.add(foodSearchResultWithOrder);
              }

              if (!foodRepositoryResult.fromDb) {
                if (!foodRepositoryResult.finished!) {
                  _foodSearchResultOpenFoodFacts.add(
                    ObjectWithOrder(
                      object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.openFoodFactsMoreResults),
                      order: order++,
                    ),
                  );
                }
              }
            }
          } else {
            _errorCode.value = foodRepositoryResult.errorCode;
            _errorMessage = foodRepositoryResult.errorMessage != null ? foodRepositoryResult.errorMessage! : OpenEatsJournalStrings.emptyString;

            if (_foodSearchResultOpenFoodFacts.isNotEmpty) {
              int nextOrder =
                  _foodSearchResultOpenFoodFacts.fold<int>(-1, (max, currentSearchEntry) => currentSearchEntry.order > max ? currentSearchEntry.order : max) +
                  1;

              _foodSearchResultOpenFoodFacts.add(
                ObjectWithOrder(
                  object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.openFoodFactsError),
                  order: nextOrder,
                ),
              );
            }
          }
        }
      }
    } else {
      //recent, only db results
      if (result[0].foods != null && result[0].foods!.isNotEmpty) {
        int order = 0;
        for (Food food in result[0].foods!) {
          _translateStandardFoodUnits(food, foodUnitLocalizations);

          //Popularity in recent mode shall not be ordered by source first, but strictly after usage amount.
          _foodSearchResultRecent.add(
            ObjectWithOrder(
              object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.searchResult, food: food),
              order: order++,
            ),
          );
        }
      }
    }

    _updateSearchResult(searchMode: searchmode);

    if (_foodSearchResult.length > 500) {
      _searchMessageCode.value = 1;
      if (_sortButtonEnabled == true || _sortOrder != SortOrder.popularity) {
        _sortButtonEnabled = false;
        _sortOrder = SortOrder.popularity;
        _sortButtonChanged.notify();
      }
    }
  }

  void _translateStandardFoodUnits(Food food, Map<String, String> foodUnitLocalizations) {
    if (food.foodUnitsWithOrder.isNotEmpty) {
      for (ObjectWithOrder<FoodUnit> unitWithOrder in food.foodUnitsWithOrder) {
        if (foodUnitLocalizations.containsKey(unitWithOrder.object.name)) {
          unitWithOrder.object.name = foodUnitLocalizations[unitWithOrder.object.name]!;
        }
      }
    }
  }

  Future<void> getFoodBySearchTextLoadMore({required Map<String, String> foodUnitLocalizations}) async {
    _currentPage = _currentPage + 1;
    await _foodRepository
        .getOpenFoodFactsFoodBySearchTextApiV1(searchText: _currentSearchText, languageCode: _settingsRepository.languageCode.value, page: _currentPage)
        .then((FoodRepositoryResult result) {
          _processResult(result: [result], foodUnitLocalizations: foodUnitLocalizations, searchmode: SearchMode.online);
        });
  }

  //always called after _checkIsLoading
  void _initSearch({required SearchMode searchMode}) {
    _cancelSearchOperations();
    _sortOrder = SortOrder.popularity;
    _sortDesc.value = true;
    _sortButtonEnabled = true;
    _errorMessage = OpenEatsJournalStrings.emptyString;
    _errorCode.value = null;
    _searchMessageCode.value = null;
    _currentPage = 1;
    _initAllSearchResults(searchMode: searchMode);
    _sortButtonChanged.notify();
    _foodSearchResultChanged.notify();
  }

  void _updateSearchResult({required SearchMode searchMode}) {
    if (!_disposed) {
      _foodSearchResult.clear();

      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultRecent);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser);
        _foodSearchResult.addAll(_foodSearchResultStandard);
        _foodSearchResult.addAll(_foodSearchResultCache);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts);
      }
      _foodSearchResultChanged.notify();
    }
  }

  void setSortOrder({required SortOrder sortOrder, required SearchMode searchMode}) {
    _foodSearchResult.clear();
    _sortOrder = sortOrder;
    _sortButtonChanged.notify();

    ObjectWithOrder<FoodSearchResultEntry>? foodSearchResultEntryPaginationError = _getAndRemoveStatusOnResultEntries(
      resultEntries: _foodSearchResultOpenFoodFacts,
      foodSearchResultStatusCode: FoodSearchResultStatusCode.openFoodFactsError,
    );

    //Sorting with no result hint doesn't trigger null reference on food object, because sort doesn't do anything when there is only one item in the list.
    if (_sortOrder == SortOrder.name) {
      _foodSearchResultUser.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.name.toLowerCase().compareTo(foodSearchResultEntryWithOrder2.object.food!.name.toLowerCase()),
      );
      _foodSearchResultStandard.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.name.toLowerCase().compareTo(foodSearchResultEntryWithOrder2.object.food!.name.toLowerCase()),
      );
      _foodSearchResultCache.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.name.toLowerCase().compareTo(foodSearchResultEntryWithOrder2.object.food!.name.toLowerCase()),
      );

      _foodSearchResultOpenFoodFacts.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.name.toLowerCase().compareTo(foodSearchResultEntryWithOrder2.object.food!.name.toLowerCase()),
      );

      _foodSearchResultRecent.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.name.toLowerCase().compareTo(foodSearchResultEntryWithOrder2.object.food!.name.toLowerCase()),
      );
    } else if (_sortOrder == SortOrder.kcal) {
      _foodSearchResultUser.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.kJoule.compareTo(foodSearchResultEntryWithOrder2.object.food!.kJoule),
      );
      _foodSearchResultStandard.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.kJoule.compareTo(foodSearchResultEntryWithOrder2.object.food!.kJoule),
      );
      _foodSearchResultCache.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.kJoule.compareTo(foodSearchResultEntryWithOrder2.object.food!.kJoule),
      );

      _foodSearchResultOpenFoodFacts.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.kJoule.compareTo(foodSearchResultEntryWithOrder2.object.food!.kJoule),
      );

      _foodSearchResultRecent.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.object.food!.kJoule.compareTo(foodSearchResultEntryWithOrder2.object.food!.kJoule),
      );
    } else if (_sortOrder == SortOrder.popularity) {
      _foodSearchResultUser.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.order.compareTo(foodSearchResultEntryWithOrder2.order),
      );
      _foodSearchResultStandard.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.order.compareTo(foodSearchResultEntryWithOrder2.order),
      );
      _foodSearchResultCache.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.order.compareTo(foodSearchResultEntryWithOrder2.order),
      );

      _foodSearchResultOpenFoodFacts.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.order.compareTo(foodSearchResultEntryWithOrder2.order),
      );

      _foodSearchResultRecent.sort(
        (foodSearchResultEntryWithOrder1, foodSearchResultEntryWithOrder2) =>
            foodSearchResultEntryWithOrder1.order.compareTo(foodSearchResultEntryWithOrder2.order),
      );
    }

    if (_sortDesc.value) {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultRecent);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser);
        _foodSearchResult.addAll(_foodSearchResultStandard);
        _foodSearchResult.addAll(_foodSearchResultCache);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts);

        if (foodSearchResultEntryPaginationError != null) {
          _foodSearchResultOpenFoodFacts.add(foodSearchResultEntryPaginationError);
          _foodSearchResult.add(foodSearchResultEntryPaginationError);
        }
      }
    } else {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultRecent.reversed);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser.reversed);
        _foodSearchResult.addAll(_foodSearchResultStandard.reversed);
        _foodSearchResult.addAll(_foodSearchResultCache.reversed);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts.reversed);

        //ensure hint that loading more foods on pagination failed is still at the end on reverse sorting
        if (foodSearchResultEntryPaginationError != null) {
          _foodSearchResultOpenFoodFacts.add(foodSearchResultEntryPaginationError);
          _foodSearchResult.add(foodSearchResultEntryPaginationError);
        }
      }
    }

    _foodSearchResultChanged.notify();
  }

  //Open food facts result may have results and at the end a hint that loading more foods on pagination failed e.g.. We need to remove the hint (it has no food
  //which will result in a null reference excpetion), sort, and then add it again at the end.
  ObjectWithOrder<FoodSearchResultEntry>? _getAndRemoveStatusOnResultEntries({
    required List<ObjectWithOrder<FoodSearchResultEntry>> resultEntries,
    required FoodSearchResultStatusCode foodSearchResultStatusCode,
  }) {
    ObjectWithOrder<FoodSearchResultEntry>? foodSearchResultWithStatus = resultEntries.firstWhereOrNull(
      (foodSearchResultEntryWithOrder) => foodSearchResultEntryWithOrder.object.foodSearchResultCode == foodSearchResultStatusCode,
    );

    if (foodSearchResultWithStatus != null) {
      resultEntries.remove(foodSearchResultWithStatus);
    }

    return foodSearchResultWithStatus;
  }

  void changeSortDirection({required SearchMode searchMode}) {
    _sortDesc.value = !_sortDesc.value;

    _foodSearchResult.clear();
    if (_sortDesc.value) {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultRecent);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser);
        _foodSearchResult.addAll(_foodSearchResultStandard);
        _foodSearchResult.addAll(_foodSearchResultCache);
        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts);
      }
    } else {
      if (searchMode == SearchMode.recent) {
        _foodSearchResult.addAll(_foodSearchResultRecent.reversed);
      } else {
        _foodSearchResult.addAll(_foodSearchResultUser.reversed);
        _foodSearchResult.addAll(_foodSearchResultStandard.reversed);
        _foodSearchResult.addAll(_foodSearchResultCache.reversed);

        ObjectWithOrder<FoodSearchResultEntry>? foodSearchResultEntryPaginationError = _getAndRemoveStatusOnResultEntries(
          resultEntries: _foodSearchResultOpenFoodFacts,
          foodSearchResultStatusCode: FoodSearchResultStatusCode.openFoodFactsError,
        );

        _foodSearchResult.addAll(_foodSearchResultOpenFoodFacts.reversed);

        //ensure hint that loading more foods on pagination failed is still at the end on reverse sorting
        if (foodSearchResultEntryPaginationError != null) {
          _foodSearchResultOpenFoodFacts.add(foodSearchResultEntryPaginationError);
          _foodSearchResult.add(foodSearchResultEntryPaginationError);
        }
      }
    }

    _foodSearchResultChanged.notify();
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

  void _cancelSearchOperations() {
    for (CancelableOperation searchOperation in _searchOperations) {
      searchOperation.cancel();
    }

    _searchOperations.clear();
  }

  void _initAllSearchResults({required SearchMode searchMode}) {
    _foodSearchResult.clear();
    _foodSearchResultUser.clear();
    _foodSearchResultStandard.clear();
    _foodSearchResultCache.clear();
    _foodSearchResultOpenFoodFacts.clear();
    _foodSearchResultRecent.clear();

    ObjectWithOrder<FoodSearchResultEntry> offlineIsLoading = ObjectWithOrder(
      object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.offlineIsLoading),
      order: 0,
    );
    _foodSearchResultUser.add(offlineIsLoading);
    _foodSearchResult.add(offlineIsLoading);

    if (searchMode == SearchMode.online) {
      ObjectWithOrder<FoodSearchResultEntry> openFoodFactsIsLoading = ObjectWithOrder(
        object: FoodSearchResultEntry(foodSearchResultCode: FoodSearchResultStatusCode.openFoodFactsIsLoading),
        order: 0,
      );

      _foodSearchResultOpenFoodFacts.add(openFoodFactsIsLoading);
      _foodSearchResult.add(openFoodFactsIsLoading);
    }
  }

  Food getNewFood() {
    return _foodRepository.getNewFood();
  }

  EatsJournalEntry getNewQuickEntry({required DateTime entryDate, required Meal meal}) {
    return _journalRepository.getNewQuickEntry(
      entryDate: entryDate,
      name: OpenEatsJournalStrings.emptyString,
      kJoule: NutritionCalculator.kJouleForOnekCal,
      meal: meal,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _currentJournalDate.dispose();
    _currentMeal.dispose();
    _floatincActionMenuElapsed.dispose();
    _foodSearchResultChanged.dispose();
    _errorCode.dispose();
    _searchMessageCode.dispose();
    _sortButtonChanged.dispose();
    _sortDesc.dispose();

    super.dispose();
  }
}

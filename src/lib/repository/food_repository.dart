import "dart:convert";
import "package:collection/collection.dart";
import "package:http/http.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/ordered_default_food_unit.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/convert.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";
import "package:openeatsjournal/service/open_food_facts/data/food_api.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/search_mode.dart";

class FoodRepository {
  FoodRepository._singleton();
  static final FoodRepository instance = FoodRepository._singleton();

  late OpenFoodFactsService _openFoodFactsService;
  late OpenEatsJournalDatabaseService _oejDatabaseService;
  late OpenEatsJournalAssetsService _oejAssetsService;

  final int _pageSize = 100;
  final int _dayForFoodUsage = 43;
  final DateFormat _csvDateFormat = DateFormat("yyyy-MM-dd HH-mm-ss");

  //must be called once before the singleton is used
  void init({
    required OpenFoodFactsService openFoodFactsService,
    required OpenEatsJournalDatabaseService oejDatabaseService,
    required OpenEatsJournalAssetsService oejAssetsService,
  }) {
    _openFoodFactsService = openFoodFactsService;
    _oejDatabaseService = oejDatabaseService;
    _oejAssetsService = oejAssetsService;
  }

  //result list must always contain exactly 4 entries, index 0 = user results, index 1 = standard results, index 2 = cached results, 3= open food facts results,
  // index 4 = all results
  Future<List<FoodRepositoryResult>> getFoodsByBarcode({required int barcode, required String languageCode, required SearchMode searchMode}) async {
    List<FoodRepositoryResult> result = [];

    List<int> localFoodSources;
    if (searchMode == SearchMode.online) {
      localFoodSources = [FoodSource.user.value];
    } else {
      localFoodSources = [FoodSource.user.value, FoodSource.openFoodFacts.value];
    }

    List<Food> allResults = [];
    List<Map<String, Object?>>? dbResult = searchMode != SearchMode.recent
        ? await _oejDatabaseService.getFoodsByBarcode(barcode: barcode, foodSourceIds: localFoodSources)
        : await _oejDatabaseService.getFoodsByBarcodeByUsage(barcode: barcode, foodSourceIds: localFoodSources, days: _dayForFoodUsage);

    List<Food>? foods = dbResult != null ? Convert.getFoodsFromDbResult(dbResult: dbResult) : [];

    Food? foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.user);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.user).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.standard);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.standard).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.openFoodFacts);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.openFoodFacts).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    if (searchMode == SearchMode.online) {
      result.add(await getOpenFoodFactsFoodByBarcode(barcode: barcode, languageCode: languageCode));
    } else {
      result.add(FoodRepositoryResult());
    }

    if (result[3].foods != null) {
      allResults.addAll(result[3].foods!);
    }

    if (allResults.isNotEmpty) {
      result.add(FoodRepositoryResult(foods: allResults));
    } else {
      result.add(FoodRepositoryResult());
    }

    return result;
  }

  Future<FoodRepositoryResult> getOpenFoodFactsFoodByBarcode({required int barcode, required String languageCode}) async {
    String? jsonString;
    try {
      jsonString = await _openFoodFactsService.getFoodByBarcode(barcode: barcode);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult(errorCode: 1, errorMessage: clientException.message);
    }

    if (jsonString != null) {
      Map<String, dynamic> json;
      try {
        json = jsonDecode(jsonString);
      } on FormatException {
        return FoodRepositoryResult(errorCode: 5);
      }

      if (json.containsKey(OpenFoodFactsApiStrings.product)) {
        Food? food = _getFoodFromOpenFoodFactsApiV1V2Food(json: json[OpenFoodFactsApiStrings.product], languageCode: languageCode);

        if (food != null) {
          return FoodRepositoryResult(foods: [food]);
        }

        return FoodRepositoryResult();
      } else {
        //no food found for this barcode
        return FoodRepositoryResult();
      }
    }

    return FoodRepositoryResult(errorCode: 3);
  }

  //result list must always contain exactly 4 entries, index 0 = user results, index 1 = standard results, index 2 = cached results, 3= open food facts results,
  // index 4 = all results
  Future<List<FoodRepositoryResult>> getFoodsBySearchText({required String searchText, required String languageCode, required SearchMode searchMode}) async {
    List<FoodRepositoryResult> result = [];

    List<int> localFoodSources;
    if (searchMode == SearchMode.online) {
      localFoodSources = [FoodSource.user.value, FoodSource.standard.value];
    } else {
      localFoodSources = [FoodSource.user.value, FoodSource.openFoodFacts.value, FoodSource.standard.value];
    }

    List<Map<String, Object?>>? dbResult = searchMode != SearchMode.recent
        ? await _oejDatabaseService.getFoodsBySearchtext(searchText: searchText, foodSourceIds: localFoodSources)
        : await _oejDatabaseService.getFoodsBySearchtextByUsage(searchText: searchText, foodSourceIds: localFoodSources, days: _dayForFoodUsage);

    List<Food> allResults = [];
    List<Food> foods = dbResult != null ? Convert.getFoodsFromDbResult(dbResult: dbResult) : [];

    allResults.addAll(foods);

    Food? foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.user);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.user).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.standard);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.standard).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.openFoodFacts);
    if (foodExists != null) {
      result.add(FoodRepositoryResult(foods: foods.where((Food food) => food.foodSource == FoodSource.openFoodFacts).toList()));
    } else {
      result.add(FoodRepositoryResult());
    }

    if (searchMode == SearchMode.online) {
      result.add(await getOpenFoodFactsFoodBySearchTextApiV1(searchText: searchText, languageCode: languageCode, page: 1));
    } else {
      result.add(FoodRepositoryResult());
    }

    if (result[3].foods != null) {
      allResults.addAll(result[3].foods!);
    }

    if (allResults.isNotEmpty) {
      result.add(FoodRepositoryResult(foods: allResults));
    } else {
      result.add(FoodRepositoryResult());
    }

    return result;
  }

  Future<FoodRepositoryResult> getOpenFoodFactsFoodBySearchTextApiV1({required String searchText, required String languageCode, required int page}) async {
    String? jsonString;

    searchText = searchText.trim();
    if (searchText != OpenEatsJournalStrings.emptyString) {
      searchText = searchText.split(" ").map((String word) => "*${word.trim()}*").join(" ");
    }

    try {
      jsonString = await _openFoodFactsService.getFoodBySearchTextApiV1(searchText: searchText, page: page, pageSize: _pageSize);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult(errorCode: 1, errorMessage: clientException.message);
    }

    List<Food> foods = [];
    Map<String, dynamic> json;
    if (jsonString != null) {
      try {
        json = jsonDecode(jsonString);
      } on FormatException {
        return FoodRepositoryResult(errorCode: 5);
      }

      if (json.containsKey(OpenFoodFactsApiStrings.products)) {
        for (Map<String, dynamic> product in json[OpenFoodFactsApiStrings.products]) {
          Food? food = _getFoodFromOpenFoodFactsApiV1V2Food(json: product, languageCode: languageCode);

          if (food != null) {
            foods.add(food);
          }
        }

        return FoodRepositoryResult(foods: foods, finished: (json[OpenFoodFactsApiStrings.products] as List<dynamic>).length < _pageSize);
      } else {
        return FoodRepositoryResult(errorCode: 2);
      }
    }

    return FoodRepositoryResult(errorCode: 3);
  }

  Food? _getFoodFromOpenFoodFactsApiV1V2Food({required Map<String, dynamic> json, required String languageCode}) {
    FoodApi foodApi = FoodApi.fromJsonApiV1V2(json);

    if (foodApi.nutriments != null && (foodApi.productQuantityUnit != null || foodApi.servingQuantityUnit != null)) {
      double? servingAdjustFactor;
      double? energyKjPer100Units;
      MeasurementUnit? nutrimentsMeasurementUnit;

      //energyKjPer100Units comes from foodApi.nutriments!.energyKj100g or foodApi.nutriments!.energyKj! and is either asssociated to serving quantity or
      //product quantity. First we try to get energyKjPer100Units and nutrimentsMeasurementUnit from serving, then from prodcut. If we get energyKjPer100Units
      //but no nutrimentsMeasurementUnit we just assume ist gram.
      if (foodApi.nutritionDataPer != null && foodApi.nutritionDataPer == OpenFoodFactsApiStrings.serving) {
        if (foodApi.servingQuantity != null) {
          num servingQuantity = num.parse(foodApi.servingQuantity!);
          servingAdjustFactor = 100 / servingQuantity;
          energyKjPer100Units = _getEnergyPer100UnitsFromServing(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        }

        //If energyKjPer100Units is not null here we assume the unit is from serving, because nutritionDataPer was not null and per serving.
        //So even the energyKj100g from the api should be in the serving unit.
        if (energyKjPer100Units != null) {
          nutrimentsMeasurementUnit = _getMeasurementUnitFromApiString(value: foodApi.servingQuantityUnit);
        }
      }

      if (energyKjPer100Units == null || nutrimentsMeasurementUnit == null) {
        //We don't have valid infos from the serving here, so we check the product data.
        //nutritionDataPer can only be 100g or serving, so if it is not serving, energyKj100g and energyKj should be the same.
        energyKjPer100Units = foodApi.nutriments!.energyKj100g?.toDouble();
        energyKjPer100Units ??= foodApi.nutriments!.energyKj?.toDouble();

        nutrimentsMeasurementUnit = _getMeasurementUnitFromApiString(value: foodApi.productQuantityUnit);

        //If we have energyKjPer100Units but no nutrimentsMeasurementUnit we just assume nutrimentsMeasurementUnit it's gram...
        if (energyKjPer100Units != null && nutrimentsMeasurementUnit == null) {
          nutrimentsMeasurementUnit = MeasurementUnit.gram;
        }
      }

      if (energyKjPer100Units != null && nutrimentsMeasurementUnit != null) {
        double? carbohydratesPer100Units = _getCarbohydratesPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? sugarPer100Units = _getSugarsPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? fatPer100Units = _getFatPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? saturatedFatPer100Units = _getSaturatedFatPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? proteinsPer100Units = _getProteinsPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? saltPer100Units = _getSaltPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);

        int order = 1;
        List<OrderedDefaultFoodUnit> orderedDefaultFoodUnits = [];
        if (_getMeasurementUnitFromApiString(value: foodApi.servingQuantityUnit) == nutrimentsMeasurementUnit) {
          //servingQuantity can also be String "null"...
          if (foodApi.servingQuantity != null) {
            double? quantity = double.tryParse(foodApi.servingQuantity!);
            if (quantity != null && quantity > 0) {
              orderedDefaultFoodUnits.add(
                OrderedDefaultFoodUnit(
                  foodUnitWithOrder: ObjectWithOrder(
                    object: FoodUnit(
                      name: OpenEatsJournalStrings.serving,
                      amount: double.parse(foodApi.servingQuantity!),
                      amountMeasurementUnit: nutrimentsMeasurementUnit,
                      //dummy id, as serving/quantity info has no id in open food facts data
                      originalFoodSourceFoodUnitId: "2",
                    ),
                    order: order,
                  ),
                  isDefault: true,
                ),
              );

              order++;
            }
          }
        }

        if (_getMeasurementUnitFromApiString(value: foodApi.productQuantityUnit) == nutrimentsMeasurementUnit) {
          //productQuantity can also be String "null"...
          if (foodApi.productQuantity != null) {
            double? quantity = double.tryParse(foodApi.productQuantity!);
            if (quantity != null && quantity > 0) {
              orderedDefaultFoodUnits.add(
                OrderedDefaultFoodUnit(
                  foodUnitWithOrder: ObjectWithOrder(
                    object: FoodUnit(
                      name: OpenEatsJournalStrings.piece,
                      amount: double.parse(foodApi.productQuantity!),
                      amountMeasurementUnit: nutrimentsMeasurementUnit,
                      //dummy id, as serving/quantity info has no id in open food facts data
                      originalFoodSourceFoodUnitId: "1",
                    ),
                    order: order,
                  ),
                  isDefault: orderedDefaultFoodUnits.isEmpty,
                ),
              );
            }
          }
        }

        Food food = Food.fromData(
          name: _getFoodName(foodApi: foodApi, languageCode: languageCode),
          brands: _getCleanBrands(foodApi.brandsTags),
          foodSource: FoodSource.openFoodFacts,
          fromDb: false,
          originalFoodSourceFoodId: foodApi.code,
          barcode: int.tryParse(foodApi.code!),
          nutritionPerGramAmount: nutrimentsMeasurementUnit == MeasurementUnit.gram ? 100 : null,
          nutritionPerMilliliterAmount: nutrimentsMeasurementUnit == MeasurementUnit.gram ? null : 100,
          kJoule: energyKjPer100Units,
          carbohydrates: carbohydratesPer100Units,
          sugar: sugarPer100Units,
          fat: fatPer100Units,
          saturatedFat: saturatedFatPer100Units,
          protein: proteinsPer100Units,
          salt: saltPer100Units,
          quantity: foodApi.quantity,
          orderedDefaultFoodUnits: orderedDefaultFoodUnits,
        );

        return food;
      }
    }

    return null;
  }

  MeasurementUnit? _getMeasurementUnitFromApiString({String? value}) {
    if (value == null) {
      return null;
    }
    if (value.trim().toLowerCase() == OpenFoodFactsApiStrings.gram) {
      return MeasurementUnit.gram;
    }
    if (value.trim().toLowerCase() == OpenFoodFactsApiStrings.milliliter) {
      return MeasurementUnit.milliliter;
    }

    return null;
  }

  //removed searchAlicious / search a licious code on 16th January 2026

  String _getFoodName({required FoodApi foodApi, required String languageCode}) {
    String name = OpenEatsJournalStrings.emptyString;

    if (languageCode == OpenEatsJournalStrings.de) {
      if (foodApi.productNameDe != null) {
        name = foodApi.productNameDe!;
      }

      if (name.trim().isEmpty) {
        if (foodApi.abbreviatedProductNameDe != null) {
          name = foodApi.abbreviatedProductNameDe!;
        }
      }

      if (name.trim().isEmpty) {
        if (foodApi.genericNameDe != null) {
          name = foodApi.genericNameDe!;
        }
      }
    }

    if (languageCode == OpenEatsJournalStrings.en || name.trim().isEmpty) {
      if (foodApi.productNameEn != null) {
        name = foodApi.productNameEn!;
      }

      if (name.trim().isEmpty) {
        if (foodApi.abbreviatedProductNameEn != null) {
          name = foodApi.abbreviatedProductNameEn!;
        }
      }

      if (name.trim().isEmpty) {
        if (foodApi.genericNameEn != null) {
          name = foodApi.genericNameEn!;
        }
      }
    }

    if (name.trim().isEmpty) {
      if (foodApi.productName != null) {
        name = foodApi.productName!;
      }

      if (name.trim().isEmpty) {
        if (foodApi.abbreviatedProductName != null) {
          name = foodApi.abbreviatedProductName!;
        }
      }

      if (name.trim().isEmpty) {
        if (foodApi.genericName != null) {
          name = foodApi.genericName!;
        }
      }
    }

    return name;
  }

  double? _getEnergyPer100UnitsFromServing({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? energyKjPer100Units = foodApi.nutriments!.energyKj100g?.toDouble();

    if (energyKjPer100Units == null && foodApi.nutriments!.energyKj != null && servingAdjustFactor != null) {
      energyKjPer100Units = (foodApi.nutriments!.energyKj! * servingAdjustFactor);
    }

    return energyKjPer100Units;
  }

  double? _getCarbohydratesPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? carbohydratesPer100Units = foodApi.nutriments!.carbohydrates100g;

    if (carbohydratesPer100Units == null && foodApi.nutriments!.carbohydrates != null && servingAdjustFactor != null) {
      carbohydratesPer100Units = foodApi.nutriments!.carbohydrates! * servingAdjustFactor;
    }

    return carbohydratesPer100Units;
  }

  double? _getSugarsPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? sugarsPer100Units = foodApi.nutriments!.sugars100g;

    if (sugarsPer100Units == null && foodApi.nutriments!.sugars != null && servingAdjustFactor != null) {
      sugarsPer100Units = foodApi.nutriments!.sugars! * servingAdjustFactor;
    }

    return sugarsPer100Units;
  }

  double? _getFatPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? fatPer100Units = foodApi.nutriments!.fat100g;

    if (fatPer100Units == null && foodApi.nutriments!.fat != null && servingAdjustFactor != null) {
      fatPer100Units = foodApi.nutriments!.fat! * servingAdjustFactor;
    }

    return fatPer100Units;
  }

  double? _getSaturatedFatPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? saturatedFatPer100Units = foodApi.nutriments!.saturatedFat100g;

    if (saturatedFatPer100Units == null && foodApi.nutriments!.saturatedFat != null && servingAdjustFactor != null) {
      saturatedFatPer100Units = foodApi.nutriments!.saturatedFat! * servingAdjustFactor;
    }

    return saturatedFatPer100Units;
  }

  double? _getProteinsPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? proteinsPer100Units = foodApi.nutriments!.proteins100g;

    if (proteinsPer100Units == null && foodApi.nutriments!.proteins != null && servingAdjustFactor != null) {
      proteinsPer100Units = foodApi.nutriments!.proteins! * servingAdjustFactor;
    }

    return proteinsPer100Units;
  }

  double? _getSaltPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    double? saltPer100Units = foodApi.nutriments!.salt100g;

    if (saltPer100Units == null && foodApi.nutriments!.salt != null && servingAdjustFactor != null) {
      saltPer100Units = foodApi.nutriments!.salt! * servingAdjustFactor;
    }

    return saltPer100Units;
  }

  List<String>? _getCleanBrands(List<String>? brands) {
    if (brands == null) {
      return null;
    }

    List<String> result = [];
    String start = OpenEatsJournalStrings.emptyString;
    for (String brand in brands) {
      if (brand.length > 2) {
        start = brand.substring(0, 3).toLowerCase();
        if (start == "xx:") {
          result.add(brand.substring(3));
        } else {
          result.add(brand);
        }
      } else {
        result.add(brand);
      }
    }

    return result;
  }

  Future<void> setFoodByExternalIdIfNecessary({required Food food}) async {
    if (food.isExternalFoodSource) {
      if (food.id == null || (food.id != null && !food.fromDb)) {
        await _setFoodByExternalId(food: food);
      }
    }
  }

  Future<void> _setFoodByExternalId({required Food food}) async {
    int foodId = await _oejDatabaseService.setFoodByExternalId(
      foodData: _getFoodData(food: food),
      id: food.id,
    );

    food.id ??= foodId;

    await _setFoodUnits(food: food);
  }

  Future<void> setFood({required Food food}) async {
    int foodId = await _oejDatabaseService.setFood(
      foodData: _getFoodData(food: food),
      id: food.id,
    );

    food.id ??= foodId;

    await _setFoodUnits(food: food);
  }

  Map<String, Object?> _getFoodData({required Food food}) {
    return {
      OpenEatsJournalStrings.dbColumnFoodSourceIdRef: food.foodSource.value,
      OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef: food.originalFoodSource?.value,
      OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef: food.originalFoodSourceFoodId,
      OpenEatsJournalStrings.dbColumnBarcode: food.barcode,
      OpenEatsJournalStrings.dbColumnName: food.name.trim() != OpenEatsJournalStrings.emptyString ? food.name : null,
      OpenEatsJournalStrings.dbColumnBrands: (food.brands.isNotEmpty) ? food.brands.join(",") : null,
      OpenEatsJournalStrings.dbColumnNutritionPerGramAmount: food.nutritionPerGramAmount,
      OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount: food.nutritionPerMilliliterAmount,
      OpenEatsJournalStrings.dbColumnKiloJoule: food.kJoule,
      OpenEatsJournalStrings.dbColumnCarbohydrates: food.carbohydrates,
      OpenEatsJournalStrings.dbColumnSugar: food.sugar,
      OpenEatsJournalStrings.dbColumnFat: food.fat,
      OpenEatsJournalStrings.dbColumnSaturatedFat: food.saturatedFat,
      OpenEatsJournalStrings.dbColumnProtein: food.protein,
      OpenEatsJournalStrings.dbColumnSalt: food.salt,
      OpenEatsJournalStrings.dbColumnQuantity: food.quantity,
      OpenEatsJournalStrings.dbColumnSearchText: getFoodSearchText(food: food),
    };
  }

  Future<void> _setFoodUnits({required Food food}) async {
    List<int> foodUnitIds = [];
    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      int foodUnitId = await _oejDatabaseService.setFoodUnit(
        foodUnitData: {
          OpenEatsJournalStrings.dbColumnFoodIdRef: food.id,
          OpenEatsJournalStrings.dbColumnName: foodUnitWithOrder.object.name,
          OpenEatsJournalStrings.dbColumnAmount: foodUnitWithOrder.object.amount,
          OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef: foodUnitWithOrder.object.amountMeasurementUnit.value,
          OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef: foodUnitWithOrder.object.originalFoodSourceFoodUnitId,
          OpenEatsJournalStrings.dbColumnOrderNumber: foodUnitWithOrder.order,
          OpenEatsJournalStrings.dbColumnIsDefault: foodUnitWithOrder.object == food.defaultFoodUnit,
        },
        id: foodUnitWithOrder.object.id,
      );

      foodUnitWithOrder.object.id ??= foodUnitId;
      foodUnitIds.add(foodUnitId);
    }

    await _oejDatabaseService.deleteFoodUnits(foodId: food.id!, exceptIds: foodUnitIds);

    //If food changes its nutritionPerXXXmount to null possibly, associated eats journal entries associated to that food and measurement unit need to be
    //updated (or deleted) otherwise we have an inconsistent state leading to errors.
    if (food.nutritionPerGramAmount == null) {
      await _oejDatabaseService.replaceFoodEntriesMeasurementUnit(
        foodId: food.id!,
        fromMeasurementUnitId: MeasurementUnit.gram.value,
        toMeasurementUnitId: MeasurementUnit.milliliter.value,
      );
    }

    if (food.nutritionPerMilliliterAmount == null) {
      await _oejDatabaseService.replaceFoodEntriesMeasurementUnit(
        foodId: food.id!,
        fromMeasurementUnitId: MeasurementUnit.milliliter.value,
        toMeasurementUnitId: MeasurementUnit.gram.value,
      );
    }
  }

  Future<DateTime> initializeStandardFoodData({required String languageCode, DateTime? lastProcessedStandardFoodDataChangeDate}) async {
    List<String> standardFoodDataAssetsassets = await _oejAssetsService.getStandardFoodFiles();

    List<List<String>> standardFoodDataCsv;
    DateTime? lastStandardFoodDataChangeDate;

    bool inDataSection = false;
    int currentFoodId = -1;
    bool foodRelevant = false;
    List<String> foodData = [];
    List<List<String>> foodUnitsData = [];

    for (int fileIndex = 1; fileIndex <= standardFoodDataAssetsassets.length; fileIndex++) {
      standardFoodDataCsv = await _oejAssetsService.getCsvContent("assets/standard_food_data.$fileIndex.csv");

      if (fileIndex == 1) {
        lastStandardFoodDataChangeDate = _csvDateFormat.parse(standardFoodDataCsv[2][0]);
      }

      if (lastProcessedStandardFoodDataChangeDate == null || lastStandardFoodDataChangeDate!.isAfter(lastProcessedStandardFoodDataChangeDate)) {
        for (int csvLineIndex = 0; csvLineIndex < standardFoodDataCsv.length; csvLineIndex++) {
          if (inDataSection) {
            if (standardFoodDataCsv[csvLineIndex].isNotEmpty) {
              if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvFood) {
                if (int.parse(standardFoodDataCsv[csvLineIndex][1]) != currentFoodId) {
                  if (currentFoodId != -1 && foodRelevant) {
                    await _setStandardFoodFromCsvData(foodDataCsv: foodData, foodUnitsCsv: foodUnitsData, languageCode: languageCode);
                  }
                }

                currentFoodId = int.parse(standardFoodDataCsv[csvLineIndex][1]);

                if (lastProcessedStandardFoodDataChangeDate == null ||
                    _csvDateFormat.parse(standardFoodDataCsv[csvLineIndex][2]).isAfter(lastProcessedStandardFoodDataChangeDate)) {
                  foodRelevant = true;
                  foodData = standardFoodDataCsv[csvLineIndex];
                  foodUnitsData.clear();
                } else {
                  foodRelevant = false;
                }
              }

              if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvFoodUnit) {
                if (foodRelevant) {
                  foodUnitsData.add(standardFoodDataCsv[csvLineIndex]);
                }
              }
            }
          } else {
            if (standardFoodDataCsv[csvLineIndex].length == 1 && standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvData) {
              inDataSection = true;
            }
          }
        }
      }
    }

    if (currentFoodId != -1 && foodRelevant) {
      await _setStandardFoodFromCsvData(foodDataCsv: foodData, foodUnitsCsv: foodUnitsData, languageCode: languageCode);
    }

    return lastStandardFoodDataChangeDate!;
  }

  Future<void> _setStandardFoodFromCsvData({required List<String> foodDataCsv, required List<List<String>> foodUnitsCsv, required String languageCode}) async {
    List<OrderedDefaultFoodUnit> foodUnitsWithOrder = [];

    int order = 1;
    for (List<String> foodUnitCsv in foodUnitsCsv) {
      foodUnitsWithOrder.add(
        OrderedDefaultFoodUnit(
          foodUnitWithOrder: ObjectWithOrder(
            object: FoodUnit(
              name: languageCode == OpenEatsJournalStrings.en ? foodUnitCsv[2] : foodUnitCsv[3],
              amount: double.parse(foodUnitCsv[4]),
              amountMeasurementUnit: MeasurementUnit.values.firstWhere((unit) => unit.text == foodUnitCsv[5]),
              originalFoodSourceFoodUnitId: foodUnitCsv[1],
            ),
            order: order,
          ),
          isDefault: foodUnitCsv[6] == OpenEatsJournalStrings.csvTrue ? true : false,
        ),
      );

      order++;
    }

    String brands = languageCode == OpenEatsJournalStrings.en ? foodDataCsv[5] : foodDataCsv[6];

    Food food = Food.fromData(
      name: languageCode == OpenEatsJournalStrings.en ? foodDataCsv[3] : foodDataCsv[4],
      foodSource: FoodSource.standard,
      fromDb: true,
      kJoule: double.parse(foodDataCsv[9]),
      brands: brands == OpenEatsJournalStrings.emptyString ? null : foodDataCsv[4].split(","),
      originalFoodSourceFoodId: foodDataCsv[1],
      nutritionPerGramAmount: foodDataCsv[7] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[7]),
      nutritionPerMilliliterAmount: foodDataCsv[8] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[8]),
      carbohydrates: foodDataCsv[12] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[12]),
      sugar: foodDataCsv[13] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[13]),
      fat: foodDataCsv[10] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[10]),
      saturatedFat: foodDataCsv[11] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[11]),
      protein: foodDataCsv[14] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[14]),
      salt: foodDataCsv[15] == OpenEatsJournalStrings.emptyString ? null : double.parse(foodDataCsv[15]),
      quantity: foodDataCsv[16],
      orderedDefaultFoodUnits: foodUnitsWithOrder,
    );

    await _setFoodByExternalId(food: food);
  }

  Future<void> deleteFood({required Food food}) async {
    if (food.id == null) {
      throw ArgumentError("Can't delete food without id.");
    }

    if (food.foodSource == FoodSource.standard) {
      throw ArgumentError("Can't delete standard food.");
    }

    await _oejDatabaseService.removeFoodIdFromEatsJournalEntries(foodId: food.id!);
    await _oejDatabaseService.deleteFoodUnits(foodId: food.id!, exceptIds: []);
    await _oejDatabaseService.deleteFood(foodId: food.id!);
  }

  String getFoodSearchText({required Food food}) {
    String searchText = food.name.trim();
    if (food.brands.isNotEmpty) {
      searchText = " $searchText ${food.brands.map((brand) => brand.trim()).join(" ")}";
    }

    return searchText;
  }
}

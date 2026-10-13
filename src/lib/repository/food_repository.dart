import "dart:convert";
import "package:collection/collection.dart";
import "package:http/http.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/ordered_default_food_unit.dart";
import "package:openeatsjournal/domain/standard_food_data_csv_header_info.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/repository/convert.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/service/assets/open_eats_journal_assets_service.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/data/food_api_v3.dart";
import "package:openeatsjournal/service/open_food_facts/data/nutriments_api_v3.dart";
import "package:openeatsjournal/service/open_food_facts/data/nutritions_per.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";
import "package:openeatsjournal/service/open_food_facts/data/food_api_v1.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class FoodRepository {
  FoodRepository({
    required SettingsRepository settingsRepository,
    required OpenFoodFactsService openFoodFactsService,
    required OpenEatsJournalDatabaseService oejDatabaseService,
    required OpenEatsJournalAssetsService oejAssetsService,
    Food Function()? getNewFood,
    String? barcodeScannerResult,
  }) : _settingsRepository = settingsRepository,
       _openFoodFactsService = openFoodFactsService,
       _oejDatabaseService = oejDatabaseService,
       _oejAssetsService = oejAssetsService,
       _getNewFood = getNewFood,
       _barcodeScannerResult = barcodeScannerResult;

  final SettingsRepository _settingsRepository;
  final OpenFoodFactsService _openFoodFactsService;
  final OpenEatsJournalDatabaseService _oejDatabaseService;
  final OpenEatsJournalAssetsService _oejAssetsService;

  final Food Function()? _getNewFood;
  final String? _barcodeScannerResult;

  final int _pageSize = 100;
  final int _dayForFoodUsage = 43;
  final DateFormat _csvDateFormat = DateFormat("yyyy-MM-dd HH-mm-ss");

  String? get barcodeScannerResult => _barcodeScannerResult;

  Future<List<FoodRepositoryResult>> getFoodsByBarcodeDb({required int barcode, required String languageCode, required bool includeCache}) async {
    List<FoodRepositoryResult> result = [];

    List<int> localFoodSources = includeCache ? [FoodSource.user.value, FoodSource.openFoodFacts.value] : [FoodSource.user.value];

    List<Map<String, Object?>>? dbResult = await _oejDatabaseService.getFoodsByBarcode(barcode: barcode, foodSourceIds: localFoodSources);

    List<Food>? foods = dbResult != null && dbResult.isNotEmpty ? Convert.getFoodsFromDbResult(dbResult: dbResult) : [];

    Food? foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.user);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.user],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.user).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.user], fromDb: true, finished: true));
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.standard);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.standard],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.standard).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.standard], fromDb: true, finished: true));
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.openFoodFacts);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.openFoodFacts],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.openFoodFacts).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.openFoodFacts], fromDb: true, finished: true));
    }

    return result;
  }

  Future<FoodRepositoryResult> getFoodsByBarcodeByUsageDb({required int barcode, required String languageCode}) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabaseService.getFoodsByBarcodeByUsage(
      today: _settingsRepository.today,
      barcode: barcode,
      foodSourceIds: [FoodSource.user.value, FoodSource.openFoodFacts.value],
      days: _dayForFoodUsage,
    );

    if (dbResult != null && dbResult.isNotEmpty) {
      List<Food> foods = Convert.getFoodsFromDbResult(dbResult: dbResult);
      return FoodRepositoryResult.ok(foodSources: [FoodSource.user, FoodSource.openFoodFacts], fromDb: true, foods: foods, finished: true);
    }

    return FoodRepositoryResult.ok(foodSources: [FoodSource.user, FoodSource.openFoodFacts], fromDb: true, finished: true);
  }

  Future<FoodRepositoryResult> getFoodByBarcodeOpenFoodFacts({required int barcode, required String languageCode}) async {
    String? jsonString;
    try {
      jsonString = await _openFoodFactsService.getFoodByBarcode(barcode: barcode);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 1, errorMessage: clientException.message);
    }

    if (jsonString != null) {
      Map<String, dynamic> json;
      try {
        json = jsonDecode(jsonString);
      } on FormatException {
        return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 5);
      }

      if (json.containsKey(OpenFoodFactsApiStrings.product)) {
        List<Food>? foods = _getFoodFromOpenFoodFactsApiV3Food(json: json[OpenFoodFactsApiStrings.product], languageCode: languageCode);

        if (foods != null) {
          return FoodRepositoryResult.ok(foodSources: [FoodSource.openFoodFacts], fromDb: false, foods: foods, finished: true);
        }

        return FoodRepositoryResult.ok(foodSources: [FoodSource.openFoodFacts], fromDb: false, finished: true);
      } else {
        //no food found for this barcode
        return FoodRepositoryResult.ok(foodSources: [FoodSource.openFoodFacts], fromDb: false, finished: true);
      }
    }

    return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 3);
  }

  Future<List<FoodRepositoryResult>> getFoodsBySearchTextDb({required String searchText, required String languageCode, required bool includeCache}) async {
    List<FoodRepositoryResult> result = [];

    List<int> localFoodSources = includeCache
        ? [FoodSource.user.value, FoodSource.openFoodFacts.value, FoodSource.standard.value]
        : [FoodSource.user.value, FoodSource.standard.value];

    List<Map<String, Object?>>? dbResult = await _oejDatabaseService.getFoodsBySearchtext(searchText: searchText, foodSourceIds: localFoodSources);

    List<Food> foods = dbResult != null && dbResult.isNotEmpty ? Convert.getFoodsFromDbResult(dbResult: dbResult) : [];

    Food? foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.user);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.user],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.user).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.user], fromDb: true, finished: true));
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.standard);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.standard],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.standard).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.standard], fromDb: true, finished: true));
    }

    foodExists = foods.firstWhereOrNull((Food food) => food.foodSource == FoodSource.openFoodFacts);
    if (foodExists != null) {
      result.add(
        FoodRepositoryResult.ok(
          foodSources: [FoodSource.openFoodFacts],
          fromDb: true,
          foods: foods.where((Food food) => food.foodSource == FoodSource.openFoodFacts).toList(),
          finished: true,
        ),
      );
    } else {
      result.add(FoodRepositoryResult.ok(foodSources: [FoodSource.openFoodFacts], fromDb: true, finished: true));
    }

    return result;
  }

  Future<FoodRepositoryResult> getFoodsBySearchTextByUsageDb({required String searchText, required String languageCode}) async {
    List<Map<String, Object?>>? dbResult = await _oejDatabaseService.getFoodsBySearchtextByUsage(
      today: _settingsRepository.today,
      searchText: searchText,
      foodSourceIds: [FoodSource.user.value, FoodSource.openFoodFacts.value, FoodSource.standard.value],
      days: _dayForFoodUsage,
    );

    if (dbResult != null && dbResult.isNotEmpty) {
      List<Food> foods = Convert.getFoodsFromDbResult(dbResult: dbResult);
      return FoodRepositoryResult.ok(foodSources: [FoodSource.user, FoodSource.standard, FoodSource.openFoodFacts], fromDb: true, foods: foods, finished: true);
    }

    return FoodRepositoryResult.ok(foodSources: [FoodSource.user, FoodSource.standard, FoodSource.openFoodFacts], fromDb: true, finished: true);
  }

  Future<FoodRepositoryResult> getFoodsBySearchTextOpenFoodFactsApiV1({required String searchText, required String languageCode, required int page}) async {
    String? jsonString;

    searchText = searchText.trim();
    if (searchText != OpenEatsJournalStrings.emptyString) {
      searchText = searchText.split(" ").map((String word) => "*${word.trim()}*").join(" ");
    }

    try {
      jsonString = await _openFoodFactsService.getFoodsBySearchTextApiV1(searchText: searchText, page: page, pageSize: _pageSize);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 1, errorMessage: clientException.message);
    }

    if (jsonString != null) {
      List<Food> foods = [];
      Map<String, dynamic> json;

      try {
        json = jsonDecode(jsonString);
      } on FormatException {
        return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 5);
      }

      if (json.containsKey(OpenFoodFactsApiStrings.products)) {
        for (Map<String, dynamic> product in json[OpenFoodFactsApiStrings.products]) {
          Food? food = _getFoodFromOpenFoodFactsApiV1Food(json: product, languageCode: languageCode);

          if (food != null) {
            foods.add(food);
          }
        }

        return FoodRepositoryResult.ok(
          foodSources: [FoodSource.openFoodFacts],
          fromDb: false,
          foods: foods,
          finished: (json[OpenFoodFactsApiStrings.products] as List<dynamic>).length < _pageSize,
        );
      } else {
        return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 2);
      }
    }

    return FoodRepositoryResult.error(foodSources: [FoodSource.openFoodFacts], fromDb: false, errorCode: 3);
  }

  Food? _getFoodFromOpenFoodFactsApiV1Food({required Map<String, dynamic> json, required String languageCode}) {
    FoodApiV1 foodApi = FoodApiV1.fromJsonApiV1(json);

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
        List<OrderedDefaultFoodUnit> orderedFoodUnitsWithDefault = [];
        if (_getMeasurementUnitFromApiString(value: foodApi.servingQuantityUnit) == nutrimentsMeasurementUnit) {
          //servingQuantity can also be String "null"...
          if (foodApi.servingQuantity != null) {
            double? quantity = double.tryParse(foodApi.servingQuantity!);
            if (quantity != null && quantity > 0) {
              orderedFoodUnitsWithDefault.add(
                OrderedDefaultFoodUnit(
                  foodUnitWithOrder: ObjectWithOrder(
                    object: FoodUnit(
                      name: OpenEatsJournalStrings.serving,
                      amount: double.parse(foodApi.servingQuantity!),
                      amountMeasurementUnit: nutrimentsMeasurementUnit,
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
              orderedFoodUnitsWithDefault.add(
                OrderedDefaultFoodUnit(
                  foodUnitWithOrder: ObjectWithOrder(
                    object: FoodUnit(
                      name: OpenEatsJournalStrings.piece,
                      amount: double.parse(foodApi.productQuantity!),
                      amountMeasurementUnit: nutrimentsMeasurementUnit,
                    ),
                    order: order,
                  ),
                  isDefault: orderedFoodUnitsWithDefault.isEmpty,
                ),
              );
            }
          }
        }

        Food food = Food.fromData(
          name: _getFoodNameApiV1(foodApi: foodApi, languageCode: languageCode),
          brands: _getCleanBrands(foodApi.brandsTags),
          foodSource: FoodSource.openFoodFacts,
          fromDb: false,
          originalFoodSourceFoodId: foodApi.code.toString(),
          barcode: foodApi.code,
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
          orderedFoodUnitsWithDefault: orderedFoodUnitsWithDefault,
        );

        return food;
      }
    }

    return null;
  }

  //Can return more than one foods because we create 2 foods if we get nutriments for food as sold and nutriments per prepared food
  List<Food>? _getFoodFromOpenFoodFactsApiV3Food({required Map<String, dynamic> json, required String languageCode}) {
    FoodApiV3 foodApi = FoodApiV3.fromJsonApiV3(json);

    List<Food> result = [];
    if (foodApi.nutriments != null) {
      Food? food = _getFoodFromOpenFoodFactsApiV3FoodByPreparation(foodApi: foodApi, preparation: OpenFoodFactsApiStrings.asSold, languageCode: languageCode);
      if (food != null) {
        result.add(food);
      }

      food = _getFoodFromOpenFoodFactsApiV3FoodByPreparation(foodApi: foodApi, preparation: OpenFoodFactsApiStrings.prepared, languageCode: languageCode);
      if (food != null) {
        result.add(food);
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  Food? _getFoodFromOpenFoodFactsApiV3FoodByPreparation({required FoodApiV3 foodApi, required String preparation, required String languageCode}) {
    NutritionsPer? nutritionsPer = _getNutritons(foodApi: foodApi, preparation: preparation);
    if (nutritionsPer != null) {
      List<OrderedDefaultFoodUnit> orderedFoodUnitsWithDefault = _getOpenFoodFactsFoodUnits(foodApi: foodApi, preparation: OpenFoodFactsApiStrings.asSold);
      List<OrderedDefaultFoodUnit> foodUnitsToRemove = [];

      for (OrderedDefaultFoodUnit orderedDefaultFoodUnit in orderedFoodUnitsWithDefault) {
        if (orderedDefaultFoodUnit.foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.gram) {
          if (nutritionsPer.nutritionPerGramAmount == null) {
            foodUnitsToRemove.add(orderedDefaultFoodUnit);
          }
        }

        if (orderedDefaultFoodUnit.foodUnitWithOrder.object.amountMeasurementUnit == MeasurementUnit.milliliter) {
          if (nutritionsPer.nutritionPerMilliliterAmount == null) {
            foodUnitsToRemove.add(orderedDefaultFoodUnit);
          }
        }
      }

      orderedFoodUnitsWithDefault.removeWhere((OrderedDefaultFoodUnit orderedDefaultFoddunit) => foodUnitsToRemove.contains(orderedDefaultFoddunit));

      return Food.fromData(
        name:
            "${_getFoodNameApiV3(foodApi: foodApi, languageCode: languageCode)}${preparation == OpenFoodFactsApiStrings.prepared ? " (prepared)" : OpenEatsJournalStrings.emptyString}",
        brands: _getCleanBrands(foodApi.brandsTags),
        foodSource: FoodSource.openFoodFacts,
        fromDb: false,
        originalFoodSourceFoodId: foodApi.code.toString(),
        barcode: foodApi.code,
        nutritionPerGramAmount: nutritionsPer.nutritionPerGramAmount,
        nutritionPerMilliliterAmount: nutritionsPer.nutritionPerMilliliterAmount,
        kJoule: nutritionsPer.kJoule,
        fat: nutritionsPer.fat,
        saturatedFat: nutritionsPer.saturatedFat,
        carbohydrates: nutritionsPer.carbohydrates,
        sugar: nutritionsPer.sugar,
        protein: nutritionsPer.protein,
        salt: nutritionsPer.salt,
        quantity: foodApi.quantity,
        orderedFoodUnitsWithDefault: orderedFoodUnitsWithDefault,
      );
    }

    return null;
  }

  List<OrderedDefaultFoodUnit> _getOpenFoodFactsFoodUnits({required FoodApiV3 foodApi, required String preparation}) {
    List<OrderedDefaultFoodUnit> orderedFoodUnitsWithDefault = [];
    int order = 1;
    NutrimentsApiV3? nutriments = foodApi.nutriments!.firstWhereOrNull(
      (NutrimentsApiV3 nutrimentsInternal) => nutrimentsInternal.preparation == preparation && nutrimentsInternal.per == OpenFoodFactsApiStrings.serving,
    );

    if (nutriments != null) {
      orderedFoodUnitsWithDefault.add(
        OrderedDefaultFoodUnit(
          foodUnitWithOrder: ObjectWithOrder(
            object: FoodUnit(
              name: OpenEatsJournalStrings.serving,
              amount: nutriments.perUnit == OpenFoodFactsApiStrings.liter ? nutriments.perQuantity.toDouble() * 1000 : nutriments.perQuantity.toDouble(),
              amountMeasurementUnit: _getMeasurementUnitFromApiString(value: nutriments.perUnit)!,
              originalFoodSourceFoodUnitId: nutriments.per,
            ),
            order: order,
          ),
          isDefault: true,
        ),
      );

      order++;
    }

    for (NutrimentsApiV3 nutrimentsInternal in foodApi.nutriments!.where(
      (NutrimentsApiV3 nutrimentsInternal2) => nutrimentsInternal2.preparation == preparation && nutrimentsInternal2.per != OpenFoodFactsApiStrings.serving,
    )) {
      orderedFoodUnitsWithDefault.add(
        OrderedDefaultFoodUnit(
          foodUnitWithOrder: ObjectWithOrder(
            object: FoodUnit(
              name: nutrimentsInternal.per,
              amount: nutrimentsInternal.perUnit == OpenFoodFactsApiStrings.liter
                  ? nutrimentsInternal.perQuantity.toDouble() * 1000
                  : nutrimentsInternal.perQuantity.toDouble(),
              amountMeasurementUnit: _getMeasurementUnitFromApiString(value: nutrimentsInternal.perUnit)!,
              originalFoodSourceFoodUnitId: nutrimentsInternal.per,
            ),
            order: order,
          ),
          isDefault: orderedFoodUnitsWithDefault.isEmpty,
        ),
      );

      order++;
    }

    if (foodApi.productQuantity != null && foodApi.productQuantityUnit != null) {
      orderedFoodUnitsWithDefault.add(
        OrderedDefaultFoodUnit(
          foodUnitWithOrder: ObjectWithOrder(
            object: FoodUnit(
              name: OpenEatsJournalStrings.piece,
              amount: foodApi.productQuantity!.toDouble(),
              amountMeasurementUnit: _getMeasurementUnitFromApiString(value: foodApi.productQuantityUnit)!,
              originalFoodSourceFoodUnitId: OpenEatsJournalStrings.piece,
            ),
            order: order,
          ),
          isDefault: orderedFoodUnitsWithDefault.isEmpty,
        ),
      );
    }

    //Null out originalFoodSourceFoodUnitId on all entries that share the same id.
    Map<String, int> idCounts = <String, int>{};
    for (OrderedDefaultFoodUnit unit in orderedFoodUnitsWithDefault) {
      String? id = unit.foodUnitWithOrder.object.originalFoodSourceFoodUnitId;
      if (id != null) {
        idCounts[id] = (idCounts[id] ?? 0) + 1;
      }
    }

    for (OrderedDefaultFoodUnit unit in orderedFoodUnitsWithDefault) {
      String? id = unit.foodUnitWithOrder.object.originalFoodSourceFoodUnitId;
      if (id != null && idCounts[id]! > 1) {
        unit.foodUnitWithOrder.object.originalFoodSourceFoodUnitId = null;
      }
    }

    return orderedFoodUnitsWithDefault;
  }

  MeasurementUnit? _getMeasurementUnitFromApiString({String? value}) {
    if (value == null) {
      return null;
    }
    if (value.trim().toLowerCase() == OpenFoodFactsApiStrings.gram) {
      return MeasurementUnit.gram;
    }
    if (value.trim().toLowerCase() == OpenFoodFactsApiStrings.milliliter || value.trim().toLowerCase() == OpenFoodFactsApiStrings.liter) {
      return MeasurementUnit.milliliter;
    }

    return null;
  }

  //removed searchAlicious / search a licious code on 16th January 2026

  String _getFoodNameApiV1({required FoodApiV1 foodApi, required String languageCode}) {
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

  String _getFoodNameApiV3({required FoodApiV3 foodApi, required String languageCode}) {
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

  NutritionsPer? _getNutritons({required FoodApiV3 foodApi, required String preparation}) {
    List<NutrimentsApiV3> nutriments = foodApi.nutriments!
        .where((NutrimentsApiV3 nutriment) => nutriment.preparation == preparation && nutriment.perQuantity > 0)
        .toList();
    if (nutriments.isEmpty) {
      return null;
    }

    List<NutrimentsApiV3> nutrimentsGram = nutriments.where((NutrimentsApiV3 nutriment) => nutriment.perUnit == OpenFoodFactsApiStrings.gram).toList();

    NutritionsPer? nutritionsPerGram;
    NutritionsPer? nutritionsPerMilliliter;

    if (nutrimentsGram.isNotEmpty) {
      // Prefer the entry that is already per 100 g, otherwise take the first one.
      NutrimentsApiV3 baseNutriments = nutrimentsGram.firstWhere(
        (NutrimentsApiV3 nutriment) => nutriment.perQuantity == 100,
        orElse: () => nutrimentsGram.first,
      );
      nutritionsPerGram = _buildNutritionsPer(allNutriments: nutrimentsGram, baseNutriments: baseNutriments, isLiquid: false);
    }

    List<NutrimentsApiV3> nutrimentsLiquid = nutriments
        .where((NutrimentsApiV3 nutriment) => nutriment.perUnit == OpenFoodFactsApiStrings.milliliter || nutriment.perUnit == OpenFoodFactsApiStrings.liter)
        .toList();
    if (nutrimentsLiquid.isNotEmpty) {
      // Prefer the entry that is already per 100 ml, then per l, otherwise take the first one.
      NutrimentsApiV3 baseNutriments = nutrimentsLiquid.firstWhere(
        (nutriment) => nutriment.perUnit == OpenFoodFactsApiStrings.milliliter && nutriment.perQuantity == 100,

        orElse: () => nutrimentsLiquid.firstWhere(
          (nutriment) => nutriment.perUnit == OpenFoodFactsApiStrings.liter && nutriment.perQuantity == 1,
          orElse: () => nutrimentsLiquid.first,
        ),
      );

      nutritionsPerMilliliter = _buildNutritionsPer(allNutriments: nutrimentsLiquid, baseNutriments: baseNutriments, isLiquid: true);
    }

    return _mergeNutritionsPer(nutritionsPerGram: nutritionsPerGram, nutritionsPerMilliliter: nutritionsPerMilliliter);
  }

  // Merges the gram and milliliter result into one NutritionsPer with both amounts set.
  // As Basis is chosen one NutritionPer in this order:
  // 100 g, then 100 ml, then 1000 ml, otherwise the gram entry.
  // The amount of the other unit is derived from the energy ratio:
  // the same energy (kJ) is expected for the same quantity of the food.
  static NutritionsPer? _mergeNutritionsPer({required NutritionsPer? nutritionsPerGram, required NutritionsPer? nutritionsPerMilliliter}) {
    if (nutritionsPerGram == null) {
      return nutritionsPerMilliliter;
    }
    if (nutritionsPerMilliliter == null) {
      return nutritionsPerGram;
    }

    NutritionsPer basis;
    NutritionsPer other;
    if (nutritionsPerGram.nutritionPerGramAmount == 100) {
      basis = nutritionsPerGram;
      other = nutritionsPerMilliliter;
    } else if (nutritionsPerMilliliter.nutritionPerMilliliterAmount == 100 || nutritionsPerMilliliter.nutritionPerMilliliterAmount == 1000) {
      basis = nutritionsPerMilliliter;
      other = nutritionsPerGram;
    } else {
      basis = nutritionsPerGram;
      other = nutritionsPerMilliliter;
    }

    // Without energy on both sides no factor can be calculated, keep the basis only.
    if (basis.kJoule <= 0 || other.kJoule <= 0) {
      return basis;
    }

    // The basis amount has basis.kJoule. The other entry has other.kJoule for its own amount,
    // so the basis energy corresponds to this many of the other unit:
    double factor = basis.kJoule / other.kJoule;
    bool isBasisGram;
    double otherAmountOriginal;
    if (other.nutritionPerGramAmount == null) {
      isBasisGram = true;
      otherAmountOriginal = other.nutritionPerMilliliterAmount!;
    } else {
      isBasisGram = false;
      otherAmountOriginal = other.nutritionPerGramAmount!;
    }

    double otherAmountAdapted = otherAmountOriginal * factor;

    return NutritionsPer(
      kJoule: basis.kJoule,
      nutritionPerGramAmount: isBasisGram ? basis.nutritionPerGramAmount : otherAmountAdapted,
      nutritionPerMilliliterAmount: isBasisGram ? otherAmountAdapted : basis.nutritionPerMilliliterAmount,
      carbohydrates: basis.carbohydrates,
      sugar: basis.sugar,
      fat: basis.fat,
      saturatedFat: basis.saturatedFat,
      protein: basis.protein,
      salt: basis.salt,
    );
  }

  // Builds a NutritionsPer in the amount of baseNutriments (kept as is, not
  // scaled to 100). Missing values are taken from the other entries of
  // allNutriments and scaled to that amount.
  static NutritionsPer? _buildNutritionsPer({required List<NutrimentsApiV3> allNutriments, required NutrimentsApiV3 baseNutriments, required bool isLiquid}) {
    final List<NutrimentsApiV3> orderedOtherNutriments = allNutriments.where((NutrimentsApiV3 nutriment) => nutriment != baseNutriments).toList();
    final int baseAmount = isLiquid ? _getAmountInGramOrMilliliter(nutriment: baseNutriments) : baseNutriments.perQuantity;

    // Energy: kJ is required, fall back to kcal if no entry has kJ.
    double? energyKiloJoule =
        baseNutriments.energyKj ??
        _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.energyKj);
    if (energyKiloJoule == null) {
      final double? energyKiloCalories =
          baseNutriments.energyKcal ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.energyKcal);
      if (energyKiloCalories != null) {
        energyKiloJoule = ConvertValidate.getKJoulesFromKCals(kCals: energyKiloCalories);
      }
    }

    // Only build the result if the required energy value exists.
    if (energyKiloJoule == null) {
      return null;
    }

    return NutritionsPer(
      kJoule: energyKiloJoule,
      nutritionPerGramAmount: isLiquid ? null : baseAmount.toDouble(),
      nutritionPerMilliliterAmount: isLiquid ? baseAmount.toDouble() : null,
      fat:
          baseNutriments.fat ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.fat),
      saturatedFat:
          baseNutriments.saturatedFat ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.saturatedFat),
      carbohydrates:
          baseNutriments.carbohydrates ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.carbohydrates),
      sugar:
          baseNutriments.sugars ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.sugars),
      protein:
          baseNutriments.proteins ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.proteins),
      salt:
          baseNutriments.salt ??
          _getValuePerAmount(orderedNutriments: orderedOtherNutriments, amountGramOrMilliliter: baseAmount, getValue: (nutriment) => nutriment.salt),
    );
  }

  // Amount in g or ml. Liters are converted to ml.
  static int _getAmountInGramOrMilliliter({required NutrimentsApiV3 nutriment}) {
    return nutriment.perUnit == OpenFoodFactsApiStrings.liter ? nutriment.perQuantity * 1000 : nutriment.perQuantity;
  }

  static double? _getValuePerAmount({
    required List<NutrimentsApiV3> orderedNutriments,
    required int amountGramOrMilliliter,
    required double? Function(NutrimentsApiV3 nutriment) getValue,
  }) {
    for (NutrimentsApiV3 nutriment in orderedNutriments) {
      double? rawValue = getValue(nutriment);
      if (rawValue != null) {
        double scaleFactor = amountGramOrMilliliter / _getAmountInGramOrMilliliter(nutriment: nutriment);
        return rawValue * scaleFactor;
      }
    }
    return null;
  }

  double? _getEnergyPer100UnitsFromServing({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? energyKjPer100Units = foodApi.nutriments!.energyKj100g?.toDouble();

    if (energyKjPer100Units == null && foodApi.nutriments!.energyKj != null && servingAdjustFactor != null) {
      energyKjPer100Units = (foodApi.nutriments!.energyKj! * servingAdjustFactor);
    }

    return energyKjPer100Units;
  }

  double? _getCarbohydratesPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? carbohydratesPer100Units = foodApi.nutriments!.carbohydrates100g;

    if (carbohydratesPer100Units == null && foodApi.nutriments!.carbohydrates != null && servingAdjustFactor != null) {
      carbohydratesPer100Units = foodApi.nutriments!.carbohydrates! * servingAdjustFactor;
    }

    return carbohydratesPer100Units;
  }

  double? _getSugarsPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? sugarsPer100Units = foodApi.nutriments!.sugars100g;

    if (sugarsPer100Units == null && foodApi.nutriments!.sugars != null && servingAdjustFactor != null) {
      sugarsPer100Units = foodApi.nutriments!.sugars! * servingAdjustFactor;
    }

    return sugarsPer100Units;
  }

  double? _getFatPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? fatPer100Units = foodApi.nutriments!.fat100g;

    if (fatPer100Units == null && foodApi.nutriments!.fat != null && servingAdjustFactor != null) {
      fatPer100Units = foodApi.nutriments!.fat! * servingAdjustFactor;
    }

    return fatPer100Units;
  }

  double? _getSaturatedFatPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? saturatedFatPer100Units = foodApi.nutriments!.saturatedFat100g;

    if (saturatedFatPer100Units == null && foodApi.nutriments!.saturatedFat != null && servingAdjustFactor != null) {
      saturatedFatPer100Units = foodApi.nutriments!.saturatedFat! * servingAdjustFactor;
    }

    return saturatedFatPer100Units;
  }

  double? _getProteinsPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
    double? proteinsPer100Units = foodApi.nutriments!.proteins100g;

    if (proteinsPer100Units == null && foodApi.nutriments!.proteins != null && servingAdjustFactor != null) {
      proteinsPer100Units = foodApi.nutriments!.proteins! * servingAdjustFactor;
    }

    return proteinsPer100Units;
  }

  double? _getSaltPer100Units({required FoodApiV1 foodApi, double? servingAdjustFactor}) {
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
    await _updateFoodEntriesMeasurementUnit(food);
  }

  Future<void> setFood({required Food food}) async {
    int foodId = await _oejDatabaseService.setFood(
      foodData: _getFoodData(food: food),
      id: food.id,
    );

    food.id ??= foodId;

    await _setFoodUnits(food: food);
    await _updateFoodEntriesMeasurementUnit(food);
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
    List<int> foodUnitIdsSet = [];

    Map<String, Object?> foodUnitData;
    int foodUnitId;

    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in food.foodUnitsWithOrder) {
      foodUnitData = {
        OpenEatsJournalStrings.dbColumnFoodIdRef: food.id,
        OpenEatsJournalStrings.dbColumnName: foodUnitWithOrder.object.name,
        OpenEatsJournalStrings.dbColumnAmount: foodUnitWithOrder.object.amount,
        OpenEatsJournalStrings.dbColumnAmountMeasurementUnitIdRef: foodUnitWithOrder.object.amountMeasurementUnit.value,
        OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef: foodUnitWithOrder.object.originalFoodSourceFoodUnitId,
        OpenEatsJournalStrings.dbColumnOrderNumber: foodUnitWithOrder.order,
        OpenEatsJournalStrings.dbColumnIsDefault: foodUnitWithOrder.object == food.defaultFoodUnit ? 1 : 0,
      };

      foodUnitId = foodUnitWithOrder.object.originalFoodSourceFoodUnitId != null
          ? await _oejDatabaseService.setFoodUnitByExternalId(foodUnitData: foodUnitData, id: foodUnitWithOrder.object.id)
          : await _oejDatabaseService.setFoodUnit(foodUnitData: foodUnitData, id: foodUnitWithOrder.object.id);

      foodUnitWithOrder.object.id ??= foodUnitId;
      foodUnitIdsSet.add(foodUnitId);
    }

    await _oejDatabaseService.deleteFoodUnitsByFoodRef(foodId: food.id!, exceptIds: foodUnitIdsSet);
  }

  Future<void> _updateFoodEntriesMeasurementUnit(Food food) async {
    //If food changes its nutritionPerXXXmount to null possibly, associated eats journal food entries associated to that food and measurement unit need to be
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
    int currentFoodId = -1;
    bool foodRelevant = false;
    List<String> foodData = [];
    List<List<String>> foodUnitsData = [];
    StandardFoodDataCsvHeaderInfo? standardFoodCsvHeaderInfo;

    for (int fileIndex = 1; fileIndex <= standardFoodDataAssetsassets.length; fileIndex++) {
      standardFoodDataCsv = await _oejAssetsService.getCsvContent(path: "assets/standard_food_data.$fileIndex.csv");

      int csvLineIndex = 0;
      if (fileIndex == 1) {
        standardFoodCsvHeaderInfo = _getCsvHeaderInfo(standardFoodDataCsv: standardFoodDataCsv);
        csvLineIndex = standardFoodCsvHeaderInfo.firstDataRowIndex;
      }

      if (lastProcessedStandardFoodDataChangeDate == null ||
          standardFoodCsvHeaderInfo!.lastStandardFoodDataChangeDate.isAfter(lastProcessedStandardFoodDataChangeDate)) {
        while (csvLineIndex < standardFoodDataCsv.length) {
          if (standardFoodDataCsv[csvLineIndex].isNotEmpty) {
            if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvFood) {
              //if last data field of a row is not closed with " it may be unregognized without length check
              if (standardFoodDataCsv[csvLineIndex].length != 17) {
                throw FormatException("Csv food row invalid data field amount, row ${csvLineIndex + 1}.");
              }

              if (int.parse(standardFoodDataCsv[csvLineIndex][1]) != currentFoodId) {
                if (currentFoodId != -1 && foodRelevant) {
                  await _setStandardFoodFromCsvData(foodDataCsv: foodData, foodUnitsCsv: foodUnitsData, languageCode: languageCode);
                }
              }

              currentFoodId = int.parse(standardFoodDataCsv[csvLineIndex][1]);

              if (lastProcessedStandardFoodDataChangeDate == null ||
                  _csvDateFormat.parseUtc(standardFoodDataCsv[csvLineIndex][2]).isAfter(lastProcessedStandardFoodDataChangeDate)) {
                foodRelevant = true;
                foodData = standardFoodDataCsv[csvLineIndex];
                foodUnitsData.clear();
              } else {
                foodRelevant = false;
              }
            } else if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvFoodUnit) {
              //if last data field of a row is not closed with " it may be unregognized without length check
              if (standardFoodDataCsv[csvLineIndex].length != 7) {
                throw FormatException("Csv food unit row invalid data field amount, row ${csvLineIndex + 1}.");
              }

              if (foodRelevant) {
                foodUnitsData.add(standardFoodDataCsv[csvLineIndex]);
              }
            } else {
              throw FormatException("Csv invalid row type, row ${csvLineIndex + 1}.");
            }
          }

          csvLineIndex++;
        }
      }
    }

    if (currentFoodId != -1 && foodRelevant) {
      await _setStandardFoodFromCsvData(foodDataCsv: foodData, foodUnitsCsv: foodUnitsData, languageCode: languageCode);
    }

    return standardFoodCsvHeaderInfo!.lastStandardFoodDataChangeDate;
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
              amountMeasurementUnit: MeasurementUnit.values.firstWhere((MeasurementUnit unit) => unit.text == foodUnitCsv[5]),
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
      orderedFoodUnitsWithDefault: foodUnitsWithOrder,
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
    await _oejDatabaseService.deleteFoodUnitsByFoodRef(foodId: food.id!, exceptIds: []);
    await _oejDatabaseService.deleteFood(foodId: food.id!);
  }

  String getFoodSearchText({required Food food}) {
    String searchText = food.name.trim();
    if (food.brands.isNotEmpty) {
      searchText = " $searchText ${food.brands.map((String brand) => brand.trim()).join(" ")}";
    }

    return searchText;
  }

  StandardFoodDataCsvHeaderInfo _getCsvHeaderInfo({required List<List<String>> standardFoodDataCsv}) {
    DateTime? lastStandardFoodDataChangeDate;
    int? firstDataRowIndex;

    bool headerFound = false;
    bool inHeader = false;
    bool commentsFound = false;
    int headerLineIndex = 0;
    for (int csvLineIndex = 0; csvLineIndex < standardFoodDataCsv.length && firstDataRowIndex == null; csvLineIndex++) {
      if (inHeader) {
        if (headerLineIndex == 1) {
          lastStandardFoodDataChangeDate = _csvDateFormat.parseUtc(standardFoodDataCsv[2][0]);
        }

        headerLineIndex++;
      }

      if (standardFoodDataCsv[csvLineIndex].length == 1) {
        if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvHeader) {
          headerFound = true;
          inHeader = true;
        }

        if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvComments) {
          if (!headerFound) {
            throw FormatException("Csv standard food data header not found before comments.");
          }

          commentsFound = true;
          inHeader = false;
        }

        if (standardFoodDataCsv[csvLineIndex][0] == OpenEatsJournalStrings.csvData) {
          if (!commentsFound) {
            throw FormatException("Csv standard food data comments not found before data.");
          }

          inHeader = false;
          firstDataRowIndex = csvLineIndex + 1;
        }
      }
    }

    if (lastStandardFoodDataChangeDate == null) {
      throw FormatException("Csv standard food data last standard food data change date not found.");
    }

    if (firstDataRowIndex == null) {
      throw FormatException("Csv standard food data first data row index not found.");
    }

    return StandardFoodDataCsvHeaderInfo(lastStandardFoodDataChangeDate: lastStandardFoodDataChangeDate, firstDataRowIndex: firstDataRowIndex);
  }

  //factory method which can be overriden for tests e.g.
  Food getNewFood() {
    if (_getNewFood == null) {
      return Food(
        name: OpenEatsJournalStrings.emptyString,
        foodSource: FoodSource.user,
        fromDb: true,
        kJoule: NutritionCalculator.kJouleForOnekCal,
        nutritionPerGramAmount: 100,
      );
    }

    return _getNewFood();
  }
}

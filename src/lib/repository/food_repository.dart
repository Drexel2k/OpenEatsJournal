import "dart:convert";

import "package:http/http.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/food_unit_type.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/repository/food_repository_result.dart";
import "package:openeatsjournal/service/database/open_eats_journal_database_service.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";
import "package:openeatsjournal/service/open_food_facts/data/food_api.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class FoodRepository {
  FoodRepository._singleton();
  static final FoodRepository instance = FoodRepository._singleton();

  late OpenFoodFactsService _openFoodFactsService;
  late OpenEatsJournalDatabaseService _oejDatabase;

  final int _pageSize = 100;

  //must be called once before the singleton is used
  void init({required OpenFoodFactsService openFoodFactsService, required OpenEatsJournalDatabaseService oejDatabase}) {
    _openFoodFactsService = openFoodFactsService;
    _oejDatabase = oejDatabase;
  }

  Future<FoodRepositoryResult> getFoodByBarcode({required int barcode, required String languageCode}) async {
    List<Food> foods = [];
    List<Food>? userFoods = await _oejDatabase.getUserFoodByBarcode(barcode);
    if (userFoods != null) {
      foods.addAll(userFoods);
    }

    FoodRepositoryResult foodRepositoryResult = await getOpenFoodFactsFoodByBarcode(barcode: barcode, languageCode: languageCode);

    //todo: show local results if online services fail...
    if (foodRepositoryResult.errorCode == null) {
      foods.add(foodRepositoryResult.foods![0]);
    }

    return FoodRepositoryResult(
      foods: foods,
      finished: foodRepositoryResult.errorCode == null ? true : false,
      errorCode: foodRepositoryResult.errorCode,
      errorMessage: foodRepositoryResult.errorMessage,
    );
  }

  Future<FoodRepositoryResult> getOpenFoodFactsFoodByBarcode({required int barcode, required String languageCode}) async {
    String? jsonString;
    try {
      jsonString = await _openFoodFactsService.getFoodByBarcode(barcode: barcode);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult(errorCode: 1, errorMessage: clientException.message);
    }

    if (jsonString != null) {
      Map<String, dynamic> json = jsonDecode(jsonString);

      if (json.containsKey(OpenFoodFactsApiStrings.product)) {
        Food? food = _getFoodFromFoodApiV1V2(json: json[OpenFoodFactsApiStrings.product], languageCode: languageCode);

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

  Future<FoodRepositoryResult> getFoodBySearchText({required String searchText, required String languageCode}) async {
    List<Food> foods = [];
    List<Food>? userFoods = await _oejDatabase.getUserFoodBySearchtext(searchText.split(" ").map((String element) => "*${element.trim()}*").join(" "));
    if (userFoods != null) {
      foods.addAll(userFoods);
    }

    FoodRepositoryResult foodRepositoryResult = await getOpenFoodFactsFoodBySearchTextApiV1(searchText: searchText, languageCode: languageCode, page: 1);

    //todo: show local results if online services fail...
    if (foodRepositoryResult.errorCode == null) {
      foods.addAll(foodRepositoryResult.foods!);
    }

    return FoodRepositoryResult(
      foods: foods,
      finished: foodRepositoryResult.finished,
      errorCode: foodRepositoryResult.errorCode,
      errorMessage: foodRepositoryResult.errorMessage,
    );
  }

  Future<List<Food>?> getUserFoodBySearchText({required String searchText}) async {
    return await _oejDatabase.getUserFoodBySearchtext(searchText);
  }

  Future<FoodRepositoryResult> getOpenFoodFactsFoodBySearchTextApiV1({required String searchText, required String languageCode, required int page}) async {
    String? jsonString;
    try {
      jsonString = await _openFoodFactsService.getFoodBySearchTextApiV1(searchText: searchText, page: page, pageSize: _pageSize);
    } on ClientException catch (clientException) {
      return FoodRepositoryResult(errorCode: 1, errorMessage: clientException.message);
    }

    List<Food> foods = [];
    if (jsonString != null) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      if (json.containsKey(OpenFoodFactsApiStrings.products)) {
        for (Map<String, dynamic> product in json[OpenFoodFactsApiStrings.products]) {
          Food? food = _getFoodFromFoodApiV1V2(json: product, languageCode: languageCode);

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

  Food? _getFoodFromFoodApiV1V2({required Map<String, dynamic> json, required String languageCode}) {
    FoodApi foodApi = FoodApi.fromJsonApiV1V2(json);

    if (foodApi.nutriments != null && (foodApi.productQuantityUnit != null || foodApi.servingQuantityUnit != null)) {
      double? servingAdjustFactor;
      int? energyKjPer100Units;
      MeasurementUnit? nutrimentsMeasurementUnit;

      if (foodApi.nutritionDataPer != null && foodApi.nutritionDataPer == OpenFoodFactsApiStrings.serving) {
        if (foodApi.servingQuantity != null) {
          num servingQuantity = num.parse(foodApi.servingQuantity!);
          servingAdjustFactor = 100 / servingQuantity;
          energyKjPer100Units = _getEnergyPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        }

        //If energyKjPer100Units is not null here we assume the unit is from serving, because nutritionDataPer was not null and per serving.
        //So even the energyKj100g from the api should be in the serving unit.
        if (energyKjPer100Units != null) {
          nutrimentsMeasurementUnit = _getMeasurementUnitFromApiString(foodApi.servingQuantityUnit);
        }
      }

      if (energyKjPer100Units == null || nutrimentsMeasurementUnit == null) {
        //We don't have valid infos from the serving here, so we check the product data.
        //nutritionDataPer can only be 100g or serving, so if it is not serving, energyKj100g and energyKj should be the same.
        energyKjPer100Units = foodApi.nutriments!.energyKj100g ?? foodApi.nutriments!.energyKj;
        nutrimentsMeasurementUnit = _getMeasurementUnitFromApiString(foodApi.productQuantityUnit);
      }

      if (energyKjPer100Units != null && nutrimentsMeasurementUnit != null) {
        double? carbohydratesPer100Units = _getCarbohydratesPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? sugarPer100Units = _getSugarsPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? fatPer100Units = _getFatPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? saturatedFatPer100Units = _getSaturatedFatPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? proteinsPer100Units = _getProteinsPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);
        double? saltPer100Units = _getSaltPer100Units(foodApi: foodApi, servingAdjustFactor: servingAdjustFactor);

        Food food = Food(
          name: _getFoodName(foodApi: foodApi, languageCode: languageCode),
          brands: _getCleanBrands(foodApi.brandsTags),
          foodSource: FoodSource.openFoodFacts,
          originalFoodSourceFoodId: foodApi.code,
          barcode: int.parse(foodApi.code),
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
        );

        if (_getMeasurementUnitFromApiString(foodApi.servingQuantityUnit) == nutrimentsMeasurementUnit) {
          if (foodApi.servingQuantity != null) {
            food.addFoodUnit(
              foodUnit: FoodUnit(
                name: OpenEatsJournalStrings.serving,
                amount: double.parse(foodApi.servingQuantity!),
                amountMeasurementUnit: nutrimentsMeasurementUnit,
                foodUnitType: FoodUnitType.serving,
              ),
            );
          }
        }

        if (_getMeasurementUnitFromApiString(foodApi.productQuantityUnit) == nutrimentsMeasurementUnit) {
          if (foodApi.productQuantity != null) {
            food.addFoodUnit(
              foodUnit: FoodUnit(
                name: OpenEatsJournalStrings.piece,
                amount: double.parse(foodApi.productQuantity!),
                amountMeasurementUnit: nutrimentsMeasurementUnit,
                foodUnitType: FoodUnitType.piece,
              ),
            );
          }
        }

        return food;
      }
    }

    return null;
  }

  MeasurementUnit? _getMeasurementUnitFromApiString(String? value) {
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

  // Future<FoodRepositoryGetFoodBySearchTextResult> getFoodBySearchTextSearchALicous({
  //   required String searchText,
  //   required String languageCode,
  //   required int page,
  // }) async {
  //   String? jsonString;
  //   try {
  //     jsonString = await _openFoodFactsService.getFoodBySearchTextSearchALicous(searchText: searchText, languageCode: languageCode, page: page);
  //   } on ClientException catch (clientException) {
  //     return FoodRepositoryGetFoodBySearchTextResult(errorCode: 1, errorMessage: clientException.message);
  //   }

  //   if (jsonString != null) {
  //     //server responed with status 200
  //     List<Food> foods = [];
  //     Map<String, dynamic> json = jsonDecode(jsonString);
  //     if (json.containsKey(OpenFoodFactsApiStrings.hits)) {
  //       int amount = 0;
  //       num parsedNumber = 0;
  //       Match? match;
  //       String? numberPart;
  //       String? alphabetPart;

  //       RegExp regex = RegExp(r'^([\d., ]+)([a-zA-Z]+)$');

  //       for (Map<String, dynamic> hit in json[OpenFoodFactsApiStrings.hits]) {
  //         FoodApi foodApi = FoodApi.fromJsonSearALiciousApi(hit);

  //         MeasurementUnit measurementUnit = MeasurementUnit.gram;
  //         if (foodApi.quantity != null) {
  //           List<String> parts = foodApi.quantity!.split(" ");
  //           if (parts.length > 1) {
  //             if (parts[1].trim().toLowerCase() == OpenFoodFactsApiStrings.liter || parts[1].trim().toLowerCase() == OpenFoodFactsApiStrings.milliliter) {
  //               measurementUnit = MeasurementUnit.milliliter;
  //             }
  //           }
  //         }

  //         if (foodApi.nutriments != null && foodApi.nutriments!.energyKj100g != null) {
  //           Food food = Food(
  //             name: _getFoodName(foodApi: foodApi, languageCode: languageCode),
  //             brands: _getCleanBrands(foodApi.brandsTags),
  //             foodSource: FoodSource.openFoodFacts,
  //             foodSourceId: foodApi.code,
  //             measurementUnit: measurementUnit,
  //             energyKjPer100Units: foodApi.nutriments!.energyKj100g!,
  //             carbohydratesPer100Units: foodApi.nutriments!.carbohydrates100g,
  //             sugarsPer100Units: foodApi.nutriments!.sugars100g,
  //             fatPer100Units: foodApi.nutriments!.fat100g,
  //             saturatedFatPer100Units: foodApi.nutriments!.saturatedFat100g,
  //             proteinsPer100Units: foodApi.nutriments!.proteins100g,
  //             saltPer100Units: foodApi.nutriments!.salt100g,
  //           );

  //           if (foodApi.quantity != null) {
  //             amount = 0;
  //             parsedNumber = 0;
  //             numberPart = null;
  //             alphabetPart = null;

  //             match = regex.firstMatch(foodApi.quantity!) as Match?;

  //             if (match != null) {
  //               numberPart = match.group(1)!.trim();
  //               alphabetPart = match.group(2)!;
  //             }

  //             if (alphabetPart != null && numberPart != null) {
  //               parsedNumber = NumberFormat(null, foodApi.lang).parse(numberPart);
  //               if (alphabetPart.toLowerCase() == OpenFoodFactsApiStrings.gram) {
  //                 amount = parsedNumber.round();
  //               }

  //               if (alphabetPart.toLowerCase() == OpenFoodFactsApiStrings.milliGram) {
  //                 amount = (parsedNumber / 1000).round();
  //               }

  //               if (alphabetPart.toLowerCase() == OpenFoodFactsApiStrings.kiloGram) {
  //                 amount = (parsedNumber * 1000).round();
  //               }

  //               if (alphabetPart.toLowerCase() == OpenFoodFactsApiStrings.milliliter) {
  //                 amount = parsedNumber.round();
  //               }

  //               if (alphabetPart.toLowerCase() == OpenFoodFactsApiStrings.liter) {
  //                 amount = (parsedNumber * 1000).round();
  //               }

  //               if (amount > 0) {
  //                 food.addFoodUnit(name: OpenEatsJournalStrings.piece, amount: amount);
  //               }
  //             }
  //           }

  //           foods.add(food);
  //         }
  //       }

  //       return FoodRepositoryGetFoodBySearchTextResult(
  //         page: json[OpenFoodFactsApiStrings.page],
  //         pageCount: json[OpenFoodFactsApiStrings.pageCount],
  //         foods: foods,
  //       );
  //     } else {
  //       return FoodRepositoryGetFoodBySearchTextResult(errorCode: 2);
  //     }
  //   }

  //   //server responded, but not status 200
  //   return FoodRepositoryGetFoodBySearchTextResult(errorCode: 3);
  // }

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

  int? _getEnergyPer100Units({required FoodApi foodApi, double? servingAdjustFactor}) {
    int? energyKjPer100Units = foodApi.nutriments!.energyKj100g;

    if (energyKjPer100Units == null && foodApi.nutriments!.energyKj != null && servingAdjustFactor != null) {
      energyKjPer100Units = (foodApi.nutriments!.energyKj! * servingAdjustFactor).round();
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

  _getCleanBrands(List<String>? brands) {
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

  Future<void> setFoodByExternalId({required Food food}) async {
    await _oejDatabase.setFoodByExternalId(food: food);
  }

  Future<void> setFood({required Food food}) async {
    await _oejDatabase.setFood(food: food);
  }
}

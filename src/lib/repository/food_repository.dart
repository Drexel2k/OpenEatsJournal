import "dart:convert";

import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/unit.dart";
import "package:openeatsjournal/service/open_food_facts/api_strings.dart";
import "package:openeatsjournal/service/open_food_facts/data/food_api.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_service.dart";
import "package:openeatsjournal/ui/utils/oej_strings.dart";

class FoodRepository {
  FoodRepository._singleton();
  static final FoodRepository instance = FoodRepository._singleton();

  late OpenFoodFactsService _openFoodFactsService;

  //must be called once before the singleton is used
  void init({required OpenFoodFactsService openFoodFactsService}) {
    _openFoodFactsService = openFoodFactsService;
  }

  Future<Food?> getFoodByBarcode({required String barcode, required String languageCode}) async {
    String? jsonString = await _openFoodFactsService.getFoodByBarcode(barcode: barcode);
    if (jsonString != null) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      FoodApi foodApi = FoodApi.fromJsonApiV2(json[ApiStrings.product]);

      if (foodApi.nutriments == null) {
        return null;
      }

      double? adjustFactor;

      if (foodApi.nutritionDataPer != null && foodApi.nutritionDataPer == ApiStrings.serving) {
        if (foodApi.servingQuantity != null) {
          int servingQuantity = int.parse(foodApi.servingQuantity!);
          adjustFactor = 100 / servingQuantity;
        }
      }

      int? energyKjPer100Units = _getEnergyPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);

      if (energyKjPer100Units == null) {
        return null;
      }

      double? carbohydratesPer100Units = _getCarbohydratesPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);
      double? sugarsPer100Units = _getSugarsPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);
      double? fatPer100Units = _getFatPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);
      double? saturatedFatPer100Units = _getSaturatedFatPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);
      double? proteinsPer100Units = _getProteinsPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);
      double? saltPer100Units = _getSaltPer100Units(foodApi: foodApi, adjustFactor: adjustFactor);

      return Food(
        name: _getFoodName(foodApi: foodApi, languageCode: languageCode),
        brands: foodApi.brandsTags,
        foodSource: FoodSource.openFoodFacts,
        foodSourceId: foodApi.id,
        measurementUnit: MeasurementUnit.gram,
        energyKjPer100Units: energyKjPer100Units,
        carbohydratesPer100Units: carbohydratesPer100Units,
        sugarsPer100Units: sugarsPer100Units,
        fatPer100Units: fatPer100Units,
        saturatedFatPer100Units: saturatedFatPer100Units,
        proteinsPer100Units: proteinsPer100Units,
        saltPer100Units: saltPer100Units,
      );
    }

    return null;
  }

  Future<List<Food>?> getFoodBySearchText({required String searchText, required String languageCode}) async {
    String? jsonString = await _openFoodFactsService.getFoodBySearchText(
      searchText: searchText,
      languageCode: languageCode,
    );
    if (jsonString != null) {
      List<Food> foods = [];
      Map<String, dynamic> json = jsonDecode(jsonString);
      for (Map<String, dynamic> hit in json["hits"]) {
        FoodApi foodApi = FoodApi.fromJsonSearALiciousApi(hit);
        if (foodApi.nutriments != null && foodApi.nutriments!.energyKj100g != null) {
          Food food = Food(
            name: _getFoodName(foodApi: foodApi, languageCode: languageCode),
            brands: foodApi.brandsTags,
            foodSource: FoodSource.openFoodFacts,
            foodSourceId: foodApi.id,
            measurementUnit: MeasurementUnit.gram,
            energyKjPer100Units: foodApi.nutriments!.energyKj100g!,
            carbohydratesPer100Units: foodApi.nutriments!.carbohydrates100g,
            sugarsPer100Units: foodApi.nutriments!.sugars100g,
            fatPer100Units: foodApi.nutriments!.fat100g,
            saturatedFatPer100Units: foodApi.nutriments!.saturatedFat100g,
            proteinsPer100Units: foodApi.nutriments!.proteins100g,
            saltPer100Units: foodApi.nutriments!.salt100g,
          );
          foods.add(food);
        }
      }
      return foods;
    }

    return null;
  }

  String _getFoodName({required FoodApi foodApi, required String languageCode}) {
    String name = OejStrings.emptyString;

    if (languageCode == OejStrings.de) {
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

    if (languageCode == OejStrings.en || name.trim().isEmpty) {
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

  int? _getEnergyPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    int? energyKjPer100Units = foodApi.nutriments!.energyKj100g;

    if (energyKjPer100Units == null && foodApi.nutriments!.energyKj != null && foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        energyKjPer100Units = foodApi.nutriments!.energyKj;
      }

      if (adjustFactor != null) {
        energyKjPer100Units = (foodApi.nutriments!.energyKj! * adjustFactor).round();
      }
    }

    return energyKjPer100Units;
  }

  double? _getCarbohydratesPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? carbohydratesPer100Units = foodApi.nutriments!.carbohydrates100g;

    if (carbohydratesPer100Units == null &&
        foodApi.nutriments!.carbohydrates != null &&
        foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        carbohydratesPer100Units = foodApi.nutriments!.carbohydrates;
      }

      if (adjustFactor != null) {
        carbohydratesPer100Units = foodApi.nutriments!.carbohydrates! * adjustFactor;
      }
    }

    return carbohydratesPer100Units;
  }

  double? _getSugarsPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? sugarsPer100Units = foodApi.nutriments!.sugars100g;

    if (sugarsPer100Units == null && foodApi.nutriments!.sugars != null && foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        sugarsPer100Units = foodApi.nutriments!.sugars;
      }

      if (adjustFactor != null) {
        sugarsPer100Units = foodApi.nutriments!.sugars! * adjustFactor;
      }
    }

    return sugarsPer100Units;
  }

  double? _getFatPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? fatPer100Units = foodApi.nutriments!.fat100g;

    if (fatPer100Units == null && foodApi.nutriments!.fat != null && foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        fatPer100Units = foodApi.nutriments!.fat;
      }

      if (adjustFactor != null) {
        fatPer100Units = foodApi.nutriments!.fat! * adjustFactor;
      }
    }

    return fatPer100Units;
  }

  double? _getSaturatedFatPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? saturatedFatPer100Units = foodApi.nutriments!.saturatedFat100g;

    if (saturatedFatPer100Units == null &&
        foodApi.nutriments!.saturatedFat != null &&
        foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        saturatedFatPer100Units = foodApi.nutriments!.saturatedFat;
      }

      if (adjustFactor != null) {
        saturatedFatPer100Units = foodApi.nutriments!.saturatedFat! * adjustFactor;
      }
    }

    return saturatedFatPer100Units;
  }

  double? _getProteinsPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? proteinsPer100Units = foodApi.nutriments!.proteins100g;

    if (proteinsPer100Units == null && foodApi.nutriments!.proteins != null && foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        proteinsPer100Units = foodApi.nutriments!.proteins;
      }

      if (adjustFactor != null) {
        proteinsPer100Units = foodApi.nutriments!.proteins! * adjustFactor;
      }
    }

    return proteinsPer100Units;
  }

  double? _getSaltPer100Units({required FoodApi foodApi, double? adjustFactor}) {
    double? saltPer100Units = foodApi.nutriments!.salt100g;

    if (saltPer100Units == null && foodApi.nutriments!.salt != null && foodApi.nutritionDataPer != null) {
      if (foodApi.nutritionDataPer == ApiStrings.hundred) {
        saltPer100Units = foodApi.nutriments!.salt;
      }

      if (adjustFactor != null) {
        saltPer100Units = foodApi.nutriments!.salt! * adjustFactor;
      }
    }

    return saltPer100Units;
  }
}

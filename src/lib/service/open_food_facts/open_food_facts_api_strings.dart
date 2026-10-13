class OpenFoodFactsApiStrings {
  OpenFoodFactsApiStrings._static();

  static const String product = "product";
  static const String serving = "serving";
  static const String nutrimentsPrefix = "nutriments.";
  static const String nutritionPrefix = "nutrition.";
  static const String pageCount = "page_count";
  static const String products = "products";
  static const String gram = "g";
  static const String liter = "l";
  static const String milliliter = "ml";
  static const String packaging = "packaging";
  static const String asSold = "as_sold";
  static const String prepared = "prepared";

  static const String fieldCode = "code";
  static const String fieldProductName = "product_name";
  static const String fieldProductNameEn = "product_name_en";
  static const String fieldProductNameDe = "product_name_de";
  static const String fieldAbbreviatedProductName = "abbreviated_product_name";
  static const String fieldAbbreviatedProductNameEn = "abbreviated_product_name_en";
  static const String fieldAbbreviatedProductNameDe = "abbreviated_product_name_de";
  static const String fieldGenericName = "generic_name";
  static const String fieldGenericNameEn = "generic_name_en";
  static const String fieldGenericNameDe = "generic_name_de";
  static const String fieldBrandsTags = "brands_tags";
  static const String fieldBrands = "brands";
  static const String fieldNutritionDataPer = "nutrition_data_per";
  static const String fieldProductQuantity = "product_quantity";
  static const String fieldProductQuantityUnit = "product_quantity_unit";
  static const String fieldEnergy = "energy";
  static const String fieldEnergyKjoule = "energy-kj";
  static const String fieldEnergy100g = "energy_100g";
  static const String fieldCarboHydrates = "carbohydrates";
  static const String fieldCarboHydrates100g = "carbohydrates_100g";
  static const String fieldSugars = "sugars";
  static const String fieldSugars100g = "sugars_100g";
  static const String fieldFat = "fat";
  static const String fieldFat100g = "fat_100g";
  static const String fieldSaturatedFat = "saturated-fat";
  static const String fieldSaturatedFat100g = "saturated-fat_100g";
  static const String fieldProteins = "proteins";
  static const String fieldProteins100g = "proteins_100g";
  static const String fieldSalt = "salt";
  static const String fieldSalt100g = "salt_100g";
  static const String fieldServingQuantity = "serving_quantity";
  static const String fieldServingQuantityUnit = "serving_quantity_unit";
  static const String fieldServingSize = "serving_size";
  static const String fieldNutriments = "nutriments";
  static const String fieldNutrition = "nutrition";
  static const String fieldQuantity = "quantity";
  static const String fieldEnergyKcal = "energy-kcal";
  static const String fieldEnergyKcal100g = "energy-kcal_100g";
  static const String fieldLang = "lang";
  static const String fieldInputSets = "input_sets";
  static const String fieldPer = "per";
  static const String fieldPerQuantity = "per_quantity";
  static const String fieldPerUnit = "per_unit";
  static const String fieldPreparation = "preparation";
  static const String fieldNutrients = "nutrients";
  static const String fieldValue = "value";
  static const String fieldSource = "source";

  static const List<String> apiV1V2CommonFields = [
    fieldCode,
    fieldProductName,
    fieldProductNameEn,
    fieldProductNameDe,
    fieldAbbreviatedProductName,
    fieldAbbreviatedProductNameEn,
    fieldAbbreviatedProductNameDe,
    fieldGenericName,
    fieldGenericNameEn,
    fieldGenericNameDe,
    fieldBrandsTags,
    fieldQuantity,
    fieldProductQuantity,
    fieldProductQuantityUnit,
    fieldServingSize,
    fieldServingQuantity,
    fieldServingQuantityUnit,
    fieldNutritionDataPer,
    fieldLang,
  ];

  static const List<String> apiV1Fields = [
    ...apiV1V2CommonFields,
    "$nutrimentsPrefix$fieldEnergy",
    "$nutrimentsPrefix$fieldEnergy100g",
    "$nutrimentsPrefix$fieldCarboHydrates",
    "$nutrimentsPrefix$fieldCarboHydrates100g",
    "$nutrimentsPrefix$fieldSugars",
    "$nutrimentsPrefix$fieldSugars100g",
    "$nutrimentsPrefix$fieldFat",
    "$nutrimentsPrefix$fieldFat100g",
    "$nutrimentsPrefix$fieldSaturatedFat",
    "$nutrimentsPrefix$fieldSaturatedFat100g",
    "$nutrimentsPrefix$fieldProteins",
    "$nutrimentsPrefix$fieldProteins100g",
    "$nutrimentsPrefix$fieldSalt",
    "$nutrimentsPrefix$fieldSalt100g",
  ];

  static const List<String> apiV3Fields = [...apiV1V2CommonFields, "$nutritionPrefix$fieldInputSets"];
}

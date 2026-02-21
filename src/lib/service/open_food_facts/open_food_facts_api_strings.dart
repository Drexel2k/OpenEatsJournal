class OpenFoodFactsApiStrings {
  OpenFoodFactsApiStrings._static();

  static const product = "product";
  static const serving = "serving";
  static const hundredGram = "100g";
  static const nutrimentsPrefix = "nutriments.";
  static const page = "page";
  static const pageCount = "page_count";
  static const hits = "hits";
  static const products = "products";
  static const gram = "g";
  static const kiloGram = "kg";
  static const milliGram = "mg";
  static const liter = "l";
  static const milliliter = "ml";

  static const fieldCode = "code";
  static const fieldProductName = "product_name";
  static const fieldProductNameEn = "product_name_en";
  static const fieldProductNameDe = "product_name_de";
  static const fieldAbbreviatedProductName = "abbreviated_product_name";
  static const fieldAbbreviatedProductNameEn = "abbreviated_product_name_en";
  static const fieldAbbreviatedProductNameDe = "abbreviated_product_name_de";
  static const fieldGenericName = "generic_name";
  static const fieldGenericNameEn = "generic_name_en";
  static const fieldGenericNameDe = "generic_name_de";
  static const fieldBrandsTags = "brands_tags";
  static const fieldBrands = "brands";
  static const fieldNutritionDataPer = "nutrition_data_per";
  static const fieldProductQuantity = "product_quantity";
  static const fieldProductQuantityUnit = "product_quantity_unit";
  static const fieldEnergy = "energy";
  static const fieldEnergy100g = "energy_100g";
  static const fieldCarboHydrates = "carbohydrates";
  static const fieldCarboHydrates100g = "carbohydrates_100g";
  static const fieldSugars = "sugars";
  static const fieldSugars100g = "sugars_100g";
  static const fieldFat = "fat";
  static const fieldFat100g = "fat_100g";
  static const fieldSaturatedFat = "saturated-fat";
  static const fieldSaturatedFat100g = "saturated-fat_100g";
  static const fieldProteins = "proteins";
  static const fieldProteins100g = "proteins_100g";
  static const fieldSalt = "salt";
  static const fieldSalt100g = "salt_100g";
  static const fieldServingQuantity = "serving_quantity";
  static const fieldServingQuantityUnit = "serving_quantity_unit";
  static const fieldServingSize = "serving_size";
  static const fieldNutriments = "nutriments";
  static const fieldQuantity = "quantity";
  static const fieldEnergyKcal = "energy-kcal";
  static const fieldEnergyKcal100g = "energy-kcal_100g";
  static const fieldLang = "lang";

  static const List<String> apiV1V2AllFields = [
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

  static const List<String> apiV1V2AllFieldsAllNutriments = [
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
    fieldNutriments,
  ];
}

import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";
import "package:openeatsjournal/service/open_food_facts/data/nutriments_api.dart";

class FoodApi {
  FoodApi({
    required String id,
    String? productName,
    String? productNameEn,
    String? productNameDe,
    String? genericName,
    String? genericNameEn,
    String? genericNameDe,
    String? abbreviatedProductName,
    String? abbreviatedProductNameEn,
    String? abbreviatedProductNameDe,
    List<String>? brandsTags,
    String? quantity,
    String? productQuantity,
    String? productQuantityUnit,
    String? servingQuantity,
    String? servingQuantityUnit,
    String? servingSize,
    String? nutritionDataPer,
    NutrimentsApi? nutriments,
  }) : _id = id,
       _productName = productName,
       _productNameEn = productNameEn,
       _productNameDe = productNameDe,
       _genericName = genericName,
       _genericNameEn = genericNameEn,
       _genericNameDe = genericNameDe,
       _abbreviatedProductName = abbreviatedProductName,
       _abbreviatedProductNameEn = abbreviatedProductNameEn,
       _abbreviatedProductNameDe = abbreviatedProductNameDe,
       _brandsTags = brandsTags,
       _quantity = quantity,
       _productQuantity = productQuantity,
       _productQuantityUnit = productQuantityUnit,
       _servingQuantity = servingQuantity,
       _servingQuantityUnit = servingQuantityUnit,
       _servingSize = servingSize,
       _nutritionDataPer = nutritionDataPer,
       _nutriments = nutriments;

  final String _id;
  final String? _productName;
  final String? _productNameEn;
  final String? _productNameDe;
  final String? _genericName;
  final String? _genericNameEn;
  final String? _genericNameDe;
  final String? _abbreviatedProductName;
  final String? _abbreviatedProductNameEn;
  final String? _abbreviatedProductNameDe;
  final List<String>? _brandsTags;
  final String? _quantity;
  final String? _productQuantity;
  final String? _productQuantityUnit;
  final String? _servingQuantity;
  final String? _servingQuantityUnit;
  final String? _servingSize;
  final String? _nutritionDataPer;
  final NutrimentsApi? _nutriments;

  String get id => _id;
  String? get productName => _productName;
  String? get productNameEn => _productNameEn;
  String? get productNameDe => _productNameDe;
  String? get genericName => _genericName;
  String? get genericNameEn => _genericNameEn;
  String? get genericNameDe => _genericNameDe;
  String? get abbreviatedProductName => _abbreviatedProductName;
  String? get abbreviatedProductNameEn => _abbreviatedProductNameEn;
  String? get abbreviatedProductNameDe => _abbreviatedProductNameDe;
  List<String>? get brandsTags => _brandsTags;
  String? get quantity => _quantity;
  String? get productQuantity => _productQuantity;
  String? get productQuantityUnit => _productQuantityUnit;

  String? get servingQuantity => _servingQuantity;
  String? get servingQuantityUnit => _servingQuantityUnit;
  String? get servingSize => _servingSize;
  String? get nutritionDataPer => _nutritionDataPer;
  NutrimentsApi? get nutriments => _nutriments;

  factory FoodApi.fromJsonApiV2(Map<String, dynamic> json) {
    return FoodApi(
      id: json[OpenFoodFactsApiStrings.fieldId],
      brandsTags: json.containsKey(OpenFoodFactsApiStrings.fieldBrandsTags)
          ? (json[OpenFoodFactsApiStrings.fieldBrandsTags] as List<dynamic>).map((brand) => brand as String).toList()
          : null,
      productName: json.containsKey(OpenFoodFactsApiStrings.fieldProductName) ? json[OpenFoodFactsApiStrings.fieldProductName] : null,
      productNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldProductNameEn) ? json[OpenFoodFactsApiStrings.fieldProductNameEn] : null,
      productNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldProductNameDe) ? json[OpenFoodFactsApiStrings.fieldProductNameDe] : null,
      genericName: json.containsKey(OpenFoodFactsApiStrings.fieldGenericName) ? json[OpenFoodFactsApiStrings.fieldGenericName] : null,
      genericNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldGenericNameEn) ? json[OpenFoodFactsApiStrings.fieldGenericNameEn] : null,
      genericNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldGenericNameDe) ? json[OpenFoodFactsApiStrings.fieldGenericNameDe] : null,
      abbreviatedProductName: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductName)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductName]
          : null,
      abbreviatedProductNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductNameEn)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductNameEn]
          : null,
      abbreviatedProductNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductNameDe)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductNameDe]
          : null,
      productQuantity: json.containsKey(OpenFoodFactsApiStrings.fieldProductQuantity) ? json[OpenFoodFactsApiStrings.fieldProductQuantity] : null,
      productQuantityUnit: json.containsKey(OpenFoodFactsApiStrings.fieldProductQuantityUnit)
          ? json[OpenFoodFactsApiStrings.fieldProductQuantityUnit]
          : null,
      servingQuantity: json.containsKey(OpenFoodFactsApiStrings.fieldServingQuantity) ? json[OpenFoodFactsApiStrings.fieldServingQuantity] : null,
      servingQuantityUnit: json.containsKey(OpenFoodFactsApiStrings.fieldServingQuantityUnit)
          ? json[OpenFoodFactsApiStrings.fieldServingQuantityUnit]
          : null,
      servingSize: json.containsKey(OpenFoodFactsApiStrings.fieldServingSize) ? json[OpenFoodFactsApiStrings.fieldServingSize] : null,
      nutritionDataPer: json.containsKey(OpenFoodFactsApiStrings.fieldNutritionDataPer)
          ? json[OpenFoodFactsApiStrings.fieldNutritionDataPer]
          : null,
      nutriments: json.containsKey(OpenFoodFactsApiStrings.fieldNutriments)
          ? NutrimentsApi.fromJson(json[OpenFoodFactsApiStrings.fieldNutriments])
          : null,
    );
  }

  factory FoodApi.fromJsonSearALiciousApi(Map<String, dynamic> json) {
    return FoodApi(
      id: json[OpenFoodFactsApiStrings.fieldCode],
      brandsTags: json.containsKey(OpenFoodFactsApiStrings.fieldBrands)
          ? (json[OpenFoodFactsApiStrings.fieldBrands] as List<dynamic>).map((brand) => brand as String).toList()
          : null,
      productName: json.containsKey(OpenFoodFactsApiStrings.fieldProductName) ? json[OpenFoodFactsApiStrings.fieldProductName] : null,
      productNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldProductNameEn) ? json[OpenFoodFactsApiStrings.fieldProductNameEn] : null,
      productNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldProductNameDe) ? json[OpenFoodFactsApiStrings.fieldProductNameDe] : null,
      genericName: json.containsKey(OpenFoodFactsApiStrings.fieldGenericName) ? json[OpenFoodFactsApiStrings.fieldGenericName] : null,
      genericNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldGenericNameEn) ? json[OpenFoodFactsApiStrings.fieldGenericNameEn] : null,
      genericNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldGenericNameDe) ? json[OpenFoodFactsApiStrings.fieldGenericNameDe] : null,
      abbreviatedProductName: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductName)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductName]
          : null,
      abbreviatedProductNameEn: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductNameEn)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductNameEn]
          : null,
      abbreviatedProductNameDe: json.containsKey(OpenFoodFactsApiStrings.fieldAbbreviatedProductNameDe)
          ? json[OpenFoodFactsApiStrings.fieldAbbreviatedProductNameDe]
          : null,
      quantity: json.containsKey(OpenFoodFactsApiStrings.fieldQuantity) ? json[OpenFoodFactsApiStrings.fieldQuantity] : null,
      nutriments: json.containsKey(OpenFoodFactsApiStrings.fieldNutriments)
          ? NutrimentsApi.fromJson(json[OpenFoodFactsApiStrings.fieldNutriments])
          : null,
    );
  }
}

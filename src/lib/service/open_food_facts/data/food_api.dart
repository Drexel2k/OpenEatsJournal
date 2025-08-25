import "package:openeatsjournal/service/open_food_facts/api_strings.dart";
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
      id: json[ApiStrings.fieldId],
      brandsTags: json.containsKey(ApiStrings.fieldBrandsTags)
          ? (json[ApiStrings.fieldBrandsTags] as List<dynamic>).map((brand) => brand as String).toList()
          : null,
      productName: json.containsKey(ApiStrings.fieldProductName) ? json[ApiStrings.fieldProductName] : null,
      productNameEn: json.containsKey(ApiStrings.fieldProductNameEn) ? json[ApiStrings.fieldProductNameEn] : null,
      productNameDe: json.containsKey(ApiStrings.fieldProductNameDe) ? json[ApiStrings.fieldProductNameDe] : null,
      genericName: json.containsKey(ApiStrings.fieldGenericName) ? json[ApiStrings.fieldGenericName] : null,
      genericNameEn: json.containsKey(ApiStrings.fieldGenericNameEn) ? json[ApiStrings.fieldGenericNameEn] : null,
      genericNameDe: json.containsKey(ApiStrings.fieldGenericNameDe) ? json[ApiStrings.fieldGenericNameDe] : null,
      abbreviatedProductName: json.containsKey(ApiStrings.fieldAbbreviatedProductName)
          ? json[ApiStrings.fieldAbbreviatedProductName]
          : null,
      abbreviatedProductNameEn: json.containsKey(ApiStrings.fieldAbbreviatedProductNameEn)
          ? json[ApiStrings.fieldAbbreviatedProductNameEn]
          : null,
      abbreviatedProductNameDe: json.containsKey(ApiStrings.fieldAbbreviatedProductNameDe)
          ? json[ApiStrings.fieldAbbreviatedProductNameDe]
          : null,
      productQuantity: json.containsKey(ApiStrings.fieldProductQuantity) ? json[ApiStrings.fieldProductQuantity] : null,
      productQuantityUnit: json.containsKey(ApiStrings.fieldProductQuantityUnit)
          ? json[ApiStrings.fieldProductQuantityUnit]
          : null,
      servingQuantity: json.containsKey(ApiStrings.fieldServingQuantity) ? json[ApiStrings.fieldServingQuantity] : null,
      servingQuantityUnit: json.containsKey(ApiStrings.fieldServingQuantityUnit)
          ? json[ApiStrings.fieldServingQuantityUnit]
          : null,
      servingSize: json.containsKey(ApiStrings.fieldServingSize) ? json[ApiStrings.fieldServingSize] : null,
      nutritionDataPer: json.containsKey(ApiStrings.fieldNutritionDataPer)
          ? json[ApiStrings.fieldNutritionDataPer]
          : null,
      nutriments: json.containsKey(ApiStrings.fieldNutriments)
          ? NutrimentsApi.fromJson(json[ApiStrings.fieldNutriments])
          : null,
    );
  }

  factory FoodApi.fromJsonSearALiciousApi(Map<String, dynamic> json) {
    return FoodApi(
      id: json[ApiStrings.fieldCode],
      brandsTags: json.containsKey(ApiStrings.fieldBrandsTags)
          ? (json[ApiStrings.fieldBrandsTags] as List<dynamic>).map((brand) => brand as String).toList()
          : null,
      productName: json.containsKey(ApiStrings.fieldProductName) ? json[ApiStrings.fieldProductName] : null,
      productNameEn: json.containsKey(ApiStrings.fieldProductNameEn) ? json[ApiStrings.fieldProductNameEn] : null,
      productNameDe: json.containsKey(ApiStrings.fieldProductNameDe) ? json[ApiStrings.fieldProductNameDe] : null,
      genericName: json.containsKey(ApiStrings.fieldGenericName) ? json[ApiStrings.fieldGenericName] : null,
      genericNameEn: json.containsKey(ApiStrings.fieldGenericNameEn) ? json[ApiStrings.fieldGenericNameEn] : null,
      genericNameDe: json.containsKey(ApiStrings.fieldGenericNameDe) ? json[ApiStrings.fieldGenericNameDe] : null,
      abbreviatedProductName: json.containsKey(ApiStrings.fieldAbbreviatedProductName)
          ? json[ApiStrings.fieldAbbreviatedProductName]
          : null,
      abbreviatedProductNameEn: json.containsKey(ApiStrings.fieldAbbreviatedProductNameEn)
          ? json[ApiStrings.fieldAbbreviatedProductNameEn]
          : null,
      abbreviatedProductNameDe: json.containsKey(ApiStrings.fieldAbbreviatedProductNameDe)
          ? json[ApiStrings.fieldAbbreviatedProductNameDe]
          : null,
      quantity: json.containsKey(ApiStrings.fieldQuantity) ? json[ApiStrings.fieldQuantity] : null,
      nutriments: json.containsKey(ApiStrings.fieldNutriments)
          ? NutrimentsApi.fromJson(json[ApiStrings.fieldNutriments])
          : null,
    );
  }
}

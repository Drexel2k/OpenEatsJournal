import "package:openeatsjournal/service/open_food_facts/data/food_api_base.dart";
import "package:openeatsjournal/service/open_food_facts/data/nutriments_api_v3.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";

class FoodApiV3 implements FoodApiBase {
  FoodApiV3({
    required int code,
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
    double? productQuantity,
    String? productQuantityUnit,
    double? servingQuantity,
    String? servingQuantityUnit,
    String? servingSize,
    String? nutritionDataPer,
    List<NutrimentsApiV3>? nutriments,
    String? lang,
  }) : _code = code,
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
       _lang = lang,
       _quantity = quantity,
       _productQuantity = productQuantity,
       _productQuantityUnit = productQuantityUnit,
       _servingQuantity = servingQuantity,
       _servingQuantityUnit = servingQuantityUnit,
       _servingSize = servingSize,
       _nutritionDataPer = nutritionDataPer,
       _nutriments = nutriments;

  final int _code;
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
  final String? _lang;
  final String? _quantity;
  final double? _productQuantity;
  final String? _productQuantityUnit;
  final double? _servingQuantity;
  final String? _servingQuantityUnit;
  final String? _servingSize;
  final String? _nutritionDataPer;
  final List<NutrimentsApiV3>? _nutriments;

  int get code => _code;
  @override
  String? get productName => _productName;
  @override
  String? get productNameEn => _productNameEn;
  @override
  String? get productNameDe => _productNameDe;
  @override
  String? get genericName => _genericName;
  @override
  String? get genericNameEn => _genericNameEn;
  @override
  String? get genericNameDe => _genericNameDe;
  @override
  String? get abbreviatedProductName => _abbreviatedProductName;
  @override
  String? get abbreviatedProductNameEn => _abbreviatedProductNameEn;
  @override
  String? get abbreviatedProductNameDe => _abbreviatedProductNameDe;
  List<String>? get brandsTags => _brandsTags;
  String? get lang => _lang;
  String? get quantity => _quantity;
  double? get productQuantity => _productQuantity;
  String? get productQuantityUnit => _productQuantityUnit;

  double? get servingQuantity => _servingQuantity;
  String? get servingQuantityUnit => _servingQuantityUnit;
  String? get servingSize => _servingSize;
  String? get nutritionDataPer => _nutritionDataPer;
  List<NutrimentsApiV3>? get nutriments => _nutriments;

  factory FoodApiV3.fromJsonApiV3(Map<String, dynamic> json) {
    return FoodApiV3(
      code: int.parse(json[OpenFoodFactsApiStrings.fieldCode]),
      brandsTags: json.containsKey(OpenFoodFactsApiStrings.fieldBrandsTags) ? _getbrandList(json) : null,
      quantity: json.containsKey(OpenFoodFactsApiStrings.fieldQuantity) ? json[OpenFoodFactsApiStrings.fieldQuantity] : null,
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
      lang: json.containsKey(OpenFoodFactsApiStrings.fieldLang) ? json[OpenFoodFactsApiStrings.fieldLang] : null,
      //Api returns int, double or text...
      productQuantity: json.containsKey(OpenFoodFactsApiStrings.fieldProductQuantity)
          ? (json[OpenFoodFactsApiStrings.fieldProductQuantity] as num).toDouble()
          : null,
      productQuantityUnit: json.containsKey(OpenFoodFactsApiStrings.fieldProductQuantityUnit) ? json[OpenFoodFactsApiStrings.fieldProductQuantityUnit] : null,
      //Api returns int, double or text...
      servingQuantity: json.containsKey(OpenFoodFactsApiStrings.fieldServingQuantity)
          ? (json[OpenFoodFactsApiStrings.fieldServingQuantity] as num).toDouble()
          : null,
      servingQuantityUnit: json.containsKey(OpenFoodFactsApiStrings.fieldServingQuantityUnit) ? json[OpenFoodFactsApiStrings.fieldServingQuantityUnit] : null,
      servingSize: json.containsKey(OpenFoodFactsApiStrings.fieldServingSize) ? json[OpenFoodFactsApiStrings.fieldServingSize] : null,
      nutritionDataPer: json.containsKey(OpenFoodFactsApiStrings.fieldNutritionDataPer) ? json[OpenFoodFactsApiStrings.fieldNutritionDataPer] : null,
      nutriments: json.containsKey(OpenFoodFactsApiStrings.fieldNutrition) && json[OpenFoodFactsApiStrings.fieldNutrition] != null
          ? _getNutrimentsFromJson(json[OpenFoodFactsApiStrings.fieldNutrition])
          : null,
    );
  }

  static List<NutrimentsApiV3>? _getNutrimentsFromJson(Map<String, dynamic> json) {
    List<NutrimentsApiV3> result = [];

    if (json.containsKey(OpenFoodFactsApiStrings.fieldInputSets) && json[OpenFoodFactsApiStrings.fieldInputSets] != null) {
      for (Map<String, dynamic> nutriment in json[OpenFoodFactsApiStrings.fieldInputSets]) {
        if (nutriment.containsKey(OpenFoodFactsApiStrings.fieldSource) &&
            nutriment[OpenFoodFactsApiStrings.fieldSource] != null &&
            nutriment[OpenFoodFactsApiStrings.fieldSource] == OpenFoodFactsApiStrings.packaging) {
          result.add(NutrimentsApiV3.fromJson(nutriment));
        }
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  static List<String>? _getbrandList(Map<String, dynamic> json) {
    List<String> result = [];
    for (dynamic brand in json[OpenFoodFactsApiStrings.fieldBrandsTags]) {
      if (brand != null) {
        result.add((brand as String).trim());
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }
}

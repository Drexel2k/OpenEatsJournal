import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";

class NutrimentsApi {
  NutrimentsApi({
    double? energyKj,
    double? carbohydrates,
    double? sugars,
    double? fat,
    double? saturatedFat,
    double? proteins,
    double? energyKj100g,
    double? carbohydrates100g,
    double? sugars100g,
    double? fat100g,
    double? saturatedFat100g,
    double? proteins100g,
    double? salt,
    double? salt100g,
  }) : _energyKj = energyKj,
       _carbohydrates = carbohydrates,
       _sugars = sugars,
       _fat = fat,
       _saturatedFat = saturatedFat,
       _proteins = proteins,
       _energyKj100g = energyKj100g,
       _carbohydrates100g = carbohydrates100g,
       _sugars100g = sugars100g,
       _fat100g = fat100g,
       _saturatedFat100g = saturatedFat100g,
       _proteins100g = proteins100g,
       _salt = salt,
       _salt100g = salt100g;

  final double? _energyKj;
  final double? _energyKj100g;
  final double? _carbohydrates;
  final double? _carbohydrates100g;
  final double? _sugars;
  final double? _sugars100g;
  final double? _fat;
  final double? _fat100g;
  final double? _saturatedFat;
  final double? _saturatedFat100g;
  final double? _proteins;
  final double? _proteins100g;
  final double? _salt;
  final double? _salt100g;

  double? get energyKj => _energyKj;
  double? get energyKj100g => _energyKj100g;
  double? get carbohydrates => _carbohydrates;
  double? get carbohydrates100g => _carbohydrates100g;
  double? get sugars => _sugars;
  double? get sugars100g => _sugars100g;
  double? get fat => _fat;
  double? get fat100g => _fat100g;
  double? get saturatedFat => _saturatedFat;
  double? get saturatedFat100g => _saturatedFat100g;
  double? get proteins => _proteins;
  double? get proteins100g => _proteins100g;
  double? get salt => _salt;
  double? get salt100g => _salt100g;

  factory NutrimentsApi.fromJson(Map<String, dynamic> json) {
    return NutrimentsApi(
      energyKj: json.containsKey(OpenFoodFactsApiStrings.fieldEnergy) && json[OpenFoodFactsApiStrings.fieldEnergy] != null
          ? _getIntFromNumOrString(json[OpenFoodFactsApiStrings.fieldEnergy]).toDouble()
          : json.containsKey(OpenFoodFactsApiStrings.fieldEnergyKcal) && json[OpenFoodFactsApiStrings.fieldEnergyKcal] != null
          ? ConvertValidate.getKJoulesFromKCals(kCals: _getIntFromNumOrString(json[OpenFoodFactsApiStrings.fieldEnergyKcal]))
          : null,
      carbohydrates: json.containsKey(OpenFoodFactsApiStrings.fieldCarboHydrates) && json[OpenFoodFactsApiStrings.fieldCarboHydrates] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldCarboHydrates])
          : null,
      sugars: json.containsKey(OpenFoodFactsApiStrings.fieldSugars) && json[OpenFoodFactsApiStrings.fieldSugars] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSugars])
          : null,
      fat: json.containsKey(OpenFoodFactsApiStrings.fieldFat) && json[OpenFoodFactsApiStrings.fieldFat] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldFat])
          : null,
      saturatedFat: json.containsKey(OpenFoodFactsApiStrings.fieldSaturatedFat) && json[OpenFoodFactsApiStrings.fieldSaturatedFat] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSaturatedFat])
          : null,
      proteins: json.containsKey(OpenFoodFactsApiStrings.fieldProteins) && json[OpenFoodFactsApiStrings.fieldProteins] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldProteins])
          : null,
      salt: json.containsKey(OpenFoodFactsApiStrings.fieldSalt) && json[OpenFoodFactsApiStrings.fieldSalt] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSalt])
          : null,
      energyKj100g: json.containsKey(OpenFoodFactsApiStrings.fieldEnergy100g) && json[OpenFoodFactsApiStrings.fieldEnergy100g] != null
          ? _getIntFromNumOrString(json[OpenFoodFactsApiStrings.fieldEnergy100g]).toDouble()
          : (json.containsKey(OpenFoodFactsApiStrings.fieldEnergyKcal100g) && json[OpenFoodFactsApiStrings.fieldEnergyKcal100g] != null
                ? ConvertValidate.getKJoulesFromKCals(kCals: _getIntFromNumOrString(json[OpenFoodFactsApiStrings.fieldEnergyKcal100g]))
                : null),
      carbohydrates100g: json.containsKey(OpenFoodFactsApiStrings.fieldCarboHydrates100g) && json[OpenFoodFactsApiStrings.fieldCarboHydrates100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldCarboHydrates100g])
          : null,
      sugars100g: json.containsKey(OpenFoodFactsApiStrings.fieldSugars100g) && json[OpenFoodFactsApiStrings.fieldSugars100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSugars100g])
          : null,
      fat100g: json.containsKey(OpenFoodFactsApiStrings.fieldFat100g) && json[OpenFoodFactsApiStrings.fieldFat100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldFat100g])
          : null,
      saturatedFat100g: json.containsKey(OpenFoodFactsApiStrings.fieldSaturatedFat100g) && json[OpenFoodFactsApiStrings.fieldSaturatedFat100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSaturatedFat100g])
          : null,
      proteins100g: json.containsKey(OpenFoodFactsApiStrings.fieldProteins100g) && json[OpenFoodFactsApiStrings.fieldProteins100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldProteins100g])
          : null,
      salt100g: json.containsKey(OpenFoodFactsApiStrings.fieldSalt100g) && json[OpenFoodFactsApiStrings.fieldSalt100g] != null
          ? _getDoubleFromNumOrString(json[OpenFoodFactsApiStrings.fieldSalt100g])
          : null,
    );
  }

  //ApiV1 returns numbers as ints, doubles oder Strings...
  static int _getIntFromNumOrString(dynamic value) {
    if (value is num) {
      return value.round();
    } else {
      return num.parse(value).round();
    }
  }

  //ApiV1 returns numbers as ints, doubles oder Strings...
  static double _getDoubleFromNumOrString(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else {
      return num.parse(value).toDouble();
    }
  }
}

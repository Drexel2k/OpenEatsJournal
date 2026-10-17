import "package:openeatsjournal/service/open_food_facts/open_food_facts_api_strings.dart";

class NutrimentsApiV3 {
  NutrimentsApiV3({
    required String per,
    required double perQuantity,
    required String perUnit,
    required String preparation,
    double? energyKj,
    double? energyKcal,
    double? fat,
    double? saturatedFat,
    double? carbohydrates,
    double? sugars,
    double? proteins,
    double? salt,
  }) : _per = per,
       _perQuantity = perQuantity,
       _perUnit = perUnit,
       _preparation = preparation,
       _energyKj = energyKj,
       _energyKcal = energyKcal,
       _fat = fat,
       _saturatedFat = saturatedFat,
       _carbohydrates = carbohydrates,
       _sugars = sugars,
       _proteins = proteins,
       _salt = salt;

  final String _per;
  final double _perQuantity;
  final String _perUnit;
  final String _preparation;
  final double? _energyKj;
  final double? _energyKcal;
  final double? _fat;
  final double? _saturatedFat;
  final double? _carbohydrates;
  final double? _sugars;
  final double? _proteins;
  final double? _salt;

  String get per => _per;
  double get perQuantity => _perQuantity;
  String get perUnit => _perUnit;
  String get preparation => _preparation;
  double? get energyKj => _energyKj;
  double? get energyKcal => _energyKcal;
  double? get fat => _fat;
  double? get saturatedFat => _saturatedFat;
  double? get carbohydrates => _carbohydrates;
  double? get sugars => _sugars;
  double? get proteins => _proteins;
  double? get salt => _salt;

  factory NutrimentsApiV3.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? nutrientsJson = json.containsKey(OpenFoodFactsApiStrings.fieldNutrients) && json[OpenFoodFactsApiStrings.fieldNutrients] != null
        ? json[OpenFoodFactsApiStrings.fieldNutrients]
        : null;

    return NutrimentsApiV3(
      per: json[OpenFoodFactsApiStrings.fieldPer],
      perQuantity: (json[OpenFoodFactsApiStrings.fieldPerQuantity] as num).toDouble(),
      perUnit: json[OpenFoodFactsApiStrings.fieldPerUnit],
      preparation: json[OpenFoodFactsApiStrings.fieldPreparation],
      energyKj: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldEnergyKjoule, nutrientsJson) : null,
      energyKcal: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldEnergyKcal, nutrientsJson) : null,
      fat: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldFat, nutrientsJson) : null,
      saturatedFat: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldSaturatedFat, nutrientsJson) : null,
      carbohydrates: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldCarboHydrates, nutrientsJson) : null,
      sugars: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldSugars, nutrientsJson) : null,
      proteins: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldProteins, nutrientsJson) : null,
      salt: nutrientsJson != null ? _getValueFromJson(OpenFoodFactsApiStrings.fieldSalt, nutrientsJson) : null,
    );
  }

  static double? _getValueFromJson(String value, Map<String, dynamic> json) {
    if (json.containsKey(value) && json[value] != null) {
      if (json[value].containsKey(OpenFoodFactsApiStrings.fieldValue) && json[value][OpenFoodFactsApiStrings.fieldValue] != null) {
        return (json[value][OpenFoodFactsApiStrings.fieldValue] as num).toDouble();
      }
    }
    return null;
  }
}

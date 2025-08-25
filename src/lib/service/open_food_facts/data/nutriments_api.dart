import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/service/open_food_facts/api_strings.dart';

class NutrimentsApi {
  NutrimentsApi({
    int? energyKj,
    double? carbohydrates,
    double? sugars,
    double? fat,
    double? saturatedFat,
    double? proteins,
    int? energyKj100g,
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

  final int? _energyKj;
  final int? _energyKj100g;
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

  int? get energyKj => _energyKj;
  int? get energyKj100g => _energyKj100g;
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
      energyKj: json.containsKey(ApiStrings.fieldEnergy) ? json[ApiStrings.fieldEnergy] as int : json.containsKey(ApiStrings.fieldEnergyKcal) ? NutritionCalculator.getKJoulesFromKCals(json[ApiStrings.fieldEnergyKcal] as int) : null,
      carbohydrates: json.containsKey(ApiStrings.fieldCarboHydrates)
          ? (json[ApiStrings.fieldCarboHydrates] as num).toDouble()
          : null,
      sugars: json.containsKey(ApiStrings.fieldSugars) ? (json[ApiStrings.fieldSugars] as num).toDouble() : null,
      fat: json.containsKey(ApiStrings.fieldFat) ? (json[ApiStrings.fieldFat] as num).toDouble() : null,
      saturatedFat: json.containsKey(ApiStrings.fieldSaturatedFat)
          ? (json[ApiStrings.fieldSaturatedFat] as num).toDouble()
          : null,
      proteins: json.containsKey(ApiStrings.fieldProteins) ? (json[ApiStrings.fieldProteins] as num).toDouble() : null,
      salt: json.containsKey(ApiStrings.fieldSalt) ? (json[ApiStrings.fieldSalt] as num).toDouble() : null,
      energyKj100g: json.containsKey(ApiStrings.fieldEnergy100g) ? (json[ApiStrings.fieldEnergy100g] as num).round() : json.containsKey(ApiStrings.fieldEnergyKcal100g) ? NutritionCalculator.getKJoulesFromKCals(json[ApiStrings.fieldEnergyKcal100g]) : null,
      carbohydrates100g: json.containsKey(ApiStrings.fieldCarboHydrates100g)
          ? (json[ApiStrings.fieldCarboHydrates100g] as num).toDouble()
          : null,
      sugars100g: json.containsKey(ApiStrings.fieldSugars100g)
          ? (json[ApiStrings.fieldSugars100g] as num).toDouble()
          : null,
      fat100g: json.containsKey(ApiStrings.fieldFat100g) ? (json[ApiStrings.fieldFat100g] as num).toDouble() : null,
      saturatedFat100g: json.containsKey(ApiStrings.fieldSaturatedFat100g)
          ? (json[ApiStrings.fieldSaturatedFat100g] as num).toDouble()
          : null,
      proteins100g: json.containsKey(ApiStrings.fieldProteins100g)
          ? (json[ApiStrings.fieldProteins100g] as num).toDouble()
          : null,
      salt100g: json.containsKey(ApiStrings.fieldSalt100g) ? (json[ApiStrings.fieldSalt100g] as num).toDouble() : null,
    );
  }
}

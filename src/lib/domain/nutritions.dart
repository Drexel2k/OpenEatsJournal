class Nutritions {
  Nutritions({required int kJoule, double? carbohydrates, double? sugar, double? fat, double? saturatedFat, double? protein, double? salt})
    : _kJoule = kJoule,
      _carbohydrates = carbohydrates,
      _sugar = sugar,
      _fat = fat,
      _saturatedFat = saturatedFat,
      _protein = protein,
      _salt = salt;

  final int _kJoule;
  final double? _carbohydrates;
  final double? _sugar;
  final double? _fat;
  final double? _saturatedFat;
  final double? _protein;
  final double? _salt;

  int get kJoule => _kJoule;
  double? get carbohydrates => _carbohydrates;
  double? get sugar => _sugar;
  double? get fat => _fat;
  double? get saturatedFat => _saturatedFat;
  double? get protein => _protein;
  double? get salt => _salt;
}

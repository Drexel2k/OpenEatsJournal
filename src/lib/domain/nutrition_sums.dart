import "package:openeatsjournal/domain/nutritions.dart";

class NutritionSums {
  NutritionSums({required int entryCount, required Nutritions nutritions})
    : _entryCount = entryCount,
      _nutritions = nutritions;

  final int _entryCount;
  final Nutritions _nutritions;

  int get entryCount => _entryCount;
  Nutritions get nutritions => _nutritions;
}

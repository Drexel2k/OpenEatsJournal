import 'package:openeatsjournal/domain/food.dart';

class FoodSearchResultEntry {
  FoodSearchResultEntry({Food? food, int? infoCode}) : _food = food, _infoCode = infoCode;

  final Food? _food;
  final int? _infoCode;

  Food? get food => _food;
  int? get infoCode => _infoCode;
}

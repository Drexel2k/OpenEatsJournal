import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/repository/food_repository_response.dart';

class FoodRepositoryGetFoodByBarcodeResult extends FoodRepositoryResponse {
  const FoodRepositoryGetFoodByBarcodeResult({
    Food? food,
    super.errorCode,
    super.errorMessage,
  }) : _food = food;

  final Food? _food;

  Food? get food => _food;
}

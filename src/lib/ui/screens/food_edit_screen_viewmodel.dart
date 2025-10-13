import "package:flutter/foundation.dart";
import "package:openeatsjournal/repository/food_repository.dart";

class EatsAddScreenViewModel extends ChangeNotifier {
  EatsAddScreenViewModel({
    required FoodRepository foodRepository
  }) : _foodRepository = foodRepository;

  final FoodRepository _foodRepository;
  

  @override
  void dispose() {
    super.dispose();
  }
}

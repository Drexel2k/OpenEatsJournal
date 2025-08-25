import 'package:openeatsjournal/repository/food_repository.dart';
import 'package:openeatsjournal/repository/settings_repository.dart';
import 'package:openeatsjournal/repository/weight_repository.dart';

class Repositories {
  const Repositories({required this.settingsRepository, required this.weightRepository, required this.foodRepository});

  final SettingsRepository settingsRepository;
  final WeightRepository weightRepository;
  final FoodRepository foodRepository;
}

import 'package:openeatsjournal/repository/food_repository.dart';
import 'package:openeatsjournal/repository/settings_repository.dart';
import 'package:openeatsjournal/repository/journal_repository.dart';

class Repositories {
  const Repositories({required this.settingsRepository, required this.foodRepository, required this.journalRepository});

  final SettingsRepository settingsRepository;
  final FoodRepository foodRepository;
  final JournalRepository journalRepository;
}

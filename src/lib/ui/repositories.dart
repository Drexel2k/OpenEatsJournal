import 'package:openeatsjournal/repository/settings_repository.dart';
import 'package:openeatsjournal/repository/weight_repository.dart';

class Repositories {
  const Repositories({
      required this.settingsRepository,
      required this.weightRepository
    }
  );
  
  final SettingsRepository settingsRepository;
  final WeightRepository weightRepository;
}
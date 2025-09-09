import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/unit.dart";

class Food {
  Food({
    required String name,
    required FoodSource foodSource,
    required String foodSourceId,
    required MeasurementUnit measurementUnit,
    required int energyKjPer100Units,
    List<String>? brands,
    double? carbohydratesPer100Units,
    double? sugarsPer100Units,
    double? fatPer100Units,
    double? saturatedFatPer100Units,
    double? proteinsPer100Units,
    double? saltPer100Units,
    String? quantity,
  }) : _name = name,
       _brands = brands,
       _foodSource = foodSource,
       _foodSourceId = foodSourceId,
       _measurementUnit = measurementUnit,
       _energyKjPer100Units = energyKjPer100Units,
       _carbohydratesPer100Units = carbohydratesPer100Units,
       _sugarsPer100Units = sugarsPer100Units,
       _fatPer100Units = fatPer100Units,
       _saturatedFatPer100Units = saturatedFatPer100Units,
       _proteinsPer100Units = proteinsPer100Units,
       _units = List.empty();

  final String _name;
  final List<String>? _brands;
  final FoodSource _foodSource;
  final String _foodSourceId;
  final MeasurementUnit _measurementUnit;
  final int _energyKjPer100Units;
  final double? _carbohydratesPer100Units;
  final double? _sugarsPer100Units;
  final double? _fatPer100Units;
  final double? _saturatedFatPer100Units;
  final double? _proteinsPer100Units;
  final List _units;

  String get name => _name;
  List<String>? get brands => _brands;
  FoodSource get foodSource => _foodSource;
  String get foodSourceId => _foodSourceId;
  MeasurementUnit get measurementUnit => _measurementUnit;
  int get energyKjPer100Units => _energyKjPer100Units;
  double? get carbohydratesPer100Units => _carbohydratesPer100Units;
  double? get sugarsPer100Units => _sugarsPer100Units;
  double? get fatPer100Units => _fatPer100Units;
  double? get saturatedFatPer100Units => _saturatedFatPer100Units;
  double? get proteinsPer100Units => _proteinsPer100Units;
  List get units => _units;
}

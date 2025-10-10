import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';

class EatsJournalEntry {
  EatsJournalEntry.fromFood({
    required Food food,
    required DateTime entryDate,
    required int amount,
    required MeasurementUnit amountMeasurementUnit,
    required Meal meal,
  }) : _food = food,
       _name = null,
       _kJoule = null,
       _carbohydrates = null,
       _sugar = null,
       _fat = null,
       _saturatedFat = null,
       _protein = null,
       _salt = null,
       _entryDate = entryDate,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit,
       _meal = meal;

  EatsJournalEntry.quick({
    required DateTime entryDate,
    required String name,
    required int amount,
    required MeasurementUnit amountMeasurementUnit,
    required int kJoule,
    required Meal meal,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? satureatedFat,
    double? protein,
    double? salt,
  }) : _food = null,
       _entryDate = entryDate,
       _name = name,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit,
       _kJoule = kJoule,
       _meal = meal,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = satureatedFat,
       _protein = protein,
       _salt = salt;

  final DateTime _entryDate;
  final int _amount;
  final MeasurementUnit _amountMeasurementUnit;
  final Meal _meal;

  final Food? _food;
  final String? _name;
  final int? _kJoule;
  final double? _carbohydrates;
  final double? _sugar;
  final double? _fat;
  final double? _saturatedFat;
  final double? _protein;
  final double? _salt;

  Food? get food => _food;
  FoodSource? get foodSource => food != null ? _food!.foodSource : null;
  String? get foodSourceIdExternal => food != null ? _food!.foodSourceIdExternal : null;
  DateTime get entryDate => _entryDate;
  String get name => food != null ? _food!.name : _name!;
  int get amount => _amount;
  MeasurementUnit get amountMeasurementUnit => _amountMeasurementUnit;
  int get kJoule => food != null ? (_food!.energyKj * (_amount / 100)).round() : _kJoule!;
  double? get carbohydrates =>
      food != null ? (_food!.carbohydrates != null ? _food.carbohydrates! * (_amount / 100) : null) : _carbohydrates;
  double? get sugar => food != null ? (_food!.sugar != null ? _food.sugar! * (_amount / 100) : null) : _sugar;
  double? get fat => food != null ? (_food!.fat != null ? _food.fat! * (_amount / 100) : null) : _fat;
  double? get saturatedFat => food != null ? (_food!.saturatedFat != null ? _food.saturatedFat! * (_amount / 100) : null) : _saturatedFat;
  double? get protein => food != null ? (_food!.protein != null ? _food.protein! * (_amount / 100) : null) : _protein;
  double? get salt => food != null ? (_food!.salt != null ? _food.salt! * (_amount / 100) : null) : _salt;
  Meal get meal => _meal;
}

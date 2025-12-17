import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';

class EatsJournalEntry {
  EatsJournalEntry.fromFood({
    required DateTime entryDate,
    required Food food,
    required double amount,
    required MeasurementUnit amountMeasurementUnit,
    required Meal meal,
  }) : _entryDate = entryDate,
       _meal = meal,
       _food = food,
       _name = food.name,
       _kJoule = amountMeasurementUnit == MeasurementUnit.gram
           ? (food.kJoule * (amount / food.nutritionPerGramAmount!)).round()
           : (food.kJoule * (amount / food.nutritionPerMilliliterAmount!)).round(),
       _carbohydrates = food.carbohydrates != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.carbohydrates! * (amount / food.nutritionPerGramAmount!)
                 : food.carbohydrates! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _sugar = food.sugar != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.sugar! * (amount / food.nutritionPerGramAmount!)
                 : food.sugar! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _fat = food.fat != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.fat! * (amount / food.nutritionPerGramAmount!)
                 : food.fat! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _saturatedFat = food.saturatedFat != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.saturatedFat! * (amount / food.nutritionPerGramAmount!)
                 : food.saturatedFat! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _protein = food.protein != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.protein! * (amount / food.nutritionPerGramAmount!)
                 : food.protein! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _salt = food.salt != null
           ? (amountMeasurementUnit == MeasurementUnit.gram
                 ? food.salt! * (amount / food.nutritionPerGramAmount!)
                 : food.salt! * (amount / food.nutritionPerMilliliterAmount!))
           : null,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit;

  EatsJournalEntry.quick({
    required DateTime entryDate,
    required String name,
    required int kJoule,
    required Meal meal,
    double? amount,
    MeasurementUnit? amountMeasurementUnit,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? satureatedFat,
    double? protein,
    double? salt,
  }) : _entryDate = entryDate,
       _meal = meal,
       _food = null,
       _name = name,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit,
       _kJoule = kJoule,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = satureatedFat,
       _protein = protein,
       _salt = salt;

  EatsJournalEntry.fromData({
    required int id,
    required DateTime entryDate,
    required String name,
    required int kJoule,
    required Meal meal,
    Food? food,
    double? amount,
    MeasurementUnit? amountMeasurementUnit,
    double? carbohydrates,
    double? sugar,
    double? fat,
    double? satureatedFat,
    double? protein,
    double? salt,
  }) : _id = id,
       _entryDate = entryDate,
       _meal = meal,
       _food = food,
       _name = name,
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit,
       _kJoule = kJoule,
       _carbohydrates = carbohydrates,
       _sugar = sugar,
       _fat = fat,
       _saturatedFat = satureatedFat,
       _protein = protein,
       _salt = salt;

  int? _id;
  DateTime _entryDate;
  Meal _meal;

  double? _amount;
  MeasurementUnit? _amountMeasurementUnit;
  Food? _food;
  String _name;
  int _kJoule;
  double? _carbohydrates;
  double? _sugar;
  double? _fat;
  double? _saturatedFat;
  double? _protein;
  double? _salt;

  set id(int? value) {
    if (value == null) {
      throw ArgumentError("Id must be set to value.");
    }
    
    if (_id != null) {
      throw ArgumentError("Existing id must must not be overriden.");
    }

    _id = value;
  }

  set entryDate(DateTime value) {
    _entryDate = value;
  }

  set meal(Meal value) {
    _meal = value;
  }

  set amount(double? value) {
    if (value == null) {
      _amountMeasurementUnit = null;
    }

    if (value != null && _amountMeasurementUnit == null) {
      _amountMeasurementUnit = MeasurementUnit.gram;
    }

    _amount = value;
  }

  set amountMeasurementUnit(MeasurementUnit? value) {
    if (value == null) {
      _amount = null;
    }

    if (value != null && _amount == null) {
      _amount = 100;
    }

    _amountMeasurementUnit = value;
  }

  set food(Food? value) {
    _food = value;

    amount ??= 100;

    if (_amountMeasurementUnit == MeasurementUnit.gram && _food!.nutritionPerGramAmount == null) {
      _amountMeasurementUnit = MeasurementUnit.milliliter;
    }

    if (_food != null) {
      _name = food!.name;
      _kJoule = amountMeasurementUnit == MeasurementUnit.gram
          ? (food!.kJoule * (_amount! / food!.nutritionPerGramAmount!)).round()
          : (food!.kJoule * (_amount! / food!.nutritionPerMilliliterAmount!)).round();
      _carbohydrates = food!.carbohydrates != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.carbohydrates! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.carbohydrates! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
      _sugar = food!.sugar != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.sugar! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.sugar! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
      _fat = food!.fat != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.fat! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.fat! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
      _saturatedFat = food!.saturatedFat != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.saturatedFat! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.saturatedFat! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
      _protein = food!.protein != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.protein! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.protein! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
      _salt = food!.salt != null
          ? (_amountMeasurementUnit == MeasurementUnit.gram
                ? food!.salt! * (_amount! / food!.nutritionPerGramAmount!)
                : food!.salt! * (_amount! / food!.nutritionPerMilliliterAmount!))
          : null;
    }
  }

  set name(String value) {
    _name = value;
  }

  set kJoule(int value) {
    _kJoule = value;
  }

  set carbohydrates(double? value) {
    _carbohydrates = value;
  }

  set sugar(double? value) {
    _sugar = value;
  }

  set fat(double? value) {
    _fat = value;
  }

  set saturatedFat(double? value) {
    _saturatedFat = value;
  }

  set protein(double? value) {
    _protein = value;
  }

  set salt(double? value) {
    _salt = value;
  }

  int? get id => _id;
  DateTime get entryDate => _entryDate;
  Meal get meal => _meal;

  Food? get food => _food;
  FoodSource? get foodSource => food != null ? _food!.foodSource : null;
  String? get foodSourceIdExternal => food != null ? _food!.originalFoodSourceFoodId : null;
  String get name => _name;
  double? get amount => _amount;
  MeasurementUnit? get amountMeasurementUnit => _amountMeasurementUnit;
  int get kJoule => _kJoule;
  double? get carbohydrates => _carbohydrates;
  double? get sugar => _sugar;
  double? get fat => _fat;
  double? get saturatedFat => _saturatedFat;
  double? get protein => _protein;
  double? get salt => _salt;
}

import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';

class EatsJournalEntry {
  EatsJournalEntry.fromFood({
    required Food food,
    required DateTime entryDate,
    required double amount,
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
  final Meal _meal;

  final double? _amount;
  final MeasurementUnit? _amountMeasurementUnit;
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
  String? get foodSourceIdExternal => food != null ? _food!.originalFoodSourceFoodId : null;
  DateTime get entryDate => _entryDate;
  String get name => food != null ? _food!.name : _name!;
  double? get amount => _amount;
  MeasurementUnit? get amountMeasurementUnit => _amountMeasurementUnit;
  int get kJoule => _getKJoule();
  double? get carbohydrates => _getCarbohydrates();
  double? get sugar => _getSugar();
  double? get fat => _getFat();
  double? get saturatedFat => _getSaturatedFat();
  double? get protein => _getProtein();
  double? get salt => _getSalt();
  Meal get meal => _meal;

  int _getKJoule() {
    if (food != null) {
      if (_amountMeasurementUnit! == MeasurementUnit.gram) {
        return (_food!.kJoule * (_amount! / _food.nutritionPerGramAmount!)).round();
      } else {
        return (_food!.kJoule * (_amount! / _food.nutritionPerMilliliterAmount!)).round();
      }
    } else {
      return _kJoule!;
    }
  }

  double? _getCarbohydrates() {
    if (food != null) {
      if (food!.carbohydrates != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.carbohydrates! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.carbohydrates! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _carbohydrates;
    }
  }

  double? _getSugar() {
    if (food != null) {
      if (food!.sugar != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.sugar! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.sugar! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _sugar;
    }
  }

  double? _getFat() {
    if (food != null) {
      if (food!.fat != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.fat! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.fat! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _fat;
    }
  }

  double? _getSaturatedFat() {
    if (food != null) {
      if (food!.saturatedFat != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.saturatedFat! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.saturatedFat! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _saturatedFat;
    }
  }

  double? _getProtein() {
    if (food != null) {
      if (food!.protein != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.protein! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.protein! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _protein;
    }
  }

  double? _getSalt() {
    if (food != null) {
      if (food!.salt != null) {
        if (_amountMeasurementUnit! == MeasurementUnit.gram) {
          return (_food!.salt! * (_amount! / _food.nutritionPerGramAmount!));
        } else {
          return (_food!.salt! * (_amount! / _food.nutritionPerMilliliterAmount!));
        }
      } else {
        return null;
      }
    } else {
      return _salt;
    }
  }
}

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
       _kJoule = 1, //dummy value, recalculated in constructor
       _amount = amount,
       _amountMeasurementUnit = amountMeasurementUnit {
    _updateNutrionsValues();
  }

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
      if (_food != null) {
        throw ArgumentError("Amount needed on food entry.");
      }

      _amountMeasurementUnit = null;
    }

    if (value != null && _amountMeasurementUnit == null) {
      _amountMeasurementUnit = MeasurementUnit.gram;
    }

    _amount = value;
    _updateNutrionsValues();
  }

  set amountMeasurementUnit(MeasurementUnit? value) {
    if (value == null) {
      if (_food != null) {
        throw ArgumentError("Mesaurement unit needed on food entry.");
      }

      _amount = null;
    } else {
      if (_food != null) {
        if (value == MeasurementUnit.gram) {
          if (_food!.nutritionPerGramAmount == null) {
            throw ArgumentError("Food doesn't support measurement unit gram.");
          }
        } else {
          if (_food!.nutritionPerMilliliterAmount == null) {
            throw ArgumentError("Food doesn't support measurement unit milliliter.");
          }
        }
      }
    }

    if (value != null && _amount == null) {
      _amount = 100;
    }

    _amountMeasurementUnit = value;
    _updateNutrionsValues();
  }

  set food(Food? value) {
    _food = value;
    if (_food != null) {
      amount ??= 100;

      if (_amountMeasurementUnit == MeasurementUnit.gram && _food!.nutritionPerGramAmount == null) {
        _amountMeasurementUnit = MeasurementUnit.milliliter;
      }

      _name = food!.name;
      _updateNutrionsValues();
    }
  }

  set name(String value) {
    _name = value;
  }

  set kJoule(int value) {
    if (_food != null) {
      throw ArgumentError("Can't set kJoule manually on food entry.");
    }

    _kJoule = value;
  }

  set carbohydrates(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set carbohydrates manually on food entry.");
    }

    _carbohydrates = value;
  }

  set sugar(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set sugar manually on food entry.");
    }

    _sugar = value;
  }

  set fat(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set fat manually on food entry.");
    }

    _fat = value;
  }

  set saturatedFat(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set saturatedFat manually on food entry.");
    }

    _saturatedFat = value;
  }

  set protein(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set protein manually on food entry.");
    }

    _protein = value;
  }

  set salt(double? value) {
    if (_food != null) {
      throw ArgumentError("Can't set salt manually on food entry.");
    }

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

  _updateNutrionsValues() {
    if (_food != null && _amount != null && _amountMeasurementUnit != null) {
      _kJoule = _amountMeasurementUnit! == MeasurementUnit.gram
          ? (_food!.kJoule * (_amount! / _food!.nutritionPerGramAmount!)).round()
          : (_food!.kJoule * (_amount! / _food!.nutritionPerMilliliterAmount!)).round();
      _carbohydrates = _food!.carbohydrates != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.carbohydrates! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.carbohydrates! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
      _sugar = _food!.sugar != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.sugar! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.sugar! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
      _fat = _food!.fat != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.fat! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.fat! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
      _saturatedFat = _food!.saturatedFat != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.saturatedFat! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.saturatedFat! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
      _protein = _food!.protein != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.protein! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.protein! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
      _salt = _food!.salt != null
          ? (_amountMeasurementUnit! == MeasurementUnit.gram
                ? _food!.salt! * (_amount! / _food!.nutritionPerGramAmount!)
                : _food!.salt! * (_amount! / _food!.nutritionPerMilliliterAmount!))
          : null;
    }
  }
}

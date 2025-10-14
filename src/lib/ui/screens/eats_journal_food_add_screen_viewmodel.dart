import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class EatsJournalFoodAddScreenViewModel extends ChangeNotifier {
  EatsJournalFoodAddScreenViewModel({
    required Food food,
    required JournalRepository journalRepository,
    required FoodRepository foodRepository,
    required SettingsRepository settingsRepository,
  }) : _food = food,
       _journalRepository = journalRepository,
       _foodRepository = foodRepository,
       _settingsRepository = settingsRepository,
       _eatsAmount = ValueNotifier<int?>(_getInitialFoodAmount(food)),
       _currentMesaureMentUnit = ValueNotifier<MeasurementUnit>(_getInitialMeasurementUnit(food)),
       _measurementSelectionEnabled = _getInitialMeasurementSelectionEnabled(food),
       _kJoule = ValueNotifier<int?>(_getInitialKJoule(food)),
       _carbohydrates = ValueNotifier<double?>(_getInitialCarbohydrates(food)),
       _sugar = ValueNotifier<double?>(_getInitialSugar(food)),
       _fat = ValueNotifier<double?>(_getInitialFat(food)),
       _saturatedFat = ValueNotifier<double?>(_getInitialSaturatedFat(food)),
       _protein = ValueNotifier<double?>(_getInitialProtein(food)),
       _salt = ValueNotifier<double?>(_getInitialSalt(food)) {
    _amount.addListener(_amountsChanged);
    _eatsAmount.addListener(_amountsChanged);
  }

  final Food _food;
  final JournalRepository _journalRepository;
  final FoodRepository _foodRepository;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<int?> _amount = ValueNotifier<int?>(1);
  final ValueNotifier<int?> _eatsAmount;
  final ValueNotifier<MeasurementUnit> _currentMesaureMentUnit;
  final bool _measurementSelectionEnabled;

  final ValueNotifier<int?> _kJoule;
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  Food get food => _food;

  ValueNotifier<int?> get amount => _amount;
  ValueNotifier<int?> get eatsAmount => _eatsAmount;
  ValueNotifier<MeasurementUnit> get currentMesaureMentUnit => _currentMesaureMentUnit;
  bool get measurementSelectionEnabled => _measurementSelectionEnabled;

  ValueNotifier<int?> get kJoule => _kJoule;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

  _amountsChanged() {
    if (_amount.value != null && _eatsAmount.value != null) {
      if (currentMesaureMentUnit.value == MeasurementUnit.gram) {
        _kJoule.value = (_food.kJoule * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!)).round();
        _carbohydrates.value = _food.carbohydrates != null
            ? _food.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!)
            : null;
        _sugar.value = _food.sugar != null ? _food.sugar! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!) : null;
        _fat.value = _food.fat != null ? _food.fat! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!) : null;
        _saturatedFat.value = _food.saturatedFat != null ? _food.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!) : null;
        _protein.value = _food.protein != null ? _food.protein! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!) : null;
        _salt.value = _food.salt != null ? _food.salt! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerGramAmount!) : null;
      } else {
        _kJoule.value = (_food.kJoule * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!)).round();
        _carbohydrates.value = _food.carbohydrates != null
            ? _food.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!)
            : null;
        _sugar.value = _food.sugar != null ? _food.sugar! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!) : null;
        _fat.value = _food.fat != null ? _food.fat! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!) : null;
        _saturatedFat.value = _food.saturatedFat != null
            ? _food.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!)
            : null;
        _protein.value = _food.protein != null ? _food.protein! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!) : null;
        _salt.value = _food.salt != null ? _food.salt! * ((_amount.value! * _eatsAmount.value!) / _food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      _kJoule.value = null;
      _carbohydrates.value = null;
      _sugar.value = null;
      _fat.value = null;
      _saturatedFat.value = null;
      _protein.value = null;
      _salt.value = null;
    }
  }

  Future<void> addEatsJournalEntry() async {
    if (_amount.value != null && eatsAmount.value != null) {
      await _foodRepository.setFoodCache(_food);

      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _settingsRepository.currentJournalDate.value,
        dayTargetKJoule: _settingsRepository.getCurrentJournalDayTargetKJoule(),
      );

      await _journalRepository.addEatsJournalEntry(
        eatsJournalEntry: EatsJournalEntry.fromFood(
          food: _food,
          entryDate: _settingsRepository.currentJournalDate.value,
          amount: _amount.value! * _eatsAmount.value!,
          amountMeasurementUnit: _currentMesaureMentUnit.value,
          meal: _settingsRepository.currentMeal.value,
        ),
      );
    }
  }

  static int _getInitialFoodAmount(Food food) {
    if (food.defaultFoodUnit != null) {
      return food.defaultFoodUnit!.amount;
    } else if (food.foodUnits.isNotEmpty) {
      return food.foodUnits[0].object.amount;
    } else {
      return 100;
    }
  }

  static MeasurementUnit _getInitialMeasurementUnit(Food food) {
    if (food.defaultFoodUnit != null) {
      return food.defaultFoodUnit!.amountMeasurementUnit;
    } else if (food.foodUnits.isNotEmpty) {
      return food.foodUnits[0].object.amountMeasurementUnit;
    } else {
      if (food.nutritionPerGramAmount != null) {
        return MeasurementUnit.gram;
      } else {
        return MeasurementUnit.milliliter;
      }
    }
  }

  static int _getInitialKJoule(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return (food.kJoule * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!)).round();
      } else {
        return (food.kJoule * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!)).round();
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return (food.kJoule * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!)).round();
      } else {
        return (food.kJoule * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!)).round();
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return (food.kJoule * (100 / food.nutritionPerGramAmount!)).round();
      } else {
        return (food.kJoule * (100 / food.nutritionPerMilliliterAmount!)).round();
      }
    }
  }

  static double? _getInitialCarbohydrates(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.carbohydrates != null ? food.carbohydrates! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.carbohydrates != null ? food.carbohydrates! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.carbohydrates != null ? food.carbohydrates! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.carbohydrates != null ? food.carbohydrates! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.carbohydrates != null ? food.carbohydrates! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.carbohydrates != null ? food.carbohydrates! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static double? _getInitialSugar(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.sugar != null ? food.sugar! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.sugar != null ? food.sugar! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.sugar != null ? food.sugar! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.sugar != null ? food.sugar! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.sugar != null ? food.sugar! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.sugar != null ? food.sugar! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static double? _getInitialFat(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.fat != null ? food.fat! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.fat != null ? food.fat! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.fat != null ? food.fat! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.fat != null ? food.fat! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.fat != null ? food.fat! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.fat != null ? food.fat! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static double? _getInitialSaturatedFat(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.saturatedFat != null ? food.saturatedFat! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.saturatedFat != null ? food.saturatedFat! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.saturatedFat != null ? food.saturatedFat! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.saturatedFat != null ? food.saturatedFat! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.saturatedFat != null ? food.saturatedFat! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.saturatedFat != null ? food.saturatedFat! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static double? _getInitialProtein(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.protein != null ? food.protein! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.protein != null ? food.protein! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.protein != null ? food.protein! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.protein != null ? food.protein! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.protein != null ? food.protein! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.protein != null ? food.protein! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static double? _getInitialSalt(Food food) {
    if (food.defaultFoodUnit != null) {
      if (food.defaultFoodUnit!.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.salt != null ? food.salt! * (food.defaultFoodUnit!.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.salt != null ? food.salt! * (food.defaultFoodUnit!.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else if (food.foodUnits.isNotEmpty) {
      if (food.foodUnits[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.salt != null ? food.salt! * (food.foodUnits[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.salt != null ? food.salt! * (food.foodUnits[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
      }
    } else {
      if (food.nutritionPerGramAmount != null) {
        return food.salt != null ? food.salt! * (100 / food.nutritionPerGramAmount!) : null;
      } else {
        return food.salt != null ? food.salt! * (100 / food.nutritionPerMilliliterAmount!) : null;
      }
    }
  }

  static bool _getInitialMeasurementSelectionEnabled(Food food) {
    if (food.nutritionPerGramAmount != null && food.nutritionPerMilliliterAmount != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _eatsAmount.dispose();

    _kJoule.dispose();
    _carbohydrates.dispose();
    _sugar.dispose();
    _fat.dispose();
    _saturatedFat.dispose();
    _protein.dispose();
    _salt.dispose();

    super.dispose();
  }
}

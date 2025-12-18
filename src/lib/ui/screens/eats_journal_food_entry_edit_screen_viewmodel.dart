import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";

class EatsJournalFoodEntryEditScreenViewModel extends ChangeNotifier {
  EatsJournalFoodEntryEditScreenViewModel({
    required EatsJournalEntry foodEntry,
    required JournalRepository journalRepository,
    required FoodRepository foodRepository,
    required SettingsRepository settingsRepository,
  }) : _journalRepository = journalRepository,
       _foodRepository = foodRepository,
       _foodEntry = foodEntry,
       _foodEntryId = foodEntry.id,
       _settingsRepository = settingsRepository,
       _eatsAmount = ValueNotifier(_getInitialFoodAmount(foodEntry.food!)),
       _currentMeasurementUnit = ValueNotifier(_getInitialMeasurementUnit(foodEntry.food!)),
       _measurementSelectionEnabled = _getInitialMeasurementSelectionEnabled(foodEntry.food!),
       _kJoule = ValueNotifier(_getInitialKJoule(foodEntry.food!)),
       _carbohydrates = ValueNotifier(_getInitialCarbohydrates(foodEntry.food!)),
       _sugar = ValueNotifier(_getInitialSugar(foodEntry.food!)),
       _fat = ValueNotifier(_getInitialFat(foodEntry.food!)),
       _saturatedFat = ValueNotifier(_getInitialSaturatedFat(foodEntry.food!)),
       _protein = ValueNotifier(_getInitialProtein(foodEntry.food!)),
       _salt = ValueNotifier(_getInitialSalt(foodEntry.food!)) {
    if (_foodEntry.food == null) {
      throw StateError("Food entry must not have a food.");
    }

    _currentJournalDate.value = _settingsRepository.currentJournalDate.value;
    _currentMeal.value = _settingsRepository.currentMeal.value;

    _currentJournalDate.addListener(_currentJournalDateChanged);
    _currentMeal.addListener(_currentMealChanged);
    _amount.addListener(_amountsChanged);
    _eatsAmount.addListener(_amountsChanged);
  }

  final JournalRepository _journalRepository;
  final FoodRepository _foodRepository;

  final ValueNotifier<DateTime> _currentJournalDate = ValueNotifier(DateTime(1900));
  final ValueNotifier<Meal> _currentMeal = ValueNotifier(Meal.breakfast);

  final EatsJournalEntry _foodEntry;
  final int? _foodEntryId;
  final SettingsRepository _settingsRepository;
  final ValueNotifier<double?> _amount = ValueNotifier(1);
  final ValueNotifier<double?> _eatsAmount;
  final ValueNotifier<MeasurementUnit> _currentMeasurementUnit;
  final bool _measurementSelectionEnabled;

  final ValueNotifier<int?> _kJoule;
  final ValueNotifier<double?> _carbohydrates;
  final ValueNotifier<double?> _sugar;
  final ValueNotifier<double?> _fat;
  final ValueNotifier<double?> _saturatedFat;
  final ValueNotifier<double?> _protein;
  final ValueNotifier<double?> _salt;

  ValueNotifier<DateTime> get currentJournalDate => _currentJournalDate;
  ValueNotifier<Meal> get currentMeal => _currentMeal;

  int? get foodEntryId => _foodEntryId;
  EatsJournalEntry get foodEntry => _foodEntry;

  ValueNotifier<double?> get amount => _amount;
  ValueNotifier<double?> get eatsAmount => _eatsAmount;
  ValueNotifier<MeasurementUnit> get currentMeasurementUnit => _currentMeasurementUnit;
  bool get measurementSelectionEnabled => _measurementSelectionEnabled;

  ValueNotifier<int?> get kJoule => _kJoule;
  ValueNotifier<double?> get carbohydrates => _carbohydrates;
  ValueNotifier<double?> get sugar => _sugar;
  ValueNotifier<double?> get fat => _fat;
  ValueNotifier<double?> get saturatedFat => _saturatedFat;
  ValueNotifier<double?> get protein => _protein;
  ValueNotifier<double?> get salt => _salt;

  void _currentJournalDateChanged() {
    _settingsRepository.currentJournalDate.value = _currentJournalDate.value;
  }

  void _currentMealChanged() {
    _settingsRepository.currentMeal.value = _currentMeal.value;
  }

  void _amountsChanged() {
    if (_amount.value != null && _eatsAmount.value != null) {
      if (currentMeasurementUnit.value == MeasurementUnit.gram) {
        _kJoule.value = (_foodEntry.food!.kJoule * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)).round();
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? _foodEntry.food!.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? _foodEntry.food!.sugar! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? _foodEntry.food!.fat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? _foodEntry.food!.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? _foodEntry.food!.protein! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? _foodEntry.food!.salt! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerGramAmount!)
            : null;
      } else {
        _kJoule.value = (_foodEntry.food!.kJoule * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)).round();
        _carbohydrates.value = _foodEntry.food!.carbohydrates != null
            ? _foodEntry.food!.carbohydrates! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _sugar.value = _foodEntry.food!.sugar != null
            ? _foodEntry.food!.sugar! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _fat.value = _foodEntry.food!.fat != null
            ? _foodEntry.food!.fat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _saturatedFat.value = _foodEntry.food!.saturatedFat != null
            ? _foodEntry.food!.saturatedFat! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _protein.value = _foodEntry.food!.protein != null
            ? _foodEntry.food!.protein! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
        _salt.value = _foodEntry.food!.salt != null
            ? _foodEntry.food!.salt! * ((_amount.value! * _eatsAmount.value!) / _foodEntry.food!.nutritionPerMilliliterAmount!)
            : null;
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

  Future<void> setFoodEntry() async {
    if (_amount.value != null && eatsAmount.value != null) {
      //can only be the case for external food, all other foods must have an id as they come from the database
      if (_foodEntry.food!.id == null) {
        await _foodRepository.setFoodByExternalId(food: _foodEntry.food!);
      }

      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: _settingsRepository.currentJournalDate.value,
        dayTargetKJoule: _settingsRepository.getCurrentJournalDayTargetKJoule(),
      );

      _foodEntry.amount = _amount.value;
      _foodEntry.amountMeasurementUnit = _currentMeasurementUnit.value;
      _foodEntry.entryDate = _settingsRepository.currentJournalDate.value;
      _foodEntry.meal = _settingsRepository.currentMeal.value;
      await _journalRepository.setEatsJournalEntry(eatsJournalEntry: _foodEntry);
    }
  }

  static double _getInitialFoodAmount(Food food) {
    if (food.defaultFoodUnit != null) {
      return food.defaultFoodUnit!.amount;
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      return food.foodUnitsWithOrder[0].object.amount;
    } else {
      return 100;
    }
  }

  static MeasurementUnit _getInitialMeasurementUnit(Food food) {
    if (food.defaultFoodUnit != null) {
      return food.defaultFoodUnit!.amountMeasurementUnit;
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      return food.foodUnitsWithOrder[0].object.amountMeasurementUnit;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return (food.kJoule * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!)).round();
      } else {
        return (food.kJoule * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!)).round();
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.carbohydrates != null ? food.carbohydrates! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.carbohydrates != null ? food.carbohydrates! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.sugar != null ? food.sugar! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.sugar != null ? food.sugar! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.fat != null ? food.fat! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.fat != null ? food.fat! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.saturatedFat != null ? food.saturatedFat! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.saturatedFat != null ? food.saturatedFat! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.protein != null ? food.protein! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.protein != null ? food.protein! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    } else if (food.foodUnitsWithOrder.isNotEmpty) {
      if (food.foodUnitsWithOrder[0].object.amountMeasurementUnit == MeasurementUnit.gram) {
        return food.salt != null ? food.salt! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerGramAmount!) : null;
      } else {
        return food.salt != null ? food.salt! * (food.foodUnitsWithOrder[0].object.amount / food.nutritionPerMilliliterAmount!) : null;
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
    _currentJournalDate.dispose();
    _currentMeal.dispose();
    _amount.dispose();
    _eatsAmount.dispose();

    _currentMeasurementUnit.dispose();
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

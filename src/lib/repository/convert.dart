import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/domain/ordered_default_food_unit.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';

class Convert {
  static Food getFoodFromDbResult({required List<Map<String, Object?>> dbResult}) {
    if (dbResult.isEmpty) {
      throw ArgumentError("Food result must not be empty.");
    }

    List<OrderedDefaultFoodUnit> orderedDefaultFoodUnits = [];

    int currentRowFoodUnitId = -1;
    int currentFoodUnitId = -1;

    Map<String, Object?>? foodUnitRow;
    OrderedDefaultFoodUnit? orderedDefaultFoodUnit;
    for (Map<String, Object?> foodUnitRowInternal in dbResult) {
      currentRowFoodUnitId = foodUnitRowInternal[OpenEatsJournalStrings.dbResultFoodUnitId] as int;
      if (currentFoodUnitId != currentRowFoodUnitId) {
        if (currentFoodUnitId != -1) {
          orderedDefaultFoodUnit = _getOrderedDefaultFoodUnit(foodUnitRow: foodUnitRow!);
          if (orderedDefaultFoodUnit != null) {
            orderedDefaultFoodUnits.add(orderedDefaultFoodUnit);
          }
        }

        currentFoodUnitId = currentRowFoodUnitId;
      }

      foodUnitRow = foodUnitRowInternal;
    }

    orderedDefaultFoodUnit = _getOrderedDefaultFoodUnit(foodUnitRow: foodUnitRow!);
    if (orderedDefaultFoodUnit != null) {
      orderedDefaultFoodUnits.add(orderedDefaultFoodUnit);
    }

    Food food = Food.fromData(
      id: dbResult[0][OpenEatsJournalStrings.dbResultFoodId] as int,
      name: dbResult[0][OpenEatsJournalStrings.dbResultFoodName] as String,
      foodSource: FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbColumnFoodSourceIdRef] as int),
      kJoule: dbResult[0][OpenEatsJournalStrings.dbResultFoodKiloJoule] as int,
      originalFoodSource: dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] != null
          ? FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceIdRef] as int)
          : null,
      originalFoodSourceFoodId: dbResult[0][OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodIdRef] as String?,
      barcode: dbResult[0][OpenEatsJournalStrings.dbColumnBarcode] as int?,
      brands: dbResult[0][OpenEatsJournalStrings.dbColumnBrands] != null
          ? (dbResult[0][OpenEatsJournalStrings.dbColumnBrands] as String).split(",").map((String brand) => brand.trim()).toList()
          : null,
      nutritionPerGramAmount: dbResult[0][OpenEatsJournalStrings.dbColumnNutritionPerGramAmount] as double?,
      nutritionPerMilliliterAmount: dbResult[0][OpenEatsJournalStrings.dbColumnNutritionPerMilliliterAmount] as double?,
      carbohydrates: dbResult[0][OpenEatsJournalStrings.dbResultFoodCarbohydrates] as double?,
      sugar: dbResult[0][OpenEatsJournalStrings.dbResultFoodSugar] as double?,
      fat: dbResult[0][OpenEatsJournalStrings.dbResultFoodFat] as double?,
      saturatedFat: dbResult[0][OpenEatsJournalStrings.dbResultFoodSaturatedFat] as double?,
      protein: dbResult[0][OpenEatsJournalStrings.dbResultFoodProtein] as double?,
      salt: dbResult[0][OpenEatsJournalStrings.dbResultFoodSalt] as double?,
      quantity: dbResult[0][OpenEatsJournalStrings.dbColumnQuantity] as String?,
      orderedDefaultFoodUnits: orderedDefaultFoodUnits.isNotEmpty ? orderedDefaultFoodUnits : null,
    );

    return food;
  }

  static OrderedDefaultFoodUnit? _getOrderedDefaultFoodUnit({required Map<String, Object?> foodUnitRow}) {
    if ((foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitId] as int?) != null) {
      return OrderedDefaultFoodUnit(
        foodUnitWithOrder: ObjectWithOrder<FoodUnit>(
          object: FoodUnit(
            id: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitId] as int,
            name: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitName] as String,
            amount: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitAmount] as double,
            amountMeasurementUnit: MeasurementUnit.getByValue(foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitAmountMeasurementUnitIdRef] as int),
            originalFoodSourceFoodUnitId: foodUnitRow[OpenEatsJournalStrings.dbColumnOriginalFoodSourceFoodUnitIdRef] as String?,
          ),
          order: foodUnitRow[OpenEatsJournalStrings.dbColumnOrderNumber] as int,
        ),
        isDefault: (foodUnitRow[OpenEatsJournalStrings.dbColumnIsDefault] as int) == 1,
      );
    }

    return null;
  }

  static List<Food> getFoodsFromDbResult({required List<Map<String, Object?>> dbResult}) {
    if (dbResult.isEmpty) {
      throw ArgumentError("Food result must not be empty.");
    }

    List<Map<String, Object?>> foodRows = [];
    List<Food> foods = [];
    int currentFoodId = -1;
    int currentRowFoodId;
    for (Map<String, Object?> row in dbResult) {
      currentRowFoodId = row[OpenEatsJournalStrings.dbResultFoodId] as int;
      if (currentRowFoodId != currentFoodId) {
        if (currentFoodId != -1) {
          foods.add(Convert.getFoodFromDbResult(dbResult: foodRows));
          foodRows.clear();
        }

        currentFoodId = currentRowFoodId;
      }

      foodRows.add(row);
    }

    foods.add(Convert.getFoodFromDbResult(dbResult: foodRows));

    return foods;
  }
}

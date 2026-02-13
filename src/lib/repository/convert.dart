import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:openeatsjournal/domain/ordered_default_food_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class Convert {
  static Food getFoodFromDbResult({required List<Map<String, Object?>> dbResult}) {
    if (dbResult.isEmpty) {
      throw ArgumentError("Food result must not be empty.");
    }

    List<OrderedDefaultFoodUnit>? orderedDefaultFoodUnits;

    if (dbResult[0][OpenEatsJournalStrings.dbResultFoodUnitId] != null) {
      orderedDefaultFoodUnits = [];
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
    }

    Food food = Food.fromData(
      id: dbResult[0][OpenEatsJournalStrings.dbResultFoodId] as int,
      name: dbResult[0][OpenEatsJournalStrings.dbResultFoodName] as String,
      foodSource: FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbResultFoodFoodSourceIdRef] as int),
      fromDb: true,
      kJoule: dbResult[0][OpenEatsJournalStrings.dbResultFoodKiloJoule] as double,
      originalFoodSource: dbResult[0][OpenEatsJournalStrings.dbResultFoodOriginalFoodSourceIdRef] != null
          ? FoodSource.getByValue(dbResult[0][OpenEatsJournalStrings.dbResultFoodOriginalFoodSourceIdRef] as int)
          : null,
      originalFoodSourceFoodId: dbResult[0][OpenEatsJournalStrings.dbResultFoodOriginalFoodSourceFoodIdRef] as String?,
      barcode: dbResult[0][OpenEatsJournalStrings.dbResultFoodBarcode] as int?,
      brands: dbResult[0][OpenEatsJournalStrings.dbResultFoodBrands] != null
          ? (dbResult[0][OpenEatsJournalStrings.dbResultFoodBrands] as String).split(",").map((String brand) => brand.trim()).toList()
          : null,
      nutritionPerGramAmount: dbResult[0][OpenEatsJournalStrings.dbResultFoodNutritionPerGramAmount] as double?,
      nutritionPerMilliliterAmount: dbResult[0][OpenEatsJournalStrings.dbResultFoodNutritionPerMilliliterAmount] as double?,
      carbohydrates: dbResult[0][OpenEatsJournalStrings.dbResultFoodCarbohydrates] as double?,
      sugar: dbResult[0][OpenEatsJournalStrings.dbResultFoodSugar] as double?,
      fat: dbResult[0][OpenEatsJournalStrings.dbResultFoodFat] as double?,
      saturatedFat: dbResult[0][OpenEatsJournalStrings.dbResultFoodSaturatedFat] as double?,
      protein: dbResult[0][OpenEatsJournalStrings.dbResultFoodProtein] as double?,
      salt: dbResult[0][OpenEatsJournalStrings.dbResultFoodSalt] as double?,
      quantity: dbResult[0][OpenEatsJournalStrings.dbResultFoodQuantity] as String?,
      orderedDefaultFoodUnits: orderedDefaultFoodUnits,
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
            originalFoodSourceFoodUnitId: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitOriginalFoodSourceFoodUnitIdRef] as String?,
          ),
          order: foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitOrderNumber] as int,
        ),
        isDefault: (foodUnitRow[OpenEatsJournalStrings.dbResultFoodUnitIsDefault] as int) == 1,
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

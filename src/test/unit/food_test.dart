import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/food_unit.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/object_with_order.dart";
import "package:test/test.dart";

void main() {
  test("Adding food units", () {
    Food food = Food(name: "My test food", foodSource: FoodSource.user, kJoule: 100, fromDb: false, nutritionPerGramAmount: 100);
    FoodUnit foodUnit1 = FoodUnit(name: "Food Unit 1", amount: 101, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit2 = FoodUnit(name: "Food Unit 2", amount: 102, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit3 = FoodUnit(name: "Food Unit 3", amount: 103, amountMeasurementUnit: MeasurementUnit.gram);
    food.addFoodUnit(foodUnit: foodUnit1);
    food.addFoodUnit(foodUnit: foodUnit2);
    food.addFoodUnit(foodUnit: foodUnit3);

    expect(food.foodUnitsWithOrder[0].object, foodUnit1);
    expect(food.foodUnitsWithOrder[0].order, 1);
    expect(food.foodUnitsWithOrder[1].object, foodUnit2);
    expect(food.foodUnitsWithOrder[1].order, 2);
    expect(food.foodUnitsWithOrder[2].object, foodUnit3);
    expect(food.foodUnitsWithOrder[2].order, 3);
  });

  test("Adding food units with order", () {
    Food food = Food(name: "My test food", foodSource: FoodSource.user, kJoule: 100, fromDb: false, nutritionPerGramAmount: 100);
    FoodUnit foodUnit1 = FoodUnit(name: "Food Unit 1", amount: 101, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit2 = FoodUnit(name: "Food Unit 2", amount: 102, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit3 = FoodUnit(name: "Food Unit 3", amount: 103, amountMeasurementUnit: MeasurementUnit.gram);
    food.addFoodUnit(foodUnit: foodUnit1);
    food.addFoodUnit(foodUnit: foodUnit2, order: 1);
    food.addFoodUnit(foodUnit: foodUnit3, order: 2);

    for (ObjectWithOrder foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object == foodUnit1) {
        expect(foodUnitWithOrder.order, 3);
      }

      if (foodUnitWithOrder.object == foodUnit2) {
        expect(foodUnitWithOrder.order, 1);
      }

      if (foodUnitWithOrder.object == foodUnit3) {
        expect(foodUnitWithOrder.order, 2);
      }
    }
  });

  test("Reorder food units", () {
    Food food = Food(name: "My test food", foodSource: FoodSource.user, kJoule: 100, fromDb: false, nutritionPerGramAmount: 100);
    FoodUnit foodUnit1 = FoodUnit(name: "Food Unit 1", amount: 101, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit2 = FoodUnit(name: "Food Unit 2", amount: 102, amountMeasurementUnit: MeasurementUnit.gram);
    FoodUnit foodUnit3 = FoodUnit(name: "Food Unit 3", amount: 103, amountMeasurementUnit: MeasurementUnit.gram);
    food.addFoodUnit(foodUnit: foodUnit1);
    food.addFoodUnit(foodUnit: foodUnit2);
    food.addFoodUnit(foodUnit: foodUnit3);

    food.upadteFoodUnitOrder(foodUnit: foodUnit1, newOrder: 2);

    for (ObjectWithOrder foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object == foodUnit1) {
        expect(foodUnitWithOrder.order, 2);
      }

      if (foodUnitWithOrder.object == foodUnit2) {
        expect(foodUnitWithOrder.order, 1);
      }

      if (foodUnitWithOrder.object == foodUnit3) {
        expect(foodUnitWithOrder.order, 3);
      }
    }

    food.upadteFoodUnitOrder(foodUnit: foodUnit3, newOrder: 2);

    for (ObjectWithOrder foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object == foodUnit1) {
        expect(foodUnitWithOrder.order, 3);
      }

      if (foodUnitWithOrder.object == foodUnit2) {
        expect(foodUnitWithOrder.order, 1);
      }

      if (foodUnitWithOrder.object == foodUnit3) {
        expect(foodUnitWithOrder.order, 2);
      }
    }

    food.upadteFoodUnitOrder(foodUnit: foodUnit2, newOrder: 3);

    for (ObjectWithOrder foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object == foodUnit1) {
        expect(foodUnitWithOrder.order, 2);
      }

      if (foodUnitWithOrder.object == foodUnit2) {
        expect(foodUnitWithOrder.order, 3);
      }

      if (foodUnitWithOrder.object == foodUnit3) {
        expect(foodUnitWithOrder.order, 1);
      }
    }

    food.upadteFoodUnitOrder(foodUnit: foodUnit2, newOrder: 1);

    for (ObjectWithOrder foodUnitWithOrder in food.foodUnitsWithOrder) {
      if (foodUnitWithOrder.object == foodUnit1) {
        expect(foodUnitWithOrder.order, 3);
      }

      if (foodUnitWithOrder.object == foodUnit2) {
        expect(foodUnitWithOrder.order, 1);
      }

      if (foodUnitWithOrder.object == foodUnit3) {
        expect(foodUnitWithOrder.order, 2);
      }
    }
  });
}

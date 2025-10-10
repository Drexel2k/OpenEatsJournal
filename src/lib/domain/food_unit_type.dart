enum FoodUnitType {
  //Values must be the same as the database ids.
  piece(1),
  serving(2);

  final int value;

  const FoodUnitType(this.value);

  static FoodUnitType getByValue(num i) {
    return FoodUnitType.values.firstWhere((x) => x.value == i);
  }
}

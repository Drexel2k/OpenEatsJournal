enum FoodSource {
  user(1),
  standard(2),
  openFoodFacts(3);

  final int value;

  const FoodSource(this.value);

  static FoodSource getByValue(num i) {
    return FoodSource.values.firstWhere((x) => x.value == i);
  }
}

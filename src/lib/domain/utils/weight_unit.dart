enum WeightUnit {
  g(1),
  oz(2);

  final int value;

  const WeightUnit(this.value);

  static WeightUnit getByValue(num i) {
    return WeightUnit.values.firstWhere((x) => x.value == i);
  }
}

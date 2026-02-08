enum HeightUnit {
  inch(1),
  cm(2);

  final int value;

  const HeightUnit(this.value);

  static HeightUnit getByValue(num i) {
    return HeightUnit.values.firstWhere((x) => x.value == i);
  }
}

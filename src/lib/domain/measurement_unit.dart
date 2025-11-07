enum MeasurementUnit {
  //Values must be the same as the database ids.
  gram(1, "g"),
  milliliter(2, "ml");

  final int value;
  final String text;

  const MeasurementUnit(this.value, this.text);

  static MeasurementUnit getByValue(num i) {
    return MeasurementUnit.values.firstWhere((x) => x.value == i);
  }
}

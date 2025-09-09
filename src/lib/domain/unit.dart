enum MeasurementUnit {
  gram(1, "g"),
  milliliter(2, "ml");

  final int value;
  final String text;

  const MeasurementUnit(this.value, this.text);
}

enum StatisticType {
  //Values must be the same as the database ids.
  //New values also need a localization, see LocalizedMealDropDownEntries.getMealDropDownMenuEntries.
  energy(1),
  weight(2),
  fat(3),
  stauratedFat(4),
  carbohydrates(5),
  sugar(6),
  protein(7),
  salt(8);

  final int value;

  const StatisticType(this.value);

  static StatisticType getByValue(num i) {
    return StatisticType.values.firstWhere((x) => x.value == i);
  }
}

enum Statistic {
  //Values must be the same as the database ids.
  //New values also need a localization, see LocalizedMealDropDownEntries.getMealDropDownMenuEntries.
  energy(1),
  weight(2);

  final int value;

  const Statistic(this.value);

  static Statistic getByValue(num i) {
    return Statistic.values.firstWhere((x) => x.value == i);
  }
}

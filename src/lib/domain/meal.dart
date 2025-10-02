enum Meal {
  //Values must be the same as the database ids.
  //New values also need a localization, see LocalizedMealDropDownEntries.getMealDropDownMenuEntries.
  breakfast(1),
  lunch(2),
  dinner(3),
  snacks(4);

  final int value;

  const Meal(this.value);

  static Meal getByValue(num i) {
    return Meal.values.firstWhere((x) => x.value == i);
  }
}
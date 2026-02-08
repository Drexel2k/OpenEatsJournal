enum EnergyUnit {
  kj(1),
  kcal(2);

  final int value;

  const EnergyUnit(this.value);

  static EnergyUnit getByValue(num i) {
    return EnergyUnit.values.firstWhere((x) => x.value == i);
  }
}

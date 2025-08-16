enum WeightTarget {
  keep(1),
  lose025(2),
  lose05(3),
  lose075(4);

  final int value;

  const WeightTarget(this.value);

  static WeightTarget getByValue(num i){
    return WeightTarget.values.firstWhere((x) => x.value == i);
  }
}
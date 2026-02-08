enum VolumeUnit {
  ml(1),
  flOzGb(2),
  flOzUs(3);

  final int value;

  const VolumeUnit(this.value);

  static VolumeUnit getByValue(num i) {
    return VolumeUnit.values.firstWhere((x) => x.value == i);
  }
}

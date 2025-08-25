enum SettingType {
  personal(1),
  app(2);

  final int value;

  const SettingType(this.value);

  static SettingType getByValue(num i) {
    return SettingType.values.firstWhere((x) => x.value == i);
  }
}

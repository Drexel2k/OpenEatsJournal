enum Gender {
  male(1),
  female(2);

  final int value;

  const Gender(this.value);

  static Gender getByValue(num i) {
    return Gender.values.firstWhere((x) => x.value == i);
  }
}

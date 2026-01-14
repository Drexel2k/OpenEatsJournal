enum SearchMode {
  online(1),
  offline(2),
  recent(3);

  final int value;

  const SearchMode(this.value);

  static SearchMode getByValue(num i) {
    return SearchMode.values.firstWhere((x) => x.value == i);
  }
}

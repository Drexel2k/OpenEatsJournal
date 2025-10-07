class FoodUnit {
  FoodUnit({required String name, required int amount}) : _name = name, _amount = amount;

  String _name;
  final int _amount;

  set name(String name) => _name = name;
  String get name => _name;
  int get amount => _amount;
}

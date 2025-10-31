import 'package:openeatsjournal/domain/food_unit.dart';

//Hack for the bug of ReorderableListview than cannot order a Textfield with focus, to remain inconsistent state between ReorderableListview rebuilds
//(ReorderableListview.listenable: _foodEditScreenViewModel.reorderableStateChanged...) to maintain error messages when setting between editing and ordering
//mode.
class FoodUnitEditWrapper {
  FoodUnitEditWrapper({required FoodUnit foodUnit}) : _foodUnit = foodUnit, _amount = foodUnit.amount;

  final FoodUnit _foodUnit;
  int? _amount;

  set amount(int? value) {
    _amount = value;
  }

  FoodUnit get foodUnit => _foodUnit;
  int? get amount => _amount;
}

import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';

class OrderedDefaultFoodUnit {
  OrderedDefaultFoodUnit({required ObjectWithOrder<FoodUnit> foodUnitWithOrder, required bool isDefault})
    : _foodUnitWithOrder = foodUnitWithOrder,
      _isDefault = isDefault;

  final ObjectWithOrder<FoodUnit> _foodUnitWithOrder;
  final bool _isDefault;

  ObjectWithOrder<FoodUnit> get foodUnitWithOrder => _foodUnitWithOrder;
  bool get isDefault => _isDefault;
}

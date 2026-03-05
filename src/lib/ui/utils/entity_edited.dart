//only case where it is really needed currently is on the foodcard, the onFoodEdited callback can't know if the food was edited or created.
class EntityEdited {
  EntityEdited({required int? originalId}) : _originalId = originalId;

  final int? _originalId;

  int? get originalId => _originalId;
}

class EntityEdited {
  EntityEdited({required int? originalId}) : _originalId = originalId;

  final int? _originalId;

  int? get originalId => _originalId;
}

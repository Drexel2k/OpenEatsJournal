class ObjectWithOrder<T> {
  ObjectWithOrder({required T object, required int order}):
  _object = object,
  _order = order;

  final T _object;
  final int _order;

  T get object => _object;
  int get order => _order;
}
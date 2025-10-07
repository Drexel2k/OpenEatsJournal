class OrderableDefaultProxy<T> {
    OrderableDefaultProxy({required T proxy, required int order}) : _proxy = proxy, _order = order;
    
  final T _proxy ;
  final int _order;

  T get proxy => _proxy;
  int get order => _order;
}
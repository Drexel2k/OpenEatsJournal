class FutureBuilderNullableResult<T> {
  FutureBuilderNullableResult({required Future<T> Function() computation}) : _computation = computation;
  final Future<T> Function() _computation;
  late T? result;

  Future<FutureBuilderNullableResult<T>> getFutureBuilderResult() async {
    result = await _computation();
    return this;
  }
}
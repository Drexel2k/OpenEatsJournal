//FutureBuilder doesn't support a null result from the future argument method,
//so nullable results can be wrapped with thid class.
//usage:

// FutureBuilderNullableResult<DateTime?> birthdayFuture = FutureBuilderNullableResult<DateTime?>(computation: () => _settingsRepository.getBirthday());

//     return FutureBuilder<FutureBuilderNullableResult<DateTime?>>(
//       future: birthdayFuture.getFutureBuilderResult(), // a previously-obtained Future<String> or null
//       builder: (BuildContext context, AsyncSnapshot<FutureBuilderNullableResult<DateTime?>> snapshot) {
//         if (snapshot.hasData) {
//           if(snapshot.data!.result != null) {
//             ...

class FutureBuilderNullableResult<T> {
  FutureBuilderNullableResult({required Future<T> Function() computation}) : _computation = computation;
  final Future<T> Function() _computation;
  late T? result;

  Future<FutureBuilderNullableResult<T>> getFutureBuilderResult() async {
    result = await _computation();
    return this;
  }
}

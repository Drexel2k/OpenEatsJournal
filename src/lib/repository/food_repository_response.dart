class FoodRepositoryResponse {
  const FoodRepositoryResponse({int? errorCode, String? errorMessage}):
  _errorCode = errorCode,
  _errorMessage = errorMessage;

  final int? _errorCode;
  final String? _errorMessage;

  int? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;
}
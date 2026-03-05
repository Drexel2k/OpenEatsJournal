class OverlayInfo {
  OverlayInfo({required String message, required double spacer}) : _message = message, _spacer = spacer;

  final String _message;
  final double _spacer;

  String get message => _message;
  double get spacer => _spacer;
}

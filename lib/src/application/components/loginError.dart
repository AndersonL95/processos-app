class CustomHttpException implements Exception {
  final String message;
  CustomHttpException(this.message);
  @override
  String toString() => message;
}

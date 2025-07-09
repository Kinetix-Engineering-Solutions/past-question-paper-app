class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {required this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

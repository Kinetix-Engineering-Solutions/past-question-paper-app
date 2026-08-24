enum ApiFailureType { network, timeout, http, invalidResponse }

final class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiFailureType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

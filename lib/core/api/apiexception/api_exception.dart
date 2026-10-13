enum ApiExceptionType {
  noInternet,
  timeout,
  connection,
  invalidUrl,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  tooManyRequests,
  serverError,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;

  // Raw body of the failed response (only set for HTTP errors)
  final String? responseBody;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return message;
  }
}

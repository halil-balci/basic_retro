import 'package:dio/dio.dart';
import 'failures.dart';

class NetworkExceptions implements Exception {
  final String message;
  final int? statusCode;

  NetworkExceptions({
    required this.message,
    this.statusCode,
  });

  factory NetworkExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkExceptions(
          message: 'Connection timeout',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return NetworkExceptions(
          message: 'Send timeout',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions(
          message: 'Receive timeout',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return NetworkExceptions._handleResponse(error.response);
      case DioExceptionType.cancel:
        return NetworkExceptions(
          message: 'Request cancelled',
          statusCode: null,
        );
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkExceptions(
            message: 'No internet connection',
            statusCode: null,
          );
        }
        return NetworkExceptions(
          message: 'Unexpected error occurred',
          statusCode: null,
        );
      default:
        return NetworkExceptions(
          message: 'Unknown error occurred',
          statusCode: null,
        );
    }
  }

  factory NetworkExceptions._handleResponse(Response? response) {
    final statusCode = response?.statusCode;
    final message = response?.data?['message'] ?? 'Unknown error';

    switch (statusCode) {
      case 400:
        return NetworkExceptions(
          message: 'Bad request: $message',
          statusCode: statusCode,
        );
      case 401:
        return NetworkExceptions(
          message: 'Unauthorized: $message',
          statusCode: statusCode,
        );
      case 403:
        return NetworkExceptions(
          message: 'Forbidden: $message',
          statusCode: statusCode,
        );
      case 404:
        return NetworkExceptions(
          message: 'Not found: $message',
          statusCode: statusCode,
        );
      case 500:
        return NetworkExceptions(
          message: 'Internal server error',
          statusCode: statusCode,
        );
      default:
        return NetworkExceptions(
          message: 'Error occurred: $message',
          statusCode: statusCode,
        );
    }
  }

  ServerFailure toFailure() {
    return ServerFailure(
      message: message,
      code: statusCode,
    );
  }
}

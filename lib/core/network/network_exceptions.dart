import 'package:dio/dio.dart';
import '../error/failures.dart';

/// Network exceptions for Dio errors
class NetworkExceptions {
  final String message;
  final int? statusCode;

  const NetworkExceptions({
    required this.message,
    this.statusCode,
  });

  /// Create NetworkExceptions from DioException
  factory NetworkExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _getMessageFromStatusCode(statusCode);
        return NetworkExceptions(
          message: message,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkExceptions(
          message: 'Request was cancelled.',
          statusCode: null,
        );
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkExceptions(
            message: 'No internet connection.',
            statusCode: null,
          );
        }
        return NetworkExceptions(
          message: error.message ?? 'An unexpected error occurred.',
          statusCode: null,
        );
      default:
        return NetworkExceptions(
          message: error.message ?? 'An unexpected error occurred.',
          statusCode: error.response?.statusCode,
        );
    }
  }

  /// Convert to Failure object
  Failure toFailure() {
    if (statusCode != null && statusCode! >= 500) {
      return ServerFailure(message: message);
    } else if (statusCode != null) {
      return NetworkFailure(message: message);
    } else {
      return NetworkFailure(message: message);
    }
  }

  static String _getMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Status code: $statusCode';
    }
  }
}

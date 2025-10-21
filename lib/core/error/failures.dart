/// Base failure class for clean architecture
abstract class Failure {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
  }) : super(message: message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
  }) : super(message: message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
  }) : super(message: message);
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required String message,
  }) : super(message: message);
}

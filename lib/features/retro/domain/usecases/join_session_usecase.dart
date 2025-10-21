import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/retro_repository.dart';

class JoinSessionUseCase implements UseCase<void, JoinSessionParams> {
  final RetroRepository repository;

  JoinSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinSessionParams params) async {
    try {
      await repository.joinSession(
        params.sessionId,
        params.userId,
        params.userName,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class JoinSessionParams {
  final String sessionId;
  final String userId;
  final String userName;

  JoinSessionParams({
    required this.sessionId,
    required this.userId,
    required this.userName,
  });
}

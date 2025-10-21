import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/retro_session.dart';
import '../repositories/retro_repository.dart';

class CreateSessionUseCase implements UseCase<RetroSession, CreateSessionParams> {
  final RetroRepository repository;

  CreateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, RetroSession>> call(CreateSessionParams params) async {
    try {
      final session = await repository.createSession(
        params.name,
        params.creatorId,
        params.creatorName,
      );
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class CreateSessionParams {
  final String name;
  final String creatorId;
  final String creatorName;

  CreateSessionParams({
    required this.name,
    required this.creatorId,
    required this.creatorName,
  });
}

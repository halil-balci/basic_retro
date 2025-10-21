import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/retro_phase.dart';
import '../repositories/retro_repository.dart';

class UpdatePhaseUseCase implements UseCase<void, UpdatePhaseParams> {
  final RetroRepository repository;

  UpdatePhaseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePhaseParams params) async {
    try {
      await repository.updateSessionPhase(params.sessionId, params.phase);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class UpdatePhaseParams {
  final String sessionId;
  final RetroPhase phase;

  UpdatePhaseParams({
    required this.sessionId,
    required this.phase,
  });
}

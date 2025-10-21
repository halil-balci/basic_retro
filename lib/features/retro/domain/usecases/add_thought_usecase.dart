import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/retro_thought.dart';
import '../repositories/retro_repository.dart';

class AddThoughtUseCase implements UseCase<void, AddThoughtParams> {
  final RetroRepository repository;

  AddThoughtUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddThoughtParams params) async {
    try {
      await repository.addThought(params.sessionId, params.thought);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class AddThoughtParams {
  final String sessionId;
  final RetroThought thought;

  AddThoughtParams({
    required this.sessionId,
    required this.thought,
  });
}

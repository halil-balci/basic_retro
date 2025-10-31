import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/gemini_repository.dart';

/// Use case for generating action items from thoughts using Gemini AI
class GenerateActionItemUseCase implements UseCase<String, GenerateActionItemParams> {
  final GeminiRepository _repository;

  GenerateActionItemUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(GenerateActionItemParams params) async {
    return await _repository.generateActionItem(params.thoughtTexts);
  }
}

/// Parameters for GenerateActionItemUseCase
class GenerateActionItemParams {
  final List<String> thoughtTexts;

  const GenerateActionItemParams({required this.thoughtTexts});
}

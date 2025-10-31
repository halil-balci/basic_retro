import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/repositories/gemini_repository.dart';
import '../datasources/gemini_datasource.dart';

/// Implementation of GeminiRepository
class GeminiRepositoryImpl implements GeminiRepository {
  final GeminiDataSource _dataSource;

  GeminiRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> generateActionItem(List<String> thoughtTexts) async {
    try {
      // Validate input
      if (thoughtTexts.isEmpty) {
        return const Left(ValidationFailure(message: 'No thoughts provided to generate action item'));
      }

      // Call data source
      final result = await _dataSource.generateActionItem(thoughtTexts);
      return Right(result);
    } on NetworkExceptions catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Repository interface for Gemini AI operations
abstract class GeminiRepository {
  /// Generate action item from thought texts
  /// 
  /// [thoughtTexts] - List of thought texts from a group
  /// Returns Either a Failure or the generated action item text
  Future<Either<Failure, String>> generateActionItem(List<String> thoughtTexts);
}

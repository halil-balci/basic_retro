import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/network_exceptions.dart';

/// API data source for external retro-related services
/// Uses Dio for HTTP operations
class RetroApiDataSource {
  final DioClient _dioClient;

  RetroApiDataSource(this._dioClient);

  /// Fetch retro templates from external API
  /// Example endpoint: GET /api/templates
  Future<List<Map<String, dynamic>>> fetchRetroTemplates() async {
    try {
      final response = await _dioClient.get('/templates');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }

  /// Send analytics data to external service
  /// Example endpoint: POST /api/analytics
  Future<void> sendAnalytics({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _dioClient.post(
        '/analytics',
        data: {
          'sessionId': sessionId,
          'eventType': eventType,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }

  /// Export session data to external service
  /// Example endpoint: POST /api/export
  Future<Map<String, dynamic>> exportSessionData({
    required String sessionId,
    required String format, // 'pdf', 'csv', 'json'
  }) async {
    try {
      final response = await _dioClient.post(
        '/export',
        data: {
          'sessionId': sessionId,
          'format': format,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }

  /// Fetch recommended action items based on session data
  /// Example endpoint: POST /api/recommendations
  Future<List<String>> fetchRecommendations({
    required String sessionId,
    required List<String> categories,
  }) async {
    try {
      final response = await _dioClient.post(
        '/recommendations',
        data: {
          'sessionId': sessionId,
          'categories': categories,
        },
      );
      return List<String>.from(response.data['recommendations']);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }

  /// Send feedback to external service
  /// Example endpoint: POST /api/feedback
  Future<void> sendFeedback({
    required String feedback,
    String? userId,
    String? sessionId,
  }) async {
    try {
      await _dioClient.post(
        '/feedback',
        data: {
          'feedback': feedback,
          'userId': userId,
          'sessionId': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }

  /// Get session statistics from external analytics service
  /// Example endpoint: GET /api/stats/{sessionId}
  Future<Map<String, dynamic>> getSessionStats(String sessionId) async {
    try {
      final response = await _dioClient.get('/stats/$sessionId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }
}

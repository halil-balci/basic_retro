import '../../domain/entities/retro_session.dart';
import '../../domain/entities/retro_thought.dart';
import '../../domain/entities/retro_phase.dart';
import '../../domain/entities/thought_group.dart';
import '../../domain/entities/action_item.dart';
import '../../domain/repositories/retro_repository.dart';
import '../datasources/firebase_retro_datasource.dart';
import '../datasources/retro_api_datasource.dart';
import '../models/retro_session_model.dart';
import '../models/retro_thought_model.dart';
import '../models/thought_group_model.dart';
import '../models/action_item_model.dart';
import '../../../../core/error/network_exceptions.dart';

/// Implementation of RetroRepository using Firebase and external APIs
class RetroRepositoryImpl implements RetroRepository {
  final FirebaseRetroDataSource _firebaseDataSource;
  final RetroApiDataSource _apiDataSource;

  RetroRepositoryImpl(this._firebaseDataSource, this._apiDataSource);

  @override
  Future<RetroSession> createSession(
    String name,
    String creatorId,
    String creatorName,
  ) async {
    final model = await _firebaseDataSource.createSession(name, creatorId, creatorName);
    return model.toEntity();
  }

  @override
  Future<RetroSession?> getSession(String sessionId) async {
    final model = await _firebaseDataSource.getSession(sessionId);
    return model?.toEntity();
  }

  @override
  Stream<RetroSession?> getSessionStream(String sessionId) {
    return _firebaseDataSource.getSessionStream(sessionId).map((model) => model?.toEntity());
  }

  @override
  Future<RetroSession?> findSessionByName(String name) async {
    final model = await _firebaseDataSource.findSessionByName(name);
    return model?.toEntity();
  }

  @override
  Future<List<RetroSession>> getAllSessions() async {
    final models = await _firebaseDataSource.getAllSessions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<RetroSession>> getUserSessions(String userId) {
    // This would need to be implemented based on your requirements
    // For now, return empty stream
    return Stream.value([]);
  }

  @override
  Future<void> joinSession(String sessionId, String userId, String userName) async {
    await _firebaseDataSource.joinSession(sessionId, userId, userName);
  }

  @override
  Future<void> leaveSession(String sessionId, String userId) async {
    await _firebaseDataSource.leaveSession(sessionId, userId);
  }

  @override
  Future<void> updateSession(RetroSession session) async {
    await _firebaseDataSource.updateSession(RetroSessionModel.fromEntity(session));
  }

  @override
  Stream<List<RetroThought>> getSessionThoughts(String sessionId) {
    return _firebaseDataSource.getSessionThoughts(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> addThought(String sessionId, RetroThought thought) async {
    await _firebaseDataSource.addThought(
      sessionId,
      RetroThoughtModel.fromEntity(thought),
    );
  }

  @override
  Future<void> updateThought(String sessionId, RetroThought thought) async {
    await _firebaseDataSource.updateThought(
      sessionId,
      RetroThoughtModel.fromEntity(thought),
    );
  }

  @override
  Future<void> deleteThought(String sessionId, String thoughtId) async {
    await _firebaseDataSource.deleteThought(sessionId, thoughtId);
  }

  @override
  Future<void> updateSessionPhase(String sessionId, RetroPhase phase) async {
    await _firebaseDataSource.updateSessionPhase(sessionId, phase);
  }

  @override
  Future<void> addGroup(String sessionId, ThoughtGroup group) async {
    await _firebaseDataSource.addGroup(
      sessionId,
      ThoughtGroupModel.fromEntity(group),
    );
  }

  @override
  Future<void> updateSessionGroups(
    String sessionId,
    List<ThoughtGroup> groups,
  ) async {
    await _firebaseDataSource.updateSessionGroups(
      sessionId,
      groups.map((g) => ThoughtGroupModel.fromEntity(g)).toList(),
    );
  }

  @override
  Future<void> updateGroupPosition(
    String sessionId,
    String groupId,
    double x,
    double y,
  ) async {
    // Implementation for updating single group position
    // This would need session data to update
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> mergeGroups(
    String sessionId,
    String targetGroupId,
    String sourceGroupId,
  ) async {
    // Implementation for merging groups
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> updateGroupName(
    String sessionId,
    String groupId,
    String newName,
  ) async {
    // Implementation for updating group name
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> clearGroups(String sessionId) async {
    await _firebaseDataSource.clearGroups(sessionId);
  }

  @override
  Stream<List<ThoughtGroup>> getSessionGroups(String sessionId) {
    return _firebaseDataSource.getSessionGroups(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> updateUserVotes(String sessionId, Map<String, int> userVotes) async {
    await _firebaseDataSource.updateUserVotes(sessionId, userVotes);
  }

  @override
  Future<void> voteForGroup(String sessionId, String groupId, String userId) async {
    await _firebaseDataSource.voteForGroup(sessionId, groupId, userId);
  }

  @override
  Future<void> removeVoteFromGroup(
    String sessionId,
    String groupId,
    String userId,
  ) async {
    await _firebaseDataSource.removeVoteFromGroup(sessionId, groupId, userId);
  }

  @override
  Future<void> updateDiscussionGroupIndex(String sessionId, int index) async {
    await _firebaseDataSource.updateDiscussionGroupIndex(sessionId, index);
  }

  @override
  Stream<List<ActionItem>> getSessionActionItems(String sessionId) {
    return _firebaseDataSource.getSessionActionItems(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> addActionItem(String sessionId, ActionItem actionItem) async {
    final model = ActionItemModel.fromEntity(actionItem);
    await _firebaseDataSource.addActionItem(sessionId, model);
  }

  @override
  Future<void> updateActionItem(String sessionId, ActionItem actionItem) async {
    final model = ActionItemModel.fromEntity(actionItem);
    await _firebaseDataSource.updateActionItem(sessionId, model);
  }

  @override
  Future<void> deleteActionItem(String sessionId, String actionItemId) async {
    await _firebaseDataSource.deleteActionItem(sessionId, actionItemId);
  }

  @override
  Future<void> clearSessionData(String sessionId) async {
    await _firebaseDataSource.clearSessionData(sessionId);
  }

  // API-based methods using Dio

  @override
  Future<List<Map<String, dynamic>>> fetchRetroTemplates() async {
    try {
      return await _apiDataSource.fetchRetroTemplates();
    } on NetworkExceptions {
      // Return empty list on error or use cached templates
      return [];
    }
  }

  @override
  Future<void> sendAnalytics({
    required String sessionId,
    required String eventType,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _apiDataSource.sendAnalytics(
        sessionId: sessionId,
        eventType: eventType,
        data: data,
      );
    } on NetworkExceptions catch (e) {
      // Log error but don't throw - analytics should not break the app
      // ignore: avoid_print
      print('Analytics error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>?> exportSessionData({
    required String sessionId,
    required String format,
  }) async {
    try {
      return await _apiDataSource.exportSessionData(
        sessionId: sessionId,
        format: format,
      );
    } on NetworkExceptions {
      return null;
    }
  }

  @override
  Future<List<String>> fetchRecommendations({
    required String sessionId,
    required List<String> categories,
  }) async {
    try {
      return await _apiDataSource.fetchRecommendations(
        sessionId: sessionId,
        categories: categories,
      );
    } on NetworkExceptions {
      return [];
    }
  }

  @override
  Future<void> sendFeedbackToApi({
    required String feedback,
    String? userId,
    String? sessionId,
  }) async {
    try {
      await _apiDataSource.sendFeedback(
        feedback: feedback,
        userId: userId,
        sessionId: sessionId,
      );
    } on NetworkExceptions catch (e) {
      // ignore: avoid_print
      print('Feedback API error: ${e.message}');
      // Fallback to Firebase if API fails
      // Could store in Firebase as backup
    }
  }

  @override
  Future<Map<String, dynamic>?> getSessionStats(String sessionId) async {
    try {
      return await _apiDataSource.getSessionStats(sessionId);
    } on NetworkExceptions {
      return null;
    }
  }
}

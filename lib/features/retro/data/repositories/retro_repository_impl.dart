import '../../domain/entities/retro_session.dart';
import '../../domain/entities/retro_thought.dart';
import '../../domain/entities/retro_phase.dart';
import '../../domain/entities/thought_group.dart';
import '../../domain/entities/action_item.dart';
import '../../domain/repositories/retro_repository.dart';
import '../datasources/firebase_retro_datasource.dart';
import '../models/retro_session_model.dart';
import '../models/retro_thought_model.dart';
import '../models/thought_group_model.dart';
import '../models/action_item_model.dart';

/// Implementation of RetroRepository using Firebase
class RetroRepositoryImpl implements RetroRepository {
  final FirebaseRetroDataSource _dataSource;

  RetroRepositoryImpl(this._dataSource);

  @override
  Future<RetroSession> createSession(
    String name,
    String creatorId,
    String creatorName,
  ) async {
    final model = await _dataSource.createSession(name, creatorId, creatorName);
    return model.toEntity();
  }

  @override
  Future<RetroSession?> getSession(String sessionId) async {
    final model = await _dataSource.getSession(sessionId);
    return model?.toEntity();
  }

  @override
  Stream<RetroSession?> getSessionStream(String sessionId) {
    return _dataSource.getSessionStream(sessionId).map((model) => model?.toEntity());
  }

  @override
  Future<RetroSession?> findSessionByName(String name) async {
    final model = await _dataSource.findSessionByName(name);
    return model?.toEntity();
  }

  @override
  Future<List<RetroSession>> getAllSessions() async {
    final models = await _dataSource.getAllSessions();
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
    await _dataSource.joinSession(sessionId, userId, userName);
  }

  @override
  Future<void> leaveSession(String sessionId, String userId) async {
    await _dataSource.leaveSession(sessionId, userId);
  }

  @override
  Future<void> updateSession(RetroSession session) async {
    await _dataSource.updateSession(RetroSessionModel.fromEntity(session));
  }

  @override
  Stream<List<RetroThought>> getSessionThoughts(String sessionId) {
    return _dataSource.getSessionThoughts(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> addThought(String sessionId, RetroThought thought) async {
    await _dataSource.addThought(
      sessionId,
      RetroThoughtModel.fromEntity(thought),
    );
  }

  @override
  Future<void> updateThought(String sessionId, RetroThought thought) async {
    await _dataSource.updateThought(
      sessionId,
      RetroThoughtModel.fromEntity(thought),
    );
  }

  @override
  Future<void> deleteThought(String sessionId, String thoughtId) async {
    await _dataSource.deleteThought(sessionId, thoughtId);
  }

  @override
  Future<void> updateSessionPhase(String sessionId, RetroPhase phase) async {
    await _dataSource.updateSessionPhase(sessionId, phase);
  }

  @override
  Future<void> addGroup(String sessionId, ThoughtGroup group) async {
    await _dataSource.addGroup(
      sessionId,
      ThoughtGroupModel.fromEntity(group),
    );
  }

  @override
  Future<void> updateSessionGroups(
    String sessionId,
    List<ThoughtGroup> groups,
  ) async {
    await _dataSource.updateSessionGroups(
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
    await _dataSource.clearGroups(sessionId);
  }

  @override
  Stream<List<ThoughtGroup>> getSessionGroups(String sessionId) {
    return _dataSource.getSessionGroups(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> updateUserVotes(String sessionId, Map<String, int> userVotes) async {
    await _dataSource.updateUserVotes(sessionId, userVotes);
  }

  @override
  Future<void> voteForGroup(String sessionId, String groupId, String userId) async {
    await _dataSource.voteForGroup(sessionId, groupId, userId);
  }

  @override
  Future<void> removeVoteFromGroup(
    String sessionId,
    String groupId,
    String userId,
  ) async {
    await _dataSource.removeVoteFromGroup(sessionId, groupId, userId);
  }

  @override
  Future<void> updateDiscussionGroupIndex(String sessionId, int index) async {
    await _dataSource.updateDiscussionGroupIndex(sessionId, index);
  }

  @override
  Stream<List<ActionItem>> getSessionActionItems(String sessionId) {
    return _dataSource.getSessionActionItems(sessionId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> addActionItem(String sessionId, ActionItem actionItem) async {
    final model = ActionItemModel.fromEntity(actionItem);
    await _dataSource.addActionItem(sessionId, model);
  }

  @override
  Future<void> updateActionItem(String sessionId, ActionItem actionItem) async {
    final model = ActionItemModel.fromEntity(actionItem);
    await _dataSource.updateActionItem(sessionId, model);
  }

  @override
  Future<void> deleteActionItem(String sessionId, String actionItemId) async {
    await _dataSource.deleteActionItem(sessionId, actionItemId);
  }

  @override
  Future<void> clearSessionData(String sessionId) async {
    await _dataSource.clearSessionData(sessionId);
  }
}

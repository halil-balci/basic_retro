import 'retro_thought.dart';
import 'retro_session.dart';
import 'retro_phase.dart';
import 'thought_group.dart';

abstract class IRetroRepository {
  // Session management
  Future<RetroSession> createSession(String name, String creatorId, String creatorName);
  Future<RetroSession?> getSession(String sessionId);
  Stream<RetroSession?> getSessionStream(String sessionId);
  Future<RetroSession?> findSessionByName(String name);
  Future<List<RetroSession>> getAllSessions();
  Stream<List<RetroSession>> getUserSessions(String userId);
  Future<void> joinSession(String sessionId, String userId, String userName);
  Future<void> leaveSession(String sessionId, String userId);
  Future<void> updateSession(RetroSession session);

  // Thoughts management
  Stream<List<RetroThought>> getSessionThoughts(String sessionId);
  Future<void> addThought(String sessionId, RetroThought thought);
  Future<void> updateThought(String sessionId, RetroThought thought);
  Future<void> deleteThought(String sessionId, String thoughtId);

  // Phase management
  Future<void> updateSessionPhase(String sessionId, RetroPhase phase);
  
  // Group management
  Future<void> addGroup(String sessionId, ThoughtGroup group);
  Future<void> updateSessionGroups(String sessionId, List<ThoughtGroup> groups);
  Future<void> updateGroupPosition(String sessionId, String groupId, double x, double y);
  Future<void> mergeGroups(String sessionId, String targetGroupId, String sourceGroupId);
  Future<void> updateGroupName(String sessionId, String groupId, String newName);
  Future<void> clearGroups(String sessionId);
  Stream<List<ThoughtGroup>> getSessionGroups(String sessionId);
  
  // Voting management
  Future<void> updateUserVotes(String sessionId, Map<String, int> userVotes);
  Future<void> voteForGroup(String sessionId, String groupId, String userId);
  Future<void> removeVoteFromGroup(String sessionId, String groupId, String userId);
  
  // Discussion management
  Future<void> updateDiscussionGroupIndex(String sessionId, int index);
}

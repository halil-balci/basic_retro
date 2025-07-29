import 'retro_thought.dart';
import 'retro_session.dart';

abstract class IRetroRepository {
  // Session management
  Future<RetroSession> createSession(String name, String creatorId);
  Future<RetroSession?> getSession(String sessionId);
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
}

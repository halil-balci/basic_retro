import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/retro_session_model.dart';
import '../models/retro_thought_model.dart';
import '../models/thought_group_model.dart';
import '../../domain/entities/retro_phase.dart';

/// Firebase data source for retro feature
class FirebaseRetroDataSource {
  final FirebaseFirestore _firestore;
  final String _sessionsCollection = 'retro_sessions';
  final String _thoughtsCollection = 'thoughts';

  FirebaseRetroDataSource(this._firestore);

  // Session operations
  Future<RetroSessionModel> createSession(
    String name,
    String creatorId,
    String creatorName,
  ) async {
    final sessionRef = _firestore.collection(_sessionsCollection).doc();
    final now = DateTime.now();
    
    final session = RetroSessionModel(
      id: sessionRef.id,
      name: name,
      creatorId: creatorId,
      createdAt: now,
      participants: [creatorId],
      activeUsers: {creatorId: creatorName},
    );

    await sessionRef.set(session.toJson());
    return session;
  }

  Future<RetroSessionModel?> getSession(String sessionId) async {
    final doc = await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .get();
    
    if (!doc.exists) return null;
    return RetroSessionModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Stream<RetroSessionModel?> getSessionStream(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return RetroSessionModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  Future<RetroSessionModel?> findSessionByName(String name) async {
    final querySnapshot = await _firestore
        .collection(_sessionsCollection)
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    
    final doc = querySnapshot.docs.first;
    return RetroSessionModel.fromJson({...doc.data(), 'id': doc.id});
  }

  Future<List<RetroSessionModel>> getAllSessions() async {
    final querySnapshot = await _firestore
        .collection(_sessionsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => RetroSessionModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> joinSession(
    String sessionId,
    String userId,
    String userName,
  ) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({
      'participants': FieldValue.arrayUnion([userId]),
      'activeUsers.$userId': userName,
    });
  }

  Future<void> leaveSession(String sessionId, String userId) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({
      'activeUsers.$userId': FieldValue.delete(),
    });
  }

  Future<void> updateSession(RetroSessionModel session) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(session.id)
        .update(session.toJson());
  }

  // Thoughts operations
  Stream<List<RetroThoughtModel>> getSessionThoughts(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .collection(_thoughtsCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RetroThoughtModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addThought(String sessionId, RetroThoughtModel thought) async {
    // If thought.id is empty, let Firebase generate one
    if (thought.id.isEmpty) {
      final docRef = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .add(thought.toJson());
      
      // Update the document with its own ID
      await docRef.update({'id': docRef.id});
    } else {
      // If thought has an ID, use it
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .doc(thought.id)
          .set(thought.toJson());
    }
  }

  Future<void> updateThought(String sessionId, RetroThoughtModel thought) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .collection(_thoughtsCollection)
        .doc(thought.id)
        .update(thought.toJson());
  }

  Future<void> deleteThought(String sessionId, String thoughtId) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .collection(_thoughtsCollection)
        .doc(thoughtId)
        .delete();
  }

  // Phase management
  Future<void> updateSessionPhase(String sessionId, RetroPhase phase) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({'currentPhase': phase.name});
  }

  // Group management
  Future<void> addGroup(String sessionId, ThoughtGroupModel group) async {
    final sessionRef = _firestore
        .collection(_sessionsCollection)
        .doc(sessionId);
    
    await sessionRef.update({
      'groups': FieldValue.arrayUnion([group.toJson()])
    });
  }

  Future<void> updateSessionGroups(
    String sessionId,
    List<ThoughtGroupModel> groups,
  ) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({
      'groups': groups.map((g) => g.toJson()).toList(),
    });
  }

  Future<void> clearGroups(String sessionId) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({'groups': []});
  }

  Stream<List<ThoughtGroupModel>> getSessionGroups(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <ThoughtGroupModel>[];
      final data = doc.data()!;
      final groupsList = data['groups'] as List<dynamic>? ?? [];
      return groupsList
          .map((g) => ThoughtGroupModel.fromJson(g as Map<String, dynamic>))
          .toList();
    });
  }

  // Voting management
  Future<void> updateUserVotes(
    String sessionId,
    Map<String, int> userVotes,
  ) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({'userVotes': userVotes});
  }

  Future<void> voteForGroup(String sessionId, String groupId, String userId) async {
    final sessionDoc = await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .get();

    if (!sessionDoc.exists) {
      throw Exception('Session not found');
    }

    final data = sessionDoc.data()!;
    
    // Check if user has remaining votes
    final userVotes = Map<String, int>.from(data['userVotes'] ?? {});
    int remainingVotes = userVotes[userId] ?? 0;
    
    // If user doesn't have votes, initialize with max votes (voting phase already started)
    if (remainingVotes == 0 && !userVotes.containsKey(userId)) {
      // Import maxVotesPerUser constant - for now use 6
      remainingVotes = 6; // RetroConstants.maxVotesPerUser
      userVotes[userId] = remainingVotes;
    }
    
    if (remainingVotes <= 0) {
      throw Exception('No votes remaining');
    }
    
    final groupsList = data['groups'] as List<dynamic>? ?? [];
    
    // Find and update the group
    final updatedGroups = groupsList.map((g) {
      final groupData = g as Map<String, dynamic>;
      if (groupData['id'] == groupId) {
        final voterIds = Map<String, int>.from(groupData['voterIds'] ?? {});
        voterIds[userId] = (voterIds[userId] ?? 0) + 1;
        
        return {
          ...groupData,
          'votes': (groupData['votes'] as int? ?? 0) + 1,
          'voterIds': voterIds,
        };
      }
      return groupData;
    }).toList();

    // Decrease user's remaining votes
    userVotes[userId] = remainingVotes - 1;

    // Update both groups and userVotes in a single operation
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({
      'groups': updatedGroups,
      'userVotes': userVotes,
    });
  }

  Future<void> removeVoteFromGroup(String sessionId, String groupId, String userId) async {
    final sessionDoc = await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .get();

    if (!sessionDoc.exists) {
      throw Exception('Session not found');
    }

    final data = sessionDoc.data()!;
    final groupsList = data['groups'] as List<dynamic>? ?? [];
    final userVotes = Map<String, int>.from(data['userVotes'] ?? {});
    
    bool voteRemoved = false;
    
    // Find and update the group
    final updatedGroups = groupsList.map((g) {
      final groupData = g as Map<String, dynamic>;
      if (groupData['id'] == groupId) {
        final voterIds = Map<String, int>.from(groupData['voterIds'] ?? {});
        
        // Only remove vote if user has voted
        if (voterIds.containsKey(userId) && voterIds[userId]! > 0) {
          voterIds[userId] = voterIds[userId]! - 1;
          if (voterIds[userId] == 0) {
            voterIds.remove(userId);
          }
          
          voteRemoved = true;
          
          return {
            ...groupData,
            'votes': ((groupData['votes'] as int? ?? 0) - 1).clamp(0, double.infinity).toInt(),
            'voterIds': voterIds,
          };
        }
      }
      return groupData;
    }).toList();

    // If vote was removed, increase user's remaining votes
    if (voteRemoved) {
      userVotes[userId] = (userVotes[userId] ?? 0) + 1;
    }

    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({
      'groups': updatedGroups,
      'userVotes': userVotes,
    });
  }

  Future<void> updateDiscussionGroupIndex(String sessionId, int index) async {
    await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .update({'currentDiscussionGroupIndex': index});
  }
}

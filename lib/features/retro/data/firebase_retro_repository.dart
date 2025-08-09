import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/retro_thought.dart';
import '../domain/retro_session.dart';
import '../domain/retro_phase.dart';
import '../domain/thought_group.dart';
import '../domain/i_retro_repository.dart';

class FirebaseRetroRepository implements IRetroRepository {
  final FirebaseFirestore _firestore;
  final String _sessionsCollection = 'retro_sessions';
  final String _thoughtsCollection = 'thoughts';

  FirebaseRetroRepository(this._firestore);

  @override
  Future<RetroSession> createSession(String name, String creatorId) async {
    try {
      final sessionRef = _firestore.collection(_sessionsCollection).doc();
      final now = DateTime.now();
      final session = RetroSession(
        id: sessionRef.id,
        name: name,
        creatorId: creatorId,
        createdAt: now,
        participants: [creatorId],
      );

      // Create the session document
      await sessionRef.set(session.toJson());
      
      // Initialize the thoughts subcollection with an empty document to ensure it exists
      // Note: We don't add any initial messages as per requirements
      
      return session;
    } catch (e) {
      debugPrint('Error in createSession: $e');
      rethrow;
    }
  }

  @override
  Future<RetroSession?> findSessionByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(_sessionsCollection)
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return RetroSession.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    } catch (e) {
      debugPrint('Error in findSessionByName: $e');
      rethrow;
    }
  }

  @override
  Future<List<RetroSession>> getAllSessions() async {
    try {
      final querySnapshot = await _firestore.collection(_sessionsCollection).get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure the document ID is included
            return RetroSession.fromJson(data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error in getAllSessions: $e');
      rethrow;
    }
  }

  @override
  Future<RetroSession?> getSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return RetroSession.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      debugPrint('Error in getSession: $e');
      rethrow;
    }
  }

  // Add stream method for session changes
  Stream<RetroSession?> getSessionStream(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          
          return RetroSession.fromJson({
            ...snapshot.data()!,
            'id': snapshot.id,
          });
        });
  }

  @override
  Stream<List<RetroSession>> getUserSessions(String userId) {
    return _firestore
        .collection(_sessionsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final sessions = snapshot.docs.map((doc) {
            return RetroSession.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList();
          
          // Sort by createdAt manually to avoid index requirement
          sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return sessions;
        });
  }

  @override
  Future<void> joinSession(String sessionId, String userId, String userName) async {
    try {
      await _firestore.collection(_sessionsCollection).doc(sessionId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'activeUsers.$userId': userName,
      });
    } catch (e) {
      debugPrint('Error in joinSession: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveSession(String sessionId, String userId) async {
    try {
      await _firestore.collection(_sessionsCollection).doc(sessionId).update({
        'activeUsers.$userId': FieldValue.delete(),
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      debugPrint('Error in leaveSession: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSession(RetroSession session) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(session.id)
          .update(session.toJson());
    } catch (e) {
      debugPrint('Error in updateSession: $e');
      rethrow;
    }
  }

  @override
  Stream<List<RetroThought>> getSessionThoughts(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .collection(_thoughtsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RetroThought.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList();
        });
  }

  @override
  Future<void> addThought(String sessionId, RetroThought thought) async {
    try {
      // Create a new document reference
      final thoughtRef = _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .doc();
      
      // Add the document ID to the thought data
      final thoughtData = thought.toJson();
      thoughtData['id'] = thoughtRef.id;
      
      // Save the thought
      await thoughtRef
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .doc();

      await thoughtRef.set({
        ...thought.toJson(),
        'id': thoughtRef.id,
      });
    } catch (e) {
      debugPrint('Error in addThought: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateThought(String sessionId, RetroThought thought) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .doc(thought.id)
          .update(thought.toJson());
    } catch (e) {
      debugPrint('Error in updateThought: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteThought(String sessionId, String thoughtId) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_thoughtsCollection)
          .doc(thoughtId)
          .delete();
    } catch (e) {
      debugPrint('Error in deleteThought: $e');
      rethrow;
    }
  }

  // Phase management
  @override
  Future<void> updateSessionPhase(String sessionId, RetroPhase phase) async {
    try {
      await _firestore.collection(_sessionsCollection).doc(sessionId).update({
        'currentPhase': phase.name,
      });
    } catch (e) {
      debugPrint('Error in updateSessionPhase: $e');
      rethrow;
    }
  }

  // Group management
  @override
  Future<void> addGroup(String sessionId, ThoughtGroup group) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .doc(group.id)
          .set(group.toJson());
    } catch (e) {
      debugPrint('Error in addGroup: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSessionGroups(String sessionId, List<ThoughtGroup> groups) async {
    try {
      final batch = _firestore.batch();
      final groupsRef = _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups');

      // Clear existing groups
      final existingGroups = await groupsRef.get();
      for (final doc in existingGroups.docs) {
        batch.delete(doc.reference);
      }

      // Add new groups
      for (final group in groups) {
        batch.set(groupsRef.doc(group.id), group.toJson());
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error in updateSessionGroups: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGroupPosition(String sessionId, String groupId, double x, double y) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .doc(groupId)
          .update({
        'x': x,
        'y': y,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error in updateGroupPosition: $e');
      rethrow;
    }
  }

  @override
  Future<void> mergeGroups(String sessionId, String targetGroupId, String sourceGroupId) async {
    try {
      final batch = _firestore.batch();
      final groupsRef = _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups');

      // Get both groups
      final targetDoc = await groupsRef.doc(targetGroupId).get();
      final sourceDoc = await groupsRef.doc(sourceGroupId).get();

      if (!targetDoc.exists || !sourceDoc.exists) {
        throw Exception('One or both groups do not exist');
      }

      final targetGroup = ThoughtGroup.fromJson(targetDoc.data()!);
      final sourceGroup = ThoughtGroup.fromJson(sourceDoc.data()!);

      // Merge thoughts
      final mergedThoughts = [...targetGroup.thoughts, ...sourceGroup.thoughts];
      final updatedGroup = targetGroup.copyWith(
        thoughts: mergedThoughts,
        updatedAt: DateTime.now(),
      );

      // Update target group and delete source group
      batch.set(groupsRef.doc(targetGroupId), updatedGroup.toJson());
      batch.delete(groupsRef.doc(sourceGroupId));

      await batch.commit();
    } catch (e) {
      debugPrint('Error in mergeGroups: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGroupName(String sessionId, String groupId, String newName) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .doc(groupId)
          .update({
        'name': newName,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error in updateGroupName: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearGroups(String sessionId) async {
    try {
      final groupsSnapshot = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .get();

      final batch = _firestore.batch();
      for (final doc in groupsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error in clearGroups: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ThoughtGroup>> getSessionGroups(String sessionId) {
    return _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .collection('groups')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ThoughtGroup.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList();
        });
  }

  // Voting management
  @override
  Future<void> updateUserVotes(String sessionId, Map<String, int> userVotes) async {
    try {
      await _firestore.collection(_sessionsCollection).doc(sessionId).update({
        'userVotes': userVotes,
      });
    } catch (e) {
      debugPrint('Error in updateUserVotes: $e');
      rethrow;
    }
  }

  @override
  Future<void> voteForGroup(String sessionId, String groupId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Update group votes
      final groupRef = _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .doc(groupId);

      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) {
        throw Exception('Group does not exist');
      }

      final group = ThoughtGroup.fromJson(groupDoc.data()!);
      final updatedGroup = group.addVote(userId);

      batch.set(groupRef, updatedGroup.toJson());

      // Update user remaining votes
      final sessionRef = _firestore.collection(_sessionsCollection).doc(sessionId);
      final sessionDoc = await sessionRef.get();
      final sessionData = sessionDoc.data();
      final userVotes = Map<String, int>.from(sessionData?['userVotes'] ?? {});
      final currentVotes = userVotes[userId] ?? 3;
      userVotes[userId] = currentVotes > 0 ? currentVotes - 1 : 0;

      batch.update(sessionRef, {'userVotes': userVotes});

      await batch.commit();
    } catch (e) {
      debugPrint('Error in voteForGroup: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeVoteFromGroup(String sessionId, String groupId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Update group votes
      final groupRef = _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection('groups')
          .doc(groupId);

      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) {
        throw Exception('Group does not exist');
      }

      final group = ThoughtGroup.fromJson(groupDoc.data()!);
      if (!group.hasUserVoted(userId)) {
        throw Exception('User has not voted for this group');
      }

      final updatedGroup = group.removeVote(userId);
      batch.set(groupRef, updatedGroup.toJson());

      // Update user remaining votes
      final sessionRef = _firestore.collection(_sessionsCollection).doc(sessionId);
      final sessionDoc = await sessionRef.get();
      final sessionData = sessionDoc.data();
      final userVotes = Map<String, int>.from(sessionData?['userVotes'] ?? {});
      final currentVotes = userVotes[userId] ?? 0;
      userVotes[userId] = currentVotes + 1;

      batch.update(sessionRef, {'userVotes': userVotes});

      await batch.commit();
    } catch (e) {
      debugPrint('Error in removeVoteFromGroup: $e');
      rethrow;
    }
  }

  // Discussion management
  @override
  Future<void> updateDiscussionGroupIndex(String sessionId, int index) async {
    try {
      await _firestore.collection(_sessionsCollection).doc(sessionId).update({
        'currentDiscussionGroupIndex': index,
      });
    } catch (e) {
      debugPrint('Error in updateDiscussionGroupIndex: $e');
      rethrow;
    }
  }
}


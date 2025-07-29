import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/retro_thought.dart';
import '../domain/retro_session.dart';
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
      final thoughtsRef = sessionRef.collection(_thoughtsCollection);
      await thoughtsRef.add({
        'content': 'Welcome to your new retro session!',
        'category': 'Start',
        'authorId': creatorId,
        'authorName': 'System',
        'timestamp': now.toIso8601String(),
      });
      
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

  @override
  Stream<List<RetroSession>> getUserSessions(String userId) {
    return _firestore
        .collection(_sessionsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RetroSession.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList();
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
}


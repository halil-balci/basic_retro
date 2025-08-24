import 'package:flutter/foundation.dart';
import '../domain/retro_thought.dart';
import '../domain/retro_session.dart';
import '../domain/retro_phase.dart';
import '../domain/thought_group.dart';
import '../domain/i_retro_repository.dart';
import '../../../core/constants/retro_constants.dart';

class RetroViewModel extends ChangeNotifier {
  final IRetroRepository _repository;
  late final String _currentUserId;
  late final String _currentUserName;
  
  List<RetroSession> _userSessions = [];
  List<RetroSession> get userSessions => _userSessions;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;
  
  RetroSession? _currentSession;
  RetroSession? get currentSession => _currentSession;

  Map<String, List<RetroThought>> _thoughtsByCategory = RetroConstants.createEmptyCategoryMap<RetroThought>();
  Map<String, List<RetroThought>> get thoughtsByCategory => _thoughtsByCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RetroViewModel(this._repository) {
    // Initialize user info from storage or create new
    _initializeUserInfo();
    _loadUserSessions();
  }

  List<RetroThought> get thoughts {
    // Return all thoughts from all categories
    final allThoughts = <RetroThought>[];
    for (final categoryThoughts in _thoughtsByCategory.values) {
      allThoughts.addAll(categoryThoughts);
    }
    return allThoughts;
  }

  void _initializeUserInfo() {
    // In a real app, you would get this from SharedPreferences or secure storage
    _currentUserId = _loadOrGenerateUserId();
    _currentUserName = _loadOrGenerateUsername();
  }

  String _loadOrGenerateUserId() {
    // TODO: Load from persistent storage
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _loadOrGenerateUsername() {
    // TODO: Load from persistent storage
    return 'User${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  void _loadUserSessions() {
    _repository.getUserSessions(_currentUserId).listen((sessions) {
      _userSessions = sessions;
      notifyListeners();
    });
  }

  Future<RetroSession?> createSession(String name) async {
    _setLoading(true);
    try {
      final session = await _repository.createSession(name, _currentUserId);
      _currentSessionId = session.id;
      _currentSession = session;
      
      // Add the new session to the list immediately
      _userSessions = [session, ..._userSessions];
      
      // Start listening to thought updates immediately
      _clearThoughts();
      _subscribeToSessionUpdates();
      notifyListeners();
      
      return session;
    } catch (e) {
      debugPrint('Error creating session: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinSession(String sessionName) async {
    _setLoading(true);
    try {
      debugPrint('Attempting to join session by name: $sessionName');
      
      // Get all sessions and find the one matching the name
      final sessions = await _repository.getAllSessions();
      RetroSession? foundSession;
      
      try {
        foundSession = sessions.firstWhere(
          (s) => s.name.toLowerCase() == sessionName.toLowerCase(),
        );
      } on StateError {
        debugPrint('Session with name "$sessionName" not found');
        return false;
      }
      
      await _repository.joinSession(foundSession.id, _currentUserId, _currentUserName);
      _currentSessionId = foundSession.id;
      _currentSession = foundSession;
      
      // Add session to user's sessions if not already present
      if (!_userSessions.any((s) => s.id == foundSession?.id)) {
        final List<RetroSession> updatedSessions = List.from(_userSessions);
        updatedSessions.insert(0, foundSession);
        _userSessions = updatedSessions;
      }
      
      // Start listening to thought updates
      _subscribeToSessionUpdates();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error joining session: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void selectSession(String sessionId) async {
    debugPrint('Selecting session: $sessionId');
    if (_currentSessionId != sessionId) {
      _setLoading(true);
      try {
        // First leave the current session if any
        if (_currentSessionId != null) {
          await _repository.leaveSession(_currentSessionId!, _currentUserId);
        }

        final session = await _repository.getSession(sessionId);
        if (session != null) {
          _currentSessionId = sessionId;
          _currentSession = session;
          
          // Join the new session as an active user
          await _repository.joinSession(sessionId, _currentUserId, _currentUserName);
          
          _clearThoughts();
          _subscribeToSessionUpdates();
          
          // Manually trigger a notification to ensure UI updates
          notifyListeners();
        } else {
          debugPrint('Session not found: $sessionId');
        }
      } catch (e) {
        debugPrint('Error selecting session: $e');
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> addThought(String content, String category) async {
    if (_currentSessionId == null) {
      debugPrint('No session selected');
      throw Exception('No session selected');
    }

    if (content.trim().isEmpty) {
      throw Exception('Thought content cannot be empty');
    }

    _setLoading(true);
    try {
      debugPrint('Adding thought to session: $_currentSessionId');
      final thought = RetroThought(
        id: '', // Will be set by Firebase
        content: content.trim(),
        authorId: _currentUserId,
        authorName: _currentUserName,
        timestamp: DateTime.now(),
        category: category,
      );

      await _repository.addThought(_currentSessionId!, thought);
      debugPrint('Thought added successfully');
    } catch (e) {
      debugPrint('Error adding thought: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _subscribeToSessionUpdates() {
    if (_currentSessionId != null) {
      debugPrint('Subscribing to thoughts for session: $_currentSessionId');
      
      // Clear existing thoughts before subscribing
      _clearThoughts();
      notifyListeners();
      
      _repository.getSessionThoughts(_currentSessionId!).listen(
        (thoughts) {
          debugPrint('Received ${thoughts.length} thoughts');
          if (_currentSessionId != null) {
            // Sort thoughts by timestamp before updating
            thoughts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            _updateThoughtsByCategory(thoughts);
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Error loading thoughts: $error');
          _clearThoughts();
          notifyListeners();
        },
      );

      // Subscribe to session changes for real-time phase updates
      _subscribeToSessionChanges();

      // Subscribe to groups if we have the method available
      try {
        _repository.getSessionGroups(_currentSessionId!).listen(
          (groups) {
            debugPrint('Received ${groups.length} groups from subscription');
            if (_currentSessionId != null && _currentSession != null) {
              _currentSession = _currentSession!.copyWith(groups: groups);
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('Error loading groups: $error');
          },
        );
      } catch (e) {
        debugPrint('Groups subscription not available: $e');
      }
    }
  }

  void _subscribeToSessionChanges() {
    if (_currentSessionId == null) return;
    
    // Listen to session document changes for phase updates
    _repository.getSessionStream(_currentSessionId!).listen(
      (session) {
        if (session != null && _currentSessionId != null) {
          final oldPhase = _currentSession?.currentPhase;
          
          // Preserve existing groups when updating session
          final existingGroups = _currentSession?.groups ?? [];
          _currentSession = session.copyWith(groups: existingGroups);
          
          // If phase changed, notify listeners
          if (oldPhase != session.currentPhase) {
            debugPrint('Phase changed from $oldPhase to ${session.currentPhase}');
          }
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Error loading session updates: $error');
      },
    );
  }

  void _updateThoughtsByCategory(List<RetroThought> thoughts) {
    final newThoughtsByCategory = RetroConstants.createEmptyCategoryMap<RetroThought>();

    for (final thought in thoughts) {
      if (newThoughtsByCategory.containsKey(thought.category)) {
        newThoughtsByCategory[thought.category]!.add(thought);
      }
    }

    _thoughtsByCategory = newThoughtsByCategory;
    
    // Also update the current session's thoughts list
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(thoughts: thoughts);
    }
  }

  void _clearThoughts() {
    _thoughtsByCategory = RetroConstants.createEmptyCategoryMap<RetroThought>();
  }

  Future<void> leaveSession() async {
    if (_currentSessionId != null) {
      try {
        await _repository.leaveSession(_currentSessionId!, _currentUserId);
      } catch (e) {
        debugPrint('Error leaving session: $e');
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleLike(String id) {}

  void addComment(String id, String text) {}

  // Phase Management
  Future<void> advancePhase() async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    if (!_currentSession!.canAdvancePhase) {
      throw Exception('Cannot advance phase: conditions not met');
    }

    final nextPhase = _currentSession!.nextPhase;
    
    try {
      await _repository.updateSessionPhase(_currentSessionId!, nextPhase);
      
      // If advancing to voting phase, initialize user votes and ensure groups exist
      if (nextPhase == RetroPhase.voting) {
        await _initializeUserVotes();
        // If no groups exist, create them from thoughts
        if (currentGroups.isEmpty) {
          await _createInitialGroups();
        }
      }
      
      // If advancing to discuss phase, ensure groups exist and reset discussion index
      if (nextPhase == RetroPhase.discuss) {
        // If no groups exist, create them from thoughts
        if (currentGroups.isEmpty) {
          await _createInitialGroups();
        }
        // Reset discussion group index to 0
        await _repository.updateDiscussionGroupIndex(_currentSessionId!, 0);
      }
      
      // If advancing to grouping phase, create initial groups from thoughts
      if (nextPhase == RetroPhase.grouping) {
        await _createInitialGroups();
      }
      
    } catch (e) {
      debugPrint('Error advancing phase: $e');
      rethrow;
    }
  }

  Future<void> _initializeUserVotes() async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    final userVotes = <String, int>{};
    for (final userId in _currentSession!.activeUsers.keys) {
      userVotes[userId] = 3; // Each user gets 3 votes
    }
    
    await _repository.updateUserVotes(_currentSessionId!, userVotes);
  }

  Future<void> _createInitialGroups() async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    final groups = <ThoughtGroup>[];
    int groupIndex = 0;
    
    // Get all thoughts from _thoughtsByCategory instead of _currentSession.thoughts
    final allThoughts = <RetroThought>[];
    for (final categoryThoughts in _thoughtsByCategory.values) {
      allThoughts.addAll(categoryThoughts);
    }
    
    // Create individual groups for each thought initially
    for (final thought in allThoughts) {
      final group = ThoughtGroup(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}_$groupIndex',
        name: 'Group ${groupIndex + 1}',
        thoughts: [thought],
        sessionId: _currentSessionId!,
        x: (groupIndex % 3) * 200.0, // Spread them out
        y: (groupIndex ~/ 3) * 150.0,
      );
      groups.add(group);
      groupIndex++;
    }
    
    await _repository.updateSessionGroups(_currentSessionId!, groups);
  }

  // Group Management
  Future<void> createGroup(String name, List<RetroThought> thoughts, double x, double y) async {
    if (_currentSessionId == null) return;
    
    final group = ThoughtGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      thoughts: thoughts,
      sessionId: _currentSessionId!,
      x: x,
      y: y,
    );
    
    await _repository.addGroup(_currentSessionId!, group);
  }

  Future<void> updateGroupPosition(String groupId, double x, double y) async {
    if (_currentSessionId == null) return;
    await _repository.updateGroupPosition(_currentSessionId!, groupId, x, y);
  }

  Future<void> mergeGroups(String targetGroupId, String sourceGroupId) async {
    if (_currentSessionId == null) return;
    await _repository.mergeGroups(_currentSessionId!, targetGroupId, sourceGroupId);
  }

  Future<void> updateGroupName(String groupId, String newName) async {
    if (_currentSessionId == null) return;
    await _repository.updateGroupName(_currentSessionId!, groupId, newName);
  }

  Future<void> clearGroups() async {
    if (_currentSessionId == null) return;
    await _repository.clearGroups(_currentSessionId!);
  }

  // Initialize groups from thoughts (for grouping phase)
  Future<void> initializeGroupsFromThoughts() async {
    if (_currentSessionId == null) return;
    
    // Clear existing groups first
    await clearGroups();
    
    final allThoughts = <RetroThought>[];
    for (final categoryThoughts in _thoughtsByCategory.values) {
      allThoughts.addAll(categoryThoughts);
    }
    
    // Create a group for each thought
    for (int i = 0; i < allThoughts.length; i++) {
      final thought = allThoughts[i];
      final group = ThoughtGroup(
        id: 'group_${thought.id}',
        name: 'Item ${i + 1}',
        thoughts: [thought],
        sessionId: _currentSessionId!,
        x: (i % 3) * 220.0 + 20,
        y: (i ~/ 3) * 160.0 + 20,
      );
      
      await _repository.addGroup(_currentSessionId!, group);
    }
  }

  // Voting Management
  Future<void> voteForGroup(String groupId) async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    final remainingVotes = _currentSession!.getUserRemainingVotes(_currentUserId);
    if (remainingVotes <= 0) {
      throw Exception('No votes remaining');
    }
    
    await _repository.voteForGroup(_currentSessionId!, groupId, _currentUserId);
  }

  Future<void> removeVoteFromGroup(String groupId) async {
    if (_currentSessionId == null) return;
    await _repository.removeVoteFromGroup(_currentSessionId!, groupId, _currentUserId);
  }

  // Discussion Management
  Future<void> nextDiscussionGroup() async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    final sorted = _currentSession!.sortedGroupsByVotes;
    final nextIndex = _currentSession!.currentDiscussionGroupIndex + 1;
    
    debugPrint('nextDiscussionGroup: current index = ${_currentSession!.currentDiscussionGroupIndex}, next index = $nextIndex, total groups = ${sorted.length}');
    
    if (nextIndex < sorted.length) {
      await _repository.updateDiscussionGroupIndex(_currentSessionId!, nextIndex);
    } else {
      debugPrint('Cannot advance: nextIndex ($nextIndex) >= sorted.length (${sorted.length})');
    }
  }

  Future<void> previousDiscussionGroup() async {
    if (_currentSessionId == null || _currentSession == null) return;
    
    final prevIndex = _currentSession!.currentDiscussionGroupIndex - 1;
    
    debugPrint('previousDiscussionGroup: current index = ${_currentSession!.currentDiscussionGroupIndex}, prev index = $prevIndex');
    
    if (prevIndex >= 0) {
      await _repository.updateDiscussionGroupIndex(_currentSessionId!, prevIndex);
    } else {
      debugPrint('Cannot go back: prevIndex ($prevIndex) < 0');
    }
  }

  // Getters for UI
  bool get canAdvancePhase => _currentSession?.canAdvancePhase ?? false;
  RetroPhase get currentPhase => _currentSession?.currentPhase ?? RetroPhase.editing;
  List<ThoughtGroup> get currentGroups => _currentSession?.groups ?? [];
  List<ThoughtGroup> get sortedGroupsByVotes => _currentSession?.sortedGroupsByVotes ?? [];
  ThoughtGroup? get currentDiscussionGroup => _currentSession?.currentDiscussionGroup;
  
  int getUserRemainingVotes() {
    return _currentSession?.getUserRemainingVotes(_currentUserId) ?? 3;
  }

  bool shouldBlurThought(RetroThought thought) {
    return currentPhase == RetroPhase.editing && thought.authorId != _currentUserId;
  }

  String getCurrentUserId() {
    return _currentUserId;
  }
}

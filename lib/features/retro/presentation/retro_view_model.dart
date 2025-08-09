import 'package:flutter/foundation.dart';
import '../domain/retro_thought.dart';
import '../domain/retro_session.dart';
import '../domain/i_retro_repository.dart';

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

  Map<String, List<RetroThought>> _thoughtsByCategory = {
    'Sad': [],
    'Mad': [],
    'Glad': [],
  };
  Map<String, List<RetroThought>> get thoughtsByCategory => _thoughtsByCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RetroViewModel(this._repository) {
    // Initialize user info from storage or create new
    _initializeUserInfo();
    _loadUserSessions();
  }

  get thoughts => null;

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
    }
  }

  void _updateThoughtsByCategory(List<RetroThought> thoughts) {
    final newThoughtsByCategory = {
      'Sad': <RetroThought>[],
      'Mad': <RetroThought>[],
      'Glad': <RetroThought>[],
    };

    for (final thought in thoughts) {
      if (newThoughtsByCategory.containsKey(thought.category)) {
        newThoughtsByCategory[thought.category]!.add(thought);
      }
    }

    _thoughtsByCategory = newThoughtsByCategory;
  }

  void _clearThoughts() {
    _thoughtsByCategory = {
      'Sad': [],
      'Mad': [],
      'Glad': [],
    };
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
}

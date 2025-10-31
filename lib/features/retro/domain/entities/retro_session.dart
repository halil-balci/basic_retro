import 'retro_thought.dart';
import 'retro_phase.dart';
import 'thought_group.dart';
import '../../../../core/constants/retro_constants.dart';

class RetroSession {
  final String id;
  final String name;
  final String creatorId;
  final DateTime createdAt;
  final List<String> participants;
  final Map<String, String> activeUsers; // Tracks currently active users with their names
  final bool isActive;
  final List<String> columns;
  final List<RetroThought> thoughts;
  final RetroPhase currentPhase;
  final List<ThoughtGroup> groups;
  final Map<String, int> userVotes; // userId -> remaining votes
  final int currentDiscussionGroupIndex;

  RetroSession({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.createdAt,
    this.participants = const [],
    this.activeUsers = const {},
    this.isActive = true,
    this.columns = RetroConstants.categories,
    this.thoughts = const [],
    this.currentPhase = RetroPhase.editing,
    this.groups = const [],
    this.userVotes = const {},
    this.currentDiscussionGroupIndex = 0,
  });

  factory RetroSession.fromJson(Map<String, dynamic> json) {
    return RetroSession(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      participants: List<String>.from(json['participants'] ?? []),
      activeUsers: Map<String, String>.from(json['activeUsers'] ?? {}),
      isActive: json['isActive'] as bool? ?? true,
      columns: List<String>.from(json['columns'] ?? RetroConstants.categories),
      thoughts: (json['thoughts'] as List<dynamic>?)
          ?.map((e) => RetroThought.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      currentPhase: RetroPhase.fromString(json['currentPhase'] as String? ?? 'editing'),
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => ThoughtGroup.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      userVotes: Map<String, int>.from(json['userVotes'] ?? {}),
      currentDiscussionGroupIndex: json['currentDiscussionGroupIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'activeUsers': activeUsers,
      'isActive': isActive,
      'columns': columns,
      'thoughts': thoughts.map((t) => t.toJson()).toList(),
      'currentPhase': currentPhase.name,
      'groups': groups.map((g) => g.toJson()).toList(),
      'userVotes': userVotes,
      'currentDiscussionGroupIndex': currentDiscussionGroupIndex,
    };
  }

  RetroSession copyWith({
    List<RetroThought>? thoughts,
    RetroPhase? currentPhase,
    List<ThoughtGroup>? groups,
    Map<String, int>? userVotes,
    int? currentDiscussionGroupIndex,
    Map<String, String>? activeUsers,
  }) {
    return RetroSession(
      id: id,
      name: name,
      creatorId: creatorId,
      createdAt: createdAt,
      participants: participants,
      activeUsers: activeUsers ?? this.activeUsers,
      isActive: isActive,
      columns: columns,
      thoughts: thoughts ?? this.thoughts,
      currentPhase: currentPhase ?? this.currentPhase,
      groups: groups ?? this.groups,
      userVotes: userVotes ?? this.userVotes,
      currentDiscussionGroupIndex: currentDiscussionGroupIndex ?? this.currentDiscussionGroupIndex,
    );
  }

  // Helper methods
  bool get canAdvancePhase {
    switch (currentPhase) {
      case RetroPhase.editing:
        return thoughts.isNotEmpty;
      case RetroPhase.grouping:
        return groups.isNotEmpty;
      case RetroPhase.voting:
        return groups.any((g) => g.votes > 0);
      case RetroPhase.discuss:
        // Son grup tartışılırken (index == length - 1) ve en az bir grup varsa finish'e geçilebilir
        return sortedGroupsByVotes.isNotEmpty && currentDiscussionGroupIndex == sortedGroupsByVotes.length - 1;
      case RetroPhase.finish:
        return false;
    }
  }

  RetroPhase get nextPhase {
    switch (currentPhase) {
      case RetroPhase.editing:
        return RetroPhase.grouping;
      case RetroPhase.grouping:
        return RetroPhase.voting;
      case RetroPhase.voting:
        return RetroPhase.discuss;
      case RetroPhase.discuss:
        return RetroPhase.finish;
      case RetroPhase.finish:
        return RetroPhase.finish;
    }
  }

  List<ThoughtGroup> get sortedGroupsByVotes {
    final sortedGroups = List<ThoughtGroup>.from(groups);
    sortedGroups.sort((a, b) => b.votes.compareTo(a.votes));
    return sortedGroups;
  }

  ThoughtGroup? get currentDiscussionGroup {
    final sorted = sortedGroupsByVotes;
    if (currentDiscussionGroupIndex < sorted.length && currentDiscussionGroupIndex >= 0) {
      final group = sorted[currentDiscussionGroupIndex];
      return group;
    }
    return null;
  }

  int getUserRemainingVotes(String userId) {
    return userVotes[userId] ?? RetroConstants.maxVotesPerUser; // Default votes per user from constants
  }
}

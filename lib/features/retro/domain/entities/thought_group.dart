import 'retro_thought.dart';

class ThoughtGroup {
  final String id;
  final String name;
  final List<RetroThought> thoughts;
  final String color;
  final double x;
  final double y;
  final int votes;
  final Map<String, int> voterIds; // userId -> vote count
  final String sessionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ThoughtGroup({
    required this.id,
    required this.name,
    required this.thoughts,
    this.color = '#E3F2FD',
    this.x = 0.0,
    this.y = 0.0,
    this.votes = 0,
    this.voterIds = const {},
    required this.sessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ThoughtGroup.fromJson(Map<String, dynamic> json) {
    return ThoughtGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      thoughts: (json['thoughts'] as List<dynamic>?)
          ?.map((e) => RetroThought.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      color: json['color'] as String? ?? '#E3F2FD',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      votes: json['votes'] as int? ?? 0,
      voterIds: Map<String, int>.from(json['voterIds'] ?? {}),
      sessionId: json['sessionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thoughts': thoughts.map((t) => t.toJson()).toList(),
      'color': color,
      'x': x,
      'y': y,
      'votes': votes,
      'voterIds': voterIds,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ThoughtGroup copyWith({
    String? id,
    String? name,
    List<RetroThought>? thoughts,
    String? color,
    double? x,
    double? y,
    int? votes,
    Map<String, int>? voterIds,
    String? sessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThoughtGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      thoughts: thoughts ?? this.thoughts,
      color: color ?? this.color,
      x: x ?? this.x,
      y: y ?? this.y,
      votes: votes ?? this.votes,
      voterIds: voterIds ?? this.voterIds,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if user has voted
  bool hasUserVoted(String userId) {
    return voterIds.containsKey(userId);
  }

  // Helper method to get user's vote count
  int getUserVoteCount(String userId) {
    return voterIds[userId] ?? 0;
  }

  // Helper method to add vote
  ThoughtGroup addVote(String userId) {
    final newVoterIds = Map<String, int>.from(voterIds);
    final currentVotes = newVoterIds[userId] ?? 0;
    newVoterIds[userId] = currentVotes + 1;
    
    return copyWith(
      votes: votes + 1,
      voterIds: newVoterIds,
      updatedAt: DateTime.now(),
    );
  }

  // Helper method to remove vote
  ThoughtGroup removeVote(String userId) {
    final newVoterIds = Map<String, int>.from(voterIds);
    final currentVotes = newVoterIds[userId] ?? 0;
    
    if (currentVotes > 1) {
      newVoterIds[userId] = currentVotes - 1;
    } else {
      newVoterIds.remove(userId);
    }
    
    return copyWith(
      votes: votes > 0 ? votes - 1 : 0,
      voterIds: newVoterIds,
      updatedAt: DateTime.now(),
    );
  }
}

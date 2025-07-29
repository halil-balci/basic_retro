import 'retro_thought.dart';

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

  RetroSession({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.createdAt,
    this.participants = const [],
    this.activeUsers = const {},
    this.isActive = true,
    this.columns = const ['Start', 'Stop', 'Continue'],
    this.thoughts = const [],
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
      columns: List<String>.from(json['columns'] ?? ['Start', 'Stop', 'Continue']),
      thoughts: (json['thoughts'] as List<dynamic>?)
          ?.map((e) => RetroThought.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'isActive': isActive,
      'columns': columns,
      'thoughts': thoughts.map((t) => t.toJson()).toList(),
    };
  }

  RetroSession copyWith({List<RetroThought>? thoughts}) {
    return RetroSession(
      id: id,
      name: name,
      creatorId: creatorId,
      createdAt: createdAt,
      participants: participants,
      isActive: isActive,
      columns: columns,
      thoughts: thoughts ?? this.thoughts,
    );
  }
}

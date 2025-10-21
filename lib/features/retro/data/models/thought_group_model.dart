import '../../domain/entities/thought_group.dart';
import 'retro_thought_model.dart';

/// Data model for ThoughtGroup with JSON serialization
class ThoughtGroupModel extends ThoughtGroup {
  ThoughtGroupModel({
    required super.id,
    required super.name,
    required super.thoughts,
    super.color,
    super.x,
    super.y,
    super.votes,
    super.voterIds,
    required super.sessionId,
    super.createdAt,
    super.updatedAt,
  });

  factory ThoughtGroupModel.fromEntity(ThoughtGroup entity) {
    return ThoughtGroupModel(
      id: entity.id,
      name: entity.name,
      thoughts: entity.thoughts,
      color: entity.color,
      x: entity.x,
      y: entity.y,
      votes: entity.votes,
      voterIds: entity.voterIds,
      sessionId: entity.sessionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory ThoughtGroupModel.fromJson(Map<String, dynamic> json) {
    return ThoughtGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      thoughts: (json['thoughts'] as List<dynamic>?)
          ?.map((e) => RetroThoughtModel.fromJson(e as Map<String, dynamic>).toEntity())
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
      'thoughts': thoughts.map((t) => RetroThoughtModel.fromEntity(t).toJson()).toList(),
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

  ThoughtGroup toEntity() {
    return ThoughtGroup(
      id: id,
      name: name,
      thoughts: thoughts,
      color: color,
      x: x,
      y: y,
      votes: votes,
      voterIds: voterIds,
      sessionId: sessionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

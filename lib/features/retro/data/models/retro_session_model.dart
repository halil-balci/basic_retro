import '../../domain/entities/retro_session.dart';
import '../../domain/entities/retro_phase.dart';
import '../../../../core/constants/retro_constants.dart';
import 'retro_thought_model.dart';
import 'thought_group_model.dart';

/// Data model for RetroSession with JSON serialization
class RetroSessionModel extends RetroSession {
  RetroSessionModel({
    required super.id,
    required super.name,
    required super.creatorId,
    required super.createdAt,
    super.participants,
    super.activeUsers,
    super.isActive,
    super.columns,
    super.thoughts,
    super.currentPhase,
    super.groups,
    super.userVotes,
    super.currentDiscussionGroupIndex,
  });

  factory RetroSessionModel.fromEntity(RetroSession entity) {
    return RetroSessionModel(
      id: entity.id,
      name: entity.name,
      creatorId: entity.creatorId,
      createdAt: entity.createdAt,
      participants: entity.participants,
      activeUsers: entity.activeUsers,
      isActive: entity.isActive,
      columns: entity.columns,
      thoughts: entity.thoughts,
      currentPhase: entity.currentPhase,
      groups: entity.groups,
      userVotes: entity.userVotes,
      currentDiscussionGroupIndex: entity.currentDiscussionGroupIndex,
    );
  }

  factory RetroSessionModel.fromJson(Map<String, dynamic> json) {
    return RetroSessionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      participants: List<String>.from(json['participants'] ?? []),
      activeUsers: Map<String, String>.from(json['activeUsers'] ?? {}),
      isActive: json['isActive'] as bool? ?? true,
      columns: List<String>.from(json['columns'] ?? RetroConstants.categories),
      thoughts: (json['thoughts'] as List<dynamic>?)
          ?.map((e) => RetroThoughtModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList() ?? [],
      currentPhase: RetroPhase.fromString(json['currentPhase'] as String? ?? 'editing'),
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => ThoughtGroupModel.fromJson(e as Map<String, dynamic>).toEntity())
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
      'thoughts': thoughts.map((t) => RetroThoughtModel.fromEntity(t).toJson()).toList(),
      'currentPhase': currentPhase.name,
      'groups': groups.map((g) => ThoughtGroupModel.fromEntity(g).toJson()).toList(),
      'userVotes': userVotes,
      'currentDiscussionGroupIndex': currentDiscussionGroupIndex,
    };
  }

  RetroSession toEntity() {
    return RetroSession(
      id: id,
      name: name,
      creatorId: creatorId,
      createdAt: createdAt,
      participants: participants,
      activeUsers: activeUsers,
      isActive: isActive,
      columns: columns,
      thoughts: thoughts,
      currentPhase: currentPhase,
      groups: groups,
      userVotes: userVotes,
      currentDiscussionGroupIndex: currentDiscussionGroupIndex,
    );
  }
}

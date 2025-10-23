import '../../domain/entities/action_item.dart';

/// Data model for ActionItem
class ActionItemModel {
  final String id;
  final String groupId;
  final String content;
  final String? assignee;

  const ActionItemModel({
    required this.id,
    required this.groupId,
    required this.content,
    this.assignee,
  });

  /// Convert model to entity
  ActionItem toEntity() {
    return ActionItem(
      id: id,
      groupId: groupId,
      content: content,
      assignee: assignee,
    );
  }

  /// Create model from entity
  factory ActionItemModel.fromEntity(ActionItem entity) {
    return ActionItemModel(
      id: entity.id,
      groupId: entity.groupId,
      content: entity.content,
      assignee: entity.assignee,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'content': content,
      'assignee': assignee,
    };
  }

  /// Create from Firebase JSON
  factory ActionItemModel.fromJson(Map<String, dynamic> json, String id) {
    return ActionItemModel(
      id: id,
      groupId: json['groupId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      assignee: json['assignee'] as String?,
    );
  }

  ActionItemModel copyWith({
    String? id,
    String? groupId,
    String? content,
    String? assignee,
  }) {
    return ActionItemModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      assignee: assignee ?? this.assignee,
    );
  }
}

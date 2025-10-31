import '../../domain/entities/action_item.dart';

/// Data model for ActionItem
class ActionItemModel {
  final String id;
  final String content;
  final String? assignee;
  final DateTime createdAt;

  const ActionItemModel({
    required this.id,
    required this.content,
    this.assignee,
    required this.createdAt,
  });

  /// Convert model to entity
  ActionItem toEntity() {
    return ActionItem(
      id: id,
      content: content,
      assignee: assignee,
      createdAt: createdAt,
    );
  }

  /// Create model from entity
  factory ActionItemModel.fromEntity(ActionItem entity) {
    return ActionItemModel(
      id: entity.id,
      content: entity.content,
      assignee: entity.assignee,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'assignee': assignee,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create from Firebase JSON
  factory ActionItemModel.fromJson(Map<String, dynamic> json, String id) {
    return ActionItemModel(
      id: id,
      content: json['content'] as String? ?? '',
      assignee: json['assignee'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
    );
  }

  ActionItemModel copyWith({
    String? id,
    String? content,
    String? assignee,
    DateTime? createdAt,
  }) {
    return ActionItemModel(
      id: id ?? this.id,
      content: content ?? this.content,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

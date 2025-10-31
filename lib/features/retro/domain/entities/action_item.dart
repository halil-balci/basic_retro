/// Represents an action item created during the discussion phase
class ActionItem {
  final String id;
  final String content;
  final String? assignee; // Optional: who is responsible
  final DateTime createdAt; // Timestamp for ordering

  const ActionItem({
    required this.id,
    required this.content,
    this.assignee,
    required this.createdAt,
  });

  ActionItem copyWith({
    String? id,
    String? content,
    String? assignee,
    DateTime? createdAt,
  }) {
    return ActionItem(
      id: id ?? this.id,
      content: content ?? this.content,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'assignee': assignee,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ActionItem.fromJson(Map<String, dynamic> json, String id) {
    return ActionItem(
      id: id,
      content: json['content'] as String? ?? '',
      assignee: json['assignee'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          assignee == other.assignee &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      (assignee?.hashCode ?? 0) ^
      createdAt.hashCode;
}

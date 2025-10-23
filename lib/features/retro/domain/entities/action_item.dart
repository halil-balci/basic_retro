/// Represents an action item created during the discussion phase
class ActionItem {
  final String id;
  final String groupId; // Associated group ID
  final String content;
  final String? assignee; // Optional: who is responsible

  const ActionItem({
    required this.id,
    required this.groupId,
    required this.content,
    this.assignee,
  });

  ActionItem copyWith({
    String? id,
    String? groupId,
    String? content,
    String? assignee,
  }) {
    return ActionItem(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      assignee: assignee ?? this.assignee,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'content': content,
      'assignee': assignee,
    };
  }

  factory ActionItem.fromJson(Map<String, dynamic> json, String id) {
    return ActionItem(
      id: id,
      groupId: json['groupId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      assignee: json['assignee'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          content == other.content &&
          assignee == other.assignee;

  @override
  int get hashCode =>
      id.hashCode ^
      groupId.hashCode ^
      content.hashCode ^
      (assignee?.hashCode ?? 0);
}

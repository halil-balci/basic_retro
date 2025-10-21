import '../../domain/entities/retro_thought.dart';

/// Data model for RetroThought with JSON serialization
class RetroThoughtModel extends RetroThought {
  RetroThoughtModel({
    required super.id,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.timestamp,
    required super.category,
    super.comments,
    super.likes,
  });

  factory RetroThoughtModel.fromEntity(RetroThought entity) {
    return RetroThoughtModel(
      id: entity.id,
      content: entity.content,
      authorId: entity.authorId,
      authorName: entity.authorName,
      timestamp: entity.timestamp,
      category: entity.category,
      comments: entity.comments,
      likes: entity.likes,
    );
  }

  factory RetroThoughtModel.fromJson(Map<String, dynamic> json) {
    return RetroThoughtModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      timestamp: json['timestamp'] is String 
        ? DateTime.parse(json['timestamp']) 
        : DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? 0),
      category: json['category'] as String? ?? 'Sad',
      comments: json['comments'] != null 
        ? List<String>.from(json['comments']) 
        : const [],
      likes: json['likes'] != null 
        ? List<String>.from(json['likes']) 
        : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'comments': comments,
      'likes': likes,
    };
  }

  RetroThought toEntity() {
    return RetroThought(
      id: id,
      content: content,
      authorId: authorId,
      authorName: authorName,
      timestamp: timestamp,
      category: category,
      comments: comments,
      likes: likes,
    );
  }
}

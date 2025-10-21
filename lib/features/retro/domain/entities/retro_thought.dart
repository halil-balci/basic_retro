class RetroThought {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  final String category; // 'Sad', 'Mad', or 'Glad'
  final List<String> comments;
  final List<String> likes;
  
  RetroThought({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    required this.category,
    this.comments = const [],
    this.likes = const [],
  });
  

  factory RetroThought.fromJson(Map<String, dynamic> json) {
    return RetroThought(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      timestamp: json['timestamp'] is String 
        ? DateTime.parse(json['timestamp']) 
        : DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? 0),
      category: json['category'] as String? ?? 'Sad',
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
    };
  }
}

class RetroComment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime timestamp;

  RetroComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
  });

  factory RetroComment.fromJson(Map<String, dynamic> json) {
    return RetroComment(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

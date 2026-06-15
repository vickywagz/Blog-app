class Post {
  final String id;
  final String title;
  final String body;
  final String author;
  final String authorId;
  final String postImage; 
  final int viewsCount;   
  final List<String> likes; 
  final List<String> savedBy; 
  final DateTime? createdAt;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.authorId,
    required this.postImage,
    required this.viewsCount,
    required this.likes,
    required this.savedBy,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      author: json['author'] ?? '',
      authorId: json['author_id'] ?? '',
      postImage: json['postImage'] ?? '',
      viewsCount: json['viewsCount'] ?? 0,
      // Safely maps string arrays from dynamic lists
      likes: List<String>.from(json['likes'] ?? []),
      savedBy: List<String>.from(json['savedBy'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  // 🟢 Append this method inside your Post class
  Post copyWith({
    String? id,
    String? title,
    String? body,
    String? author,
    String? authorId,
    String? postImage,
    int? viewsCount,
    List<String>? likes,
    List<String>? savedBy,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      postImage: postImage ?? this.postImage,
      viewsCount: viewsCount ?? this.viewsCount, // 🟢 Smoothly update view count parameter
      likes: likes ?? this.likes,
      savedBy: savedBy ?? this.savedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
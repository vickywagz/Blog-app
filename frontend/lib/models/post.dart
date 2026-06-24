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
    // 🟢 SAFE PARSING: Extract author name if populated as an object, otherwise read string
    String parsedAuthor = '';
    if (json['author'] is Map) {
      parsedAuthor = json['author']['name'] ?? json['author']['username'] ?? '';
    } else if (json['author'] is String) {
      parsedAuthor = json['author'];
    }

    // 🟢 SAFE PARSING: Extract author database ID if populated as an object, otherwise read string
    String parsedAuthorId = '';
    if (json['author_id'] is Map) {
      parsedAuthorId = json['author_id']['_id'] ?? json['author_id']['id'] ?? '';
    } else if (json['author_id'] is String) {
      parsedAuthorId = json['author_id'];
    } else if (json['author'] is Map) {
      // Intelligent fallback: if author_id is missing but author is an object, pull the ID from inside it
      parsedAuthorId = json['author']['_id'] ?? json['author']['id'] ?? '';
    }

    // 🟢 SAFE PARSING: Extract image URL if asset object metadata is returned instead of string
    String parsedImage = '';
    if (json['postImage'] is Map) {
      parsedImage = json['postImage']['url'] ?? json['postImage']['secure_url'] ?? '';
    } else if (json['postImage'] is String) {
      parsedImage = json['postImage'];
    }

    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      author: parsedAuthor,
      authorId: parsedAuthorId,
      postImage: parsedImage,
      viewsCount: json['viewsCount'] ?? 0,
      likes: List<String>.from(json['likes'] ?? []),
      savedBy: List<String>.from(json['savedBy'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }

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
      viewsCount: viewsCount ?? this.viewsCount, 
      likes: likes ?? this.likes,
      savedBy: savedBy ?? this.savedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
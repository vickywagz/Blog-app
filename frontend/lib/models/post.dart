class Post {
  final String id;
  final String title;
  final String body;
  final String author;
  final String authorId;
  final String createdAt;
  final String image; // 🟢 Changed from String? to String so it's always safe to use directly

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.authorId,
    required this.createdAt,
    required this.image, // 🟢 Now required and guaranteed to have a fallback string value
  });

  factory Post.fromJson(Map<String, dynamic> parsedJson) {
    final String titleText = parsedJson['title']?.toString() ?? 'blog';
    
    // 1. Extract the image from JSON if it exists
    String? jsonImage = parsedJson['image'];

    // 2. 🟢 Dynamic Generator Fallback
    // If jsonImage is null or empty, generate a premium placeholder URL using the title as a unique seed.
    // We sanitize the title by removing spaces and special characters.
    if (jsonImage == null || jsonImage.trim().isEmpty) {
      final sanitizedSeed = Uri.encodeComponent(
        titleText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')
      );
      // Fetches an optimized 800x500 image. The /seed/ path guarantees 
      // that a specific post title will always return the exact same image!
      jsonImage = 'https://picsum.photos/seed/$sanitizedSeed/800/500';
    }

    return Post(
      id: parsedJson['_id'].toString(),
      title: titleText,
      body: parsedJson['body'].toString(),
      author: parsedJson['author'].toString(),
      authorId: parsedJson['author_id'].toString(),
      createdAt: parsedJson['createdAt'].toString(),
      image: jsonImage, // 🟢 Safely populated with a real link or our dynamic fallback
    );
  }
}
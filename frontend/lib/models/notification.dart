class NotificationModel {
  final String id;
  final String type; 
  final bool isRead;
  final String senderName;
  final String senderAvatar;
  final String postTitle;
  final String postId;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.isRead,
    required this.senderName,
    required this.senderAvatar,
    required this.postTitle,
    required this.postId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Gracefully handles the Mongoose .populate() sub-objects
    final senderObj = json['sender'] as Map<String, dynamic>? ?? {};
    final postObj = json['post'] as Map<String, dynamic>? ?? {};

    return NotificationModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      senderName: senderObj['name'] ?? 'Someone',
      senderAvatar: senderObj['profilePicture'] ?? '',
      postTitle: postObj['title'] ?? 'your post',
      postId: postObj['_id'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
}
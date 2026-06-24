class User {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String profilePicture;
  final bool isVerified;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePicture,
    required this.isVerified,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      isVerified: json['isVerified'] ?? false,
      profileImage: json['profileImage'] ?? json['avatar'],
    );
  }
}
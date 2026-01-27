class CommunityPost {
  final String id;
  final String authorName;
  final String authorLocation;
  final String cropName;
  final String title;
  final String description;
  final String? image;
  final List<String> tags;
  final int likes;
  final DateTime date;
  final List<Comment> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorLocation,
    required this.cropName,
    required this.title,
    required this.description,
    this.image,
    required this.tags,
    required this.likes,
    required this.date,
    required this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['_id'] ?? '',
      authorName: json['authorName'] ?? 'Unknown',
      authorLocation: json['authorLocation'] ?? '',
      cropName: json['cropName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Comment {
  final String authorName;
  final String text;
  final bool isExpert;
  final DateTime date;

  Comment({
    required this.authorName,
    required this.text,
    required this.isExpert,
    required this.date,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      authorName: json['authorName'] ?? 'Unknown',
      text: json['text'] ?? '',
      isExpert: json['isExpert'] ?? false,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

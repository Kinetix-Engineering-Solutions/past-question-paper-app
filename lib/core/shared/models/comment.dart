class Comment {
  final String commentId;
  final String questionId;
  final String userId;
  final String? authorName; // Added for UI consistency
  final String? textContent;
  final String? externalVideoUrl;
  final int upvotes;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.questionId,
    required this.userId,
    this.authorName,
    this.textContent,
    this.externalVideoUrl,
    required this.upvotes,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: (json['commentId'] ?? json['id'] ?? '').toString(),
      questionId: (json['questionId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      authorName: json['authorName'] as String?,
      textContent: json['textContent'] as String?,
      externalVideoUrl: json['externalVideoUrl'] as String?,
      upvotes: (json['upvotes'] as num? ?? 0).toInt(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'questionId': questionId,
      'userId': userId,
      'authorName': authorName,
      'textContent': textContent,
      'externalVideoUrl': externalVideoUrl,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

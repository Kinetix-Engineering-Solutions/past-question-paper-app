final class BookmarkTarget {
  const BookmarkTarget({required this.userId, required this.questionId});

  final String userId;
  final String questionId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookmarkTarget &&
            userId == other.userId &&
            questionId == other.questionId;
  }

  @override
  int get hashCode => Object.hash(userId, questionId);
}

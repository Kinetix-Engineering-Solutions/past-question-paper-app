enum QuestionProgressStatus {
  understood('understood'),
  needsReview('needs_review');

  const QuestionProgressStatus(this.apiValue);

  final String apiValue;

  static QuestionProgressStatus fromApiValue(String value) {
    return switch (value) {
      'understood' => QuestionProgressStatus.understood,
      'needs_review' => QuestionProgressStatus.needsReview,
      _ => throw FormatException('Unknown question progress status: $value'),
    };
  }
}

final class QuestionProgress {
  const QuestionProgress({
    required this.questionId,
    required this.topicId,
    required this.status,
    required this.reviewCount,
    required this.firstReviewedAt,
    required this.lastReviewedAt,
  });

  final String questionId;
  final String topicId;
  final QuestionProgressStatus status;
  final int reviewCount;
  final DateTime firstReviewedAt;
  final DateTime lastReviewedAt;

  factory QuestionProgress.fromJson(Map<String, dynamic> json) {
    return QuestionProgress(
      questionId: json['question_id'] as String,
      topicId: json['topic_id'] as String,
      status: QuestionProgressStatus.fromApiValue(json['status'] as String),
      reviewCount: json['review_count'] as int,
      firstReviewedAt: DateTime.parse(json['first_reviewed_at'] as String),
      lastReviewedAt: DateTime.parse(json['last_reviewed_at'] as String),
    );
  }
}

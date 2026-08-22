final class TopicProgressSummary {
  const TopicProgressSummary({
    required this.topicId,
    required this.reviewedCount,
    required this.understoodCount,
    required this.needsReviewCount,
    required this.reviewAttemptCount,
    required this.lastReviewedAt,
  });

  final String topicId;
  final int reviewedCount;
  final int understoodCount;
  final int needsReviewCount;
  final int reviewAttemptCount;
  final DateTime lastReviewedAt;

  factory TopicProgressSummary.fromJson(Map<String, dynamic> json) {
    return TopicProgressSummary(
      topicId: json['topic_id'] as String,
      reviewedCount: json['reviewed_count'] as int,
      understoodCount: json['understood_count'] as int,
      needsReviewCount: json['needs_review_count'] as int,
      reviewAttemptCount: json['review_attempt_count'] as int,
      lastReviewedAt: DateTime.parse(json['last_reviewed_at'] as String),
    );
  }
}

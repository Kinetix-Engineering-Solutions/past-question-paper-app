final class QuestionQuery {
  const QuestionQuery({
    required this.topicId,
    this.examYear,
    this.season,
    this.questionNumber,
  });

  final String topicId;
  final int? examYear;
  final String? season;
  final String? questionNumber;

  bool get hasFilters =>
      examYear != null || season != null || questionNumber != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuestionQuery &&
            topicId == other.topicId &&
            examYear == other.examYear &&
            season == other.season &&
            questionNumber == other.questionNumber;
  }

  @override
  int get hashCode => Object.hash(topicId, examYear, season, questionNumber);
}

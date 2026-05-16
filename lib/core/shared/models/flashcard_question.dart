class FlashcardQuestion {
  final String id;
  final String subjectId;
  final int grade;
  final String topic;
  final int? year;
  final String? season;
  final String? paper;
  final String? questionNumber;
  final String? questionImageUrl;
  final String? answerImageUrl;

  const FlashcardQuestion({
    required this.id,
    required this.subjectId,
    required this.grade,
    required this.topic,
    required this.year,
    required this.season,
    required this.paper,
    required this.questionNumber,
    required this.questionImageUrl,
    required this.answerImageUrl,
  });
}

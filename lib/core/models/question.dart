class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });
}

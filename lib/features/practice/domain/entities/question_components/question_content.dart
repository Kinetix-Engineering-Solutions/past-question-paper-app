class QuestionContent {
  final String format;
  final String questionText;
  final String? imageUrl;
  final List<String> options;
  final List<String>? optionImages;
  final List<String> correctOrder;
  final String correctAnswer;
  final String explanation;
  final int? points;
  final int? timeAllocation;

  const QuestionContent({
    required this.format,
    required this.questionText,
    this.imageUrl,
    required this.options,
    this.optionImages,
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
    this.points,
    this.timeAllocation,
  });

  bool get hasImageOptions => optionImages != null && optionImages!.isNotEmpty;

  bool get hasQuestionImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get useTextOptions => !hasImageOptions && options.isNotEmpty;

  bool get useQuestionImage => hasQuestionImage;

  List<String> get displayOptions => hasImageOptions ? optionImages! : options;
}
